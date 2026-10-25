# Perform inference assessment: do the target stats differ between day and
# night, by site, flight altitude and target class? (e.g. Alfred 40 m day
# vs night, for the "shrub" targets)
library(lidaynight)

# Get the path of the directory containing the actual file
# Working directory: save graphics
ROOT <- getwd()

source(file.path(ROOT, "R", "utils", "custom_stats.R"))
source(file.path(ROOT, "R", "utils", "custom_plots.R"))

areas <- c(
  "alfred",
  "alfred_loff",
  "quinces",
  "encinacorba_hillside",
  "encinacorba_scenery"
)
target_classes <- c("road", "shrub", "open_treed", "dense_treed")

# Stats directory: current mission statistics
SDIR <- file.path(ROOT, "results", "stats")
AOIPATH <- file.path(ROOT, "data", "metadata", "flights_common_aoi.gpkg")
GRPATH <- file.path(ROOT, "data", "metadata", "ground_reference_targets.gpkg")

stats_files <- list.files(SDIR, "*.csv$", recursive = TRUE)
stats_table <- data.frame(
  site = dirname(dirname(stats_files)),
  mission = basename(dirname(stats_files)),
  stat = basename(stats_files),
  path = stats_files
)

# Targets outside a site's common AOI are covered by some missions but not
# others (the common AOI is the intersection of every mission footprint), so
# they would show up as spurious day-only/night-only detections. Drop them
# before any test.
target_stats_long <- load_target_stats(stats_table, areas) |>
  filter_target_stats_within_aoi(areas, AOIPATH, GRPATH, target_classes)

# Proxy metric per day/night hypothesis (see README "Expected differences").
# `n_pnts` is not tested: `targetStats()` runs on ground-classified points
# only, which are all last returns, so it is identical to `n_pnts_last`
# and testing both would just duplicate a family of tests.
# `n_pnts_last` is not tested for magnitude either: ground-classified counts
# saturate at ~12-13 per buffer at every altitude and time, so the count only
# carries whether ground was reached at all. That is the detection test
# below; a magnitude test on it would repeat the detection result.
#   * intensity_avg, rmse_last, prop_last_incoherent - only defined when the
#     target has at least one ground last return (NA otherwise), so the
#     magnitude test only uses targets detected in both conditions.
target_stat_metrics <- c(
  "intensity_avg",
  "rmse_last",
  "prop_last_incoherent"
)

# One row per target, with day/night values side by side. Pairs with an NA
# in either condition are dropped by the callers, which keeps exactly the
# targets detected in both conditions (counts are 0, not NA, so the
# detection test still sees every target).
pair_by_target <- function(data) {
  data |>
    dplyr::select(pnt_id, time, value) |>
    tidyr::pivot_wider(names_from = time, values_from = value)
}

complete_pairs <- function(pairs) {
  pairs[!is.na(pairs$day) & !is.na(pairs$night), ]
}

# Detection test (exact McNemar), once per site x height x class -------------
# A target is "detected" when at least one ground last return fell inside its
# buffer (n_pnts_last > 0). This is the same condition that makes
# intensity_avg/rmse_last/prop_last_incoherent non-NA, so detection is a
# property of the target, not of the metric: running it once per group
# (instead of once per metric) avoids repeating an identical test and
# inflating the correction family.
#
# Exact McNemar = two-sided binomial sign test on the discordant pairs
# (targets detected in one condition only), preferred over the chi-squared
# approximation because per-class sample sizes are small (~2-47).
run_detection_test <- function(pairs) {
  day_detected   <- pairs$day > 0
  night_detected <- pairs$night > 0

  n_both       <- sum(day_detected & night_detected)
  n_day_only   <- sum(day_detected & !night_detected)
  n_night_only <- sum(!day_detected & night_detected)
  n_neither    <- sum(!day_detected & !night_detected)
  n_discordant <- n_day_only + n_night_only

  # No discordant pairs means detection was identical in both conditions:
  # nothing to test.
  p_value <- if (n_discordant == 0) {
    NA_real_
  } else {
    stats::binom.test(n_day_only, n_discordant, p = 0.5)$p.value
  }

  dplyr::tibble(
    n_targets = nrow(pairs),
    n_both = n_both, n_day_only = n_day_only,
    n_night_only = n_night_only, n_neither = n_neither,
    n_discordant = n_discordant,
    # Smallest two-sided p-value the exact test can return with this many
    # discordant pairs (all of them in the same direction): 2 * 0.5^n.
    mcnemar_min_p = if (n_discordant == 0) NA_real_ else min(1, 2 * 0.5^n_discordant),
    mcnemar_p_value = p_value
  )
}

