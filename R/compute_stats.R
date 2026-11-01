#!/usr/bin/env Rscript
library(lidaynight)

args <- commandArgs(trailingOnly = TRUE)

if (!length(args) %in% c(5, 6)) {
  stop(
    "Usage: Rscript compute_stats.R <point_clouds_dir> <time> <height> <area> <buffer_m> [epsg]",
    "\nExample: Rscript <script>.R \"W/pclouds\" day 100 alfred 0.5",
    "\nExample: Rscript <script>.R \"W/pclouds\" night 100 encinacorba_hillside 0.5 32630",
    call. = FALSE
  )
}

# Mission properties
time <- args[[2]]
height <- args[[3]]
area <- args[[4]]

# Buffer radius to compute the target metrics
buffer_m <- as.numeric(args[[5]])

point_clouds_dir <- args[[1]]

# Optional CRS (EPSG code) to compute the stats in. Needed when a mission is
# stored in a CRS whose map units are not ground meters at the site (e.g.
# Encinacorba missions stored in UTM 20N instead of UTM 30N)
epsg <- if (length(args) == 6) as.numeric(args[[6]]) else NULL

if (!is.null(epsg) && is.na(epsg)) {
  stop("\nInvalid <epsg> parameter '", args[[6]], "'.", call. = FALSE)
}

time_opts <- c("day", "night")
if (!time %in% time_opts) {
  stop(
    "\nInvalid <time> parameter '", time,
    "'.\n Available options are: ", paste(time_opts, collapse= ", "),
    call. = FALSE
  )
}

height_opts <- c(100, 75, 40)
if (!height %in% height_opts) {
  stop(
    "\nInvalid <height> parameter '", height,
    "'.\n Available options are: ", paste(height_opts, collapse=", "),
    call. = FALSE
  )
}

area_opts <- c(
  "alfred",
  "alfred_loff",
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

message(paste("Processing", area, time, height, sep=" "))

# Process the operations in parallel
n_workers <- max(1, parallel::detectCores() - 10)

ROOT <- getwd()

# Select the current flight mission path
mission_folder <- paste(time, height, sep="_")
FMPATH <- file.path(point_clouds_dir, mission_folder)

if (!dir.exists(FMPATH)) {
    stop("Mission folder does not exists: ", FMPATH)
}
message("Mission folder: ", FMPATH)

# Area of interest
aoi_layer <- paste0(area, "_common")
AOIPATH <- file.path(ROOT, "data/metadata/flights_common_aoi.gpkg")

# Ground reference path
gr_fname <- "ground_reference_targets.gpkg"
GRPATH <- file.path(ROOT, "data/metadata", gr_fname)

# Folder to store the computed stats
STATSPATH <- openStatsFolder(ROOT, area, time, height)

# Retile mission laz files
# ------------------------------------------------------------------------------
grids_folder <- file.path(ROOT, "results", "grids", area, mission_folder)
grid_params_path  <- file.path(grids_folder, "retile_chunk_params.rds")
grid_params <- readRDS(grid_params_path)

fmpath_retiled <- retileCatalog(FMPATH, grid_params, n_workers = n_workers)

compressLasFolder(fmpath_retiled)

# Reproject the retiled catalog in place (after retiling, so the stored grid
# params, defined in the original CRS, still apply)
# ------------------------------------------------------------------------------
if (!is.null(epsg)) {
  reprojectCatalog(fmpath_retiled, epsg, n_workers = n_workers)
}

# Compute global statistics within the AOI region
# ------------------------------------------------------------------------------
globalStats(fmpath_retiled, AOIPATH, STATSPATH, layer_name = aoi_layer)

# Ground classification
# ------------------------------------------------------------------------------
fmpath_cls <- groundClassification(fmpath_retiled, overwrite=FALSE)

# Compute ground reference statistics for each ground reference target
# ------------------------------------------------------------------------------
targetStats(
  fmpath_cls,
  GRPATH,
  "Height",
  "Code",
  area,
  buffer_m = buffer_m,
  out_folder = STATSPATH
)

# Remove all objects from the global environment and release unused memory
rm(list = ls(envir = .GlobalEnv), envir = .GlobalEnv)
gc()
