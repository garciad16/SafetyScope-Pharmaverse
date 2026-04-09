# ==============================================================================
# SafetyScope — Tab 2: Adverse Events & Lab Safety
# EXPLORATION SCRIPT
# ==============================================================================
# Run this top-to-bottom in RStudio before touching app.R.
# ==============================================================================

library(dplyr)
library(pharmaverseadam)
library(rtables)

# --- Load the data ------------------------------------------------------------
adsl <- pharmaverseadam::adsl
adae <- pharmaverseadam::adae

# What are we working with?
dim(adae)    # how many AE rows x columns?
names(adae)  # what columns exist?


# ==============================================================================
# WIDGET 2.1 — AE Summary Table
# ==============================================================================

# --- Understand the key columns -----------------------------------------------

# TRTEMFL = "Treatment Emergent Flag"
# Only count AEs that started AFTER the first dose. If a patient had a
# headache before the trial, that's not the drug's fault.
table(adae$TRTEMFL, useNA = "ifany")

# AESER = "Serious Event" (Y/N)
# Serious = death, hospitalization, disability, life-threatening
table(adae$AESER, useNA = "ifany")

# AREL = "Analysis Causality"
# Did the investigator think the drug caused this AE?
table(adae$AREL, useNA = "ifany")

# AESEV = Severity (MILD / MODERATE / SEVERE)
table(adae$AESEV, useNA = "ifany")

# AEACN = "Action Taken with Study Treatment"
# Did they reduce the dose, stop the drug, etc.?
table(adae$AEACN, useNA = "ifany")

# AESDTH = "Results in Death" (Y/N)
table(adae$AESDTH, useNA = "ifany")

# --- Filter to safety population + treatment-emergent -------------------------
adae_te <- adae %>%
  filter(SAFFL == "Y", TRTEMFL == "Y")

cat("Total AE rows:", nrow(adae), "\n")
cat("Treatment-emergent AEs in safety pop:", nrow(adae_te), "\n")

# --- Quick manual counts (sanity check before rtables) ------------------------

# How many unique patients with ANY AE per arm?
adae_te %>%
  group_by(ARM) %>%
  summarise(n_patients = n_distinct(USUBJID))

# How many unique patients with SERIOUS AEs per arm?
adae_te %>%
  filter(AESER == "Y") %>%
  group_by(ARM) %>%
  summarise(n_patients = n_distinct(USUBJID))

# Denominator — total patients per arm from adsl
adsl %>%
  filter(SAFFL == "Y") %>%
  count(ARM)

# --- Build the rtables AE summary table ---------------------------------------

# Prep: both datasets need ARM as the same factor with the same levels
adsl_f <- adsl %>%
  filter(SAFFL == "Y") %>%
  mutate(ARM = factor(ARM))

adae_f <- adae_te %>%
  mutate(ARM = factor(ARM, levels = levels(adsl_f$ARM)))

# Custom analysis function — rtables passes in the data for each arm,
# plus .N_col (patient count from alt_counts_df = adsl)
s_ae_summary <- function(df, .N_col, ...) {
  in_rows(
    "Patients with any TEAE"          = rcell(
      n_distinct(df$USUBJID) * c(1, 1 / .N_col), format = "xx (xx.x%)"
    ),
    "Serious AE"                      = rcell(
      n_distinct(df$USUBJID[df$AESER == "Y"]) * c(1, 1 / .N_col), format = "xx (xx.x%)"
    ),
    "Related AE"                      = rcell(
      n_distinct(df$USUBJID[df$AREL %in% c("POSSIBLE", "PROBABLE")]) * c(1, 1 / .N_col), format = "xx (xx.x%)"
    ),
    "Severe AE"                       = rcell(
      n_distinct(df$USUBJID[df$AESEV == "SEVERE"]) * c(1, 1 / .N_col), format = "xx (xx.x%)"
    ),
    "AE leading to discontinuation"   = rcell(
      n_distinct(df$USUBJID[df$AEACN == "DRUG WITHDRAWN"]) * c(1, 1 / .N_col), format = "xx (xx.x%)"
    ),
    "Death"                           = rcell(
      n_distinct(df$USUBJID[df$AESDTH == "Y"]) * c(1, 1 / .N_col), format = "xx (xx.x%)"
    )
  )
}

