**Widget 2.1: Top-Line AE Summary Table**

- **Dataset:** `adae` (which already has `adsl` columns merged in)
- **Filter:** `SAFFL == "Y"` and `TRTEMFL == "Y"` (treatment-emergent only)
- **Columns:** `USUBJID`, `ARM`, `AESER`, `AREL`, `ASEVN`, `AEACN`, `AESDTH`
- **Computation:** For each `ARM`, count unique `USUBJID` where:
    - Any TEAE exists → "Patients with any AE"
    - `AESER == "Y"` → "Patients with any serious AE"
    - `AREL == "PROBABLE"` or `"POSSIBLE"` → "Patients with any related AE"
    - `ASEVN >= 3` (or `AESEV == "SEVERE"`) → "Patients with any Grade ≥3 AE"
    - `AEACN == "DRUG WITHDRAWN"` → "Patients with AE leading to discontinuation"
    - `AESDTH == "Y"` → "Deaths"
    - Denominator = total patients per arm from `adsl` where `SAFFL == "Y"`
- **Package:** Can use `rtables` or build manually with `dplyr::summarise` + `gtsummary`
- **Output:** The classic "Table 14.3.1" — rows are categories above, columns are treatment arms, cells show n (%)

**Widget 2.2 — AE Incidence by Preferred Term**

- Data: `adae` + `adsl` (for denominator)
- What it does: answers "what specific AEs are patients having?" — grouped horizontal bar chart showing incidence rate (%) for the top 10 most frequent preferred terms, with all 3 arms side by side. Immediately shows which AEs are more common in drug arms vs. placebo.
- Key columns: `USUBJID`, `ARM`, `AEDECOD`
- Filters: `TRTEMFL == "Y"` + shared sidebar
- Output: grouped horizontal bar chart via ggplot2 + plotly

**Widget 2.3: Severity Heatmap**

- **Dataset:** `adae`
- **Filter:** `SAFFL == "Y"`, `TRTEMFL == "Y"`
- **Columns:** `AEDECOD`, `AESEV` (MILD/MODERATE/SEVERE), `USUBJID`, `ARM`
- **Computation:** For the top 15 most frequent PTs, cross-tabulate: rows = PT, columns = severity level. Cell value = count of unique patients. Optionally facet by `ARM`.
- **Output:** Heatmap grid — darker color = more patients. Rows = PTs, columns = MILD | MODERATE | SEVERE. Instantly shows whether a common AE tends to be mild or severe.

**Widget 2.4: Hy's Law Scatter Plot**

- **Dataset:** `adlb`
- **Filter:** `SAFFL == "Y"`, `ONTRTFL == "Y"` (on-treatment labs only)
- **Columns:** `USUBJID`, `PARAMCD`, `R2ANRHI` (ratio of value to upper limit of normal), `ARM`
- **Computation:** This requires two analytes per patient:
    1. Filter to `PARAMCD == "ALT"`, take the **maximum** `R2ANRHI` per patient → this is peak ALT as a multiple of ULN
    2. Filter to `PARAMCD == "BILI"`, take the **maximum** `R2ANRHI` per patient → this is peak bilirubin as ×ULN
    3. Join these two values on `USUBJID` so each patient has one point: (max ALT ×ULN, max Bili ×ULN)
    4. Draw reference lines at x = 3 (ALT > 3×ULN) and y = 2 (Bili > 2×ULN)
    5. The **upper-right quadrant** (both elevated) = potential Hy's Law cases = serious liver toxicity signal
- **Output:** Scatter plot. X-axis = peak ALT (×ULN), Y-axis = peak Bilirubin (×ULN). Points colored by `ARM`. Shaded danger zone in the upper-right. Any points in that zone are alarming and warrant patient-level follow-up.

**Widget 2.5: Lab Shift Plot**

- **Dataset:** `adlb`
- **Filter:** `SAFFL == "Y"`, user selects an analyte (e.g., ALT, AST, creatinine)
- **Columns:** `USUBJID`, `PARAMCD`, `BASE` (baseline value), `AVAL` (post-baseline value), `ANRLO`, `ANRHI`, `ARM`, `ABLFL`
- **Computation:**
    1. Filter to the user-selected `PARAMCD`
    2. Get baseline: filter where `ABLFL == "Y"` → gives `BASE` per patient
    3. Get worst post-baseline: for each patient, take the `max(AVAL)` across all post-baseline visits
    4. Each patient becomes one point: (baseline, worst post-baseline)
    5. Draw reference lines at `ANRLO` and `ANRHI` on both axes, creating a 3×3 grid (Low/Normal/High at baseline × Low/Normal/High post-baseline)
- **Output:** Scatter plot. X-axis = baseline value, Y-axis = worst post-baseline value. Diagonal line = no change. Points above the diagonal worsened. Points in the upper-right quadrant that crossed from below `ANRHI` to above it = new abnormals. Color by `ARM`

DATASETS

