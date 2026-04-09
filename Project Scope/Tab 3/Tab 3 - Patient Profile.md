### Tab 3 — Safety Summary

_Is this drug safe? Give me the headline._

**Widget 3.1 — Value Boxes**

- Data: `adsl` + `adae` + `adlb`
- What it does: row of metric cards showing critical numbers at a glance — total patients, TEAE rate, SAE rate, discontinuation rate, deaths, Hy's Law cases
- Output: value_box() components from bslib

**Widget 3.2 — Top 5 AEs**

- Data: `adae`
- What it does: small table showing the 5 most frequent preferred terms with incidence % per arm
- Key columns: `USUBJID`, `ARM`, `AEDECOD`
- Output: reactable table

**Widget 3.3 — Patient Listing Table**

- Data: `adsl`
- What it does: one row per patient — ID, arm, age, sex, days on treatment, status. Sortable and searchable. Moved from Tab 1.
- Key columns: `USUBJID`, `ARM`, `AGE`, `SEX`, `TRTDURD`, `EOSSTT`
- Output: interactive table via reactable