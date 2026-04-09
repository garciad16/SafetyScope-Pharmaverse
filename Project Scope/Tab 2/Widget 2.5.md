**Widget 2.5 — AE & Lab Correlation**

- Data: `adae` + `adlb` (joined on USUBJID)
- What it does: for the top 10 most common AEs, shows how many of those patients also had high values for specific lab analytes (ALT, AST, BILI for liver; CREAT for kidney; HGB for blood). Answers "are the symptoms patients feel linked to organ-level damage?"
- Key columns: `USUBJID`, `AEDECOD` (from adae), `PARAMCD`, `ANRIND` (from adlb)
- Filters: shared sidebar (ARM, AGE)
- Format: "n/total" where n = patients with both the AE and high lab, total = patients with that AE
- Output: reactable table with descriptive subtitle
- Key finding: lab abnormalities are mild (10-20%) and evenly spread — no specific organ is disproportionately hit. BILI is consistently low across all AEs (good — no liver failure signal). HGB is nearly zero (drug isn't affecting blood). The drug causes skin irritation but appears not systemically toxic.

![[Pasted image 20260407150818.png]]

**What the table tells you:**

**The drug is mostly a skin problem, not an organ problem.** Look at the numbers — the highest lab abnormality rates are around 10-20%, and they're fairly consistent across all AEs. There's no AE where liver labs suddenly spike to 50%. That's reassuring.

**Liver (ALT, AST, BILI):** Pruritus has 11/54 with high ALT and 11/54 with high AST — about 20%. But BILI is only 3/54 (5.6%). Remember from Hy's Law: it's the _combination_ of high ALT + high BILI that's dangerous. Having slightly high ALT alone is liver stress, not liver failure. The low BILI numbers across the board are good news.

**Kidney (CREAT):** 10/54 pruritus patients (18.5%) had high creatinine. That's worth noting — it could mean the drug is mildly stressing the kidneys, or it could just be that elderly patients commonly have slightly elevated creatinine. You'd need to compare this to the Placebo rate to know if it's drug-related.

**Blood (HGB):** Almost all zeros. The drug isn't affecting blood cell production. Good.

**The key insight:** the top AEs are all skin-related (pruritus, erythema, rash, application site reactions) and the lab abnormalities are mild and spread evenly — no specific organ is being disproportionately hit. This suggests the drug causes local skin irritation but isn't systemically toxic. That's the kind of conclusion a safety reviewer would draw from this table.