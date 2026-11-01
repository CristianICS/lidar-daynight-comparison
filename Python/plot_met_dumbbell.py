"""
Dumbbell (paired dot) plot of the meteorological conditions per flight.

One panel per variable shared by all sites (wind speed, air temperature
and relative humidity), sites on the y-axis, and day and night joined by
a line. Flight height is shown by the row label.

Notes
-----
Flights that fall within the same station averaging interval share one
observation (e.g. several Spanish flights within one hourly AEMET record).
Instead of one marker per flight, the plot draws one point per observation:

    * Heights sharing an observation both by day and by night are merged
      into one row, labelled with every height it covers (``75 & 100 m*``).
    * Heights sharing an observation only by day or only by night keep
      their own rows; the shared points are drawn hollow and joined by a
      thin grey vertical bracket.

The observation time is read from the ``utc_observation`` column (filled
for the Spanish AEMET records). Where it is empty (Canadian records),
flights of the same site and time of day are considered to share an
observation when wind speed, temperature and relative humidity are all
identical.
"""
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.lines import Line2D

ROOT = Path(__file__).resolve().parent.parent
MET_PATH = ROOT / "data" / "metadata" / "missions_meteorologica_data.csv"
OUTPUT_DIR = ROOT / "results" / "met"

# Site id, label and country, in plotting order (Canada first, then Spain)
SITES = [
    ("alfred", "Alfred", "CA"),
    ("quinces", "Quinces", "CA"),
    ("encinacorba_s1", "Encinacorba S1", "ES"),
    ("encinacorba_s2", "Encinacorba S2", "ES"),
]

# Column and axis label of each shared variable
VARIABLES = [
    ("wind_speed", "Wind speed (m/s)"),
    ("temperature", "Temperature (°C)"),
    ("relative_humidity", "Relative humidity (%)"),
]
VALUE_COLS = [column for column, _ in VARIABLES]

TIMES = ["day", "night"]
TIME_COLORS = {"day": "#f9f0a1", "night": "#867493"}
# Darker outlines of the same hues, so the pale day fill and the hollow
# shared markers stay visible on a white background
TIME_EDGES = {"day": "#b3a536", "night": "#5c4d69"}
MARKER_SIZE = 60

# Vertical spacing between rows, sites and countries, and position of the
# site header above the first row of its site
SITE_GAP = 2.0
COUNTRY_GAP = 0.6
HEADER_OFFSET = 1
# Extra shift (points) of the site headers to the left of the height labels
HEADER_INDENT = 30


def load_met() -> pd.DataFrame:
    """
    Read the flight table and assign an observation id to each flight.

    Returns
    -------
    pd.DataFrame
        One row per flight with its site, time, height, observation id
        and shared variables.
    """
    df = pd.read_csv(MET_PATH)
    df["height"] = df["height"].astype(int)

    # Infer the observation where its time is not given (identical values)
    inferred = df.groupby(["site", "time", *VALUE_COLS]).ngroup()
    df["observation"] = df["utc_observation"].fillna(
        "inferred_" + inferred.astype(str))
    df = df[["site", "time", "height", "observation", *VALUE_COLS]]

    n_values = df.groupby(["site", "time", "observation"])[VALUE_COLS].nunique()
    if (n_values > 1).any().any():
        raise ValueError("Flights sharing an observation have different values")
    return df


def format_heights(heights: list[int]) -> str:
    """Label a row with its flight heights, e.g. ``40/75/100*``."""
    label = "/".join(str(height) for height in heights)
    return label + "*" if len(heights) > 1 else label


def build_rows(df: pd.DataFrame) -> pd.DataFrame:
    """
    Group the flights of each site into plotting rows.

    Heights sharing the same observation both by day and by night form a
    single row. Each row keeps the observation id and values per time.

    Returns
    -------
    pd.DataFrame
        One row per plotting row with its site, heights, y position,
        and ``{time}_observation`` / ``{time}_{variable}`` columns.
    """
    wide = df.pivot(index=["site", "height"], columns="time",
                    values=["observation", *VALUE_COLS])
    wide.columns = [f"{time}_{column}" for column, time in wide.columns]
    wide = wide.reset_index()

    obs_cols = [f"{time}_observation" for time in TIMES]
    rows = []
    y = 0.0
    previous_country = None
    for site, label, country in SITES:
        site_wide = wide[wide["site"] == site]
        if site_wide.empty:
            continue
        if previous_country is not None:
            y -= SITE_GAP + (COUNTRY_GAP if country != previous_country else 0)
        previous_country = country

        groups = site_wide.fillna({col: "" for col in obs_cols}).groupby(
            obs_cols, sort=False)
        site_rows = [group for _, group in groups]
        site_rows.sort(key=lambda group: group["height"].min())
        for i, group in enumerate(site_rows):
            if i:
                y -= 1
            row = group.iloc[0].to_dict()
            row.update({
                "label": label,
                "country": country,
                "heights": sorted(group["height"]),
                "y": y,
            })
            rows.append(row)
    return pd.DataFrame(rows)


