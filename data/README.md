Files inside the `data` directory:

- `metadata` Shared files related to the missions:
  - AOIs containing the area with the same amount of flight lines per site.
  - Database with the ground reference values per site and class. The columns are:
    - "Name": pseudo point ID
    - "Code": class name (e.g. `open_treed`)
    - "Northing", "Easting": Coordinates UTM
    - "Height": target height in ellipsoidal units. The quinces points have been corrected to ellipsoidal using the geoidal model. They were in orthometric heights
    - "Date", "Time": Collection date and time
    - "State" (optional): GNSS receiver status in the moment of the capture (e.g. FIXED)
    - "geom": Geometry column
- `shared` Information related to all the flights.
  - Geoidal models to convert between ellipsoidal and orthometric heights (Spain and Canada)
- `sites` Information related to each site.
  - Meteo data
  - Raster files
  - Reports from PPP post-processing

Coordinate reference systems used:

- Canada
  - Alfred EPSG:32618
  - Quinces EPSG:32620
- Spain
  - Artieda EPSG:
  - Encinacorba EPSG:

- Whether heights are ellipsoidal, orthometric, or geoid-corrected
- Which geoid model was used

TODO:

- Meaning of CHM, DTM, AOI, PPP, JFFN
