"""
Compute statistics from each site per flight time.
"""
from pathlib import Path
import pandas as pd

ROOT = Path(__file__).resolve().parent.parent / "data"

START_TIME = "2025-06-16 18:44:00"
END_TIME = "2025-06-16 19:10:00"

station_path = ROOT / "alfred_MetStation.csv"
# Avoid reading the first two rows containing metadata
station = pd.read_csv(station_path, skiprows=2)

station["Timestamps"] = pd.to_datetime(
    station["Timestamps"],
    format="%m/%d/%Y %I:%M:%S %p",
    errors="coerce"
)

def compute_stats(df: pd.DataFrame, time_intervals: list) -> None:
    """

    Parameters
    -------------------
    time_intervals : List[str]
        datetime data aware strings corresponding to the flight duration,
        time start, time end.
    
    Notes:
    D.F. during the flight
    B.F. before the flight

    Timestamp example: 06/01/2024 09:15:00 PM
    """
    # Flight times
    start = pd.Timestamp(time_intervals[0])
    end = pd.Timestamp(time_intervals[1])
    flight_data = df[df["Timestamps"].between(start, end)]

    rad_col = ' W/m2 Solar Radiation'
    print(f"mean {rad_col} D.F.", flight_data[rad_col].mean())
    
    # Compute the mean precipitation during the 24 hours before the flight
    pp_col = ' mm Precipitation'
    pp_start = start - pd.Timedelta(hours=24)
    pp_filtered = df[df["Timestamps"].between(pp_start, start)]
    print(f"mean {pp_col} 24h B.F.", pp_filtered[pp_col].mean())

    pp_rate_col = ' mm/h Max Precip Rate'
    print(f"mean {pp_rate_col} D.F.", flight_data[pp_rate_col].mean())

    wind_col = ' m/s Wind Speed'
    print(f"mean {wind_col} D.F.", flight_data[wind_col].mean())
    
    gust_col = ' m/s Gust Speed'
    print(f"max {gust_col} D.F.", flight_data[gust_col].max())

    temp_col = ' degree_C Air Temperature'
    print(f"mean {temp_col} D.F.", flight_data[temp_col].mean())

    vapor_col = ' kPa Vapor Pressure'
    print(f"mean {vapor_col} D.F.", flight_data[vapor_col].mean())

    atm_col = ' kPa Atmospheric Pressure'
    print(f"mean {atm_col} D.F.", flight_data[atm_col].mean())

    # Humidity?
    hum_col = ' m3/m3 Water Content'
    print(f"mean {hum_col} D.F.", flight_data[hum_col].mean())

compute_stats(station, [START_TIME, END_TIME])
