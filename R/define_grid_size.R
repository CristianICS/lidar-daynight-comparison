#!/usr/bin/env Rscript
library(lidaynight)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 5) {
  stop(
    "Usage: Rscript define_grid_size.R <point_clouds_dir> <time> <height> <area> <chunk_size>",
    "\nExample: Rscript define_grid_size.R W/pclouds day 100 alfred 75",
    call. = FALSE
  )
}

# Mission properties
time <- args[[2]]
height <- args[[3]]
area <- args[[4]]
requested_size <- as.numeric(args[[5]])

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

message(paste("Processing", area, time, height, sep=" "))

# Select the current flight mission path
mission_folder <- paste(time, height, sep="_")
FMPATH <- file.path(point_clouds_dir, mission_folder)

# Store the grid params inside the result folder
results_folder <- file.path(getwd(), "results", "grids", area, mission_folder)
if (!dir.exists(results_folder)) {
  dir.create(results_folder, recursive = TRUE)
}

checkTileGrid(FMPATH, results_folder, chunk_size=requested_size)
