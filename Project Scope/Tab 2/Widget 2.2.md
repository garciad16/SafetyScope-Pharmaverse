**Widget 2.2 — AE Incidence by Preferred Term**

- Data: `adae` + `adsl` (for denominator)
- What it does: answers "what specific AEs are patients having?" — grouped horizontal bar chart showing incidence rate (%) for the top 10 most frequent preferred terms, with all 3 arms side by side. Immediately shows which AEs are more common in drug arms vs. placebo.
- Key columns: `USUBJID`, `ARM`, `AEDECOD`
- Filters: `TRTEMFL == "Y"` + shared sidebar
- Output: grouped horizontal bar chart via ggplot2 + plotly

Widget 2.1 just told you the _how many_ — 89-92% of drug-arm patients had AEs. Widget 2.2 answers the **what** — which specific adverse events are driving those numbers?

A butterfly plot (also called a tornado plot or back-to-back bar chart) is a horizontal bar chart where two groups face each other from a center axis. The preferred terms (specific AE names like "Headache", "Nausea", "Dizziness") are listed vertically in the middle, and the bars extend left for one arm and right for another. You can instantly see which AEs are more common in the drug arm vs. placebo — the asymmetry tells the story.

Why this matters after Widget 2.1: you know 89% of High Dose patients had AEs, but is that because everyone got mild nausea, or because a dozen different things went wrong? If one or two PTs dominate (say "Application Site Erythema" makes up 60% of all AEs), that's a focused, manageable side effect. If it's spread across 30 different PTs, the drug is causing systemic problems.

The tricky part with 3 arms: a classic butterfly plot compares 2 groups. We have 3 (Placebo, High Dose, Low Dose). Options are to show only Placebo vs. one drug arm at a time (with a dropdown to switch), or show the top 10 PTs as a grouped horizontal bar chart with all 3 arms.

**Updated Widget 2.2 — Butterfly Plot**

- Data: `adae`
- What it does: compare AE incidence rates by preferred term across arms
- Key columns: `USUBJID`, `ARM`, `AEDECOD`, `TRTEMFL`, `SAFFL`
- Computation: for each `AEDECOD`, count unique patients per arm, divide by arm total from `adsl`, pick the top 10 most frequent PTs
- Output: horizontal bar chart via ggplot2 + plotly

![[Pasted image 20260402113338.png]]

The computation is a bit more involved than the previous widgets. The key step is counting **unique patients** per preferred term, not total events. If one patient had 5 headaches, that's still 1 patient with "Headache" — same logic as Widget 2.1 but now broken out by each specific AE name.

Since we have 3 arms, I'd suggest a grouped horizontal bar chart (all 3 arms side by side for each PT) rather than a true butterfly (which only works with 2 groups). That way you can compare Placebo, High Dose, and Low Dose in one view.