def draw_panel(ax: plt.Axes, rows: pd.DataFrame, variable: str) -> None:
    """Draw the dumbbells of one variable."""
    # Day-night connectors
    for _, row in rows.iterrows():
        xs = [row[f"{time}_{variable}"] for time in TIMES]
        ax.plot(xs, [row["y"]] * 2, color="0.8", lw=2.5,
                solid_capstyle="round", zorder=1)

    for time in TIMES:
        color = TIME_COLORS[time]
        edge = TIME_EDGES[time]
        obs_col = f"{time}_observation"
        value_col = f"{time}_{variable}"
        shared = rows.groupby(["site", obs_col])["y"].transform("size") > 1

        # Brackets joining rows that share one observation in this period
        for _, group in rows[shared].groupby(["site", obs_col]):
            x = group[value_col].iloc[0]
            ax.plot([x, x], [group["y"].min(), group["y"].max()],
                    color="0.6", lw=1, zorder=2)

        for (_, row), is_shared in zip(rows.iterrows(), shared):
            if pd.isna(row[value_col]):
                continue
            ax.scatter(row[value_col], row["y"], s=MARKER_SIZE, marker="o",
                       facecolors="white" if is_shared else color,
                       edgecolors=edge, linewidths=1.5, zorder=3)


def add_site_labels(fig: plt.Figure, ax: plt.Axes, rows: pd.DataFrame) -> None:
    """
    Write each site name as a header above its rows, starting
    ``HEADER_INDENT`` points left of the height tick labels, and a unit
    heading above the ticks.
    """
    pad = ax.yaxis.get_major_ticks()[0].get_pad() or 0.0
    fig.canvas.draw()
    renderer = fig.canvas.get_renderer()
    tick_width = max(label.get_window_extent(renderer).width
                     for label in ax.get_yticklabels())
    offset = -(tick_width * 72 / fig.dpi + pad + HEADER_INDENT)

    for label, group in rows.groupby("label", sort=False):
        ax.annotate(str(label),
                    xy=(0, group["y"].max() + HEADER_OFFSET),
                    xycoords=ax.get_yaxis_transform(),
                    xytext=(offset, 0), textcoords="offset points",
                    ha="left", va="center", fontweight="bold")

    ax.annotate("Height (m)", xy=(0, 1), xycoords="axes fraction",
                xytext=(-pad, 6), textcoords="offset points",
                ha="right", va="bottom", fontsize=9, color="0.35")


def legend_handles() -> list[Line2D]:
    """Build the legend entries for times and shared observations."""
    def handle(label, face, edge):
        return Line2D([], [], ls="none", marker="o", markersize=8,
                      markerfacecolor=face, markeredgecolor=edge,
                      markeredgewidth=1.5, label=label)

    handles = [handle(time.capitalize(), TIME_COLORS[time], TIME_EDGES[time])
               for time in TIMES]
    handles.append(handle("Shared by rows", "white", "0.4"))
    return handles


def plot(rows: pd.DataFrame) -> plt.Figure:
    """Draw one panel per shared variable."""
    span = rows["y"].max() + HEADER_OFFSET - rows["y"].min() + 1
    height = 1.2 + 0.32 * span
    fig, axes = plt.subplots(1, len(VARIABLES), sharey=True,
                             figsize=(11, height))

    separators = rows.loc[rows["country"] != rows["country"].shift(), "y"]
    for ax, (variable, title) in zip(axes, VARIABLES):
        draw_panel(ax, rows, variable)
        ax.set_title(title, fontsize=11)
        ax.grid(axis="x", color="0.92", lw=0.8, zorder=0)
        ax.tick_params(axis="y", length=0)
        ax.tick_params(axis="x", colors="0.35")
        for side in ["top", "right", "left"]:
            ax.spines[side].set_visible(False)
        ax.spines["bottom"].set_color("0.7")
        # Separator between countries, halfway between the site header and
        # the last row of the previous country
        for y in separators.iloc[1:]:
            gap = 1 + SITE_GAP + COUNTRY_GAP
            ax.axhline(y + (HEADER_OFFSET + gap) / 2, color="0.75",
                       lw=0.8, ls="--", zorder=0)

    axes[0].set_yticks(rows["y"], [format_heights(h) for h in rows["heights"]])
    axes[0].set_ylim(rows["y"].min() - 0.7,
                     rows["y"].max() + HEADER_OFFSET + 0.5)

    fig.legend(handles=legend_handles(), loc="lower center",
               ncol=len(legend_handles()), frameon=False,
               bbox_to_anchor=(0.5, -0.02), handletextpad=0.3,
               columnspacing=1.2)
    fig.tight_layout(rect=(0, 0.06, 1, 1))
    add_site_labels(fig, axes[0], rows)
    return fig


def main() -> None:
    met = load_met()
    rows = build_rows(met)

    n_obs = met.groupby(["site", "time"])["observation"].nunique()
    print("Independent observations per site and time:")
    print(n_obs.unstack().to_string())
    print(f"Flights: {len(met)}, observations: {n_obs.sum()}")

    fig = plot(rows)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for suffix in ["png", "svg"]:
        path = OUTPUT_DIR / f"met_dumbbell.{suffix}"
        fig.savefig(path, dpi=300, bbox_inches="tight")
        print(f"Saved figure to {path}")


if __name__ == "__main__":
    main()
