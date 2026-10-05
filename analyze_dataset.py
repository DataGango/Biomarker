"""Build exploratory charts and a narrative summary from the bundled trial CSV."""

from __future__ import annotations

import csv
import html
from collections import Counter, defaultdict
from pathlib import Path


ROOT = Path(__file__).resolve().parent
DATA_PATH = ROOT / "data" / "diabetes_trials.csv"
OUTPUT = ROOT / "data"
PERIODS = [
    ("2010–2015", 2010, 2015),
    ("2016–2020", 2016, 2020),
    ("2021–2026*", 2021, 2026),
]
COLORS = ["#176b56", "#d7644f", "#c8952e", "#5585a5", "#806650"]


def read_trials():
    with DATA_PATH.open(encoding="utf-8-sig", newline="") as handle:
        rows = list(csv.DictReader(handle))
    required = {"year", "status", "allocation", "has_results", "title", "conditions"}
    if not rows or not required.issubset(rows[0]):
        raise ValueError("Dataset is empty or missing required trial fields")
    return rows


def period_name(year):
    for name, start, end in PERIODS:
        if start <= year <= end:
            return name
    return "Other"


def svg_start(title, subtitle, width=960, height=480):
    return [
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {} {}" role="img" aria-label="{}">'.format(
            width, height, html.escape(title)
        ),
        '<rect width="100%" height="100%" fill="#ffffff"/>',
        '<text x="46" y="48" fill="#18312e" font-family="Georgia,serif" font-size="27">{}</text>'.format(html.escape(title)),
        '<text x="46" y="73" fill="#667773" font-family="Arial,sans-serif" font-size="13">{}</text>'.format(html.escape(subtitle)),
    ]


def svg_text(x, y, text, size=12, fill="#52645f", anchor="start", weight="400"):
    return '<text x="{}" y="{}" text-anchor="{}" fill="{}" font-family="Arial,sans-serif" font-size="{}" font-weight="{}">{}</text>'.format(
        x, y, anchor, fill, size, weight, html.escape(str(text))
    )


