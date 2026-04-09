### What is this?

An R Shiny dashboard for reviewing safety data from an early-phase clinical trial. Built using open-source pharmaverse packages and synthetic ADaM datasets — no real patient data.

This is a learning project for getting familiar with ADaM datasets, the pharmaverse ecosystem, and building clinical trial dashboards in R Shiny.

---

### Datasets

All data comes from the `pharmaverseadam` R package. Four datasets, all joined on `USUBJID` (unique patient ID).

|Dataset|What it is|Grain|
|---|---|---|
|`adsl`|Patient roster — demographics, treatment arm, study status|One row per patient|
|`adae`|Adverse events — what went wrong, how bad, related to drug?|One row per AE event|
|`adex`|Drug exposure — dose, duration, timing|One row per dose record|
|`adlb`|Lab results — blood tests, liver/kidney markers, normals|One row per lab test per visit|

Key concept: `adae`, `adex`, and `adlb` all have `adsl` columns (ARM, AGE, SEX, SAFFL, etc.) already merged in. You can filter/group by treatment arm directly without joining. You only need standalone `adsl` for patient-level summaries (like the demographics table) and for denominators (total patients per arm, including those with zero events).

Important filter: always start with `SAFFL == "Y"` (safety population — patients who received at least one dose).

---

### File Structure

```
safetyscope/
├── SCOPE.md            # This file
├── app.R               # The Shiny dashboard (all tabs, all widgets)
├── eda_tab1.R          # Explore adsl + adex for Tab 1
├── eda_tab2.R          # Explore adae + adlb for Tab 2     [TODO]
├── eda_tab3.R          # Explore all datasets for Tab 3    [TODO]
```

Workflow: run the EDA script first to understand the data, then the Shiny app is just presentation.

---

### Dashboard Layout

One sidebar with shared filters (treatment arm checkboxes, patient count). Three tabs.

---

### Tab 1 — Population & Exposure

_Who is in the study and how much drug did they get?_

**Widget 1.1 — Demographics Table** Data: `adsl`. Summarize age, sex, race by treatment arm. Output: formatted summary table.

**Widget 1.2 — Disposition Chart** Data: `adsl`. Count patients by study status (completed, discontinued, ongoing) per arm. Output: bar chart.

**Widget 1.3 — Exposure Box Plot** Data: `adsl`. Show distribution of how long patients stayed on drug, per arm. Key column: `TRTDURD`. Output: box plot.

**Widget 1.4 — Swimmer Plot** Data: `adex` + `adsl`. Horizontal timeline bar per patient showing their time on drug. Output: horizontal bar chart (y = patients, x = study day, color = arm).

---

### Tab 2 — Adverse Events & Lab Safety

_What happened to patients and is the drug damaging anything?_

**Widget 2.1 — AE Summary Table** Data: `adae`. Count patients with any AE, serious AE, related AE, severe AE, AE leading to discontinuation — by arm. Filter: `TRTEMFL == "Y"`. Output: summary table.

**Widget 2.2 — AE Incidence by Preferred Term**

- Data: `adae` + `adsl` (for denominator)
- What it does: answers "what specific AEs are patients having?" — grouped horizontal bar chart showing incidence rate (%) for the top 10 most frequent preferred terms, with all 3 arms side by side. Immediately shows which AEs are more common in drug arms vs. placebo.
- Key columns: `USUBJID`, `ARM`, `AEDECOD`
- Filters: `TRTEMFL == "Y"` + shared sidebar
- Output: grouped horizontal bar chart via ggplot2 + plotly

**Widget 2.3 — Severity Heatmap** Data: `adae`. Cross-tabulate top AEs by severity level. Output: heatmap (rows = preferred terms, columns = mild/moderate/severe).

**Widget 2.4 — Hy's Law Plot** Data: `adlb`. Scatter plot checking for liver toxicity signals (peak ALT vs. peak bilirubin, both as multiples of upper limit of normal). Output: scatter plot with danger quadrant shaded.

**Widget 2.5 — Lab Shift Plot** Data: `adlb`. Baseline vs. worst post-baseline lab value per patient for a user-selected analyte. Output: scatter plot with reference range lines.

---

### Tab 3 — Patient Profile

_What happened to this specific patient?_

**Widget 3.1 — Patient Selector** Data: `adsl` + `adae` summary. Dropdown to pick a patient, enriched with AE count and worst severity.

**Widget 3.2 — Clinical Timeline** Data: `adex` + `adae` + `adlb` (filtered to one patient). Drug exposure, AEs, and lab flags on a single time axis.

**Widget 3.3 — AE Listing Table** Data: `adae` (filtered to one patient). Every AE for the selected patient with full detail. Output: sortable table.

**Widget 3.4 — Lab Sparklines** Data: `adlb` (filtered to one patient). Small trend charts for key analytes (ALT, AST, bilirubin, creatinine). Output: grid of small line charts.

**Widget 3.5 — Patient Summary Card** Data: `adsl` + `adae` summary. One-line snapshot: age, sex, arm, days on treatment, AE count, status.

---

### Widget-to-Dataset Map

|Widget|adsl|adae|adex|adlb|
|---|---|---|---|---|
|1.1 Demographics Table|✓||||
|1.2 Disposition Chart|✓||||
|1.3 Exposure Box Plot|✓||||
|1.4 Swimmer Plot|✓||✓||
|2.1 AE Summary Table||✓|||
|2.2 Butterfly Plot||✓|||
|2.3 Severity Heatmap||✓|||
|2.4 Hy's Law Plot||||✓|
|2.5 Lab Shift Plot||||✓|
|3.1 Patient Selector|✓|✓|||
|3.2 Clinical Timeline||✓|✓|✓|
|3.3 AE Listing Table||✓|||
|3.4 Lab Sparklines||||✓|
|3.5 Patient Summary Card|✓|✓|||

---

### Build Order

1. Tab 1 widgets (adsl + adex only — simplest data) ← **we are here**
2. Tab 2 widgets (adae + adlb — more columns but same patterns)
3. Tab 3 widgets (joins across all four — most complex)

---

### Tech Stack

| What               | Package              |
| ------------------ | -------------------- |
| Data               | `pharmaverseadam`    |
| App framework      | `shiny` + `bslib`    |
| Tables             | `gtsummary` + `gt`   |
| Plots              | `ggplot2` + `plotly` |
| Interactive tables | `reactable`          |