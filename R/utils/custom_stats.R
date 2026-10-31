custom_add_stats <- function(folder_path, stats_stem, area_name) {
  stats <- lidaynight:: read_one_stats_folder(folder_path, stats_stem)
  stats$layer <- area_name

  # Stat stems must look like "bytarget_gf_<class>_buf<N>cm"; reject legacy
  # files predating the buffer_m parameter/filename tag instead of silently
  # coercing them.
  class_match <- regmatches(
    stats_stem,
    regexec("^bytarget_gf_(.*)_buf\\d+cm$", stats_stem)
  )[[1]]

  if (length(class_match) != 2L || !"buffer_m" %in% names(stats)) {
    stop(
      "Legacy target stats file (missing buffer tag/column): ",
      file.path(folder_path, paste0(stats_stem, ".csv")),
      ". Regenerate it with the current targetStats().",
      call. = FALSE
    )
  }

  stats$class <- class_match[2]
  stats
}

reshape_statistics_long_custom <- function(stats_wide) {
  # `pnt_id` identifies the physical ground-reference target a target-stats
  # row belongs to. It must stay a column (like layer/time/height/class)
  # rather than being melted into a "statistic" of its own, otherwise a
  # day/night pair for the same target can no longer be matched back
  # together (e.g. for a paired test) once the data is in long format.
  tidyr::pivot_longer(
    stats_wide,
    cols = -tidyselect::any_of(c("layer", "time", "height", "class", "buffer_m", "pnt_id")),
    names_to = "statistic",
    values_to = "value"
  )
}

load_global_stats <- function(stats_table, areas, stats_filename) {

  target_files <- stats_table |>
    dplyr::filter(site %in% areas) |>
    dplyr::filter(stat == stats_filename) |>
    dplyr::mutate("folder_path" = file.path(SDIR, dirname(path))) |>
    dplyr::mutate("stat_stem" = tools::file_path_sans_ext(stat))

  target_stats_raw <- lapply(
    target_files$folder_path,
    lidaynight::read_one_stats_folder,
    target_files$stat_stem[1]
  )

  target_stats_raw <- do.call(vctrs::vec_rbind, target_stats_raw)
  target_stats <- lidaynight::select_stats_columns(target_stats_raw, target_files$stat_stem[1])

  # `select_stats_columns()` only keeps the columns lidaynight's .roi_stats
  # mapping already knows how to rename; pnts_height_lt_q01/_q99 (the number of
  # points below the 1st/99th height percentiles in roi_stats.csv) aren't part
  # of that mapping, so they'd otherwise be silently dropped. Carry them through
  # unrenamed.
  # target_stats[c("pnts_height_q01", "pnts_height_q99")] <- target_stats_raw[c("pnts_height_q01", "pnts_height_q99")]

  target_stats$layer <- target_files$site

  target_stats_long <- reshape_statistics_long_custom(target_stats)
  target_stats_long
}

# Each mission's `roi_stats.gpkg` (written by `lidaynight::globalStats()`
# alongside `roi_stats.csv`) stores the very ROI polygon the stats in
# `roi_stats.csv` were computed over. Reading it back gives the ROI area
# (m^2) for that site/time/height, needed to turn a raw point count into a
# point density comparable across missions with differently sized ROIs.
compute_roi_areas <- function(stats_table, areas, stats_filename = "roi_stats.csv") {
  roi_files <- stats_table |>
    dplyr::filter(site %in% areas) |>
    dplyr::filter(stat == stats_filename) |>
    dplyr::mutate(
      folder_path = file.path(SDIR, dirname(path)),
      gpkg_path = file.path(folder_path, sub("\\.csv$", ".gpkg", stats_filename))
    )

  roi_areas <- Map(
    function(folder_path, gpkg_path, site_name) {
      metadata <- lidaynight::parse_folder_metadata(folder_path)
      roi <- sf::st_read(gpkg_path, quiet = TRUE)

      data.frame(
        layer = site_name,
        time = metadata$time,
        height = metadata$height,
        area_m2 = as.numeric(sum(sf::st_area(roi)))
      )
    },
    folder_path = roi_files$folder_path,
    gpkg_path = roi_files$gpkg_path,
    site_name = roi_files$site
  )

  do.call(vctrs::vec_rbind, roi_areas)
}