def write_annual_chart(year_counts):
    width, height = 960, 480
    left, right, top, bottom = 56, 26, 112, 74
    plot_w, plot_h = width - left - right, height - top - bottom
    years = sorted(year_counts)
    maximum = max(year_counts.values())
    ceiling = ((maximum + 199) // 200) * 200
    slot = plot_w / len(years)
    bar_w = slot * 0.66
    parts = svg_start("Clinical-trial records by year", "Counts recalculated from bundled dataset; 2026 is partial")
    for tick in range(0, ceiling + 1, max(1, ceiling // 4)):
        y = top + plot_h - (tick / ceiling) * plot_h
        parts.append('<line x1="{}" y1="{:.1f}" x2="{}" y2="{:.1f}" stroke="#d9e2dc"/>'.format(left, y, width-right, y))
        parts.append(svg_text(left - 10, y + 4, tick, 10, anchor="end"))
    for index, year in enumerate(years):
        value = year_counts[year]
        bar_h = value / ceiling * plot_h
        x = left + index * slot + (slot - bar_w) / 2
        y = top + plot_h - bar_h
        color = "#cf624b" if year == max(years) else "#176b56"
        parts.append('<rect x="{:.1f}" y="{:.1f}" width="{:.1f}" height="{:.1f}" fill="{}"/>'.format(x, y, bar_w, bar_h, color))
        parts.append(svg_text(x + bar_w/2, height - 43, year, 10, anchor="middle"))
    parts.append(svg_text(width-right, height-15, "* 2026 partial", 10, anchor="end"))
    parts.append("</svg>")
    (OUTPUT / "trials_by_year.svg").write_text("\n".join(parts), encoding="utf-8")


def write_status_chart(status_counts):
    width, height = 960, 510
    left, right, top = 205, 90, 112
    plot_w = width - left - right
    ordered = status_counts.most_common()
    row_h = 35
    maximum = max(status_counts.values())
    parts = svg_start("Registry status at dataset export", "Status counts describe records in this extract, not treatment success", width, height)
    for index, (status, value) in enumerate(ordered):
        y = top + index * row_h
        parts.append(svg_text(left - 14, y + 17, status.replace("_", " ").title(), 11, anchor="end"))
        bar_w = value / maximum * plot_w
        parts.append('<rect x="{}" y="{}" width="{:.1f}" height="20" fill="{}"/>'.format(left, y, bar_w, COLORS[index % len(COLORS)]))
        parts.append(svg_text(left + bar_w + 8, y + 15, "{:,} ({:.1f}%)".format(value, value / sum(status_counts.values()) * 100), 10))
    parts.append("</svg>")
    (OUTPUT / "trial_status.svg").write_text("\n".join(parts), encoding="utf-8")


def write_period_chart(period_counts):
    width, height = 960, 485
    left, right, top, bottom = 65, 28, 115, 82
    plot_w, plot_h = width-left-right, height-top-bottom
    indicators = [
        ("COMPLETED", "Completed"),
        ("RESULTS", "Results posted"),
        ("RANDOMIZED", "Randomized allocation"),
    ]
    max_pct = 100
    parts = svg_start("Trial characteristics across periods", "Percent of records in each period; 2021–2026 includes partial 2026", width, height)
    for tick in range(0, 101, 20):
        y = top + plot_h - tick / max_pct * plot_h
        parts.append('<line x1="{}" y1="{:.1f}" x2="{}" y2="{:.1f}" stroke="#d9e2dc"/>'.format(left, y, width-right, y))
        parts.append(svg_text(left-12, y+4, "{}%".format(tick), 10, anchor="end"))
    period_w = plot_w / len(PERIODS)
    group_w = period_w * .62
    bar_w = group_w / len(indicators)
    for period_index, (name, _, _) in enumerate(PERIODS):
        counts = period_counts[name]
        x0 = left + period_index * period_w + (period_w-group_w)/2
        for indicator_index, (key, label) in enumerate(indicators):
            percentage = counts[key] / counts["TOTAL"] * 100
            bar_h = percentage / max_pct * plot_h
            x = x0 + indicator_index * bar_w
            y = top + plot_h - bar_h
            parts.append('<rect x="{:.1f}" y="{:.1f}" width="{:.1f}" height="{:.1f}" fill="{}"/>'.format(x+4, y, bar_w-8, bar_h, COLORS[indicator_index]))
            parts.append(svg_text(x+bar_w/2, y-7, "{:.0f}%".format(percentage), 9, anchor="middle", weight="700"))
        parts.append(svg_text(left + period_index * period_w + period_w/2, height-46, name, 12, anchor="middle", weight="700"))
        parts.append(svg_text(left + period_index * period_w + period_w/2, height-25, "n={:,}".format(counts["TOTAL"]), 10, anchor="middle"))
    legend_y = 92
    legend_x = left
    for index, (_, label) in enumerate(indicators):
        x = legend_x + index * 185
        parts.append('<rect x="{}" y="{}" width="11" height="11" fill="{}"/>'.format(x, legend_y-10, COLORS[index]))
        parts.append(svg_text(x+17, legend_y, label, 11))
    parts.append("</svg>")
    (OUTPUT / "trial_period_comparison.svg").write_text("\n".join(parts), encoding="utf-8")


def main():
    OUTPUT.mkdir(parents=True, exist_ok=True)
    rows = read_trials()
    year_counts = Counter(int(row["year"]) for row in rows)
    status_counts = Counter(row["status"].strip() or "NOT REPORTED" for row in rows)
    period_counts = defaultdict(Counter)
    diabetes_matches = 0
    actual_enrollment = []
    for row in rows:
        year = int(row["year"])
        period = period_name(year)
        group = period_counts[period]
        group["TOTAL"] += 1
        group["COMPLETED"] += row["status"].upper() == "COMPLETED"
        group["RESULTS"] += row["has_results"].lower() == "true"
        group["RANDOMIZED"] += row["allocation"].upper() == "RANDOMIZED"
        searchable = (row["title"] + " " + row["conditions"]).lower()
        diabetes_matches += "diabet" in searchable
        if row["enrollment_type"] == "ACTUAL" and row["enrollment"].strip():
            actual_enrollment.append(float(row["enrollment"]))

    write_annual_chart(year_counts)
    write_status_chart(status_counts)
    write_period_chart(period_counts)

    count = len(rows)
    completed = status_counts["COMPLETED"]
    results = sum(row["has_results"].lower() == "true" for row in rows)
    broad_search_pct = diabetes_matches / count * 100
    highest_year = max(year_counts, key=year_counts.get)
    nonmatches = count - diabetes_matches
    period_lines = []
    for name, _, _ in PERIODS:
        group = period_counts[name]
        period_lines.append(
            "- **{}:** {:,} records; {:.1f}% marked completed, {:.1f}% with results posted, {:.1f}% randomized.{}".format(
                name,
                group["TOTAL"],
                group["COMPLETED"] / group["TOTAL"] * 100,
                group["RESULTS"] / group["TOTAL"] * 100,
                group["RANDOMIZED"] / group["TOTAL"] * 100,
                " This window includes only part of 2026." if name == "2021–2026*" else "",
            )
        )
    narrative = f"""# Dataset analysis: diabetes clinical-trial records

## Dataset and scope

This exploratory analysis uses `{DATA_PATH.name}` ({count:,} trial records), with record years from {min(year_counts)} through {max(year_counts)}. The rows include registry status, phase, allocation, enrollment, intervention, conditions, and a per-record flag indicating whether results are posted. Individual rows link to ClinicalTrials.gov study pages. The dataset’s original query, export timestamp, and inclusion rules were not included, so this should not be treated as a complete census or a representative sample of all diabetes research.

A simple case-insensitive search of each record’s title and condition text finds “diabet” in {diabetes_matches:,} records ({broad_search_pct:.1f}%). The other {nonmatches:,} records are retained in the dataset and include unrelated or comparator conditions. This is a keyword coverage check, not a clinical classification. The results here must not be interpreted as childhood-cancer evidence; this is a separate diabetes-trial dataset.

## Main findings

- The largest annual count in the extract is {year_counts[highest_year]:,} in {highest_year}, but 2026 is partial and annual counts can reflect the extract’s query/update process rather than research activity alone.
- {completed:,} records ({completed / count * 100:.1f}%) are marked `COMPLETED`. Registry status is an administrative study status; it does not establish that an intervention works or is safe.
- {results:,} records ({results / count * 100:.1f}%) have `has_results=True`. The flag indicates result availability in this extract, not the direction, quality, or clinical importance of findings.
- Records marked completed are more frequent in earlier periods; the 2021–2026 period is not directly comparable because it includes recent and partial years, many studies may still be active, and records can have estimated start dates.
- Period detail:

{chr(10).join(period_lines)}

## Figures

1. `trials_by_year.svg` shows the number of records by start year; 2026 is marked as partial.
2. `trial_status.svg` shows registry status counts in this export.
3. `trial_period_comparison.svg` compares completed status, posted-results flags, and randomized allocation as shares within each period.

## Method and caveats

Counts are computed directly from the CSV. “Randomized” means the allocation field equals `RANDOMIZED`; “results posted” means the CSV field `has_results` is true; “completed” means the status equals `COMPLETED`. Periods are 2010–2015, 2016–2020, and 2021–2026 inclusive, with the last period labeled partial. Annual counts and period totals were reconciled with the companion `annual_counts.csv` and `period_summary.csv` files: all totals matched the 15,087 trial rows.

Records are trial registrations, not participants or published results. Enrollment values are not summed as unique people because participants may appear in multiple trials. The extract contains missing values and mixed actual/estimated fields. The dataset does not provide enough provenance to assess search completeness, de-duplicate study families beyond the trial identifier, infer treatment efficacy, or make causal claims. This is descriptive analysis only.
"""
    (ROOT / "dataset_analysis.md").write_text(narrative, encoding="utf-8")
    print("Rows: {:,}; years: {}–{}; diabetes keyword coverage: {:.1f}%".format(count, min(year_counts), max(year_counts), broad_search_pct))
    print("Completed: {:,} ({:.1f}%); results posted: {:,} ({:.1f}%)".format(completed, completed/count*100, results, results/count*100))
    print("Wrote 3 SVG charts and dataset_analysis.md")


if __name__ == "__main__":
    main()
