
##What is this?

An R Shiny dashboard for reviewing safety data from an early-phase clinical trial. Built using open-source pharmaverse packages and synthetic ADaM datasets — no real patient data.

This is a learning project for getting familiar with ADaM datasets, the pharmaverse ecosystem, and building clinical trial dashboards in R Shiny.

## Datasets

All data comes from the `pharmaverseadam` R package. Four datasets, all joined on `USUBJID` (unique patient ID).

|Dataset|What it is|Grain|
|---|---|---|
|`adsl`|Patient roster — demographics, treatment arm, study status|One row per patient|
|`adae`|Adverse events — what went wrong, how bad, related to drug?|One row per AE event|
|`adex`|Drug exposure — dose, duration, timing|One row per dose record|
|`adlb`|Lab results — blood tests, liver/kidney markers, normals|One row per lab test per visit|

Key concept: `adae`, `adex`, and `adlb` all have `adsl` columns (ARM, AGE, SEX, SAFFL, etc.) already merged in. You can filter/group by treatment arm directly without joining. You only need standalone `adsl` for patient-level summaries (like the demographics table) and for denominators (total patients per arm, including those with zero events).

Important filter: always start with `SAFFL == "Y"` (safety population — patients who received at least one dose).

## File Structure

```
safetyscope/
├── SCOPE.md            # This file
├── app.R               # The Shiny dashboard (all tabs, all widgets)
├── eda_tab1.R          # Explore adsl for Tab 1
├── eda_tab2.R          # Explore adae + adlb for Tab 2
├── eda_tab3.R          # Explore all datasets for Tab 3
```

Workflow: run the EDA script first to understand the data, then the Shiny app is just presentation.

## Dashboard Layout

One sidebar with shared filters (treatment arm checkboxes, age range slider, patient count). Three tabs.

### Tab 1 — Population & Exposure

_Who is in the study and how much drug did they get?_

**Widget 1.1 — Sex & Race Distribution by Arm**

- Data: `adsl`
- What it does: stacked bar chart showing race breakdown within each sex, faceted by treatment arm
- Key columns: `ARM`, `SEX`, `RACE`
- Filters: `ARM` (checkboxes), `AGE` (range slider) — both in sidebar
- Output: stacked bar chart via ggplot2 + plotly

**Widget 1.2 — Patient Disposition by Arm**

- Data: `adsl`
- What it does: answers "did they finish it?" — grouped bar chart showing completed vs. discontinued per treatment arm. In this dataset, more Xanomeline patients discontinued than completed (vs. Placebo where most completed), which is a signal worth investigating in Tab 2.
- Key columns: `ARM`, `EOSSTT` (values: COMPLETED, DISCONTINUED)
- Filters: shared sidebar (ARM checkboxes, AGE slider)
- Output: grouped bar chart via ggplot2 + plotly

**Widget 1.3 — Exposure Box Plot**

- Data: `adsl`
- What it does: show distribution of how long patients stayed on drug, per arm
- Key columns: `ARM`, `TRTDURD`
- Output: box plot (x = arm, y = days)

### Tab 2 — Adverse Events & Lab Safety

_What happened to patients and is the drug damaging anything?_

**Widget 2.1 — AE Summary Table**

- Data: `adae`
- What it does: count patients with any AE, serious AE, related AE, severe AE, AE leading to discontinuation — by arm
- Key columns: `USUBJID`, `ARM`, `AESER`, `AREL`, `AESEV`, `AEACN`, `TRTEMFL`
- Filter: `TRTEMFL == "Y"` (treatment-emergent AEs only)
- Output: summary table

**Widget 2.2 — AE Incidence by Preferred Term**

- Data: `adae` + `adsl` (for denominator)
- What it does: answers "what specific AEs are patients having?" — grouped horizontal bar chart showing incidence rate (%) for the top 10 most frequent preferred terms, with all 3 arms side by side. Immediately shows which AEs are more common in drug arms vs. placebo.
- Key columns: `USUBJID`, `ARM`, `AEDECOD`
- Filters: `TRTEMFL == "Y"` + shared sidebar
- Output: grouped horizontal bar chart via ggplot2 + plotly

**Widget 2.3 — Severity Heatmap**

