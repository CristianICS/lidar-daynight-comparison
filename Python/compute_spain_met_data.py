"""
Build the meteorological table for the Spanish flights.

Reads the hourly AEMET records from the Daroca station (indicativo 9390)
and, for each flight time, retrieves the wind speed, air temperature and
relative humidity recorded at the closest full hour.

Notes
-----
AEMET hourly records and flight times are in UTC. Flight times are
converted to local time (Europe/Madrid, CEST in September) only to be
displayed in the final table.

Units in the AEMET files:
    * Wind speed: km/h (converted to m/s).
    * Temperature: tenths of degree Celsius (converted to degree Celsius).
    * Relative humidity: %.
"""
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent.parent / "data" / "metadata"
MET_DIR = ROOT / "daroca_met_data"
OUTPUT_PATH = ROOT / "spain_met_data.csv"

LOCAL_TZ = "Europe/Madrid"

# Flight times in UTC
FLIGHT_TIMES = [
    "2025-09-10 19:43",
    "2025-09-10 19:55",
    "2025-09-10 20:03",
    "2025-09-10 21:11",
    "2025-09-10 21:22",
    "2025-09-10 21:31",
    "2025-09-11 11:56",
    "2025-09-11 12:08",
    "2025-09-11 12:18",
    "2025-09-11 14:39",
    "2025-09-11 14:49",
    "2025-09-11 14:56",
]

# File name, hourly column prefix, output column and unit conversion factor
VARIABLES = [
    ("viento.csv", "VEL_", "Wind Speed (m/s)", 1 / 3.6),
    ("temperatura seco y humedo.csv", "T", "Temperature (c)", 0.1),
    ("humedad relativa.csv", "HU", "Relative humidity (%)", 1.0),
]


def read_hourly(file_name: str, prefix: str) -> pd.Series:
    """
    Read an AEMET daily file and reshape its hourly columns into a series.

    Parameters
    ----------
    file_name : str
        Name of the AEMET CSV file inside ``MET_DIR``.
    prefix : str
        Prefix of the hourly columns, e.g. ``"T"`` for ``T00`` to ``T23``.

    Returns
    -------
    pd.Series
        Values indexed by UTC timestamp.
    """
    df = pd.read_csv(MET_DIR / file_name, sep=";", encoding="latin-1")
    df = df.rename(columns={df.columns[1]: "YEAR"})  # "AÑO" column

    hour_cols = [f"{prefix}{hour:02d}" for hour in range(24)]
    long = df.melt(
        id_vars=["YEAR", "MES", "DIA"],
        value_vars=hour_cols,
        var_name="hour",
        value_name="value",
    )
    long["hour"] = long["hour"].str.removeprefix(prefix).astype(int)
    long["timestamp"] = pd.to_datetime(
        {
            "year": long["YEAR"],
            "month": long["MES"],
            "day": long["DIA"],
            "hour": long["hour"],
        },
        utc=True,
    )
    return long.set_index("timestamp")["value"].sort_index()


def nearest_hour(timestamp: pd.Timestamp) -> pd.Timestamp:
    """Round a timestamp to the closest full hour (half past rounds up)."""
    return (timestamp + pd.Timedelta(minutes=30)).floor("h")


def build_table(flight_times: list[str]) -> pd.DataFrame:
    """
    Build the meteorological table for the given flight times.

    Parameters
    ----------
    flight_times : list[str]
        Flight times in UTC, formatted as ``"YYYY-MM-DD HH:MM"``.

    Returns
    -------
    pd.DataFrame
        One row per flight time with the closest hourly observations.
    """
    utc = pd.to_datetime(pd.Series(flight_times), utc=True)
    local = utc.dt.tz_convert(LOCAL_TZ)
    observation = utc.apply(nearest_hour)

    table = pd.DataFrame({
        "Local time": local.dt.strftime("%Y-%m-%d %H:%M"),
        "Time UTC": utc.dt.strftime("%Y-%m-%d %H:%M"),
        "Observation UTC": observation.dt.strftime("%Y-%m-%d %H:%M"),
    })

    for file_name, prefix, column, factor in VARIABLES:
        hourly = read_hourly(file_name, prefix)
        table[column] = (hourly.reindex(observation).to_numpy() * factor)
        table[column] = table[column].round(2)

    return table


def main() -> None:
    table = build_table(FLIGHT_TIMES)
    table.to_csv(OUTPUT_PATH, index=False)
    print(table.to_string(index=False))

    value_cols = [column for _, _, column, _ in VARIABLES]
    date = table["Local time"].str.slice(0, 10).rename("Date")
    stats = table[value_cols].groupby(date).agg(["mean", "std", "min", "max"])
    print("\nStats by date:")
    print(stats.round(2).to_string())
    print(f"\nSaved table to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
