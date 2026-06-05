## -----------------------------------------------------------
## 07_stats_tables.R
## Create clean stats tables (velocity + directionality) 
## Tables are saved in /tables and also copied to /figs
## -----------------------------------------------------------

source(here::here("scripts/00_packages.R"))

## ---- Ensure output folders exist ----

tables_dir <- here::here("tables")
if (!dir.exists(tables_dir)) dir.create(tables_dir)

figs_dir <- here::here("figs")
if (!dir.exists(figs_dir)) dir.create(figs_dir)

## ===========================================================
## 1. VELOCITY TABLES
## ===========================================================

## ---- Load velocity stats ----

vel_rep_means <- readr::read_rds(
  here::here("data_clean", "velocity_rep_means.rds")
)

vel_treat_summary <- readr::read_rds(
  here::here("data_clean", "velocity_treat_summary.rds")
)

vel_anova_tidy <- readr::read_rds(
  here::here("data_clean", "velocity_anova_tidy.rds")
)

vel_tukey_tidy <- readr::read_rds(
  here::here("data_clean", "velocity_tukey_tidy.rds")
)

## ---- Treatment order and label mapping ----

treat_levels <- c("CTRL", "DMSO", "MZB", "IS6", "U73122", "U73433")

vel_treat_labels <- c(
  "CTRL"   = "CTRL",
  "DMSO"   = "1% DMSO",
  "MZB"    = "100 \u03BCM MZB",
  "IS6"    = "1 mM IS6",
  "U73122" = "20 \u03BCM U73122",
  "U73433" = "20 \u03BCM U73433"
)

# Desired order of labels
vel_label_order <- unname(vel_treat_labels[treat_levels])

## ---- Velocity treatment-level summary table ----

vel_tracks_summary <- vel_rep_means %>%
  dplyr::group_by(treatment) %>%
  dplyr::summarise(
    n_rep        = dplyr::n(),
    total_tracks = sum(n_tracks),
    .groups      = "drop"
  )

message("Velocity tracks summary:")
print(vel_tracks_summary)

vel_summary_table <- vel_treat_summary %>%
  dplyr::mutate(
    treatment = factor(treatment, levels = treat_levels),
    Treatment = vel_treat_labels[as.character(treatment)],
    Mean_velocity = round(treatment_mean, 1),
    SD_velocity   = round(treatment_sd, 1),
    SEM_velocity  = round(treatment_se, 1)
  ) %>%
  dplyr::left_join(
    vel_tracks_summary %>% 
      dplyr::rename(n_rep_tracks = n_rep),   # <<< rename BEFORE join
    by = "treatment"
  ) %>%
  dplyr::select(
    Treatment,
    n_rep = n_rep_tracks,      # <<< now safe
    total_tracks,
    Mean_velocity,
    SD_velocity,
    SEM_velocity
  ) %>%
  dplyr::arrange(factor(Treatment, levels = vel_label_order))


message("\nVelocity treatment summary table:")
print(vel_summary_table)

# Save to /tables and /figs
vel_summary_file <- "velocity_treatment_summary.csv"
readr::write_csv(vel_summary_table, file.path(tables_dir, vel_summary_file))
readr::write_csv(vel_summary_table, file.path(figs_dir,   vel_summary_file))

## ---- Velocity ANOVA table ----

vel_anova_table <- vel_anova_tidy %>%
  dplyr::mutate(
    term = dplyr::recode(
      term,
      treatment = "Between groups (treatment)",
      Residuals = "Within groups (residual)"
    ),
    sumsq    = round(sumsq, 2),
    meansq   = round(meansq, 2),
    statistic = round(statistic, 2),
    p.value   = signif(p.value, 3)
  ) %>%
  dplyr::select(
    Term      = term,
    df,
    Sum_sq    = sumsq,
    Mean_sq   = meansq,
    F_value   = statistic,
    p_value   = p.value
  )

message("\nVelocity ANOVA table:")
print(vel_anova_table)

vel_anova_file <- "velocity_anova_summary.csv"
readr::write_csv(vel_anova_table, file.path(tables_dir, vel_anova_file))
readr::write_csv(vel_anova_table, file.path(figs_dir,   vel_anova_file))

## ---- Velocity Tukey tables ----

vel_tukey_table <- vel_tukey_tidy %>%
  dplyr::filter(term == "treatment") %>%
  dplyr::mutate(
    Contrast    = gsub("-", " vs ", contrast),
    Difference  = round(estimate, 1),
    Lower_95_CI = round(conf.low, 1),
    Upper_95_CI = round(conf.high, 1),
    Adjusted_p  = signif(adj.p.value, 3)
  ) %>%
  dplyr::select(
    Contrast,
    Difference,
    Lower_95_CI,
    Upper_95_CI,
    Adjusted_p
  )

message("\nVelocity Tukey all-contrasts table:")
print(vel_tukey_table)

vel_tukey_all_file <- "velocity_tukey_all_contrasts.csv"
readr::write_csv(vel_tukey_table, file.path(tables_dir, vel_tukey_all_file))
readr::write_csv(vel_tukey_table, file.path(figs_dir,   vel_tukey_all_file))

