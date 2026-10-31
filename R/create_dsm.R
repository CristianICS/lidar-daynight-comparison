# Create normalized Digital Surface Model
library(lidR)
library(terra)

# Config ----------------------------------------------------------------------
# Buffer (m) loaded around each tile so points near tile edges get their real
# neighbours from the adjacent tiles during SOR
sor_buffer <- 10

filter_outliers <- function(chunk) {
  laz <- lidR::readLAS(chunk)
  if (lidR::is.empty(laz)) return(NULL)

  # --- Statistical Outlier Removal (SOR) ---
  # Flags points whose average distance to k nearest neighbors
  # is beyond m standard deviations from the mean
  laz <- lidR::classify_noise(laz, lidR::sor(k = 10, m = 3))

  # Remove points classified as noise (class 18) and drop buffer points
  # (buffer == 0 marks core points) before writing
  laz_clean <- lidR::filter_poi(
    laz,
    Classification != lidR::LASNOISE & buffer == 0
  )
  return(laz_clean)
}

point_clouds_dir <- "W:/koreen/Koreen Alfred Processing/corrected LAS no GCPs"


# Select the flights and time producing the lower point density point clouds
height <- 100
time <- "day"
area <- "alfred"

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

# Process tile by tile (chunk size 0) with a buffer, keeping the original
# file names in the output folder
cls_raw_catalog <- readLAScatalog(cls_path)
opt_chunk_size(cls_raw_catalog) <- 0
opt_chunk_buffer(cls_raw_catalog) <- sor_buffer
opt_output_files(cls_raw_catalog) <- file.path(outliers_dir, "{ORIGINALFILENAME}")
opt_laz_compression(cls_raw_catalog) <- TRUE

catalog_apply(
  cls_raw_catalog,
  filter_outliers,
  .options = list(need_buffer = TRUE)
)
gc()

# Create DEM ----------------------------------------------------------------
cls_catalog <- readLAScatalog(outliers_dir)
# In case there were more files in the same folder, select the ones without
# outliers with a custom suffix.
# target_files <- list.files(
  # outliers_dir,
  # pattern = "_outlier_filter.laz",
  # full.names = TRUE
# )
# cls_catalog <- readLAScatalog(target_files)

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

# Select only the point clouds with more than 3 points
norm_files <- nlas$filename

valid_files <- norm_files[sapply(norm_files, function(f) {
  las <- readLAS(f)
  npoints(las) >= 3
})]

nlas_valid <- readLAScatalog(valid_files)

if (!file.exists(dsm_path)) {
  dsm <- rasterize_canopy(nlas_valid, res = 0.20, p2r(0.15, na.fill = tin()))

  writeRaster(
    dsm,
    dsm_path,
    gdal=c("COMPRESS=DEFLATE", "PREDICTOR=2")
  )
}

gc()
