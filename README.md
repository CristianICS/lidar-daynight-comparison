# A comparison of day and night LiDAR flights

The signal-to-noise ratio is higher at night due to the absence of solar interference. In other words, the backscatter intensity should be higher at night than during the day. Point density will also increase with darkness and more ground returns will be detected. This is probably more important for "low power" system, like drone lidar.

The absence of solar interference should make the intensity higher at night. This could facilitate the collection of data at higher altitudes at night without loss of quality.

## Scientific background

The noise introduced by sunlight during the daytime affects the backscatter LiDAR signal (the paper discuss space-based LiDAR) (W. Sun et al., 2016, p. 1) In addition, the intensity values are affected by the density of the canopy and the orientation of its elements in space (Arnqvist et al., 2020, p. 5940).

Another study compared the day and night performance of a space-based sensor (H. Sun et al., 2021).

Check the humidity and temperature conditions at the MET stations. According to the [RockRobotic website](http://learn.rockrobotic.com/how-does-lidar-intensity-impact-the-accuracy-of-point-clouds) (search a scientific paper talking about that), the higher the temperature, the weaker the returned laser signal pulse. This is because air density decreases with high temperatures, “causing the laser pulse to scatter more”.

At night, the temperature is lower, but the humidity is higher (mainly because the air's capacity to hold water vapour is lower at night due to the lower air temperature). “As the humidity increases, the amount of water vapor in the air also increases, causing the laser pulse to scatter more. This can lead to a weaker return signal and a decrease in LiDAR intensity.”

## Methods

### Study sites and missions

Quinces bog\*.

Ellipsoidal heights, EPSG:32620

Stored inside working data (Pangolin): "W:/koreen/Koreen_DayNight_LiDAR_Quinces/corrected LAS"

| Height | Moment | Date | Time UTC | Local time |
| 40 | Day | Jun 3, 2025 | 3:10 pm| 11:10 am |
| 75 | Day | Jun 3, 2025| 4:18 pm| 12:18 pm\*\* |
| 100 | Day | Jun 3, 2025| 12:18 pm\*\* |
| 40 | Night | Jun 2, 2025| 4:23 am| 12:23 am |
| 75 | Night | Jun 2, 2025| 4:42 am | 12:42 am |
| 75v2 | Night | Aug 20, 2025| 1:33 am | 9:33 pm |
| 100 | Night | Wrong |  |  |
| 100v2 | Night | Aug 20, 2025 | 12:53 am | 8:53 pm |

Alfred bog\*.

Ellipsoidal heights, EPSG:32618

Stored inside working data (Pangolin): "W:/koreen/Koreen Alfred Processing/corrected LAS no GCPs"

| Height | Moment | Date | Time UTC | Local time |
| 40 | Afternoon | Jun 12, 2025 | 11:44 pm | 6:44 pm |
| 75 | Day | Jun 16, 2025 | 6:49 pm | 1:49 pm |
| 100 | Afternoon | Jun 12, 2025 | 12:34 pm | 7:34 pm |
| 40 | Night | Jun 13, 2025 | 4:15 am | 11:15 pm |
| 75 | Night | Jun 13, 2025 | 5:58 am | 12:58 am |
| 100 | Night | Jun 13, 2025 | 3:38 am | 10:38 pm |

\*: The LiDAR has been processed with PPP using a base station recording Rinex data up to 3 hours. The base location was PPP'd and then updated when trajectory correction was done. A point dataset was collected using a GNSS Stonex station at each site for validation purposes.

\*\*: It is probably that 75 and 100 day flights at Quinces were flown in the same mission.

Some problems:

- The 100-meter flight in Nova Scotia is unavailable to process. This was re-collected in August.
- The 40m night flight in Alfred was incomplete.

### Field notes

Day 8 - Encinacorba night

- Calibrated payload when we started the 100 m flight
- Wind is from 6-9 m/s each time
- We accidentally flew at 1.9 m/s
- The 100 m flight was normal
- 40 m flight we couldn't calibrate at the end
- It also started raining right at the end of the 40 m flight.

Day 9 - Artieda day and night

- We did 40 and 100 with one set of batteries. 
- We didn't land but we did do the recalibration for both flights.
- then we 75.
- wind 5 m/s
- Flew 1.9 m/s again because we couldn't change it.

Day 10 - Encinacorba night 

- At steep slopes site:
    - flew at 3.1 m/s
    - All missions with one set of batteries
    - else did calibration at the end of each mission but didn't do a 2nd calibration again at the start of the next mission as they are continuous.
    - low wind (0-1 m/s)
- Site at top of mountain by edge
    - we did 40 and 100 then landed and switched batteries to do the 75
    - did all calibrations the same as the other site.
    - wind was high at times (from 7-11 m/s)

Day 11 - Encinacorba day:

- At steep slope site (burned hillshade)
    - Failed the first flight (the camera wasn’t turned on)
    - We did 40, 75 and 100 with one set of batteries.
    - flew at 3.1 m/s
    - We did 40 and 100 flew at 1.9 m/s with one set of batteries, then 75 with the other set.
    - did all calibrations the same as the day 10
- At scenery site
    - RTK collection - need to add height of pole (1.8m)
    - flew at 3.1 m/s the three flights
    - We did the 40, 75 and 100 with one set of batteries.

### Comparison analysis

*First tests without GCPs georef. The targets cannot be detected at night.*

1. Counting the number of points in each return -- spatially, rasterize the number of points at 25 cm resolution[^1] and count the number of returns.  We should do this at a subset in the center of the image so that we have a consistent number of flightlines.
2. Computing the average intensity by return. - spatially, rasterize the intensity for each "return".
3. Calculate the root mean square error (RMSE) of the heights between GNSS-collected points and LiDAR point clouds. **The first approach involves trying to locate the LiDAR ground return points at the exact GNSS positions.** The second approach is to create a DEM or perform a buffer around the GNSS points, computing the average height of the last return or only return.
4. Make a product showing how many flightlines are at each location for each flight/height.

[^1]: 25 cm might not be a good resolution. Some points do not contain information around 25cm buffer.

### Computing LiDAR day/night metrics

File structure recommended

R folder contains the main function files. Each folder with the mission flights contains an R folder to compute the stats of the current file, with the global functions. Why are separated files used? Because each mission has its own characteristics (e.g. orthometric vs geoidal heights).

The workflow is the following:

1. Clip all the tiles to the mission AOI
2. Classify the point cloud with [OpenPointClass](https://github.com/uav4geo/OpenPointClass)
    * Delete the old clip file and persist only the classified one.
3. Compute the stats

### Workflow

1. Cristian downloads Rinex files for time of flight from Spanish active stations (Encinacorba) and the RINEX file for the base from artieda.
2. Cristian uploads GPS rover validation data from Spanish flights.
3. Koreen processes data through Pospac
4. Koreen processes data through e-las and outputs individual laz files per flightline.
5. Koreen create bounding boxes to clip out "evaluation area" where 5 flightlines overlap AND we have GPS validation data.  
6. Cristian's script:
    - Clip each strip to bounding box
    - Filter each strip with a for loop and save them as temp file.  
    - Create a las catalog for each filtered strip (e.g. temp file) in lidR. 
    - Function to calculate all of the stats in the table - this reads the catalog and create a temp file to do the filtering process.

## Notes/thoughts

- We don’t have a dry and low elevation site and point density may increase with elevation due to air density.  Think about getting a dry, low lying site with the Hesai.
- Replace CRS: Alfred should be EPSG:32618 and Quinces is EPSG:32620. There might be some inconsistencies between ellipsoidal and orthometric heights within the Alfred and Quinces flights. The ones with orethometric heights have been labeled in a different way. This means that the conversions will not be needed for all and you'll have to use the file name to figure it out. For the spanish sites only orthometric.

## Met station

Water content: absolute and relative humidity (indicate mist/fog)

The met station gives g/m3. Convert it to m3/m3 (volumetric units).

## References

Arnqvist, J., Freier, J., & Dellwik, E. (2020). Robust processing of airborne laser scans to plant area density profiles. Biogeosciences, 17(23), 5939–5952. https://doi.org/10.5194/bg-17-5939-2020

Sun, H., Yang, J., Zhang, Q., Song, L., Gao, H., Jing, X., Lin, G., & Yang, K. (2021). Effects of Day/Night Factor on the Detection Performance of FY4A Lightning Mapping Imager in Hainan, China. Remote Sensing, 13(11), 2200. https://doi.org/10.3390/rs13112200

Sun, W., Hu, Y., MacDonnell, D. G., Weimer, C., & Baize, R. R. (2016). Technique to separate lidar signal and sunlight. Optics Express, 24(12), 12949. https://doi.org/10.1364/OE.24.012949
