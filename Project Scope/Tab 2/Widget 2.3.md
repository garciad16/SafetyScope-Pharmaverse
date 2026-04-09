**Widget 2.3 — Severity Heatmap**

- Data: `adae` (pre-filtered to SAFFL == "Y" and TRTEMFL == "Y" via `adae_te`)
- What it does: answers "how bad are the top AEs?" — cross-tabulates preferred terms × severity (MILD/MODERATE/SEVERE). Darker cells = more patients. Shows whether common AEs tend to be mild nuisances or severe problems.
- Key columns: `USUBJID`, `AEDECOD`, `AESEV`
- Filters: shared sidebar + in-tab slider for number of terms (same as Widget 2.2)
- Output: heatmap via ggplot2 + plotly (all arms combined)

Widget 2.2 just showed you _which_ AEs are most common. Widget 2.3 answers **how bad are they?**

Knowing that 30% of patients had Pruritus (itching) is useful, but it matters a lot whether that's 30% with _mild_ itching or 30% with _severe_ itching. A drug that causes mild itching in many patients is very different from one that causes severe itching.

A severity heatmap cross-tabulates the top preferred terms against the three severity grades (MILD, MODERATE, SEVERE). Each cell shows how many patients had that combination. The color intensity represents the count — darker cells mean more patients. You read it like this: scan across a row to see if an AE tends to be mild or severe, scan down a column to see which AEs concentrate at a particular severity level.

What to look for:

- **AEs that are mostly mild** (dark cell on the left, light on the right) — these are nuisance side effects but probably manageable
- **AEs that cluster in severe** (dark cell on the right) — these are the concerning ones that might need dose modifications or monitoring
- **Differences between arms** — if we facet by arm, you can see whether the drug makes an AE _worse_ (not just more frequent)

This connects to what you already saw: Widget 2.1 showed Low Dose has 16 patients (19%) with severe AEs vs. 8 (9.5%) for High Dose. The heatmap will show you _which specific AEs_ are responsible for that.