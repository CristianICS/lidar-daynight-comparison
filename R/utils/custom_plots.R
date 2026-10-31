# Human-readable site names, keyed by the `layer` values used throughout the
# stats tables (see `areas` in compute_graphics_internal.R). Shared across
# every plotting function below that facets by site.
site_labels <- c(
  alfred = "Alfred",
  alfred_loff = "Alfred LOff",
  quinces = "Quinces",
  encinacorba_hillside = "Encinacorba hillside",
  encinacorba_scenery = "Encinacorba scenery"
)

# Human-readable target class names, keyed by the `class` values used
# throughout the stats tables. Shared across every plotting function below
# that facets by class.
class_labels <- c(
  road = "Road",
  dense_treed = "Dense treed",
  open_treed = "Open treed",
  shrub = "Shrub"
)

# Share of targets with at least one ground last return (n_pnts_last > 0)
# per site, class, altitude and time - the quantity the McNemar detection
# test in compute_inference.R compares. Ground counts saturate at ~12-13
# per buffer, so detection is the only informative ground-return measure.
# `stats_long` should already be restricted to targets inside the common AOI,
# otherwise uncovered targets show up as non-detections.
make_target_detection_plot <- function(stats_long) {
  stats_plot <- stats_long |>
    dplyr::filter(statistic == "n_pnts_last") |>
    dplyr::group_by(layer, time, height, class) |>
    dplyr::summarise(
      n_targets = dplyr::n(),
      n_detected = sum(value > 0),
      percent_detected = 100 * n_detected / n_targets,
      .groups = "drop"
    ) |>
    dplyr::mutate(time = factor(time, levels = c("day", "night")))

  ggplot2::ggplot(
    stats_plot,
    ggplot2::aes(x = factor(height), y = percent_detected, fill = time)
  ) +
    ggplot2::geom_col(
      width = 0.7,
      position = ggplot2::position_dodge(width = 0.75),
      color = "black",
      linewidth = 0.3
    ) +
    # Detected/total count above each bar: groups range from 2 to 43
    # targets, so the same percentage can mean very different evidence.
    ggplot2::geom_text(
      ggplot2::aes(label = paste0(n_detected, "/", n_targets)),
      position = ggplot2::position_dodge(width = 0.75),
      vjust = -0.4,
      size = 2.3
    ) +
    ggplot2::scale_y_continuous(limits = c(0, 115), breaks = seq(0, 100, 25)) +
    ggplot2::scale_fill_manual(
      values = c(
        day = "#f9f0a1",
        night = "#867493"
      )
    ) +
    ggplot2::facet_grid(
      rows = ggplot2::vars(class),
      cols = ggplot2::vars(layer),
      scales = "free_x",
      space = "free_x",
      labeller = ggplot2::labeller(
        layer = ggplot2::as_labeller(site_labels),
        class = ggplot2::as_labeller(class_labels)
      )
    ) +
    ggplot2::labs(
      x = "Flight altitude (m)",
      y = "Targets with ground returns (%)",
      fill = "Time"
    ) +
    ggplot2::theme_linedraw(base_size = 12) +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold"),
      legend.position = "bottom"
    )
}

