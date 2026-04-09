**Widget 1.1 — Sex & Race Distribution by Arm**

- Data: `adsl`
- What it does: stacked bar chart showing race breakdown within each sex, faceted by treatment arm
- Key columns: `ARM`, `SEX`, `RACE`
- Filters: `ARM` (checkboxes), `AGE` (range slider) — both in sidebar
- Output: stacked bar chart via ggplot2 + plotly

**Widget 1.2: Disposition Donut/Bar Chart**

- **Dataset:** `adsl` only
- **Filter:** `SAFFL == "Y"`
- **Columns:** `ARM`, `EOSSTT` (Completed / Discontinued / Ongoing)
- **Computation:** Count patients per `EOSSTT` category within each `ARM`. Optionally, for discontinued patients, you could cross-reference `adae` to count how many discontinued _due to AE_ (where `AEACN == "DRUG WITHDRAWN"`), but that's an enhancement.
- **Output:** Donut chart or stacked bar chart faceted by arm

**Widget 1.3: Exposure Duration Box Plot**

- **Dataset:** `adsl` (has `TRTDURD` pre-computed) or `adex` filtered to `PARAMCD == "TRTDURD"`
- **Filter:** `SAFFL == "Y"`
- **Columns:** `ARM`, `TRTDURD` (total treatment duration in days)
- **Computation:** None beyond grouping — the box plot function handles the statistics (median, IQR, whiskers)
- **Output:** Box plot with one box per treatment arm, y-axis = days on treatment

**Widget 1.4 — Patient Listing Table**

- Data: `adsl`
- What it does: one row per patient — the raw data behind the charts in 1.1–1.3. Sortable by any column, searchable. Lets reviewers verify the aggregate patterns at the individual level.
- Key columns: `USUBJID`, `ARM`, `AGE`, `SEX`, `TRTDURD`, `EOSSTT`
- Filters: shared sidebar (ARM checkboxes, AGE slider)
- Output: interactive table via reactable


DATASETS

## Dataset 1: `adsl` — Subject Level (one row per patient)

This is your patient roster. Every patient in the trial gets exactly one row. You'll join every other dataset back to this.

**Columns we'll use:**

|Column|What it means|How we'll use it|
|---|---|---|
|`USUBJID`|Unique patient ID|**Primary join key** across all datasets|
|`ARM` / `TRT01A`|Treatment arm (e.g., "Xanomeline High Dose", "Placebo")|Group-by variable for almost every analysis|
|`AGE`, `SEX`, `RACE`, `ETHNIC`|Demographics|Demographics summary table|
|`SAFFL`|Safety population flag ("Y" = included in safety analysis)|**Filter** — always subset to `SAFFL == "Y"` before any safety analysis|
|`EOSSTT`|End of study status (Completed, Discontinued, Ongoing)|Disposition chart|
|`DTHFL`|Death flag|Patient summary card, disposition|
|`TRTSDT` / `TRTEDT`|First/last treatment dates|Exposure duration calculation|
|`TRTDURD`|Treatment duration in days|Box plot, swimmer plot|

**Columns we might explore:**

`AGEGR1` (age group buckets), `REGION1` (geography), `DTH30FL` / `DTHA30FL` (death within/after 30 days of treatment), `LDDTHELD` (days from last dose to death).



## Dataset 3: `adex` — Exposure (one row per dose record)

Each row represents one period of drug exposure for a patient. A patient who was on drug for 12 weeks might have multiple rows (one per visit, or one per dose change).

**Columns we'll use:**

|Column|What it means|How we'll use it|
|---|---|---|
|`USUBJID`|Patient ID|Join to `adsl`|
|`EXTRT`|Drug name|Verify which treatment|
|`EXDOSE`|Actual dose given|Dose level tracking|
|`EXDOSU`|Dose units (mg, etc.)|Labels|
|`PARAMCD`|Parameter code (e.g., "DOSE", "TRTDUR")|Filter to specific summary parameters|
|`AVAL`|Analysis value|The numeric value for whatever `PARAMCD` is|
|`ASTDT` / `AENDT`|Exposure start/end date|Swimmer plot bars|
|`ASTDY` / `AENDY`|Exposure start/end study day|Timeline x-axis|
|`EXDURD`|Duration of this exposure period|Duration summaries|
|`EXDOSFRQ`|Dosing frequency|Context for dose adjustments|
|`EXADJ`|Reason for dose adjustment|Link to AEs causing dose changes|

**Columns we might explore:**

`EXPLDOS` (planned dose — compare actual vs. planned), `VISIT` / `VISITNUM` (which study visit), `EXROUTE` (route of administration).