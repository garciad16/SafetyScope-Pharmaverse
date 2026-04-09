**Widget 3.1 — Value Boxes**

- Data: `adsl` + `adae` + `adlb`
- What it does: row of metric cards showing critical numbers at a glance — total patients, TEAE rate, SAE rate, discontinuation rate, deaths, Hy's Law cases
- Output: value_box() components from bslib

Widget 3.1 is a row of **value boxes** across the top — big numbers with labels that answer "is this drug safe?" in 5 seconds. Think of it like the KPI cards at the top of any business dashboard, but for drug safety.

The six metrics:

- **Total Patients** — how big is this study? (from `adsl`)
- **TEAE Rate** — what % of patients had any treatment-emergent AE? High = the drug is causing things. (from `adae`)
- **SAE Rate** — what % had serious AEs? This is the "how bad" number. (from `adae`)
- **Discontinuation Rate** — what % dropped out? Connects back to Tab 1. (from `adsl`)
- **Deaths** — the most critical safety number. (from `adae`)
- **Hy's Law Cases** — any liver danger signals? (from `adlb`)

Each box is one number, one label, one color. Green = good, red = concerning, neutral = informational. No charts, no tables — just the headline numbers.



