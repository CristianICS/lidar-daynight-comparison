# Day–Night LiDAR Flight Comparison

This repository contains scripts, notes, and workflow documentation for comparing drone-based LiDAR acquisitions collected during daytime and nighttime flights.

The main objective is to evaluate whether nighttime LiDAR acquisitions produce higher-quality point clouds than daytime acquisitions because of reduced solar interference. The comparison focuses on signal intensity, point density, return structure, and vertical accuracy against GNSS validation points.

## Working hypothesis

Nighttime LiDAR flights are expected to have:

* Higher signal-to-noise ratio due to reduced solar background noise.
* Higher backscatter intensity.
* Increased point density.
* More ground returns, especially under vegetation.
* Potentially improved data quality at higher flight altitudes.

These effects may be especially important for lower-power drone LiDAR systems.

## Scientific background

Solar radiation can introduce noise into daytime LiDAR measurements, reducing the quality of the backscatter signal. This effect has been documented in space-based LiDAR studies, where sunlight contamination must be separated from the LiDAR return signal (Sun et al., 2016).

LiDAR intensity is also affected by canopy structure, including canopy density and the orientation of canopy elements (Arnqvist et al., 2020). Therefore, vegetation structure must be considered when interpreting day–night differences in intensity and return density.

A related study evaluated day and night performance differences for a space-based lightning mapping sensor (Sun et al., 2021). Although this is not a drone LiDAR study, it is relevant as an example of day/night effects on optical remote sensing performance.

Atmospheric conditions may also influence LiDAR intensity. Temperature, humidity, mist, and fog can affect laser propagation and signal attenuation. For this reason, meteorological station data should be checked for each flight.

TODO: Add peer-reviewed references on the effect of temperature, humidity, water vapour, fog, and aerosols on airborne or terrestrial LiDAR intensity.

## Study sites and flight inventory

### Quinces bog

* Coordinate reference system: `EPSG:32620`
* Heights: ellipsoidal
* Flight speed: 3.1 m/s
<!-- * Local working data path:
  `W:/koreen/Koreen_DayNight_LiDAR_Quinces/corrected LAS` -->

|   Height | Moment | Date                            | Time UTC | Local time |
| -------: | ------ | ------------------------------- | -------: | ---------: |
|     40 m | Day    | 2025-06-03                      |    15:10 |      11:10 |
|     75 m | Day    | 2025-06-03                      |    16:18 |      12:18 |
|    100 m | Day    | 2025-06-03                      |     TODO |      12:18 |
|     40 m | Night  | 2025-06-02                      |    04:23 |      00:23 |
|     75 m | Night  | 2025-06-02                      |    04:42 |      00:42 |
|  75 m v2 | Night  | 2025-08-20                      |    01:33 |      21:33 |
|    100 m | Night  | TODO: incorrect original record |     TODO |       TODO |
| 100 m v2 | Night  | 2025-08-20                      |    00:53 |      20:53 |

Notes:

* The 75 m and 100 m daytime flights at Quinces were flown during the same mission.
* The original 100 m nighttime flight was unavailable for processing and was recollected in August 2025.
* 100 and 75 nighttime flights were reprocessed to obtain ellipsoidal heights.

### Alfred bog

* Coordinate reference system: `EPSG:32618`
* Heights: ellipsoidal
* Flight speed: 3.1 m/s
<!-- * Local working data path:
  `W:/koreen/Koreen Alfred Processing/corrected LAS no GCPs` -->

| Height | Moment    | Date       | Time UTC | Local time |
| -----: | --------- | ---------- | -------: | ---------: |
|   40 m | Afternoon | 2025-06-12 |    23:44 |      18:44 |
|   75 m | Day       | 2025-06-16 |    18:49 |      13:49 |
|  100 m | Afternoon | 2025-06-12 |    00:34 |      19:34 |
|   40 m | Night     | 2025-06-13 |    04:15 |      23:15 |
|   75 m | Night     | 2025-06-13 |    05:58 |      00:58 |
|  100 m | Night     | 2025-06-13 |    03:38 |      22:38 |

Notes:

* The 40 m nighttime flight at Alfred was incomplete.
* The 100 m nighttime flight had orthometric heights. It was reprocessed to obtain ellipsoidal heights.

