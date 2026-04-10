# ==============================================================================
# SafetyScope — Early-Phase Clinical Trial Safety Review Dashboard
# ==============================================================================
#
# EDA Scripts (run these first to explore the data):
#   eda_tab1.R  — adsl  (Population & Exposure)
#   eda_tab2.R  — adae + adlb  (Adverse Events & Lab Safety)
#   eda_tab3.R  — all datasets (Patient Profile)
#
# Tab 1 — Population & Exposure
#   1.1  Sex & Race Distribution   → eda_tab1.R, WIDGET 1.1
#   1.2  Patient Disposition       → eda_tab1.R, WIDGET 1.2
#   1.3  Treatment Duration        → eda_tab1.R, WIDGET 1.3
#
# Tab 2 — Adverse Events & Lab Safety
#   2.1  AE Summary Table          → eda_tab2.R, WIDGET 2.1
#   2.2  AE Incidence by PT        → eda_tab2.R, WIDGET 2.2
#   2.3  Severity Heatmap          → eda_tab2.R, WIDGET 2.3
#   2.4  Hy's Law Plot             → eda_tab2.R, WIDGET 2.4
#   2.5  AE & Lab Correlation      → eda_tab2.R, WIDGET 2.5
#
# Tab 3 — Safety Summary
#   3.1  Safety Scorecard          → eda_tab3.R, WIDGET 3.1
#   3.2  Key Findings              → eda_tab3.R, WIDGET 3.3
#
# ==============================================================================

library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(plotly)
library(reactable)
library(rtables)
library(pharmaverseadam)

# --- Data prep ----------------------------------------------------------------

# Shorten arm labels for cleaner plots
shorten_arm <- function(x) {
  dplyr::case_match(x,
                    "Xanomeline High Dose" ~ "High Dose",
                    "Xanomeline Low Dose"  ~ "Low Dose",
                    .default = x
  )
}

# Tab 1: adsl only
adsl_safety <- pharmaverseadam::adsl %>%
  filter(SAFFL == "Y") %>%
  mutate(ARM = shorten_arm(ARM)) %>%
  select(USUBJID, ARM, AGE, SEX, RACE, EOSSTT, TRTDURD)

# Tab 2: adae (treatment-emergent, safety pop) + adsl for denominator
adae_te <- pharmaverseadam::adae %>%
  filter(SAFFL == "Y", TRTEMFL == "Y") %>%
  mutate(ARM = shorten_arm(ARM))

adsl_denom <- pharmaverseadam::adsl %>%
  filter(SAFFL == "Y") %>%
  mutate(ARM = factor(shorten_arm(ARM)))

# Tab 2: adlb (lab data, safety pop)
adlb <- pharmaverseadam::adlb %>%
  filter(SAFFL == "Y") %>%
  mutate(ARM = shorten_arm(ARM))