# Build the layout
lyt <- basic_table(show_colcounts = TRUE) %>%
  split_cols_by("ARM") %>%
  analyze("USUBJID", s_ae_summary)

# Build with alt_counts_df = adsl for correct denominator
tbl <- build_table(lyt, adae_f, alt_counts_df = adsl_f)
tbl


# ==============================================================================
# WIDGET 2.2 — AE Incidence by Preferred Term
# ==============================================================================

# AEDECOD = "Dictionary-Derived Term" (Preferred Term)
# This is the standardized name for each AE, e.g. "Headache", "Nausea"
# How many unique PTs are there?
length(unique(adae_te$AEDECOD))

# What are the most common ones?
adae_te %>%
  group_by(AEDECOD) %>%
  summarise(n_patients = n_distinct(USUBJID)) %>%
  arrange(desc(n_patients)) %>%
  head(15)

# Count unique patients per PT per arm
pt_by_arm <- adae_te %>%
  group_by(ARM, AEDECOD) %>%
  summarise(n = n_distinct(USUBJID), .groups = "drop")

# Get denominators from adsl
arm_totals <- adsl %>%
  filter(SAFFL == "Y") %>%
  count(ARM, name = "N")

# Join and calculate incidence rate
pt_by_arm <- pt_by_arm %>%
  left_join(arm_totals, by = "ARM") %>%
  mutate(pct = round(n / N * 100, 1))

# Pick top 10 PTs by overall frequency
top_pts <- adae_te %>%
  group_by(AEDECOD) %>%
  summarise(total = n_distinct(USUBJID)) %>%
  arrange(desc(total)) %>%
  head(10) %>%
  pull(AEDECOD)

# Filter to top 10 only
pt_by_arm %>%
  filter(AEDECOD %in% top_pts) %>%
  arrange(AEDECOD, ARM)


# ==============================================================================
# WIDGET 2.3 — Severity Heatmap
# ==============================================================================

# AESEV = severity grade: MILD, MODERATE, SEVERE
table(adae_te$AESEV, useNA = "ifany")

# How does severity break down for the top PTs?
# First get the top 10 most frequent PTs
top_pts <- adae_te %>%
  group_by(AEDECOD) %>%
  summarise(total = n_distinct(USUBJID)) %>%
  arrange(desc(total)) %>%
  head(10) %>%
  pull(AEDECOD)

# Cross-tabulate: PT × severity, counting unique patients
adae_te %>%
  filter(AEDECOD %in% top_pts) %>%
  group_by(AEDECOD, AESEV) %>%
  summarise(n = n_distinct(USUBJID)) %>%
  arrange(AEDECOD, AESEV)

# Check: is PRURITUS mostly mild or severe?
adae_te %>%
  filter(AEDECOD == "PRURITUS") %>%
  count(AESEV)


# ==============================================================================
# WIDGET 2.4 — Hy's Law Plot
# ==============================================================================

# Load lab data
adlb <- pharmaverseadam::adlb

dim(adlb)
names(adlb)

# What lab tests (PARAMCDs) are available?
unique(adlb$PARAMCD)

# Do we have ALT and BILI?
"ALT" %in% unique(adlb$PARAMCD)
"BILI" %in% unique(adlb$PARAMCD)

# R2ANRHI = ratio of result to upper limit of normal
# If ALT upper limit is 40 and patient's value is 120, R2ANRHI = 3.0
summary(adlb$R2ANRHI)

# ONTRTFL = on-treatment flag (only labs drawn while patient was on drug)
table(adlb$ONTRTFL, useNA = "ifany")

