**Widget 1.2 — Patient Disposition by Arm**

- Data: `adsl`
- What it does: answers "did they finish it?" — grouped bar chart showing completed vs. discontinued per treatment arm. In this dataset, more Xanomeline patients discontinued than completed (vs. Placebo where most completed), which is a signal worth investigating in Tab 2.
- Key columns: `ARM`, `EOSSTT` (values: COMPLETED, DISCONTINUED)
- Filters: shared sidebar (ARM checkboxes, AGE slider)
- Output: grouped bar chart via ggplot2 + plotly

Think of it this way: Widget 1.1 answers _"who is in the study?"_ — Widget 1.2 answers _"did they finish it?"_

In a clinical trial, not every patient who starts will finish. Some complete the full course of treatment as planned. Others drop out early — maybe the drug made them sick, maybe they moved, maybe they withdrew consent, maybe they died. The column `EOSSTT` (End of Study Status) captures this for each patient.

The typical values you'll see are:

- **Completed** — patient finished the study as planned
- **Discontinued** — patient left the study early for some reason
- **Ongoing** — patient is still in the study (if data was cut before the study ended) ***** NOT EXISTING IN THIS DATA SET

Why this matters in early-phase trials: if one treatment arm has way more discontinuations than placebo, that's a red flag. It might mean the drug is causing side effects bad enough that patients can't tolerate it. And that directly connects to Widget 2.1 later (the AE summary table) where you'd investigate _what_ those side effects were.

The optional enhancement I mentioned — cross-referencing `adae` where `AEACN == "DRUG WITHDRAWN"` — would let you break discontinuations into "discontinued due to AE" vs. "discontinued for other reasons." But let's keep it simple for now and just use `EOSSTT` from `adsl`.

Let me visualize the workflow.

![[Pasted image 20260401150704.png|517]]

The pipeline is almost identical to Widget 1.1 — same dataset, same filters, just swapping `SEX`/`RACE` for `EOSSTT`. The computation is literally one line: `count(ARM, EOSSTT)`.

