#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 3) {
  stop(
    "Usage: Rscript common_aoi.R <point_clouds_dir> <area> <pnts_filter>",
    "\nExample: Rscript <script>.R W/pclouds alfred FALSE",
    call. = FALSE
  )
}

# Mission properties
point_clouds_dir <- args[[1]]
area <- args[[2]]
pnts_filter <- as.logical(args[[3]])


area_opts <- c(
  "alfred",
  "alfred_lo",
  "quinces",
  "artieda",
  "encinacorba_hillside",
  "encinacorba_scenery"
)

if (!area %in% area_opts) {
  stop(
    "\nInvalid <area> parameter '", area,
    "'.\n Available options are: ", paste(area_opts, collapse= ", "),
    call. = FALSE
  )
}

message(paste("Processing", area, sep=" "))

# Predefined missions
missions <- c(
  "night_100",
  "night_40",
  "day_100",
  "day_40"
)

# Shared folder containing metadata for all missions
data_folder <- file.path(getwd(), "data", "metadata")

# Compute the gt4 AOI for one mission
extract_gt4_aoi <- function(mission_name, point_cloud_dir, area) {

  ctg_path <- file.path(point_cloud_dir, mission_name)
  if (!dir.exists(ctg_path)) {
    warning(paste("The mission folder does not exist: ", mission_name))
    return(NULL)
  }

  ctg <- lidR::readLAScatalog(ctg_path)

  tiles <- sf::st_sf(
    mission = mission_name,
    tile_id = seq_len(nrow(ctg@data)),
    geometry = ctg@data$geometry,
    crs = sf::st_crs(ctg)
  )

  tiles <- sf::st_make_valid(tiles)

  overlap_count <- sf::st_intersection(tiles)

  gt4 <- overlap_count |>
    dplyr::select(n_overlaps = n.overlaps, geometry) |>
    dplyr::filter(n_overlaps > 4)

  if (nrow(gt4) == 0) {
    warning(paste("No gt4 polygons found for mission:", mission_name))
    return(NULL)
  }

  # Dissolve gt4 polygons within the mission
  gt4_aoi <- sf::st_sf(
    mission = mission_name,
    geometry = sf::st_union(gt4),
    crs = sf::st_crs(gt4)
  )

  gt4_aoi <- sf::st_make_valid(gt4_aoi)

  sf::st_write(
    gt4_aoi,
    file.path(data_folder, "flights_common_aoi.gpkg"),
    layer = paste0(area, "_", mission_name),
    delete_layer = TRUE,
    quiet=TRUE
  )

  return(gt4_aoi)
}

# Apply to all missions
mission_gt4_list <- lapply(
  missions,
  extract_gt4_aoi,
  point_cloud_dir = point_clouds_dir,
  area=area
)

mission_gt4_list <- Filter(Negate(is.null), mission_gt4_list)
computed_missions <- length(mission_gt4_list)
if (computed_missions < length(missions)) {
  warning("At least one required mission has no gt4 AOI.")
}

# Check CRS for all the missions
# Encinacorba hillside mission contains two different CRS
get_crs <- function(x) {paste0(sf::st_crs(x)$epsg, " ")}
crs_list <- lapply(mission_gt4_list, get_crs)
message(paste0("AOI CRSs: ", crs_list))
if (area == "encinacorba_hillside") {
  mission_gt4_list <- lapply(mission_gt4_list, sf::st_transform, crs=32630)
}

mission_gt4_aoi <- dplyr::bind_rows(mission_gt4_list)

# Count how many mission-level gt4 AOIs overlap each output polygon
mission_overlap_count <- sf::st_intersection(mission_gt4_aoi)

mission_overlap_count <- mission_overlap_count |>
  dplyr::mutate(n_mission_overlaps = lengths(origins)) |>
  dplyr::select(n_mission_overlaps, geometry)

# Keep areas shared by all missions
common_gt4_aoi <- mission_overlap_count |>
  dplyr::filter(n_mission_overlaps == computed_missions)

common_gt4_aoi <- sf::st_make_valid(common_gt4_aoi)

if (nrow(common_gt4_aoi) == 0) {
  stop("No common gt4 AOI was found across all missions.")
}

# Keep only common AOI polygons containing target points
if (pnts_filter) {
  pnts_path <- file.path(data_folder, "ground_reference_targets.gpkg")
  pnts_sf <- sf::st_read(pnts_path, area, quiet=TRUE)

  pnts_sf <- sf::st_transform(pnts_sf, sf::st_crs(common_gt4_aoi))

  common_gt4_aoi_with_points <- common_gt4_aoi[
    lengths(sf::st_intersects(common_gt4_aoi, pnts_sf)) > 0,
  ]

  if (nrow(common_gt4_aoi_with_points) == 0) {
    stop("No common gt4 AOI polygons intersect the target points.")
  }

  common_gt4_aoi <- common_gt4_aoi_with_points
}

# Dissolve final result
common_gt4_aoi_dissolved <- sf::st_sf(
  layer = "common_gt4_aoi",
  geometry = sf::st_union(common_gt4_aoi),
  crs = sf::st_crs(common_gt4_aoi)
)

common_gt4_aoi_dissolved <- sf::st_make_valid(common_gt4_aoi_dissolved)

# Save output
sf::st_write(
  common_gt4_aoi_dissolved,
  file.path(data_folder, "flights_common_aoi.gpkg"),
  layer = paste0(area, "_common"),
  delete_layer = TRUE
)