### Artieda ravine

* Coordinate reference system: `EPSG:32630`
* Heights: ellipsoidal
* Flight speed: 1.9 m/s
<!-- * Local working data path:
  `W:/koreen/Koreen Alfred Processing/corrected LAS no GCPs` -->

| Height | Moment    | Date       | Time UTC | Local time |
| -----: | --------- | ---------- | -------: | ---------: |
|   40 m | Afternoon | 2025-09-09 |    17:30 |      19:30 |
|   75 m | Afternoon | 2025-09-09 |    18:02 |      20:02 |
|  100 m | Afternoon | 2025-09-09 |    17:46 |      19:46 |
|   40 m | Night     | 2025-09-09 |    21:50 |      23:50 |
|   75 m | Night     | 2025-09-10 |    22:17 |      00:17 |
|  100 m | Night     | 2025-09-09\* |    22:06 |      00:06 |

\* The 100m night mission started the day ninth and finished during day tenth.

Notes:

* The 40 m and 100 m day/night flights were completed with one set of batteries.
* The drone did not land between those flights, but recalibration was performed for both.
* The 75 m day/night flight was completed separately.
* Wind speed was approximately 5 m/s.
* Flights were again flown at 1.9 m/s because the speed could not be changed.

## GNSS and trajectory processing notes

The LiDAR data were processed with PPP using base station RINEX files recorded for up to 3 hours (Canadian sites) and national NTRIP corrections (Spanish sites).
 The base station location was PPP-corrected and then updated during trajectory correction.

A GNSS validation point dataset was collected at each site using a Stonex GNSS station (Canadian sites) and Emlid GNSS (Spanish sites). These validation points are used for evaluating vertical accuracy.

## Setting a common flight mission area

The overlap between HESAI flightlines is irregular. To ensure that missions are compared over equivalent areas, an area of interest (AOI) was created for each mission site using only zones with common flightline overlap.

The AOI files are stored in:

```text
data/metadata/flights_common_overlap.gpkg
```

TODO: Check and upload the script used to generate the AOIs.

## Processing workflow

First, install the custom package containing the functions required for the workflow.

```R
devtools::install_github("CristianICS/lidaynight")
```

The second step is retiling the mission `LAZ` files. Use `R/define_grid_size.R` to find a good size to retile with:

```
Rscript R/define_grid_size.R <point_clouds_dir> <time> <height> <area> <chunk_size>
```

Then, use the R script `R/compute_stats.R`. The chunk size selected in the last run of the previous command is used to compute statistics for each flight mission.
```bash
Rscript R/compute_stats.R <point_clouds_dir> <time> <height> <area>
```

`point_clouds_dir`

Folder containing the processed mission `LAZ` files. There must be one folder per combination of acquisition time and flight altitude. These subfolders must be named using the format `<time>_<height>`.

`time`

Acquisition time of the mission: `day` or `night`.

`height`

Flight altitude: `40`, `75`, or `100`.

`area`

Study area. Current options are `alfred` and `quinces`.

`chunk_size`

Chunk edge length, in metres, used to retile the mission point cloud.

### Workflow steps

For each mission, `compute_stats.R` performs the following steps:

1. Retile the files to create an efficient processing grid.
2. Compute ROI-level metrics.
3. Classify ground points in each chunk using the Progressive TIN Densification (PTD) algorithm.[^1]
4. Compute target-level metrics using ground-classified points and GNSS reference height data.

Target-level statistics are computed using all ground-classified points within a 50 cm radius of each GNSS reference point.