detection_results <- target_stats_long |>
  dplyr::filter(statistic == "n_pnts_last") |>
  dplyr::group_by(layer, height, class) |>
  dplyr::group_modify(~ run_detection_test(complete_pairs(pair_by_target(.x)))) |>
  dplyr::ungroup()

# Single family: every site x height x class group with at least one
# discordant pair (p.adjust ignores the NA groups when counting tests).
# `mcnemar_attainable_bonferroni` flags groups where even the most extreme
# split could reach significance after Bonferroni, i.e. where a
# non-significant result is informative rather than a power limitation.
detection_results <- detection_results |>
  dplyr::mutate(
    m_tests = sum(!is.na(mcnemar_p_value)),
    mcnemar_attainable_bonferroni = !is.na(mcnemar_min_p) & mcnemar_min_p < 0.05 / m_tests,
    mcnemar_p_bonferroni = stats::p.adjust(mcnemar_p_value, method = "bonferroni"),
    mcnemar_p_bh         = stats::p.adjust(mcnemar_p_value, method = "BH"),
    significant_detection_bonferroni = !is.na(mcnemar_p_bonferroni) & mcnemar_p_bonferroni < 0.05,
    significant_detection_bh         = !is.na(mcnemar_p_bh) & mcnemar_p_bh < 0.05
  ) |>
  dplyr::arrange(layer, height, class)

# Normality test: Shapiro-Wilk on the paired differences ---------------------
# Checks whether a parametric test (paired t-test, which needs the day/night
# differences to be roughly normal) would be admissible, evaluated on the
# exact sample each magnitude test below runs on.
run_shapiro_test <- function(pairs) {
  diffs <- pairs$night - pairs$day

  # shapiro.test() needs 3-5000 values and fails on constant input.
  test <- if (length(diffs) < 3) NULL else tryCatch(shapiro.test(diffs), error = function(e) NULL)

  dplyr::tibble(
    shapiro_statistic = if (is.null(test)) NA_real_ else unname(test$statistic),
    p_value           = if (is.null(test)) NA_real_ else test$p.value,
    n                 = length(diffs)
  )
}

target_metric_data <- target_stats_long |>
  dplyr::filter(statistic %in% target_stat_metrics)

shapiro_results <- target_metric_data |>
  dplyr::group_by(statistic, layer, height, class) |>
  dplyr::group_modify(~ run_shapiro_test(complete_pairs(pair_by_target(.x)))) |>
  dplyr::ungroup()

# When observed p-value > 0.05 the differences look normal.
shapiro_results |>
  dplyr::filter(!is.na(p_value)) |>
  dplyr::count(normal = p_value > 0.05)

# A substantial share of groups reject normality, Shapiro-Wilk has little
# power to detect non-normality at the typical group size (~11 pairs), and
# the metrics are discretised (intensity) or bounded (proportions in [0, 1]), so
# the paired Wilcoxon is used uniformly instead of the paired t-test.

