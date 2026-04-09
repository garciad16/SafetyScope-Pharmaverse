**Widget 1.3 — Exposure Box Plot** Data: `adsl`. Show distribution of how long patients stayed on drug, per arm. Key column: `TRTDURD`. Output: box plot.

Widget 1.1 answers "who is in the study?", Widget 1.2 answers "did they finish it?", and Widget 1.3 answers **"how long were they actually on the drug?"**

This is important because in Widget 1.2 you just saw that more Xanomeline patients discontinued than completed. But that raises a follow-up question: _how early did they drop off?_ Did they last 150 days before quitting, or did they bail after 2 weeks? That's a very different story clinically.

The column `TRTDURD` in `adsl` gives you this — it's the total treatment duration in days, already pre-computed for each patient. One number per patient.

A box plot is the right visualization here because it shows you the full distribution at a glance: the median (where most patients land), the interquartile range (where the middle 50% fall), and the whiskers/outliers (the extremes). You get one box per treatment arm, so you can immediately compare.

What to look for when you see the chart:

- **If the Xanomeline boxes are shorter and lower than Placebo** — patients on the drug stayed on treatment for less time, which aligns with the higher discontinuation rate you saw in Widget 1.2
- **If there are outliers at the low end of the drug arms** — some patients dropped off very early, possibly due to intolerable side effects
- **If the boxes are similar across arms** — treatment duration isn't different, meaning discontinuations happened at similar timepoints regardless of arm

This widget uses the exact same `filtered_adsl()` reactive as 1.1 and 1.2 — same data, same filters, just looking at `TRTDURD` instead of `SEX`/`RACE` or `EOSSTT`.

![[Pasted image 20260401152621.png|317]]
This is the simplest pipeline of all four Tab 1 widgets. You don't even need a `count()` or `group_by()` — you just hand the raw filtered data to ggplot and `geom_boxplot()` does everything: it calculates the median, quartiles, whiskers, and outlier points per arm automatically.

Here's how the three widgets tell a story together:

- **Widget 1.1** — the study has roughly equal-sized arms with similar demographics
- **Widget 1.2** — but wait, the drug arms have way more discontinuations than placebo
- **Widget 1.3** — and those drug arm patients stayed on treatment for fewer days

That's the narrative arc of Tab 1. By the time you get to Tab 2, the viewer is already thinking "ok something is going wrong in the drug arms — show me the adverse events."

The code:

A few things to note about this one:

- **No `count()` or `group_by()`** — the raw filtered data goes straight into ggplot. `geom_boxplot()` computes the median, quartiles, whiskers, and outliers on its own.
- **`guides(fill = "none")`** — hides the legend since the arm names are already on the x-axis. No need to show the same info twice.
- **Each arm gets its own color** — slate for Placebo, teal for High Dose, sage for Low Dose. Muted like the other charts.
![[Pasted image 20260401153343.png]]

This is the Placebo arm's box plot. Reading from the tooltip:

- **Median: 182 days** — the typical Placebo patient stayed on treatment for about 6 months. Half the patients lasted longer, half lasted shorter.
- **Q1: 133 days** — the bottom 25% of patients lasted 133 days or less (~4.5 months)
- **Q3: 183 days** — 75% of patients lasted 183 days or less. Notice Q3 and the median are almost identical (183 vs 182), which means a large chunk of patients clustered right around the 6-month mark — probably the planned study duration.
- **Upper fence: 210 days** — the longest any Placebo patient stayed
- **Max: 210 days** — same as the fence, meaning no outliers on the high end

The black dots at the bottom are **outliers** — patients who dropped off much earlier than everyone else. Those are worth investigating individually in Tab 3 later.

The big takeaway for Placebo: most patients made it to the end (~180 days), with a tight cluster near the top. That's what a healthy control arm looks like.


![[Pasted image 20260401154202.png]]


Big difference. Compare them side by side:

![[Pasted image 20260401154242.png]]

The median dropped from 182 to **76 days** — the typical high-dose patient lasted less than half as long as the typical Placebo patient. That's a dramatic difference.

The Q1 tells an even sharper story: 25% of high-dose patients were gone by **day 36** — barely a month in. Compare that to Placebo's Q1 of 133 days.

But notice Q3 is similar (182 vs 183). That means the patients who _did_ tolerate the drug lasted about as long as Placebo. So you've got a split population: some patients couldn't handle it and dropped early, while others were fine and stayed the full course.

That huge box (from 36 to 182) compared to Placebo's tight box (133 to 183) visually shows this spread. The drug works for some but is intolerable for others — which is exactly the kind of finding that makes early-phase safety review critical.

This connects directly to what you'll build in Tab 2: _what adverse events were those early dropouts experiencing?

![[Pasted image 20260401154639.png]]

![[Pasted image 20260401154721.png]]

The Low Dose is almost identical to High Dose — median of 81 vs. 76 days, Q1 of 33 vs. 36 days. That's surprising. You'd normally expect the lower dose to be better tolerated, meaning patients stick around longer. But here, both dose levels are dropping patients at roughly the same rate.

The same split-population pattern shows up again: Q1 is around 33 days (early dropouts), but Q3 is 182 days (patients who stayed the full course). So regardless of dose, about half the patients on Xanomeline can't tolerate it past 2-3 months.

Key takeaways from Widget 1.3:

- **Both drug arms lose patients much faster than Placebo** — median ~80 days vs. 182 days
- **Dose doesn't seem to matter** — Low Dose isn't meaningfully better than High Dose for retention
- **The drug is either tolerable or it isn't** — patients cluster at either end, not in the middle

All of this feeds the question Tab 2 will answer: what AEs are driving those early discontinuations, and are they the same across both dose levels?