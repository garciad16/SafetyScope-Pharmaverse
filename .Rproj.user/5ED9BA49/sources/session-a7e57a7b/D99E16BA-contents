# ==============================================================================
# SafetyScope — Tab 3: Safety Summary
# EXPLORATION SCRIPT
# ==============================================================================
# Run this top-to-bottom in RStudio before touching app.R.
# ==============================================================================

library(dplyr)
library(pharmaverseadam)

# --- Load the data ------------------------------------------------------------
adsl <- pharmaverseadam::adsl
adae <- pharmaverseadam::adae
adlb <- pharmaverseadam::adlb


# ==============================================================================
# WIDGET 3.1 — Value Boxes (key headline metrics)
# ==============================================================================

# These are the numbers a stakeholder wants at a glance.

adsl_safety <- adsl %>% filter(SAFFL == "Y")
adae_te <- adae %>% filter(SAFFL == "Y", TRTEMFL == "Y")

# Total patients in safety population
n_total <- nrow(adsl_safety)
cat("Total patients:", n_total, "\n")

# TEAE rate — % with any treatment-emergent AE
n_with_ae <- n_distinct(adae_te$USUBJID)
cat("Patients with any TEAE:", n_with_ae, "(", round(n_with_ae / n_total * 100, 1), "%)\n")

# SAE rate — % with any serious AE
n_with_sae <- adae_te %>%
  filter(AESER == "Y") %>%
  n_distinct(.$USUBJID)
cat("Patients with serious AE:", n_with_sae, "\n")

# Discontinuation rate
n_discontinued <- adsl_safety %>%
  filter(EOSSTT == "DISCONTINUED") %>%
  nrow()
cat("Discontinued:", n_discontinued, "(", round(n_discontinued / n_total * 100, 1), "%)\n")

# Deaths
n_deaths <- adae_te %>%
  filter(AESDTH == "Y") %>%
  n_distinct(.$USUBJID)
cat("Deaths:", n_deaths, "\n")

# Hy's Law cases (ALT >= 3×ULN AND Bili >= 2×ULN)
alt_peaks <- adlb %>%
  filter(SAFFL == "Y", PARAMCD == "ALT") %>%
  group_by(USUBJID) %>%
  summarise(peak_alt = max(R2ANRHI, na.rm = TRUE), .groups = "drop")

bili_peaks <- adlb %>%
  filter(SAFFL == "Y", PARAMCD == "BILI") %>%
  group_by(USUBJID) %>%
  summarise(peak_bili = max(R2ANRHI, na.rm = TRUE), .groups = "drop")

hys_cases <- alt_peaks %>%
  inner_join(bili_peaks, by = "USUBJID") %>%
  filter(peak_alt >= 3, peak_bili >= 2)

cat("Hy's Law cases:", nrow(hys_cases), "\n")


# ==============================================================================
# WIDGET 3.2 — Top 5 AEs
# ==============================================================================

# Most common preferred terms across all arms
adae_te %>%
  group_by(AEDECOD) %>%
  summarise(n = n_distinct(USUBJID)) %>%
  mutate(pct = round(n / n_total * 100, 1)) %>%
  arrange(desc(n)) %>%
  head(5)

# Same but broken out by arm
arm_totals <- adsl_safety %>% count(ARM, name = "N")

adae_te %>%
  group_by(ARM, AEDECOD) %>%
  summarise(n = n_distinct(USUBJID), .groups = "drop") %>%
  left_join(arm_totals, by = "ARM") %>%
  mutate(pct = round(n / N * 100, 1)) %>%
  group_by(AEDECOD) %>%
  mutate(total = sum(n)) %>%
  ungroup() %>%
  filter(AEDECOD %in% (
    adae_te %>%
      group_by(AEDECOD) %>%
      summarise(n = n_distinct(USUBJID)) %>%
      arrange(desc(n)) %>%
      head(5) %>%
      pull(AEDECOD)
  )) %>%
  arrange(desc(total), ARM)


# ==============================================================================
# WIDGET 3.3 — Patient Listing Table (moved from Tab 1)
# ==============================================================================

# One row per patient with key info — sortable, searchable
adsl_safety %>%
  select(USUBJID, ARM, AGE, SEX, TRTDURD, EOSSTT) %>%
  arrange(TRTDURD) %>%
  head(10)


# ==============================================================================
# NOTES
# ==============================================================================
#
#
#