# Magnitude test (paired Wilcoxon signed-rank), per metric -------------------
# Ties and zero differences are frequent (intensity is an integer mean over
# few points, and prop_last_incoherent is often exactly 0 or 1).
# With R's default zero.method, zero differences are discarded and, when any
# zeros or ties remain, the exact distribution is replaced by the normal
# approximation with continuity correction. `n_nonzero` is therefore the
# effective sample size, and `wilcox_method` records which variant was used.
run_magnitude_test <- function(pairs) {
  diffs <- pairs$night - pairs$day
  nonzero <- diffs[diffs != 0]

  safe_median <- function(x) if (length(x) > 0) stats::median(x) else NA_real_

  empty <- dplyr::tibble(
    n_pairs = length(diffs), n_nonzero = length(nonzero),
    has_ties = anyDuplicated(abs(nonzero)) > 0,
    median_day = safe_median(pairs$day),
    median_night = safe_median(pairs$night),
    median_diff = safe_median(diffs),
    hl_estimate = NA_real_,
    v_statistic = NA_real_, wilcox_method = NA_character_, wilcox_p_value = NA_real_
  )

  if (length(nonzero) < 2) {
    return(empty)
  }

  test <- tryCatch(
    suppressWarnings(wilcox.test(pairs$night, pairs$day, paired = TRUE)),
    error = function(e) NULL
  )

  if (is.null(test)) {
    return(empty)
  }

  empty$v_statistic    <- unname(test$statistic)
  empty$wilcox_method  <- test$method
  empty$wilcox_p_value <- test$p.value

  # Hodges-Lehmann estimate (pseudo-median of the night-minus-day
  # differences): the effect size matching the signed-rank test. Unlike the
  # plain median difference, it is not stuck at 0 when most differences are
  # zero (e.g. prop_last_incoherent). Computed in a separate call so a
  # failure of the confidence-interval search never discards the p-value.
  hl <- tryCatch(
    suppressWarnings(wilcox.test(pairs$night, pairs$day, paired = TRUE, conf.int = TRUE)$estimate),
    error = function(e) NA_real_
  )
  empty$hl_estimate <- unname(hl)
  empty
}

magnitude_results <- target_metric_data |>
  dplyr::group_by(statistic, layer, height, class) |>
  dplyr::group_modify(~ run_magnitude_test(complete_pairs(pair_by_target(.x)))) |>
  dplyr::ungroup()

# One correction family per metric: each metric answers a distinct
# hypothesis (README "Expected differences"), so the family is the set of
# site x height x class groups tested for that hypothesis.
magnitude_results <- magnitude_results |>
  dplyr::group_by(statistic) |>
  dplyr::mutate(
    m_tests = sum(!is.na(wilcox_p_value)),
    wilcox_p_bonferroni = stats::p.adjust(wilcox_p_value, method = "bonferroni"),
    wilcox_p_bh         = stats::p.adjust(wilcox_p_value, method = "BH"),
    significant_magnitude_bonferroni = !is.na(wilcox_p_bonferroni) & wilcox_p_bonferroni < 0.05,
    significant_magnitude_bh         = !is.na(wilcox_p_bh) & wilcox_p_bh < 0.05
  ) |>
  dplyr::ungroup() |>
  dplyr::arrange(statistic, layer, height, class)

# Column reference:
# detection_results, one row per site/height/class group:
#   n_both/n_day_only/n_night_only/n_neither - targets per detection outcome
#     (day-detected x night-detected); n_discordant = n_day_only +
#     n_night_only is the sample the exact McNemar test runs on.
#   mcnemar_min_p - smallest p-value attainable with n_discordant pairs;
#     mcnemar_attainable_bonferroni is FALSE when even a perfectly one-sided
#     split could not survive Bonferroni, so a non-significant result there
#     reflects low power, not evidence of equal detection.
#   mcnemar_p_value - raw p-value (NA if no discordant pairs). Check whether
#     n_day_only or n_night_only is larger to see which condition is the one
#     under-detecting.
# magnitude_results, one row per metric/site/height/class group:
#   n_pairs/n_nonzero - pairs entering the test and those left after
#     dropping zero differences (the effective sample size).
#   median_day/median_night - per-condition medians over the same pairs.
#   median_diff - median night-minus-day difference.
#   hl_estimate - Hodges-Lehmann estimate of the night-minus-day shift, the
#     effect size reported in the paper tables.
#   v_statistic - Wilcoxon V (sum of ranks of positive night-minus-day
#     differences): night is systematically higher when V is close to
#     n_nonzero*(n_nonzero+1)/2, lower when V is close to 0.
#   *_bonferroni/*_bh - adjusted p-values; use these, not the raw ones, to
#     call a result significant.
detection_results
magnitude_results

