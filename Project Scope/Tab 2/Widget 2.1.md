*Widget 2.1: Top-Line AE Summary Table**

- **Dataset:** `adae` (which already has `adsl` columns merged in)
- **Filter:** `SAFFL == "Y"` and `TRTEMFL == "Y"` (treatment-emergent only, if AE started or worsened)
- **Columns:** `USUBJID`, `ARM`, `AESER`, `AREL` (Analysis Causality) , `ASEVN` (Analysis Severity/Intensity N), `AEACN` (Action Taken with Study Treatment), `AESDTH` (Results in Death)
- **Computation:** For each `ARM`, count unique `USUBJID` where:
    - Any TEAE exists → "Patients with any AE"
    - `AESER == "Y"` → "Patients with any serious AE"
    - `AREL == "PROBABLE"` or `"POSSIBLE"` → "Patients with any related AE, meaning that AE : Indicates that the analysis determines there is a reasonable possibility that the adverse event could have been caused by the study medication, though other causes are plausible."
    - `ASEVN >= 3` (or `AESEV == "SEVERE"`) → "Patients with any Grade ≥3 AE"
    - `AEACN == "DRUG WITHDRAWN"` → "Patients with AE leading to discontinuation"
    - `AESDTH == "Y"` → "Deaths"
    - Denominator = total patients per arm from `adsl` where `SAFFL == "Y"`
- **Package:** Can use `rtables` or build manually with `dplyr::summarise` + `gtsummary`
- **Output:** The classic "Table 14.3.1" — rows are categories above, columns are treatment arms, cells show n (%)

Tab 1 told you the _what_ — patients are dropping out of the drug arms faster. Widget 2.1 answers the **why** — it's the first look at adverse events.

This is arguably the most important single table in any clinical trial safety report. In regulatory submissions it's literally called "Table 14.3.1" and it's the first thing an FDA reviewer looks at. It's a high-level scorecard that answers: _how many patients in each arm had something go wrong, and how bad was it?_

Here's what each row means in plain terms:

**Patients with any AE** — did anything happen at all? In most trials this is 80-100% of patients in every arm, because even headaches and mild nausea count. What matters is the _difference_ between arms.

**Patients with any serious AE (SAE)** — "serious" in clinical trials has a specific legal definition. It means the AE resulted in death, hospitalization, disability, was life-threatening, or was a birth defect. This is a much smaller number than "any AE" and a much bigger deal.

**Patients with any related AE** — the investigator (doctor running the trial) judged this AE as probably or possibly caused by the study drug. This filters out things like catching a cold during the trial, which isn't the drug's fault.

**Patients with any severe AE** — severity is graded as MILD, MODERATE, or SEVERE. Note that "severe" and "serious" are different things. A severe headache is not serious (no hospitalization). A mild allergic reaction that requires hospitalization _is_ serious but not severe. This row counts SEVERE grade events.

**Patients with AE leading to discontinuation** — this directly connects to Widget 1.2. You saw that more Xanomeline patients discontinued. This row tells you how many of those discontinuations were _because of an AE_ specifically.

**Deaths** — self-explanatory and the most critical safety signal.

The key filter is `TRTEMFL == "Y"` — treatment-emergent AEs only. This means AEs that started _after_ the first dose. If a patient had a headache before the trial started, that doesn't count. We only care about events that could be caused by the drug.

The denominator is important: you're counting **unique patients**, not total events. If one patient had 15 headaches, that's still 1 patient with an AE, not 15. And the percentage is based on total patients per arm from `adsl`, including patients who had _zero_ AEs.

![[Pasted image 20260402101326.png]]

The workflow has one twist compared to Tab 1: you need **two datasets working together**. `adae` gives you the event-level data to count, but `adsl` gives you the denominator. If there are 84 patients in the High Dose arm and 60 of them had an AE, the cell shows "60 (71.4%)". You can't get that 84 from `adae` alone because patients with zero AEs have no rows there.




rtables 

Think of it like building a table in **two steps** instead of one:

**Step 1 — Define the layout** (describe _what_ the table should look like, before seeing any data)

![[Pasted image 20260402102134.png]]

That's the core idea: layout first, data second. This is different from `dplyr` or `gtsummary` where you pipe data through transformations directly.

The key functions in the layout pipeline:

![[Pasted image 20260402102203.png]]