[^1]: Progressive TIN Densification (PTD). [Axelsson (2000)](https://www.isprs.org/proceedings/xxxiii/congress/part4/111_xxxiii-part4.pdf)

### Output directory

The stat files are stored inside the `results` folder using the following tree:

```
results/
└── stats/
    └── <area>
        └── <time>_<height>
            ├── roi_stats.csv
            ├── roi_stats.gpkg
            ├── byclass_gf.csv
            ├── bytarget_gf_<cls_name>.csv
            └── bytarget_gf_<cls_name>.gpkg
```

The ROI-level metrics are stored as a `csv` and `gpkg`, linked to the AOI that was used in the last one.

For the target-level metrics, there is one file per class included in the targets (see section [Target-level metrics](#target-level-metrics)). A GeoPackage file is created for each target class. It contains the target-level metrics and the corresponding geometries. A final `byclass_gf.csv` file is computed aggregating the errors from the targets of each class.

### Render the reports

The final step is to generate the reports for each area. Once the statistics have been created, run the following command in the terminal:

```bash
Rscript R/render_report.R <area>
```

This will populate the `report.qmd` file with the statistics. Currently, only some statistics are available: percentages from ROI-level statistics, and average intensity and RMSE from target-level statistics.

ROI-level statistics are shown as dodged bar plots, while target-level metrics are shown as violin plots representing the distribution of all available ground reference points.

Reports for currently processed sites can be found in the `results/reports/<area>` folder.

## Comparison metrics

Two groups of statistics are computed: ROI-level LiDAR QA metrics and target-level vertical accuracy metrics. These are stored in the custom R package [lidaynight](https://github.com/CristianICS/lidaynight).

### ROI-level metrics

ROI-level metrics are computed with `globalStats()`. The function reads a folder of LAZ files as a `lidR` catalog, clips the data to a region of interest, computes QA metrics for each ROI, and writes the results to both `.csv` and `.gpkg` outputs.

The main metrics are:

| Metric                     | Description                                                                   |
| -------------------------- | ----------------------------------------------------------------------------- |
| `n_pnts`                   | Total number of points inside the ROI.                                        |
| `dup_pnts`                 | Number of duplicated points based on identical `X`, `Y`, and `Z` coordinates. |
| `intensity_avg`            | Mean LiDAR intensity.                                                         |
| `ret_1`, `ret_2`, `ret_3`  | Number of first, second, and third returns.                                   |
| `ret_single`               | Number of points from pulses with only one return.                            |
| `ret_abvone`               | Number of points from pulses with more than one return.                       |
| `pnts_na_height`           | Number of points with missing height values.                                  |
| `pnts_negative_height`     | Number of points with negative height values.                                 |
| `height_q01`, `height_q99` | 1st and 99th height percentiles.                                              |
| `pnts_height_lt_q01`       | Number of points below the 1st height percentile.                             |
| `pnts_height_gt_q99`       | Number of points above the 99th height percentile.                            |

Percentage versions of count-based metrics are added automatically using `add_pct_metrics()`. These columns use the suffix `_pct` and are calculated relative to `n_pnts`.

### Target-level metrics

Target-level metrics are computed with `targetStats()`. The function compares LiDAR points against GNSS ground reference targets using a fixed buffer around each target point. Metrics are computed using only ground-classified points by setting `ground_filter = TRUE`.

The buffer radius is set to 50 cm because smaller buffers left some ground reference points with no LiDAR points, especially in densely vegetated areas.

Targets are grouped by vegetation or surface class:

| Class         | Description                                   |
| ------------- | --------------------------------------------- |
| `road`        | Roads or good paths with no vegetation cover. |
| `shrub`       | Areas covered with bushes and shrubs with no or sparse trees. |
| `open_treed`  | Areas with sparse trees and understory.       |
| `dense_treed` | Highly dense vegetated areas.                 |

For each target buffer, the computed metrics are:

| Metric                   | Description                                                                                  |
| ------------------------ | -------------------------------------------------------------------------------------------- |
| `n_pnts`                 | Total number of LiDAR points inside the buffer.                                              |
| `n_pnts_last`            | Number of last-return points inside the buffer.                                              |
| `n_pnts_last_incoherent` | Number of last returns with an absolute height error greater than the incoherency threshold. |
| `intensity_avg`          | Mean LiDAR intensity inside the buffer.                                                      |
| `thickness`              | Difference between maximum and minimum height among last returns.                            |
| `sum_errs_last`          | Sum of last-return height errors relative to the GNSS reference height.                      |
| `sum_errs_last_sq`       | Sum of squared last-return height errors.                                                    |
| `rmse_last`              | RMSE of last-return heights relative to the GNSS reference height.                           |
| `bias_last`              | Mean signed height error of last returns.                                                    |

Class-level summaries are also written. These aggregate the target-level results by class and include:

* Number of targets.
* Number of targets containing last returns.
* Total number of last returns.
* Class-level RMSE.
* Class-level bias.

Per-target RMSE values should not be averaged directly because each target buffer can contain a different number of last returns. Instead, class-level RMSE is computed from the total sum of squared errors divided by the total number of last returns.

## Meteorological data

Meteorological station data should be checked for each flight.

Relevant variables include:

* Air temperature.
* Relative humidity.
* Absolute humidity.
* Water vapour content.
* Fog, mist, or precipitation.
* Wind speed.
* Wind direction.

The meteorological station reports water content in `g/m³`.

TODO: Convert water content from `g/m³` to volumetric units if needed. Confirm the target unit and formula before analysis.

## Field notes

The following field notes are retained for traceability.

<details>
<summary>Spanish campaign notes</summary>

September, 2025

### Day 8 — Encinacorba night

* Payload was calibrated before starting the 100 m flight.
* Wind speed was approximately 6–9 m/s.
* Flights were accidentally flown at 1.9 m/s.
* The 100 m flight was normal.
* The 40 m flight could not be calibrated at the end.
* Rain started at the end of the 40 m flight.

### Day 9 — Artieda day and night

* The 40 m and 100 m flights were completed with one set of batteries.
* The drone did not land between those flights, but recalibration was performed for both.
* The 75 m flight was completed separately.
* Wind speed was approximately 5 m/s.
* Flights were again flown at 1.9 m/s because the speed could not be changed.

### Day 10 — Encinacorba night

#### Steep slope site

* Flights were flown at 3.1 m/s.
* All missions were completed with one set of batteries.
* Calibration was performed at the end of each mission.
* A second calibration was not performed at the start of the next mission because the missions were continuous.
* Wind speed was low, approximately 0–1 m/s.

#### Mountain edge site

* The 40 m and 100 m flights were completed first.
* The drone then landed and batteries were changed before the 75 m flight.
* Calibrations were performed in the same way as at the steep slope site.
* Wind speed was high at times, approximately 7–11 m/s.

### Day 11 — Encinacorba day

#### Steep slope site

* The first flight failed because the camera was not turned on.
* The 40 m, 75 m, and 100 m flights were completed with one set of batteries.
* Flights were flown at 3.1 m/s.
* Another set of 40 m and 100 m flights was flown at 1.9 m/s with one set of batteries, followed by the 75 m flight with another battery set.
* Calibrations were performed in the same way as on Day 10.

#### Scenery site

* RTK data were collected.
* TODO: Add the pole height correction of 1.8 m to the RTK data.
* The 40 m, 75 m, and 100 m flights were flown at 3.1 m/s.
* All three flights were completed with one set of batteries.

### Operational workflow

1. Download RINEX files for the time of flight from Spanish active stations for Encinacorba.
2. Download or retrieve the RINEX file for the Artieda base station.
3. Upload GPS rover validation data from Spanish flights.
4. Process trajectories in POSPac.
5. Process LiDAR data through e-LAS and export individual LAZ files per flightline.
6. Create bounding boxes for evaluation areas where:

   * At least five flightlines overlap.
   * GNSS validation data are available.

</details>

## Known issues and TODOs

* Confirm the correct UTC time for the Quinces 100 m daytime flight.
* Add peer-reviewed references on atmospheric effects on LiDAR intensity.
* Add met station characteristics

## References

Arnqvist, J., Freier, J., & Dellwik, E. (2020). Robust processing of airborne laser scans to plant area density profiles. *Biogeosciences, 17*(23), 5939–5952. https://doi.org/10.5194/bg-17-5939-2020

Sun, H., Yang, J., Zhang, Q., Song, L., Gao, H., Jing, X., Lin, G., & Yang, K. (2021). Effects of day/night factor on the detection performance of FY4A Lightning Mapping Imager in Hainan, China. *Remote Sensing, 13*(11), 2200. https://doi.org/10.3390/rs13112200

Sun, W., Hu, Y., MacDonnell, D. G., Weimer, C., & Baize, R. R. (2016). Technique to separate LiDAR signal and sunlight. *Optics Express, 24*(12), 12949. https://doi.org/10.1364/OE.24.012949
