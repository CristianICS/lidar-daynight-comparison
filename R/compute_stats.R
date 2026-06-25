#!/usr/bin/env Rscript
library(lidaynight)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 5) {
  stop(
    "Usage: Rscript compute_stats.R <point_clouds_dir> <time> <height> <area> <chunk_size>",
    "\nExample: Rscript <script>.R W/pclouds day 100 alfred",
    call. = FALSE
  )
}

# Mission properties
time <- args[[2]]
height <- args[[3]]
area <- args[[4]]
chunk_size <- args[[5]]

point_clouds_dir <- args[[1]]

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

area_opts <- c("alfred", "quinces")
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
mission_folder <- paste(area, time, height, sep="_")
FMPATH <- file.path(point_clouds_dir, area, mission_folder)

# Area of interest
aoi_database <- file.path(ROOT, "data/metadata/flights_common_overlap.gpkg")
aoi_layer <- paste0(area, "_100_40")
AOIPATH <- file.path(aoi_database)

# Ground reference path
gr_fname <- paste0(area, "_ground_reference.gpkg")
GRPATH <- file.path(ROOT, "data/sites", area, gr_fname)

# Folder to store the computed stats
STATSPATH <- configStatsFolder(ROOT, area, time, height)

# Retile mission laz files
# ------------------------------------------------------------------------------
grid_params <- list("size" = chunk_size, "buffer" = 0, "alignment" = TRUE)
fmpath_retiled <- retileCatalog(FMPATH, grid_params, n_workers)

catalogCompression(fmpath_retiled, overwrite=FALSE)

# Compute global statistics within the AOI region
# ------------------------------------------------------------------------------
globalStats(fmpath_retiled, AOIPATH, STATSPATH, layer_name = aoi_layer)

# Ground classification
# ------------------------------------------------------------------------------
fmpath_cls <- groundClassification(fmpath_retiled, overwrite=TRUE)

# Compute ground reference statistics for each ground reference target
# ------------------------------------------------------------------------------
targetStats(fmpath_cls, GRPATH, "Height", "Code", area, out_folder = STATSPATH)