- Data: `adae` (pre-filtered to SAFFL == "Y" and TRTEMFL == "Y" via `adae_te`)
- What it does: answers "how bad are the top AEs?" — cross-tabulates preferred terms × severity (MILD/MODERATE/SEVERE). Darker cells = more patients. Shows whether common AEs tend to be mild nuisances or severe problems.
- Key columns: `USUBJID`, `AEDECOD`, `AESEV`
- Filters: shared sidebar + in-tab slider for number of terms (same as Widget 2.2)
- Output: heatmap via ggplot2 + plotly (all arms combined)

**Widget 2.4 — Hy's Law Plot**

- Data: `adlb`
- What it does: scatter plot checking for liver toxicity signals (ALT vs. bilirubin)
- Key columns: `USUBJID`, `PARAMCD`, `R2ANRHI`, `ARM`
- Output: scatter plot with danger quadrant shaded

**Widget 2.5 — AE & Lab Correlation**

- Data: `adae` + `adlb` (joined on USUBJID)
- What it does: for the top 10 most common AEs, shows how many of those patients also had high values for specific lab analytes (ALT, AST, BILI for liver; CREAT for kidney; HGB for blood). Answers "are the symptoms patients feel linked to organ-level damage?"
- Key columns: `USUBJID`, `AEDECOD` (from adae), `PARAMCD`, `ANRIND` (from adlb)
- Filters: shared sidebar (ARM, AGE)
- Format: "n/total" where n = patients with both the AE and high lab, total = patients with that AE
- Output: reactable table with descriptive subtitle
- Key finding: lab abnormalities are mild (10-20%) and evenly spread — no specific organ is disproportionately hit. BILI is consistently low across all AEs (good — no liver failure signal). HGB is nearly zero (drug isn't affecting blood). The drug causes skin irritation but appears not systemically toxic.

### Tab 3 — Safety Summary

_Is this drug safe? Give me the headline._

**Widget 3.1 — Safety Scorecard**

- Data: `adsl` + `adae` + `adlb`
- What it does: three grouped cards summarizing the safety profile with drug-vs-placebo comparisons. Population & Retention (discontinuation rate, median days on treatment), Adverse Events (TEAE rate, most common AE, serious AEs, deaths), Lab Safety (Hy's Law cases with interpretation).
- Output: bslib card() components with tags$strong(), tags$p(), tags$br() — no custom CSS

**Widget 3.3 — Key Findings**

- Data: `adsl` + `adae` + `adlb`
- What it does: auto-generated bullet points summarizing the safety narrative. Five findings computed from filtered data: AE rate difference (drug vs placebo), top 3 most common AEs, serious AE and death counts, discontinuation rate and treatment duration difference, Hy's Law assessment.
- Output: bslib card() with tags$ul() / tags$li() — no custom CSS
- Key findings from synthetic data:
    - Drug arms had ~90% TEAE rate vs ~76% placebo
    - Top AEs are all skin/application site related (pruritus, erythema, rash)
    - Serious AEs rare (0-2.4% per arm)
    - Drug-arm patients discontinued at ~69% vs ~33% placebo, ~105 fewer days on treatment
    - 1 Hy's Law case detected

## Widget-to-Dataset Map

|Widget|adsl|adae|adex|adlb|
|---|:-:|:-:|:-:|:-:|
|1.1 Sex & Race Distribution|✓||||
|1.2 Patient Disposition|✓||||
|1.3 Exposure Box Plot|✓||||
|2.1 AE Summary Table|✓|✓|||
|2.2 AE Incidence by PT|✓|✓|||
|2.3 Severity Heatmap||✓|||
|2.4 Hy's Law Plot||||✓|
|2.5 AE & Lab Correlation||✓||✓|
|3.1 Safety Scorecard|✓|✓||✓|
|3.3 Key Findings|✓|✓||✓|

## Build Order

1. Tab 1 widgets (adsl only) ✓
2. Tab 2 widgets (adae + adlb) ✓
3. Tab 3 widgets (summary across all datasets) ✓

## Tech Stack

|What|Package|
|---|---|
|Data|`pharmaverseadam`|
|App framework|`shiny` + `bslib`|
|Tables|`rtables`, `reactable`|
|Plots|`ggplot2` + `plotly`|
|App framework|`shiny` + `bslib`|
|Tables|`rtables`, `reactable`|
|Plots|`ggplot2` + `plotly`|
