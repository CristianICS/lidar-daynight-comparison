# Create normalized Digital Surface Model
library(lidR)
library(terra)

# Config ----------------------------------------------------------------------
filter_outliers <- function(laz_path) {
  laz <- lidR::readLAS(laz_path)

  # --- Statistical Outlier Removal (SOR) ---
  # Flags points whose average distance to k nearest neighbors
  # is beyond m standard deviations from the mean
  laz <- lidR::classify_noise(laz, lidR::sor(k = 10, m = 3))

  # Remove points classified as noise (class 18)
  laz_clean <- lidR::filter_poi(laz, laz$Classification != lidR::LASNOISE)
  return(laz_clean)
}

point_clouds_dir <- "W:/koreen/Koreen_DayNight_LiDAR_Quinces/corrected LAS"


# Select the flights and time producing the lower point density point clouds
height <- 100
time <- "day"
area <- "quinces"

available_areas <- c(
  "alfred",
  "artieda",
  "encinacorba_hillside",
  "encinacorba_scenery",
  "quinces"
)

if (!area %in% available_areas) {
  message("Selected area is not inside the available ones.")
}

# Directory where rasters wll be saved
area_dir <- file.path(getwd(), "data/sites", area)
if(!dir.exists(area_dir)) {
  message("Output directory does not exist.")
}

raster_dir <- file.path(area_dir, "raster")
if (!dir.exists(raster_dir)) {
  dir.create(raster_dir)
}

# Select the best classified point cloud according to ground reference data
cls_path <- file.path(
  point_clouds_dir,
  paste(time, height, sep = "_"),
  "retiled/cls"
)

if (!dir.exists(cls_path)) {
  message("CLS folder does not exist.")
}

# Filter outliers -------------------------------------------------------------
outliers_dir <- file.path(cls_path, "outlier_filter")
if (!dir.exists(outliers_dir)) {
  dir.create(outliers_dir)
}

laz_files <- list.files(cls_path, pattern = ".laz$", full.names = TRUE)

invisible(lapply(laz_files, function(laz_path) {
  message("Filtering outliers: ", basename(laz_path))

  laz_clean <- filter_outliers(laz_path)

  out_path <- file.path(outliers_dir, basename(laz_path))
  lidR::writeLAS(laz_clean, out_path)
  gc()
}))

# Create DEM ----------------------------------------------------------------
cls_catalog <- readLAScatalog(outliers_dir)

dtm_path <- file.path(raster_dir, paste(area, "DEM.tif", sep = "_"))

if (file.exists(dtm_path)) {
  dtm_tin <- rast(dtm_path)
} else {
  dtm_tin <- rasterize_terrain(cls_catalog, res = 0.20, algorithm = tin())

  writeRaster(
    dtm_tin,
    dtm_path,
    gdal=c("COMPRESS=DEFLATE", "PREDICTOR=2")
  )
  gc()
}

# Compute derived products ----------------------------------------------------
# Slope in degrees (standard for analysis)
slope_path <- file.path(raster_dir, paste(area, "slope.tif", sep = "_"))
if (!file.exists(slope_path)) {
  slope_deg <- terrain(dtm_tin, v = "slope", unit = "degrees")

    writeRaster(
    slope_deg,
    slope_path,
    gdal=c("COMPRESS=DEFLATE", "PREDICTOR=2")
  )
  rm(slope_deg)
  gc()
}

# Aspect
aspect_path <- file.path(raster_dir, paste(area, "aspect.tif", sep = "_"))
if (!file.exists(aspect_path)) {
  aspect_deg <- terrain(dtm_tin, v = "aspect", unit = "degrees")
  writeRaster(
    aspect_deg,
    aspect_path,
    gdal=c("COMPRESS=DEFLATE", "PREDICTOR=2")
  )
  rm(aspect_deg)
  gc()
}

# Compute Hillshade raster using the radian layers
hillshade_path <- file.path(raster_dir, paste(area, "hillshade.tif", sep = "_"))

if (!file.exists(hillshade_path)) {

  slope_rad <- terrain(dtm_tin, v = "slope", unit = "radians")
  aspect_rad <- terrain(dtm_tin, v = "aspect", unit = "radians")

  hillshade <- shade(
    slope = slope_rad,
    aspect = aspect_rad,
    angle = 45,
    direction = 315
  )
  writeRaster(
    hillshade,
    hillshade_path,
    gdal=c("COMPRESS=DEFLATE", "PREDICTOR=2")
  )

  rm(hillshade, slope_rad, aspect_rad)
  gc()
}

# Height normalization --------------------------------------------------------
normalization_dir <- file.path(outliers_dir, "nrm_tiles")
if (!dir.exists(normalization_dir)) {
  dir.create(normalization_dir)
}

opt_output_files(cls_catalog) <- file.path(
  normalization_dir, "hillside_{XLEFT}_{YTOP}_normalized"
)
opt_laz_compression(cls_catalog) <- TRUE

nlas <- normalize_height(cls_catalog, algorithm = dtm_tin)
gc()

# Create an nDSF by interpolating heights of the points -----------------------
dsm_path <- file.path(raster_dir, paste(area, "nDSM.tif", sep = "_"))

# Save the processed tiles in R
opt_output_files(nlas) <- ""

if (!file.exists(dsm_path)) {
  dsm <- rasterize_canopy(nlas, res = 0.20, p2r(0.15, na.fill = tin()))

  writeRaster(
    dsm,
    dsm_path,
    gdal=c("COMPRESS=DEFLATE", "PREDICTOR=2")
  )
}

gc()