# Join each row's ROI area (m^2) onto a long-format roi_stats table by
# (layer, time, height).
add_roi_area_m2 <- function(stats_long, stats_table, areas, stats_filename = "roi_stats.csv") {
  roi_areas <- compute_roi_areas(stats_table, areas, stats_filename)
  dplyr::left_join(stats_long, roi_areas, by = c("layer", "time", "height"))
}

# Convert the raw "Total number of points" count into a point density
# (points / m^2) using the `area_m2` column added by `add_roi_area_m2()`,
# so the global ROI barplot compares acquisitions with differently sized
# ROIs fairly. Duplicated points and points with negative heights are
# removed from the count first, using their percentages of the same mission
# (n * (1 - pct / 100) recovers n - count). Otherwise the density would be
# inflated by the very artifacts reported in the duplicate and negative-height
# metrics. A duplicated negative point is subtracted twice, which is negligible
# given the few negative points per mission. Left untouched (including keeping
# `area_m2` out of the result) when `area_m2` isn't present, e.g. if
# statistics other than roi_stats.csv are ever passed in.
normalize_points_by_area <- function(
    stats_long,
    statistic_name = "Total number of points",
    invalid_pct_stats = c(
      "Duplicated points (%)",
      "Points with negative heights (%)"
    )
) {
  if (!"area_m2" %in% names(stats_long)) {
    return(stats_long)
  }

  stats_long |>
    dplyr::group_by(layer, time, height) |>
    dplyr::mutate(
      invalid_pct = {
        if (!all(invalid_pct_stats %in% statistic)) {
          stop(
            "Missing statistic(s) to clean the point density for ",
            paste(dplyr::cur_group(), collapse = " "), ": ",
            paste(setdiff(invalid_pct_stats, statistic), collapse = ", "),
            call. = FALSE
          )
        }
        sum(value[statistic %in% invalid_pct_stats])
      },
      value = dplyr::if_else(
        statistic == statistic_name,
        value * (1 - invalid_pct / 100) / area_m2,
        value
      )
    ) |>
    dplyr::ungroup() |>
    dplyr::select(-area_m2, -invalid_pct)
}

load_target_stats_wide <- function(stats_table, areas) {
  target_files <- stats_table |>
    dplyr::filter(site %in% areas) |>
    # dplyr::filter(stat == paste0("bytarget_gf_", class_optn, ".csv")) |>
    dplyr::filter(stringr::str_detect(stat, "^bytarget_gf_")) |>
    dplyr::mutate("folder_path" = file.path(SDIR, dirname(path))) |>
    dplyr::mutate("stat_stem" = tools::file_path_sans_ext(stat))

  target_stats <- Map(
    custom_add_stats,
    folder_path = target_files$folder_path,
    stats_stem = target_files$stat_stem,
    area_name = target_files$site
  )

  target_stats <- do.call(vctrs::vec_rbind, target_stats)

  # `targetStats()` reports counts as 0 (not NA) when no ground last return
  # fell in the buffer, so `n_pnts_last_incoherent == 0` can mean either
  # "clean target" or "nothing measured". The proportion of incoherent last
  # returns is only defined for detected targets (NA otherwise), and unlike
  # the raw count it is not inflated by a mission simply having more points.
  target_stats$prop_last_incoherent <- ifelse(
    target_stats$n_pnts_last > 0,
    target_stats$n_pnts_last_incoherent / target_stats$n_pnts_last,
    NA_real_
  )

  target_stats
}