The special part for AE tables: `rtables` has `alt_counts_df` which lets you pass in `adsl` as the denominator source. This is important because by default rtables sets column Ns to the number of rows per group (number of AEs per arm), but for safety tables you want the number of patients per arm from ADSL. [Insightsengineering](https://insightsengineering.github.io/rtables/v0.6.10/articles/clinical_trials.html)

	If you just count rows in `adae` for that arm, you might see 300 rows. But that doesn't mean 300 patients had AEs — it means 300 _events_ happened across 84 patients. Some patients had lots of events, some had none.

	When you compute a percentage like "60 (71.4%)", the denominator needs to be **84** (total patients in that arm from `adsl`), not 300 (total events from `adae`).

	That's the problem `rtables` solves with `alt_counts_df` — you pass in `adsl` separately and it uses the patient count from there as the denominator instead of counting rows in `adae`.

**Why pharma uses it:** rtables was designed to create regulatory-ready tables for health authority review, with requirements like cell values separate from formatting, programmatic access to non-rounded values for cross-checking, and pagination for submission documents. [GitHub](https://github.com/insightsengineering/rtables/blob/main/README.md)



**How Widget 2.1 actually works, step by step:**

The whole thing has 3 parts: the layout, the analysis function, and the build.

**Part 1 — The layout** tells rtables the shape of the table:

```r
lyt <- basic_table(show_colcounts = TRUE) %>%
  split_cols_by("ARM") %>%
  analyze("USUBJID", s_ae_summary)
```

This says: make columns from the `ARM` variable (Placebo, High Dose, Low Dose), show the patient count in each column header (N=86, N=84, N=84), and run the function `s_ae_summary` on each column's data.

**Part 2 — The analysis function** does the actual counting. When rtables runs, it takes all the `adae` rows for one arm (say Placebo), passes them into this function, and says "here's the data, and `.N_col` is 86 (from adsl)":

```r
s_ae_summary <- function(df, .N_col, ...) {
  in_rows(
    "Patients with any TEAE" = rcell(
      n_distinct(df$USUBJID) * c(1, 1 / .N_col),
      format = "xx (xx.x%)"
    ),
    "Serious AE" = rcell(
      n_distinct(df$USUBJID[df$AESER == "Y"]) * c(1, 1 / .N_col),
      format = "xx (xx.x%)"
    ),
    ...
  )
}
```

Breaking down one row: `n_distinct(df$USUBJID)` counts unique patients with any AE in this arm — say 70. Then `* c(1, 1 / .N_col)` creates two numbers: `70` and `70/86 = 0.814`. The `format = "xx (xx.x%)"` tells rtables to display that as `70 (81.4%)`.

For the serious AE row, `df$USUBJID[df$AESER == "Y"]` first filters to only rows where AESER is "Y", then counts unique patients among those.

**Part 3 — The build** puts it all together:

````r
tbl <- build_table(lyt, adae_f, alt_counts_df = adsl_f)
```

This says: take the layout, feed it `adae` as the main data, but use `adsl` for the column counts (the denominator). Without `alt_counts_df`, rtables would count rows in `adae` per arm (number of events, not patients). With it, the N in the header comes from `adsl` — the actual number of patients per arm.

**The output** looks something like:
```
                                Placebo    High Dose    Low Dose
                                (N=86)     (N=84)       (N=84)
——————————————————————————————————————————————————————————————
Patients with any TEAE        70 (81.4%)  72 (85.7%)   71 (84.5%)
Serious AE                    8 (9.3%)    12 (14.3%)   10 (11.9%)
Related AE                    ...         ...          ...
Severe AE                     ...         ...          ...
AE leading to discontinuation ...         ...          ...
Death                         ...         ...          ...
````

![[Pasted image 20260402111350.png]]

**Serious AE** — a legal/regulatory definition. An AE is "serious" if it caused any of these outcomes: death, hospitalization, permanent disability, was life-threatening, or was a birth defect. A mild rash that lands you in the hospital is a _serious_ AE. It's about the **consequence**, not how bad it feels.

**Related AE** — the doctor's judgment call. Did they think the study drug _caused_ this AE? If a patient on the drug gets a headache, was it the drug or did they just sleep badly? The investigator marks each AE as "related" or "not related." This row only counts the ones they judged as drug-related.

**Severe AE** — a grading of intensity. How bad was the experience for the patient? MILD (noticeable but not disruptive), MODERATE (interferes with daily activities), SEVERE (can't function normally). A severe headache that you treat at home with ibuprofen is _severe_ but not _serious_. It's about **how bad it felt**, not the medical consequence.

The confusing part: severe ≠ serious. You can have a severe headache (intensity) that's not serious (no hospitalization). You can have a mild allergic reaction (intensity) that _is_ serious (requires hospitalization).

**What the table tells me:**

**Patients with any TEAE** — Placebo: 65 (75.6%), High Dose: 75 (89.3%), Low Dose: 77 (91.7%). Both drug arms have notably more patients experiencing AEs than Placebo. That ~15% gap confirms the drug is causing _something_. But 75.6% of Placebo patients also had AEs — which is normal, because even sugar pills come with headaches, colds, and life events that get recorded.

**Serious AE** — still very low across all arms (0-2 patients). Good news for the drug — whatever it's causing, it's not landing people in the hospital or causing life-threatening events. Zero serious AEs in Placebo is a bit unusual but possible with a small sample.

**Related AE** — now this is the big signal. Placebo: 43 (50.0%), High Dose: 69 (82.1%), Low Dose: 72 (85.7%). Investigators judged the majority of drug-arm AEs as _probably or possibly caused by the drug_. Half of Placebo patients also got a "related" judgment, which seems high — that could mean the investigators were liberal with their causality assessments, or it could reflect the blinding (they didn't always know who was on drug vs. placebo). The key comparison: 50% vs. 82-86% is a clear drug effect.

**Severe AE** — Placebo: 5 (5.8%), High Dose: 8 (9.5%), Low Dose: 16 (19.0%). This pattern is still odd — Low Dose has double the severe AEs of High Dose. In a real trial this would warrant investigation in Widget 2.2 to see _which_ specific AEs are driving that.

**AE leading to discontinuation** — 1 per arm (1.2% each). Still flat across arms, meaning the mass discontinuations from Tab 1 weren't formally coded as drug-withdrawn in the AE action field.

**Death** — Placebo: 2 (2.3%), High Dose: 0 (0.0%), Low Dose: 1 (1.2%). The deaths are actually in the Placebo and Low Dose arms, not High Dose. In a small study like this, 2 deaths in Placebo could be age-related (remember the median age is 75). No deaths in High Dose is reassuring.

**The overall story so far:** the drug clearly causes more adverse events (91% vs. 76%), and investigators believe most of them are drug-related (85% vs. 50%). But the events are mostly not serious and not leading to formal drug withdrawal. The next question — which Widget 2.2 will answer — is _what specifically are these AEs?_