make_dodged_barplot_custom <- function(stats_long, target_statistics = "All") {

  # Convert the raw point count into a point density (pnts/m^2), excluding
  # duplicated and negative-height points, when ROI area is available (see
  # `add_roi_area_m2()`), so sites/missions with differently sized ROIs
  # remain comparable.
  stats_long <- normalize_points_by_area(stats_long)

  statistic_labels <- c(
    `Total number of points` = "N Pnts. / m2",
    `Duplicated points (%)` = "Dup. pnts (%)",
    `Points with negative heights (%)` = "Pnts. -Z (%)",
    `First returns (%)` = "1st (%)",
    `Second returns (%)` = "2nd  (%)",
    `Third returns (%)` = "3th (%)",
    `Points with only single returns (%)` = "Single (%)",
    `Points with more than one return (%)` = "> 1 ret. (%)",
    `Outliers` = "Outliers"
  )

  # Collapse the below-1st-quantile and above-99th-quantile outlier counts
  # into a single "Outliers" statistic (sum of both) before anything else
  # (filtering, labelling) operates on `statistic`.
  outlier_stats <- c(
    "Outliers below height 1st quantile",
    "Outliers above height 99th quantile"
  )

  stats_long <- stats_long |>
    dplyr::mutate(
      statistic = dplyr::if_else(statistic %in% outlier_stats, "Outliers", statistic)
    ) |>
    dplyr::group_by(dplyr::across(-value)) |>
    dplyr::summarise(value = sum(value), .groups = "drop")

  available_stats <- unique(stats_long$statistic)

  if (
    length(target_statistics) == 1L &&
    identical(target_statistics, "All")
  ) {
    selected_stats <- available_stats
  } else {
    unknown_stats <- setdiff(target_statistics, available_stats)

    if (length(unknown_stats) > 0L) {
      stop(
        "Unknown statistic(s): ",
        paste(unknown_stats, collapse = ", "),
        call. = FALSE
      )
    }

    selected_stats <- target_statistics
  }

  stats <- stats_long |>
    dplyr::filter(statistic %in% target_statistics) |>
    dplyr::mutate(
      time = factor(time, levels = c("day", "night")),
      statistic = factor(statistic, levels = names(statistic_labels))
    )

  ggplot2::ggplot(
    stats,
    ggplot2::aes(x = factor(height), y = value, fill = time)
  ) +
    ggplot2::geom_col(
      width = 0.7,
      position = ggplot2::position_dodge(width = 0.75),
      color = "black",
      linewidth = 0.3
    ) +
    ggplot2::scale_fill_manual(
      values = c(
        day = "#f9f0a1",
        night = "#867493"
      )
    ) +
    ggplot2::facet_grid(
      rows = ggplot2::vars(statistic),
      cols = ggplot2::vars(layer),
      scales = "free",
      space = "free_x",
      labeller = ggplot2::labeller(
        statistic = ggplot2::as_labeller(statistic_labels),
        layer = ggplot2::as_labeller(site_labels)
      )
    ) +
    ggplot2::labs(
      x = "Flight altitude (m)",
      y = "Value",
      fill = "Time"
    ) +
    ggplot2::theme_linedraw(base_size = 12) +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      strip.text.x = ggplot2::element_text(face = "bold"),
      strip.text.y = ggplot2::element_text(face = "bold", angle = -90),
      legend.position = "bottom"
    )
}

make_violin_plot_custom <- function(stats_long, target_statistics = "All") {

  statistic_labels <- c(
    "n_pnts_last" = "N pnts.",
    "n_pnts_last_incoherent" = "N last inch. pnts.",
    "intensity_avg" = "Intensity",
    "thickness" = "Thick. (m)",
    "rmse_last" = "RMSE (m)"
  )

  available_stats <- names(statistic_labels)

  if (
    length(target_statistics) == 1L &&
    identical(target_statistics, "All")
  ) {
    selected_stats <- available_stats
  } else {
    unknown_stats <- setdiff(target_statistics, available_stats)

    if (length(unknown_stats) > 0L) {
      stop(
        "Unknown statistic(s): ",
        paste(unknown_stats, collapse = ", "),
        call. = FALSE
      )
    }

    selected_stats <- target_statistics
  }

  stats <- stats_long |>
    dplyr::filter(statistic %in% selected_stats) |>
    dplyr::mutate(
      time = factor(time, levels = c("day", "night")),
      statistic = factor(statistic, levels = names(statistic_labels))
    )

  ggplot2::ggplot(
    stats,
    ggplot2::aes(x = factor(height), y = value, fill = time)
  ) +
    ggplot2::geom_violin(
      trim = TRUE,
      alpha = 0.75,
      color = "black",
      linewidth = 0.3
    ) +
    ggplot2::scale_fill_manual(
      values = c(
        day = "#f9f0a1",
        night = "#867493"
      )
    ) +
    ggplot2::facet_grid(
      rows = ggplot2::vars(statistic),
      cols = ggplot2::vars(layer),
      scales = "free",
      space = "free_x",
      labeller = ggplot2::labeller(
        statistic = ggplot2::as_labeller(statistic_labels),
        layer = ggplot2::as_labeller(site_labels)
      )
    ) +
    ggplot2::labs(
      x = "Flight altitude (m)",
      y = "Value",
      fill = "Time"
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      strip.text.x = ggplot2::element_text(face = "bold"),
      strip.text.y = ggplot2::element_text(face = "bold", angle = -90),
      legend.position = "bottom"
    )
}

