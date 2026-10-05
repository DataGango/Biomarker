# Dataset analysis: diabetes clinical-trial records

## Dataset and scope

This exploratory analysis uses `diabetes_trials.csv` (15,087 trial records), with record years from 2010 through 2026. The rows include registry status, phase, allocation, enrollment, intervention, conditions, and a per-record flag indicating whether results are posted. Individual rows link to ClinicalTrials.gov study pages. The dataset’s original query, export timestamp, and inclusion rules were not included, so this should not be treated as a complete census or a representative sample of all diabetes research.

A simple case-insensitive search of each record’s title and condition text finds “diabet” in 14,361 records (95.2%). The other 726 records are retained in the dataset and include unrelated or comparator conditions. This is a keyword coverage check, not a clinical classification. The results here must not be interpreted as childhood-cancer evidence; this is a separate diabetes-trial dataset.

## Main findings

- The largest annual count in the extract is 1,079 in 2024, but 2026 is partial and annual counts can reflect the extract’s query/update process rather than research activity alone.
- 9,014 records (59.7%) are marked `COMPLETED`. Registry status is an administrative study status; it does not establish that an intervention works or is safe.
- 2,675 records (17.7%) have `has_results=True`. The flag indicates result availability in this extract, not the direction, quality, or clinical importance of findings.
- Records marked completed are more frequent in earlier periods; the 2021–2026 period is not directly comparable because it includes recent and partial years, many studies may still be active, and records can have estimated start dates.
- Period detail:

- **2010–2015:** 4,751 records; 78.6% marked completed, 28.2% with results posted, 77.9% randomized.
- **2016–2020:** 4,372 records; 68.5% marked completed, 21.2% with results posted, 75.3% randomized.
- **2021–2026*:** 5,964 records; 38.3% marked completed, 6.8% with results posted, 75.6% randomized. This window includes only part of 2026.

## Figures

1. `trials_by_year.svg` shows the number of records by start year; 2026 is marked as partial.
2. `trial_status.svg` shows registry status counts in this export.
3. `trial_period_comparison.svg` compares completed status, posted-results flags, and randomized allocation as shares within each period.

## Method and caveats

Counts are computed directly from the CSV. “Randomized” means the allocation field equals `RANDOMIZED`; “results posted” means the CSV field `has_results` is true; “completed” means the status equals `COMPLETED`. Periods are 2010–2015, 2016–2020, and 2021–2026 inclusive, with the last period labeled partial. Annual counts and period totals were reconciled with the companion `annual_counts.csv` and `period_summary.csv` files: all totals matched the 15,087 trial rows.

Records are trial registrations, not participants or published results. Enrollment values are not summed as unique people because participants may appear in multiple trials. The extract contains missing values and mixed actual/estimated fields. The dataset does not provide enough provenance to assess search completeness, de-duplicate study families beyond the trial identifier, infer treatment efficacy, or make causal claims. This is descriptive analysis only.