# How many tests are flagged as significant under each correction, by test
# family
family_summary <- dplyr::bind_rows(
  detection_results |>
    dplyr::summarise(
      n_tested = sum(!is.na(mcnemar_p_value)),
      n_attainable_bonferroni = sum(mcnemar_attainable_bonferroni),
      n_significant_bonferroni = sum(significant_detection_bonferroni),
      n_significant_bh = sum(significant_detection_bh)
    ) |>
    dplyr::mutate(family = "detection (n_pnts_last > 0)", .before = 1),
  magnitude_results |>
    dplyr::group_by(family = paste("magnitude:", statistic)) |>
    dplyr::summarise(
      n_tested = sum(!is.na(wilcox_p_value)),
      n_exact = sum(grepl("exact", wilcox_method)),
      n_significant_bonferroni = sum(significant_magnitude_bonferroni),
      n_significant_bh = sum(significant_magnitude_bh),
      # Direction from V against its null expectation n(n+1)/4.
      n_bh_night_higher = sum(significant_magnitude_bh & v_statistic > n_nonzero * (n_nonzero + 1) / 4, na.rm = TRUE),
      n_bh_day_higher = sum(significant_magnitude_bh & v_statistic < n_nonzero * (n_nonzero + 1) / 4, na.rm = TRUE)
    )
)
family_summary

# Paper tables ----------------------------------------------------------------
# Written to results/stats/_tables as CSV (exact values) and as a single
# Markdown file (rounded, with significance marks) for the manuscript.
TABDIR <- file.path(SDIR, "_tables")
dir.create(TABDIR, showWarnings = FALSE)

fmt_p <- function(p) {
  dplyr::case_when(
    is.na(p) ~ "–",
    p < 0.001 ~ "<0.001",
    TRUE ~ formatC(p, format = "f", digits = 3)
  )
}

# "**" significant after Bonferroni, "*" significant after BH only.
sig_mark <- function(bonferroni, bh) {
  dplyr::case_when(bonferroni ~ "**", bh ~ "*", TRUE ~ "")
}

label_groups <- function(data) {
  data <- data |>
    dplyr::mutate(
      Site = unname(site_labels[layer]),
      `Altitude (m)` = as.integer(as.character(height))
    )

  if ("class" %in% names(data)) {
    data$Class <- unname(class_labels[data$class])
  }

  data
}

metric_digits <- c(intensity_avg = 2, prop_last_incoherent = 2, rmse_last = 3)
metric_titles <- c(
  intensity_avg = "Mean intensity",
  prop_last_incoherent = "Proportion of incoherent last returns",
  rmse_last = "Last-return RMSE (m)"
)

# Mission-level vertical error. Not a hypothesis test: it documents the
# systematic offsets that dominate rmse_last/prop_last_incoherent in some
# missions, so the day/night differences in those groups can be read
# correctly.
mission_error_table <- target_stats_long |>
  dplyr::filter(statistic %in% c("bias_last", "rmse_last")) |>
  dplyr::group_by(layer, height, time, statistic) |>
  dplyr::summarise(value = stats::median(value, na.rm = TRUE), .groups = "drop") |>
  tidyr::pivot_wider(names_from = c(statistic, time), values_from = value) |>
  label_groups() |>
  dplyr::arrange(Site, `Altitude (m)`) |>
  dplyr::transmute(
    Site, `Altitude (m)`,
    `Median bias day (m)` = round(bias_last_day, 2),
    `Median bias night (m)` = round(bias_last_night, 2),
    `Median RMSE day (m)` = round(rmse_last_day, 2),
    `Median RMSE night (m)` = round(rmse_last_night, 2)
  )