make_target_na_by_buffer_plot <- function(na_stats) {
  stats_plot <- na_stats |>
    dplyr::mutate(
      time = factor(time, levels = c("day", "night")),
      buffer_cm = factor(round(buffer_m * 100))
    )

  ggplot2::ggplot(
    stats_plot,
    ggplot2::aes(x = buffer_cm, y = percent_na, fill = time)
  ) +
    ggplot2::geom_col(
      width = 0.7,
      position = ggplot2::position_dodge(width = 0.75),
      color = "black",
      linewidth = 0.3
    ) +
    ggplot2::scale_fill_manual(
      values = c(
        day = "#f9f0a1",
        night = "#867493"
      )
    ) +
    ggplot2::facet_grid(
      rows = ggplot2::vars(layer, class),
      cols = ggplot2::vars(height),
      scales = "free_x",
      space = "free_x",
      labeller = ggplot2::labeller(
        layer = ggplot2::as_labeller(site_labels),
        class = ggplot2::as_labeller(class_labels)
      )
    ) +
    ggplot2::labs(
      x = "Buffer radius (cm)",
      y = "NA values (%)",
      fill = "Time"
    ) +
    ggplot2::theme_linedraw(base_size = 12) +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      strip.text.x = ggplot2::element_text(face = "bold"),
      strip.text.y = ggplot2::element_text(face = "bold", angle = 0, hjust = 0),
      legend.position = "bottom"
    )
}

make_target_boxplot_by_class <- function(stats_long, target_statistic, y_label = target_statistic) {

  available_stats <- unique(stats_long$statistic)

  if (!target_statistic %in% available_stats) {
    stop("Unknown statistic: ", target_statistic, call. = FALSE)
  }

  stats <- stats_long |>
    dplyr::filter(statistic == target_statistic) |>
    dplyr::mutate(time = factor(time, levels = c("day", "night")))

  ggplot2::ggplot(
    stats,
    ggplot2::aes(x = factor(height), y = value, fill = time)
  ) +
    ggplot2::geom_boxplot(
      notch = FALSE,
      alpha = 0.75,
      color = "black",
      linewidth = 0.3,
      outlier.shape = NA,
      position = ggplot2::position_dodge(width = 0.8)
    ) +
    ggplot2::geom_point(
      position = ggplot2::position_jitterdodge(jitter.width = 0.1, dodge.width = 0.8),
      size = 0.8,
      alpha = 0.5,
      show.legend = FALSE
    ) +
    ggplot2::scale_fill_manual(
      values = c(
        day = "#f9f0a1",
        night = "#867493"
      )
    ) +
    ggplot2::facet_grid(
      rows = ggplot2::vars(class),
      cols = ggplot2::vars(layer),
      scales = "free_x",
      space = "free_x",
      labeller = ggplot2::labeller(
        layer = ggplot2::as_labeller(site_labels),
        class = ggplot2::as_labeller(class_labels)
      )
    ) +
    ggplot2::labs(
      x = "Flight altitude (m)",
      y = y_label,
      fill = "Time"
    ) +
    ggplot2::theme_linedraw(base_size = 12) +
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(),
      strip.text = ggplot2::element_text(face = "bold"),
      legend.position = "bottom"
    )
}

save_custom_plot <- function(plot_obj, out_path, width = 10, height = 5, units = "in") {
  ggplot2::ggsave(
    filename = out_path,
    plot = plot_obj,
    device = tools::file_ext(out_path),
    width = width,
    height = height,
    units = units
  )
}