load_target_stats <- function(stats_table, areas, target_buffer_m = 0.5) {
  target_stats <- load_target_stats_wide(stats_table, areas)

  # Some sites (e.g. quinces) were run with several buffer radii as part of
  # a buffer sensitivity test, so more than one `buffer_m` value can be
  # present per site/class/time/height. Restrict to a single canonical
  # buffer for the standard day/night comparison plots, otherwise those
  # extra rows get silently pooled together with the rest. Pass
  # `target_buffer_m = NULL` to keep every buffer (e.g. for a dedicated
  # buffer-sensitivity plot).
  if (!is.null(target_buffer_m)) {
    target_stats <- target_stats[
      abs(target_stats$buffer_m - target_buffer_m) < 1e-6,
    ]
  }

  target_stats_long <- reshape_statistics_long_custom(target_stats)
  target_stats_long
}

# Ground-reference targets located outside a site's common AOI (the area
# covered by every compared mission, see R/common_aoi.R) can never
# intersect a LAS point regardless of buffer radius. Their `.tid` (stored
# as `pnt_id` in the target stats) is reproduced here exactly as
# `lidaynight::targetStats()` assigns it: sequential row order after
# filtering the area's ground-reference layer to the target classes.
# Returns both the full re-derived id set (`all_ids`) and the subset
# inside the AOI (`inside_ids`); `all_ids` lets callers sanity-check that
# this re-derivation actually matches the ids used in the stats files.
# Areas without their own AOI and ground-reference layers reuse another
# area's: alfred_loff covers the same area as alfred, so it uses the
# `alfred_common` AOI and the `alfred` ground-reference targets (no
# `alfred_loff_common` or `alfred_loff` layers exist).
AREA_LAYER_ALIASES <- c(alfred_loff = "alfred")

get_inside_aoi_pnt_ids <- function(area_name, aoi_path, gr_path, target_classes) {
  layer_area <- if (area_name %in% names(AREA_LAYER_ALIASES)) {
    AREA_LAYER_ALIASES[[area_name]]
  } else {
    area_name
  }
  aoi <- sf::st_read(aoi_path, layer = paste0(layer_area, "_common"), quiet = TRUE)
  pnts <- sf::st_read(gr_path, layer = layer_area, quiet = TRUE)
  pnts <- pnts[pnts$Code %in% target_classes, ]
  pnts$pnt_id <- seq_len(nrow(pnts))
  pnts <- sf::st_transform(pnts, sf::st_crs(aoi))

  list(
    all_ids = pnts$pnt_id,
    inside_ids = pnts$pnt_id[lengths(sf::st_intersects(pnts, aoi)) > 0]
  )
}

# Drop target stats rows (any buffer radius) whose ground-reference point
# falls outside its site's common AOI.
filter_target_stats_within_aoi <- function(
  target_stats,
  areas,
  aoi_path,
  gr_path,
  target_classes
) {
  aoi_pnt_ids <- lapply(
    stats::setNames(areas, areas),
    get_inside_aoi_pnt_ids,
    aoi_path = aoi_path,
    gr_path = gr_path,
    target_classes = target_classes
  )

  # Sanity check: every pnt_id present in the stats must be one of the ids
  # re-derived above. Since those ids are reconstructed from
  # ground_reference_targets.gpkg rather than read off the stats' own
  # geometry, a mismatch would mean the re-derivation no longer matches
  # what `lidaynight::targetStats()` actually assigned, and the AOI
  # filter below would silently keep or drop the wrong targets.
  for (area_name in areas) {
    stats_ids <- unique(target_stats$pnt_id[target_stats$layer == area_name])
    unknown_ids <- setdiff(stats_ids, aoi_pnt_ids[[area_name]]$all_ids)

    if (length(unknown_ids) > 0L) {
      stop(
        "Target stats for '", area_name, "' contain pnt_id(s) not found ",
        "among its re-derived ground-reference targets: ",
        paste(unknown_ids, collapse = ", "),
        ". The `.tid` order assumed by `get_inside_aoi_pnt_ids()` no ",
        "longer matches `lidaynight::targetStats()`.",
        call. = FALSE
      )
    }
  }

  inside_df <- dplyr::bind_rows(lapply(areas, function(area_name) {
    data.frame(layer = area_name, pnt_id = aoi_pnt_ids[[area_name]]$inside_ids)
  }))

  dplyr::semi_join(target_stats, inside_df, by = c("layer", "pnt_id"))
}