detection_table <- detection_results |>
  dplyr::filter(!is.na(mcnemar_p_value)) |>
  label_groups() |>
  dplyr::transmute(
    Site, `Altitude (m)`, Class,
    n = n_targets, Both = n_both, `Day only` = n_day_only,
    `Night only` = n_night_only, Neither = n_neither,
    p = fmt_p(mcnemar_p_value),
    `p (BH)` = paste0(fmt_p(mcnemar_p_bh), sig_mark(significant_detection_bonferroni, significant_detection_bh)),
    `p (Bonf.)` = fmt_p(mcnemar_p_bonferroni),
    `Bonf. attainable` = ifelse(mcnemar_attainable_bonferroni, "yes", "no")
  )

family_table <- family_summary |>
  dplyr::transmute(
    Family = family, Tests = n_tested,
    `Sig. (Bonf.)` = n_significant_bonferroni, `Sig. (BH)` = n_significant_bh,
    `Night > day (BH)` = n_bh_night_higher, `Day > night (BH)` = n_bh_day_higher
  )

# Compact overview: Hodges-Lehmann night-minus-day shift per metric and
# group, with significance marks.
overview_table <- magnitude_results |>
  dplyr::mutate(
    cell = dplyr::if_else(
      is.na(hl_estimate),
      "–",
      paste0(
        # `+ 0` turns a rounded -0 into 0 so it does not print as "-0.0".
        sprintf("%.*f", unname(metric_digits[statistic]), round(hl_estimate, unname(metric_digits[statistic])) + 0),
        sig_mark(significant_magnitude_bonferroni, significant_magnitude_bh)
      )
    )
  ) |>
  dplyr::select(layer, height, class, statistic, cell) |>
  tidyr::pivot_wider(names_from = statistic, values_from = cell) |>
  label_groups() |>
  dplyr::arrange(Site, `Altitude (m)`, Class) |>
  dplyr::select(Site, `Altitude (m)`, Class, dplyr::all_of(names(metric_titles)))
metric_cols <- seq_along(metric_titles) + 3
names(overview_table)[metric_cols] <- paste0("Δ ", metric_titles[names(overview_table)[metric_cols]])

magnitude_table <- function(metric) {
  d <- metric_digits[[metric]]
  magnitude_results |>
    dplyr::filter(statistic == metric) |>
    label_groups() |>
    dplyr::arrange(Site, `Altitude (m)`, Class) |>
    dplyr::transmute(
      Site, `Altitude (m)`, Class,
      `n pairs` = n_pairs, `n non-zero` = n_nonzero,
      `Median day` = round(median_day, d), `Median night` = round(median_night, d),
      `HL Δ` = round(hl_estimate, d), V = v_statistic,
      p = fmt_p(wilcox_p_value),
      `p (BH)` = paste0(fmt_p(wilcox_p_bh), sig_mark(significant_magnitude_bonferroni, significant_magnitude_bh)),
      `p (Bonf.)` = fmt_p(wilcox_p_bonferroni),
      Method = dplyr::case_when(
        is.na(wilcox_method) ~ "–",
        grepl("exact", wilcox_method) ~ "exact",
        TRUE ~ "normal approx."
      )
    )
}

paper_tables <- c(
  list(
    mission_vertical_error = mission_error_table,
    detection = detection_table,
    test_families = family_table,
    magnitude_overview = overview_table
  ),
  stats::setNames(
    lapply(names(metric_titles), magnitude_table),
    paste0("magnitude_", names(metric_titles))
  )
)

for (tab_name in names(paper_tables)) {
  utils::write.csv(paper_tables[[tab_name]], file.path(TABDIR, paste0(tab_name, ".csv")), row.names = FALSE)
}

md_lines <- unlist(lapply(names(paper_tables), function(tab_name) {
  c(
    paste("##", tab_name), "",
    knitr::kable(paper_tables[[tab_name]], format = "pipe"), ""
  )
}))
writeLines(md_lines, file.path(TABDIR, "paper_tables.md"), useBytes = TRUE)
