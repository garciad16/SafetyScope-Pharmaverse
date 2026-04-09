# ==============================================================================
# SafetyScope — Tab 1: Population & Exposure
# EXPLORATION SCRIPT
# ==============================================================================
# Run this top-to-bottom in RStudio before touching app.R.
# Goal: understand the data, see what's in it, test things out.
# ==============================================================================

library(dplyr)
library(pharmaverseadam)

# --- Load the data ------------------------------------------------------------
# adsl = one row per patient (demographics, treatment arm, status)
adsl <- pharmaverseadam::adsl

# What are we working with?
dim(adsl)       # how many patients x how many columns?
names(adsl)     # what columns exist?


# ==============================================================================
# WIDGET 1.1 — Sex & Race Distribution by Treatment Arm
# ==============================================================================

# SAFFL = "Safety Population Flag"
# In clinical trials, not every enrolled patient gets analyzed.
# SAFFL == "Y" means "this patient received at least one dose of study drug"
# and is therefore included in safety analyses. We ALWAYS filter on this.
table(adsl$SAFFL)

# ARM = which treatment group the patient was assigned to
table(adsl$ARM)

# AGE — used as a filter in the dashboard, not displayed
summary(adsl$AGE)

# SEX and RACE — these are what we're charting
table(adsl$SEX)
table(adsl$RACE)

# Apply the safety filter and keep only what we need
adsl_safety <- adsl %>%
  filter(SAFFL == "Y") %>%
  select(USUBJID, ARM, AGE, SEX, RACE)

# Quick check: how many patients per arm?
adsl_safety %>% count(ARM)

# Sex by arm
adsl_safety %>% count(ARM, SEX)

# Race by arm
adsl_safety %>% count(ARM, RACE)

# The full breakdown — this is the data behind the bar chart
# Each bar = one sex within one arm, stacked by race
adsl_safety %>% count(ARM, SEX, RACE)


# ==============================================================================
# WIDGET 1.2 — Disposition Chart
# ==============================================================================

# EOSSTT = "End of Study Status"
# Tells you if the patient completed the study, discontinued, or is ongoing.
table(adsl$EOSSTT)

# How many completed vs discontinued per arm?
adsl %>%
  filter(SAFFL == "Y") %>%
  count(ARM, EOSSTT)


# ==============================================================================
# WIDGET 1.3 — Exposure Box Plot
# ==============================================================================

# TRTDURD = "Total Treatment Duration (Days)"
# Already computed in adsl — no need to calculate it ourselves.
summary(adsl$TRTDURD)

# Duration by arm
adsl %>%
  filter(SAFFL == "Y") %>%
  group_by(ARM) %>%
  summarise(
    median_days = median(TRTDURD, na.rm = TRUE),
    min_days    = min(TRTDURD, na.rm = TRUE),
    max_days    = max(TRTDURD, na.rm = TRUE)
  )


# ==============================================================================
# NOTES
# ==============================================================================
#
#
#