Let me start with the basics before getting to Hy's Law.

**What is lab data?**

During a clinical trial, patients get regular blood draws at scheduled visits — just like routine bloodwork at a doctor's office. The lab analyzes the blood and returns numbers for things like:

- **ALT** (alanine aminotransferase) — a liver enzyme. If this number goes up, the liver is stressed or damaged.
- **AST** (aspartate aminotransferase) — another liver enzyme. Same idea.
- **Bilirubin** — a waste product the liver processes. If this goes up, the liver isn't clearing waste properly.
- **Creatinine** — a kidney marker. If this goes up, kidneys aren't filtering well.

Each test has a **normal range** — for example, ALT might be normal between 10-40 U/L. Every patient's result is compared against that range. The dataset also has a column called `R2ANRHI` which is the ratio of the patient's value to the upper limit of normal. So if the upper limit is 40 and the patient's ALT is 120, `R2ANRHI = 3.0` (three times the upper limit of normal, written as "3×ULN").

**Why do we care about liver labs specifically?**

Many drugs are processed by the liver. A drug that looks fine based on symptoms (no pain, no nausea) might be quietly damaging the liver. You wouldn't know until you check the bloodwork. This is called **drug-induced liver injury (DILI)** and it's one of the top reasons drugs get pulled from the market _after_ approval. So regulators care about it a lot.

**What is Hy's Law?**

A physician named Hy Zimmerman noticed a pattern: if a drug causes both ALT to spike (≥3× upper limit of normal) AND bilirubin to spike (≥2× upper limit of normal) in the same patient, there's a ~10% chance that patient will develop fatal liver failure. That's an incredibly high mortality rate for a drug side effect.

So "Hy's Law" became a standard safety screen: for every patient, take their peak ALT and peak bilirubin during the study, plot them as a point, and draw the danger lines at ALT = 3×ULN and bilirubin = 2×ULN. The plot has four quadrants:

![[Pasted image 20260406151028.png]]

**Upper-right quadrant is the alarm.** Any patient dot landing there triggers immediate investigation. Even one dot is a serious safety signal.

**Widget 2.4 — Hy's Law Plot**

- Data: `adlb` (pre-filtered to SAFFL == "Y", received at least one dose of the study dug.  On-treatment labs ONTRTFL == "Y" identifies if an observation occurred while the subject was actively receiving treatment)
- What it does: for each patient, plot their peak ALT (×ULN) vs. peak bilirubin (×ULN). Shaded danger zone in the upper-right.
- Key columns: `USUBJID`, `PARAMCD`, `R2ANRHI`, `ARM`
- Computation: filter to ALT → get max R2ANRHI per patient. Filter to BILI → get max R2ANRHI per patient. Join on USUBJID. Plot.
- Output: scatter plot via ggplot2 + plotly

![[Pasted image 20260406151155.png]]


The key thing that makes this pipeline different from the others: you're pulling **two separate analytes** from `adlb` (ALT and Bilirubin), summarizing each one per patient, then joining them together so each patient becomes a single dot with two coordinates. Every other widget we've built works on one dataset flowing straight down — this one has a fork and merge.

