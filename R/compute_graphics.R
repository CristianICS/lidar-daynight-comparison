# Draw custom graphics to show in the paper
# -----------------------------------------------------------------------------

# Get the path of the directory containing the actual file
# Working directory: save graphics
ROOT <- getwd()

source(file.path(ROOT, "R", "utils", "custom_stats.R"))
source(file.path(ROOT, "R", "utils", "custom_plots.R"))

# Stats directory: current mission statistics
SDIR <- file.path(ROOT, "results", "stats")

# Directory to export the graphics
OUTDIR <- file.path(SDIR, "_graphics")

# Common AOI and ground-reference targets (used to drop targets outside the
# area covered by every mission)
AOIPATH <- file.path(ROOT, "data", "metadata", "flights_common_aoi.gpkg")
GRPATH <- file.path(ROOT, "data", "metadata", "ground_reference_targets.gpkg")
target_classes <- c("road", "shrub", "open_treed", "dense_treed")

class_optns <- c("shrub", "dense_treed", "open_treed", "road")
areas <- c(
  "alfred",
  "alfred_loff",
  "quinces",
  "encinacorba_hillside",
  "encinacorba_scenery"
)

# Produce a table containing all the available statistics per mission
stats_files <- list.files(SDIR, "*.csv$", recursive=TRUE)
stats_table <- data.frame(
  site = dirname(dirname(stats_files)),
  mission = basename(dirname(stats_files)),
  stat = basename(stats_files),
  path = stats_files
)

# 3.1 Whole-mission (ROI) stats by site - barplots ---------------------------
# Unlike the target stats (3.2/3.3), these are computed once per mission
# over the full common AOI, not per ground-reference point, so there is a
# single value per site/time/height rather than a distribution. Each panel
# row is one statistic and each column is one site, with flight altitude on
# the x-axis, mirroring the row/column-by-site layout used below. Two
# groups are plotted separately because they answer different questions:
#   * quality  -> point yield and artifact rates (raw point count, duplicate
#     points, points with negative heights, 1st/99th height percentiles)
#     that flag acquisition problems independent of vegetation or ground
#     targets.
#   * returns  -> return-order composition (1st/2nd/3rd, single vs. multiple
#     returns), a coarse proxy for canopy penetration at the whole-mission
#     scale, complementing the per-class returns seen in 3.2.
global_stats_long <- load_global_stats(stats_table, areas, "roi_stats.csv")
global_stats_long <- add_roi_area_m2(global_stats_long, stats_table, areas, "roi_stats.csv")

roi_stat_groups <- list(
  "global_stats.png" = c(
    "Total number of points",
    "Duplicated points (%)",
    "Points with negative heights (%)",
    "Outliers"
  ),
  "global_stats_returns.png" = c(
    "First returns (%)",
    "Second returns (%)",
    "Third returns (%)",
    "Points with only single returns (%)",
    "Points with more than one return (%)"
  )
)

roi_stat_plot_heights <- c(
  "global_stats.png" = 11,
  "global_stats_returns.png" = 7
)

for (out_file in names(roi_stat_groups)) {
  global_plot <- make_dodged_barplot_custom(global_stats_long, roi_stat_groups[[out_file]])
  save_custom_plot(
    global_plot,
    file.path(OUTDIR, out_file),
    width = 10,
    height = roi_stat_plot_heights[[out_file]]
  )
}

# Create target mission site stats - violin plots
target_stats_long <- load_target_stats(stats_table, areas)

target_stats_plot_1 <- c("intensity_avg", "rmse_last")
target_stats_plot_2 <- c("n_pnts_last", "n_pnts_last_incoherent", "thickness")

target_plot <- make_violin_plot_custom(target_stats_long, target_stats_plot_1)
save_custom_plot(target_plot, file.path(OUTDIR, "target_stats.png"))

target_plot <- make_violin_plot_custom(target_stats_long, target_stats_plot_2)
save_custom_plot(target_plot, file.path(OUTDIR, "target_stats_informative.png"))

# 3.2 Day/night hypothesis plots by target class - box plots ------------------
# Each panel row is one target class (road/shrub/open_treed/dense_treed) so
# that vegetation-dependent effects are not averaged away across classes, and
# each column is one site. Flight altitude is on the x-axis, so the effect of
# height is visible within the same plot. Proxy metric used per hypothesis
# (see README "Expected differences"):
#   * Higher backscatter intensity      -> intensity_avg
#   * More ground returns under veg.    -> ground detection (n_pnts_last > 0),
#     plotted separately below
#   * Data quality across altitude      -> rmse_last
#   * Higher SNR / less solar noise     -> prop_last_incoherent (proxy: no
#     direct SNR metric is computed anywhere in the pipeline)
# `n_pnts` is not plotted: target stats use ground-classified points only,
# which are all last returns, so it is identical to `n_pnts_last`. Point
# density is shown at the mission level in 3.1 instead.
hypothesis_labels <- c(
  intensity_avg = "Intensity",
  prop_last_incoherent = "Incoherent last returns (proportion)",
  rmse_last = "RMSE (m)"
)

for (stat_name in names(hypothesis_labels)) {
  hypothesis_plot <- make_target_boxplot_by_class(
    target_stats_long,
    stat_name,
    y_label = hypothesis_labels[[stat_name]]
  )

  save_custom_plot(
    hypothesis_plot,
    file.path(OUTDIR, paste0("target_", stat_name, "_by_class.png")),
    width = 12,
    height = 9
  )
}

# Ground detection by class. Ground counts saturate at ~12-13 per buffer, so
# a count boxplot would only show whether ground was reached; this plots that
# directly (share of targets with n_pnts_last > 0), matching the McNemar
# detection test in compute_inference.R. Restricted to the common AOI so
# uncovered targets do not count as non-detections.
target_detection_long <- filter_target_stats_within_aoi(
  target_stats_long,
  areas,
  AOIPATH,
  GRPATH,
  target_classes
)

save_custom_plot(
  make_target_detection_plot(target_detection_long),
  file.path(OUTDIR, "target_ground_detection_by_class.png"),
  width = 12,
  height = 9
)

# 3.3 Buffer radius sensitivity: NA values inside the study AOI --------------
# Test how the amount of missing target data (rmse_last == NA, i.e. no
# last-return LAS point fell inside a target's buffer) changes with the
# buffer radius (25/50/75/100 cm). Ground-reference targets outside a
# site's common AOI (the area covered by every compared mission, see
# R/common_aoi.R) can never intersect a LAS point regardless of buffer
# size, so they are dropped first to avoid confounding the buffer effect
# with out-of-coverage points.
target_stats_wide <- load_target_stats_wide(stats_table, areas)
target_stats_in_aoi <- filter_target_stats_within_aoi(
  target_stats_wide,
  areas,
  AOIPATH,
  GRPATH,
  target_classes
)

buffer_na_stats <- target_stats_in_aoi |>
  dplyr::group_by(layer, time, height, class, buffer_m) |>
  dplyr::summarise(
    total_values = dplyr::n(),
    count_na = sum(is.na(rmse_last)),
    percent_na = 100 * count_na / total_values,
    .groups = "drop"
  )

buffer_na_plot <- make_target_na_by_buffer_plot(buffer_na_stats)
save_custom_plot(
  buffer_na_plot,
  file.path(OUTDIR, "target_na_by_buffer.png"),
  width = 9,
  height = 16
)