# --- UI -----------------------------------------------------------------------
ui <- page_navbar(
  title = tags$span("SafetyScope",
                    tags$small(" | Xanomeline Safety Review", style = "font-weight: 300;")
  ),
  theme = bs_theme(
    version    = 5,
    preset     = "shiny",
    font_scale = 0.9
  ),
  fillable = FALSE,
  
  sidebar = sidebar(
    title = "Filters",
    checkboxGroupInput(
      "selected_arms", "Treatment Arms",
      choices  = sort(unique(adsl_safety$ARM)),
      selected = sort(unique(adsl_safety$ARM))
    ),
    sliderInput(
      "age_range", "Age Range",
      min   = min(adsl_safety$AGE),
      max   = max(adsl_safety$AGE),
      value = c(min(adsl_safety$AGE), max(adsl_safety$AGE))
    ),
    hr(),
    textOutput("patient_count")
  ),
  
  # ============================================================================
  # TAB 1 — Population & Exposure
  # ============================================================================
  nav_panel("Population & Exposure", class = "bslib-page-dashboard",
            layout_columns(
              col_widths = c(6, 6),
              card(
                card_header("Sex & Race Distribution"),
                plotlyOutput("demo_chart", height = "280px")
              ),
              card(
                card_header("Patient Disposition"),
                plotlyOutput("disposition_chart", height = "280px")
              )
            ),
            card(
              card_header("Treatment Duration by Arm"),
              plotlyOutput("exposure_boxplot", height = "280px")
            )
  ),
  
  # ============================================================================
  # TAB 2 — Adverse Events & Lab Safety
  # ============================================================================
  nav_panel("Adverse Events & Lab Safety",
            navset_card_tab(
              # --- Sub-tab: Adverse Events ---
              nav_panel("Adverse Events", class = "bslib-page-dashboard",
                        card(
                          card_header("AE Summary"),
                          uiOutput("ae_summary_table")
                        ),
                        layout_columns(
                          col_widths = c(6, 6),
                          card(
                            card_header("AE by Preferred Term"),
                            plotlyOutput("butterfly_plot", height = "400px"),
                            sliderInput("top_n_pts", "Number of terms to show",
                                        min = 5, max = 25, value = 10, step = 1)
                          ),
                          card(
                            card_header("Severity Heatmap"),
                            plotlyOutput("severity_heatmap", height = "400px"),
                            sliderInput("top_n_heatmap", "Number of terms to show",
                                        min = 5, max = 25, value = 10, step = 1)
                          )
                        )
              ),
              # --- Sub-tab: Lab Safety ---
              nav_panel("Lab Safety", class = "bslib-page-dashboard",
                        layout_columns(
                          col_widths = c(6, 6),
                          card(
                            card_header("Hy's Law Plot"),
                            plotlyOutput("hys_law_plot", height = "350px")
                          ),
                          card(
                            card_header("AE & Lab Correlation"),
                            card_body(
                              tags$p(tags$small(
                                "For each AE: how many patients also had lab results above normal?",
                                "ALT/AST/BILI = Liver, CREAT = Kidney, HGB = Blood."
                              )),
                              reactableOutput("ae_lab_corr")
                            )
                          )
                        )
              )
            )
  ),
  
  # ============================================================================
  # TAB 3 — Safety Summary
  # ============================================================================
  nav_panel("Safety Summary", class = "bslib-page-dashboard",
            uiOutput("safety_scorecard"),
            uiOutput("key_findings")
  )
)