vel_tukey_vs_ctrl <- vel_tukey_table %>%
  dplyr::filter(grepl("CTRL", Contrast))

message("\nVelocity Tukey vs CTRL table:")
print(vel_tukey_vs_ctrl)

vel_tukey_ctrl_file <- "velocity_tukey_vs_CTRL.csv"
readr::write_csv(vel_tukey_vs_ctrl, file.path(tables_dir, vel_tukey_ctrl_file))
readr::write_csv(vel_tukey_vs_ctrl, file.path(figs_dir,   vel_tukey_ctrl_file))

## ===========================================================
## 2. DIRECTIONALITY TABLES
## ===========================================================

## ---- Load direction stats ----

dir_rep_means <- readr::read_rds(
  here::here("data_clean", "direction_rep_means.rds")
)

dir_treat_summary <- readr::read_rds(
  here::here("data_clean", "direction_treat_summary.rds")
)

dir_anova_tidy <- readr::read_rds(
  here::here("data_clean", "direction_anova_tidy.rds")
)

dir_tukey_tidy <- readr::read_rds(
  here::here("data_clean", "direction_tukey_tidy.rds")
)

dir_treat_labels <- vel_treat_labels
dir_label_order  <- vel_label_order


## ---- Direction tracks summary ----

dir_tracks_summary <- dir_rep_means %>%
  dplyr::group_by(treatment) %>%
  dplyr::summarise(
    n_rep        = dplyr::n(),
    total_tracks = sum(n_tracks),
    .groups      = "drop"
  )

message("\nDirection tracks summary:")
print(dir_tracks_summary)

## ---- Directionality treatment-level summary table ----

dir_summary_table <- dir_treat_summary %>%
  dplyr::mutate(
    treatment = factor(treatment, levels = treat_levels),
    Treatment = dir_treat_labels[as.character(treatment)],
    Mean_directness = round(treatment_mean, 3),
    SD_directness   = round(treatment_sd, 3),
    SEM_directness  = round(treatment_se, 3)
  ) %>%
  dplyr::left_join(
    dir_tracks_summary %>%
      dplyr::rename(n_rep_tracks = n_rep),
    by = "treatment"
  ) %>%
  dplyr::select(
    Treatment,
    n_rep = n_rep_tracks,
    total_tracks,
    Mean_directness,
    SD_directness,
    SEM_directness
  ) %>%
  dplyr::arrange(factor(Treatment, levels = dir_label_order))

message("\nDirectionality treatment summary table:")
print(dir_summary_table)

dir_summary_file <- "direction_treatment_summary.csv"
readr::write_csv(dir_summary_table, file.path(tables_dir, dir_summary_file))
readr::write_csv(dir_summary_table, file.path(figs_dir,   dir_summary_file))

## ---- Directionality ANOVA table ----

dir_anova_table <- dir_anova_tidy %>%
  dplyr::mutate(
    term = dplyr::recode(
      term,
      treatment = "Between groups (treatment)",
      Residuals = "Within groups (residual)"
    ),
    sumsq    = round(sumsq, 4),
    meansq   = round(meansq, 4),
    statistic = round(statistic, 2),
    p.value   = signif(p.value, 3)
  ) %>%
  dplyr::select(
    Term      = term,
    df,
    Sum_sq    = sumsq,
    Mean_sq   = meansq,
    F_value   = statistic,
    p_value   = p.value
  )

message("\nDirectionality ANOVA table:")
print(dir_anova_table)

dir_anova_file <- "direction_anova_summary.csv"
readr::write_csv(dir_anova_table, file.path(tables_dir, dir_anova_file))
readr::write_csv(dir_anova_table, file.path(figs_dir,   dir_anova_file))

## ---- Directionality Tukey tables ----

dir_tukey_table <- dir_tukey_tidy %>%
  dplyr::filter(term == "treatment") %>%
  dplyr::mutate(
    Contrast    = gsub("-", " vs ", contrast),
    Difference  = round(estimate, 3),
    Lower_95_CI = round(conf.low, 3),
    Upper_95_CI = round(conf.high, 3),
    Adjusted_p  = signif(adj.p.value, 3)
  ) %>%
  dplyr::select(
    Contrast,
    Difference,
    Lower_95_CI,
    Upper_95_CI,
    Adjusted_p
  )

message("\nDirectionality Tukey all-contrasts table:")
print(dir_tukey_table)

dir_tukey_all_file <- "direction_tukey_all_contrasts.csv"
readr::write_csv(dir_tukey_table, file.path(tables_dir, dir_tukey_all_file))
readr::write_csv(dir_tukey_table, file.path(figs_dir,   dir_tukey_all_file))

dir_tukey_vs_ctrl <- dir_tukey_table %>%
  dplyr::filter(grepl("CTRL", Contrast))

message("\nDirectionality Tukey vs CTRL table:")
print(dir_tukey_vs_ctrl)

dir_tukey_ctrl_file <- "direction_tukey_vs_CTRL.csv"
readr::write_csv(dir_tukey_vs_ctrl, file.path(tables_dir, dir_tukey_ctrl_file))
readr::write_csv(dir_tukey_vs_ctrl, file.path(figs_dir,   dir_tukey_ctrl_file))