# Get peak ALT per patient (max R2ANRHI while on treatment)
alt_peaks <- adlb %>%
  filter(SAFFL == "Y", PARAMCD == "ALT") %>%
  group_by(USUBJID, ARM) %>%
  summarise(peak_alt = max(R2ANRHI, na.rm = TRUE), .groups = "drop")

head(alt_peaks)

# Get peak bilirubin per patient
bili_peaks <- adlb %>%
  filter(SAFFL == "Y", PARAMCD == "BILI") %>%
  group_by(USUBJID) %>%
  summarise(peak_bili = max(R2ANRHI, na.rm = TRUE), .groups = "drop")

head(bili_peaks)

# Join them — each patient becomes one point
hys_data <- alt_peaks %>%
  inner_join(bili_peaks, by = "USUBJID")

head(hys_data)

# Any patients in the danger zone? (ALT >= 3 AND Bili >= 2)
hys_data %>% filter(peak_alt >= 3, peak_bili >= 2)


# ==============================================================================
# WIDGET 2.5 — Lab Shift Plot
# ==============================================================================

# What analytes are available?
adlb %>%
  filter(SAFFL == "Y") %>%
  distinct(PARAMCD, PARAM) %>%
  arrange(PARAMCD)

# ABLFL = baseline flag ("Y" = this is the baseline measurement)
table(adlb$ABLFL, useNA = "ifany")

# BASE = baseline value (carried forward on every row for that patient+analyte)
# AVAL = the actual result at each visit
# ANRHI = upper limit of normal

# Example: look at ALT shift data
alt_shift <- adlb %>%
  filter(SAFFL == "Y", PARAMCD == "ALT", !is.na(BASE), !is.na(AVAL)) %>%
  group_by(USUBJID, ARM) %>%
  summarise(
    baseline = first(BASE),
    worst    = max(AVAL, na.rm = TRUE),
    anrhi    = first(ANRHI),
    .groups  = "drop"
  )

head(alt_shift)

# How many patients worsened (worst > baseline)?
alt_shift %>%
  mutate(worsened = worst > baseline) %>%
  count(ARM, worsened)

# How many crossed from normal to abnormal?
alt_shift %>%
  mutate(new_abnormal = baseline <= anrhi & worst > anrhi) %>%
  count(ARM, new_abnormal)


# ==============================================================================
# WIDGET 2.5 — AE & Lab Correlation
# ==============================================================================

# Question: do patients with the most common AEs also have abnormal labs?
# This joins adae and adlb on USUBJID.

# ANRIND = reference range indicator (NORMAL, HIGH, LOW)
table(adlb$ANRIND, useNA = "ifany")

# Get patients with top 5 most frequent AEs
top5 <- adae_te %>%
  group_by(AEDECOD) %>%
  summarise(n = n_distinct(USUBJID)) %>%
  arrange(desc(n)) %>%
  head(5) %>%
  pull(AEDECOD)

top5

# Patients with each of those AEs
ae_patients <- adae_te %>%
  filter(AEDECOD %in% top5) %>%
  distinct(AEDECOD, USUBJID)

# Patients with ANY abnormal lab during the study
lab_abnormals <- adlb %>%
  filter(SAFFL == "Y", ANRIND %in% c("HIGH", "LOW")) %>%
  distinct(USUBJID)

cat("Patients with abnormal labs:", nrow(lab_abnormals), "\n")

# Join: for each top AE, how many of those patients also had abnormal labs?
ae_patients %>%
  mutate(has_abnormal_lab = USUBJID %in% lab_abnormals$USUBJID) %>%
  group_by(AEDECOD) %>%
  summarise(
    total    = n(),
    with_lab = sum(has_abnormal_lab),
    pct      = round(with_lab / total * 100, 1)
  ) %>%
  arrange(desc(total))


# ==============================================================================
# NOTES
# ==============================================================================
#
#
#