# --- Server -------------------------------------------------------------------
server <- function(input, output, session) {
  
  # === Shared reactive: filtered by arm + age =================================
  filtered_adsl <- reactive({
    req(input$selected_arms)
    adsl_safety %>%
      filter(ARM %in% input$selected_arms,
             AGE >= input$age_range[1],
             AGE <= input$age_range[2])
  })
  
  output$patient_count <- renderText({
    paste0("Showing ", nrow(filtered_adsl()), " patients")
  })
  
  # === TAB 1 WIDGETS ==========================================================
  
  # --- Widget 1.1: Sex & Race Distribution ------------------------------------
  output$demo_chart <- renderPlotly({
    plot_data <- filtered_adsl() %>%
      count(ARM, SEX, RACE)
    
    p <- ggplot(plot_data, aes(x = SEX, y = n, fill = RACE)) +
      geom_col() +
      facet_wrap(~ARM) +
      scale_fill_manual(values = c(
        "WHITE"                            = "#7A8B99",
        "BLACK OR AFRICAN AMERICAN"        = "#9B8EA6",
        "AMERICAN INDIAN OR ALASKA NATIVE" = "#8A9A82"
      )) +
      scale_x_discrete(labels = c("F" = "Female", "M" = "Male")) +
      labs(x = "Sex", y = "Count", fill = "Race") +
      theme_minimal()
    
    ggplotly(p) %>% layout(hoverlabel = list(bgcolor = "white"))
  })
  
  # --- Widget 1.2: Disposition Chart ------------------------------------------
  output$disposition_chart <- renderPlotly({
    plot_data <- filtered_adsl() %>%
      count(ARM, EOSSTT)
    
    p <- ggplot(plot_data, aes(x = ARM, y = n, fill = EOSSTT)) +
      geom_col(position = "dodge") +
      scale_fill_manual(values = c(
        "COMPLETED"    = "#5B8C85",
        "DISCONTINUED" = "#C25B5B"
      )) +
      labs(x = NULL, y = "Count", fill = "Status") +
      theme_minimal()
    
    ggplotly(p) %>% layout(hoverlabel = list(bgcolor = "white"))
  })
  
  # --- Widget 1.3: Exposure Box Plot ------------------------------------------
  output$exposure_boxplot <- renderPlotly({
    p <- ggplot(filtered_adsl(), aes(x = ARM, y = TRTDURD, fill = ARM)) +
      geom_boxplot() +
      scale_fill_manual(values = c(
        "Placebo"              = "#7A8B99",
        "High Dose" = "#5B8C85",
        "Low Dose"  = "#8A9A82"
      )) +
      labs(x = NULL, y = "Days on Treatment") +
      guides(fill = "none") +
      theme_minimal()
    
    ggplotly(p) %>% layout(hoverlabel = list(bgcolor = "white"))
  })
  
  # === TAB 2 WIDGETS ==========================================================
  
  # --- Widget 2.1: AE Summary Table (rtables) ---------------------------------
  output$ae_summary_table <- renderUI({
    # Get filtered patient IDs
    patient_ids <- filtered_adsl()$USUBJID
    
    # Filter adae + adsl to match sidebar filters
    adae_f <- adae_te %>%
      filter(USUBJID %in% patient_ids) %>%
      mutate(ARM = factor(ARM, levels = levels(adsl_denom$ARM)))
    
    adsl_f <- adsl_denom %>%
      filter(USUBJID %in% patient_ids)
    
    # Custom analysis function: for each ARM column, count unique patients
    # .N_col comes from alt_counts_df (adsl) — the correct denominator
    s_ae_summary <- function(df, .N_col, ...) {
      in_rows(
        "Patients with any TEAE"          = rcell(
          n_distinct(df$USUBJID) * c(1, 1 / .N_col),
          format = "xx (xx.x%)"
        ),
        "Serious AE"                      = rcell(
          n_distinct(df$USUBJID[df$AESER == "Y"]) * c(1, 1 / .N_col),
          format = "xx (xx.x%)"
        ),
        "Related AE"                      = rcell(
          n_distinct(df$USUBJID[df$AREL %in% c("POSSIBLE", "PROBABLE")]) * c(1, 1 / .N_col),
          format = "xx (xx.x%)"
        ),
        "Severe AE"                       = rcell(
          n_distinct(df$USUBJID[df$AESEV == "SEVERE"]) * c(1, 1 / .N_col),
          format = "xx (xx.x%)"
        ),
        "AE leading to discontinuation"   = rcell(
          n_distinct(df$USUBJID[df$AEACN == "DRUG WITHDRAWN"]) * c(1, 1 / .N_col),
          format = "xx (xx.x%)"
        ),
        "Death"                           = rcell(
          n_distinct(df$USUBJID[df$AESDTH == "Y"]) * c(1, 1 / .N_col),
          format = "xx (xx.x%)"
        )
      )
    }
    
    # Build rtables layout
    lyt <- basic_table(show_colcounts = TRUE) %>%
      split_cols_by("ARM") %>%
      analyze("USUBJID", s_ae_summary)
    
    # Build table with adsl as denominator source
    tbl <- build_table(lyt, adae_f, alt_counts_df = adsl_f)
    
    # Convert to HTML for Shiny display
    HTML(toString(as_html(tbl)))
  })
  
  # --- Widget 2.2: AE by Preferred Term (Butterfly Plot) -----------------------
  output$butterfly_plot <- renderPlotly({
    patient_ids <- filtered_adsl()$USUBJID
    
    # Count unique patients per PT per arm
    pt_data <- adae_te %>%
      filter(USUBJID %in% patient_ids) %>%
      group_by(ARM, AEDECOD) %>%
      summarise(n = n_distinct(USUBJID), .groups = "drop")
    
    # Get denominators
    arm_totals <- adsl_denom %>%
      filter(USUBJID %in% patient_ids) %>%
      count(ARM, name = "N")
    
    # Calculate incidence %
    pt_data <- pt_data %>%
      left_join(arm_totals, by = "ARM") %>%
      mutate(pct = n / N * 100)
    
    # Pick top N PTs by overall frequency (slider controls N)
    top_pts <- adae_te %>%
      filter(USUBJID %in% patient_ids) %>%
      group_by(AEDECOD) %>%
      summarise(total = n_distinct(USUBJID)) %>%
      arrange(desc(total)) %>%
      head(input$top_n_pts) %>%
      pull(AEDECOD)
    
    plot_data <- pt_data %>%
      filter(AEDECOD %in% top_pts) %>%
      mutate(
        AEDECOD = factor(AEDECOD, levels = rev(top_pts)),
        pct = round(pct, 1),
        tooltip = paste0(AEDECOD, "\n", ARM, "\nIncidence: ", pct, "%")
      )
    
    p <- ggplot(plot_data, aes(x = AEDECOD, y = pct, fill = ARM, text = tooltip)) +
      geom_col(position = "dodge") +
      coord_flip() +
      scale_fill_manual(values = c(
        "Placebo"               = "#7A8B99",
        "High Dose"  = "#5B8C85",
        "Low Dose"   = "#8A9A82"
      )) +
      labs(x = NULL, y = "Incidence (%)", fill = "Arm") +
      theme_minimal()
    
    ggplotly(p, tooltip = "text") %>% layout(hoverlabel = list(bgcolor = "white"))
  })
  
  # --- Widget 2.3: Severity Heatmap --------------------------------------------
  output$severity_heatmap <- renderPlotly({
    patient_ids <- filtered_adsl()$USUBJID
    
    ae_filtered <- adae_te %>%
      filter(USUBJID %in% patient_ids)
    
    # Get top N PTs by overall frequency
    top_pts <- ae_filtered %>%
      group_by(AEDECOD) %>%
      summarise(total = n_distinct(USUBJID)) %>%
      arrange(desc(total)) %>%
      head(input$top_n_heatmap) %>%
      pull(AEDECOD)
    
    # Cross-tabulate PT × severity, counting unique patients
    heat_data <- ae_filtered %>%
      filter(AEDECOD %in% top_pts) %>%
      group_by(AEDECOD, AESEV) %>%
      summarise(n = n_distinct(USUBJID), .groups = "drop") %>%
      mutate(
        AEDECOD = factor(AEDECOD, levels = rev(top_pts)),
        AESEV = factor(AESEV, levels = c("MILD", "MODERATE", "SEVERE")),
        tooltip = paste0(AEDECOD, "\n", AESEV, "\nPatients: ", n)
      )
    
    p <- ggplot(heat_data, aes(x = AESEV, y = AEDECOD, fill = AESEV, text = tooltip)) +
      geom_tile(color = "white", linewidth = 0.5) +
      geom_text(aes(label = n), size = 3.5) +
      scale_fill_manual(values = c(
        "MILD"     = "#F0EFEB",
        "MODERATE" = "#D4A0A0",
        "SEVERE"   = "#C25B5B"
      )) +
      labs(x = "Severity", y = NULL, fill = "Severity") +
      theme_minimal()
    
    ggplotly(p, tooltip = "text") %>% layout(hoverlabel = list(bgcolor = "white"))
  })
  
  # --- Widget 2.4: Hy's Law Plot -----------------------------------------------
  output$hys_law_plot <- renderPlotly({
    patient_ids <- filtered_adsl()$USUBJID
    
    # Peak ALT per patient (as multiple of upper limit of normal)
    alt_peaks <- adlb %>%
      filter(USUBJID %in% patient_ids, PARAMCD == "ALT") %>%
      group_by(USUBJID, ARM) %>%
      summarise(peak_alt = max(R2ANRHI, na.rm = TRUE), .groups = "drop")
    
    # Peak bilirubin per patient
    bili_peaks <- adlb %>%
      filter(USUBJID %in% patient_ids, PARAMCD == "BILI") %>%
      group_by(USUBJID) %>%
      summarise(peak_bili = max(R2ANRHI, na.rm = TRUE), .groups = "drop")
    
    # Join: one point per patient
    hys_data <- alt_peaks %>%
      inner_join(bili_peaks, by = "USUBJID") %>%
      mutate(tooltip = paste0("Patient: ", USUBJID,
                              "\nARM: ", ARM,
                              "\nALT: ", round(peak_alt, 1), "×ULN",
                              "\nBili: ", round(peak_bili, 1), "×ULN"))
    
    p <- ggplot(hys_data, aes(x = peak_alt, y = peak_bili, color = ARM, text = tooltip)) +
      # Danger zone shading (ALT >= 3 AND Bili >= 2)
      annotate("rect", xmin = 3, xmax = Inf, ymin = 2, ymax = Inf,
               fill = "#C25B5B", alpha = 0.15) +
      # Reference lines
      geom_vline(xintercept = 3, linetype = "dashed", color = "#999") +
      geom_hline(yintercept = 2, linetype = "dashed", color = "#999") +
      # Patient dots
      geom_point(size = 3, alpha = 0.7) +
      scale_color_manual(values = c(
        "Placebo"               = "#7A8B99",
        "High Dose"  = "#5B8C85",
        "Low Dose"   = "#8A9A82"
      )) +
      labs(x = "Peak ALT (×ULN)", y = "Peak Bilirubin (×ULN)", color = "Arm") +
      theme_minimal()
    
    ggplotly(p, tooltip = "text") %>% layout(hoverlabel = list(bgcolor = "white"))
  })
  
  # --- Widget 2.5: AE & Lab Correlation ---------------------------------------
  output$ae_lab_corr <- renderReactable({
    patient_ids <- filtered_adsl()$USUBJID
    
    ae_filtered <- adae_te %>%
      filter(USUBJID %in% patient_ids)
    
    # Get top 10 PTs with patient counts
    top10 <- ae_filtered %>%
      group_by(AEDECOD) %>%
      summarise(total = n_distinct(USUBJID), .groups = "drop") %>%
      arrange(desc(total)) %>%
      head(10)
    
    # Patients per PT
    ae_patients <- ae_filtered %>%
      filter(AEDECOD %in% top10$AEDECOD) %>%
      distinct(AEDECOD, USUBJID)
    
    # Key analytes — patients with HIGH values
    key_labs <- c("ALT", "AST", "BILI", "CREAT", "HGB")
    
    lab_highs <- adlb %>%
      filter(USUBJID %in% patient_ids,
             PARAMCD %in% key_labs,
             ANRIND == "HIGH") %>%
      distinct(USUBJID, PARAMCD)
    
    # For each PT × analyte, count patients with both
    corr_wide <- top10 %>%
      rename(`Preferred Term` = AEDECOD, `Patients with AE` = total)
    
    for (lab in key_labs) {
      lab_pts <- lab_highs %>% filter(PARAMCD == lab) %>% pull(USUBJID)
      corr_wide[[lab]] <- sapply(corr_wide$`Preferred Term`, function(pt) {
        pt_patients <- ae_patients %>% filter(AEDECOD == pt) %>% pull(USUBJID)
        n_both <- sum(pt_patients %in% lab_pts)
        n_total <- length(pt_patients)
        pct <- if (n_total > 0) round(n_both / n_total * 100, 1) else 0
        paste0(n_both, "/", n_total, " (", pct, "%)")
      })
    }
    
    reactable(
      corr_wide,
      compact  = TRUE,
      columns = list(
        `Preferred Term`   = colDef(minWidth = 160, align = "center"),
        `Patients with AE` = colDef(name = "n", minWidth = 40, align = "center"),
        ALT   = colDef(minWidth = 80, align = "center"),
        AST   = colDef(minWidth = 80, align = "center"),
        BILI  = colDef(minWidth = 80, align = "center"),
        CREAT = colDef(minWidth = 80, align = "center"),
        HGB   = colDef(minWidth = 80, align = "center")
      ),
      striped   = TRUE,
      highlight = TRUE,
      sortable  = TRUE
    )
  })
  
  # === TAB 3 WIDGETS ==========================================================
  
  # --- Widget 3.1: Safety Scorecard ---------------------------------------------
  output$safety_scorecard <- renderUI({
    data <- filtered_adsl()
    patient_ids <- data$USUBJID
    n_total <- nrow(data)
    placebo <- data %>% filter(ARM == "Placebo")
    drug    <- data %>% filter(ARM != "Placebo")
    ae_all  <- adae_te %>% filter(USUBJID %in% patient_ids)
    
    # Metrics
    disc_drug_pct    <- round(sum(drug$EOSSTT == "DISCONTINUED", na.rm = TRUE) / nrow(drug) * 100, 1)
    disc_placebo_pct <- round(sum(placebo$EOSSTT == "DISCONTINUED", na.rm = TRUE) / nrow(placebo) * 100, 1)
    med_dur_drug     <- median(drug$TRTDURD, na.rm = TRUE)
    med_dur_placebo  <- median(placebo$TRTDURD, na.rm = TRUE)
    teae_drug_pct    <- round(n_distinct(ae_all$USUBJID[ae_all$ARM != "Placebo"]) / nrow(drug) * 100, 1)
    teae_placebo_pct <- round(n_distinct(ae_all$USUBJID[ae_all$ARM == "Placebo"]) / nrow(placebo) * 100, 1)
    n_sae    <- ae_all %>% filter(AESER == "Y") %>% n_distinct(.$USUBJID)
    n_deaths <- ae_all %>% filter(AESDTH == "Y") %>% n_distinct(.$USUBJID)
    top_ae   <- ae_all %>% group_by(AEDECOD) %>% summarise(n = n_distinct(USUBJID), .groups = "drop") %>% arrange(desc(n)) %>% head(1)
    top_ae_pct <- round(top_ae$n / n_total * 100, 1)
    
    n_hys <- adlb %>% filter(USUBJID %in% patient_ids, PARAMCD == "ALT") %>%
      group_by(USUBJID) %>% summarise(alt = max(R2ANRHI, na.rm = TRUE), .groups = "drop") %>%
      inner_join(
        adlb %>% filter(USUBJID %in% patient_ids, PARAMCD == "BILI") %>%
          group_by(USUBJID) %>% summarise(bili = max(R2ANRHI, na.rm = TRUE), .groups = "drop"),
        by = "USUBJID"
      ) %>% filter(alt >= 3, bili >= 2) %>% nrow()
    
    tagList(
      tags$h4(paste0("Safety Profile Overview — ", n_total, " patients in safety population")),
      tags$hr(),
      
      layout_columns(col_widths = c(4, 4, 4),
                     card(
                       card_header("Population & Retention"),
                       tags$p(
                         tags$strong(paste0(disc_drug_pct, "%")), " drug-arm discontinued vs. ",
                         tags$strong(paste0(disc_placebo_pct, "%")), " placebo"
                       ),
                       tags$p(
                         "Median days on treatment:", tags$br(),
                         tags$strong(paste0("Drug: ", med_dur_drug, " days")),
                         " vs ",
                         tags$strong(paste0("Placebo: ", med_dur_placebo, " days"))
                       )
                     ),
                     card(
                       card_header("Adverse Events"),
                       tags$p(
                         "TEAE rate: ", tags$strong(paste0(teae_drug_pct, "%")),
                         " drug vs. ", tags$strong(paste0(teae_placebo_pct, "%")), " placebo"
                       ),
                       tags$p(
                         "Most common: ", tags$strong(top_ae$AEDECOD), paste0(" (", top_ae_pct, "%)"), tags$br(),
                         "Serious AEs: ", tags$strong(paste0(n_sae, " patients")), tags$br(),
                         "Deaths: ", tags$strong(n_deaths)
                       )
                     ),
                     card(
                       card_header("Lab Safety"),
                       tags$p("Hy's Law cases: ", tags$strong(n_hys)),
                       tags$p(
                         if (n_hys == 0) "No liver failure signal detected."
                         else "Concurrent ALT and bilirubin elevation. Investigate immediately."
                       )
                     )
      )
    )
  })
  
  # --- Widget 3.3: Key Findings ------------------------------------------------
  output$key_findings <- renderUI({
    data <- filtered_adsl()
    patient_ids <- data$USUBJID
    n_total <- nrow(data)
    ae_filtered <- adae_te %>% filter(USUBJID %in% patient_ids)
    
    placebo_data <- data %>% filter(ARM == "Placebo")
    drug_data    <- data %>% filter(ARM != "Placebo")
    
    teae_drug    <- round(n_distinct(ae_filtered$USUBJID[ae_filtered$USUBJID %in% drug_data$USUBJID]) / nrow(drug_data) * 100, 1)
    teae_placebo <- round(n_distinct(ae_filtered$USUBJID[ae_filtered$USUBJID %in% placebo_data$USUBJID]) / nrow(placebo_data) * 100, 1)
    disc_drug    <- round(sum(drug_data$EOSSTT == "DISCONTINUED", na.rm = TRUE) / nrow(drug_data) * 100, 1)
    disc_placebo <- round(sum(placebo_data$EOSSTT == "DISCONTINUED", na.rm = TRUE) / nrow(placebo_data) * 100, 1)
    
    top_ae <- ae_filtered %>%
      group_by(AEDECOD) %>% summarise(n = n_distinct(USUBJID), .groups = "drop") %>%
      arrange(desc(n)) %>% head(3)
    
    n_sae    <- ae_filtered %>% filter(AESER == "Y") %>% n_distinct(.$USUBJID)
    n_deaths <- ae_filtered %>% filter(AESDTH == "Y") %>% n_distinct(.$USUBJID)
    med_drug    <- median(drug_data$TRTDURD, na.rm = TRUE)
    med_placebo <- median(placebo_data$TRTDURD, na.rm = TRUE)
    dur_diff    <- med_placebo - med_drug
    
    n_hys <- adlb %>% filter(USUBJID %in% patient_ids, PARAMCD == "ALT") %>%
      group_by(USUBJID) %>% summarise(alt = max(R2ANRHI, na.rm = TRUE), .groups = "drop") %>%
      inner_join(
        adlb %>% filter(USUBJID %in% patient_ids, PARAMCD == "BILI") %>%
          group_by(USUBJID) %>% summarise(bili = max(R2ANRHI, na.rm = TRUE), .groups = "drop"),
        by = "USUBJID"
      ) %>% filter(alt >= 3, bili >= 2) %>% nrow()
    
    card(
      card_header("Key Findings"),
      tags$ul(
        tags$li(paste0(
          "Drug arms had a ", teae_drug, "% TEAE rate vs. ", teae_placebo,
          "% for placebo — a ", round(teae_drug - teae_placebo, 1),
          " percentage point increase."
        )),
        tags$li(paste0(
          "The three most common AEs were ",
          top_ae$AEDECOD[1], " (", round(top_ae$n[1] / n_total * 100, 1), "%), ",
          top_ae$AEDECOD[2], " (", round(top_ae$n[2] / n_total * 100, 1), "%), and ",
          top_ae$AEDECOD[3], " (", round(top_ae$n[3] / n_total * 100, 1),
          "%) — all skin/application site related."
        )),
        tags$li(paste0(
          "Serious AEs were rare: ", n_sae, " patient(s) across all arms. ",
          n_deaths, " death(s) reported."
        )),
        tags$li(paste0(
          "Drug-arm patients discontinued at ", disc_drug, "% vs. ", disc_placebo,
          "% for placebo. Median time on treatment was ", dur_diff,
          " days shorter in the drug arms."
        )),
        tags$li(
          if (n_hys == 0) {
            "No Hy's Law cases detected — no liver failure signal."
          } else {
            paste0(n_hys, " Hy's Law case(s) detected. Further investigation recommended.")
          }
        )
      )
    )
  })
  
}

shinyApp(ui, server)