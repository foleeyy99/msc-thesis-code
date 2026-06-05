## -----------------------------------------------------------
## 05_direction_stats.R
## Directness (directionality) stats for ibidi exports
## -----------------------------------------------------------

source(here::here("scripts/00_packages.R"))

## ---- 1. Load cleaned direction data ----

dir_df <- readr::read_rds(
  here::here("data_clean", "ibidi_direction_stats.rds")
)

# Keep only what we need, and rename directionality -> directness for clarity
dir_df <- dir_df %>%
  dplyr::select(
    treatment,
    replicate,
    track_number,
    directness = directionality
  )

message("Preview of raw directness data:")
print(
  dir_df %>%
    dplyr::count(treatment, replicate) %>%
    dplyr::arrange(treatment, replicate)
)

## ---- 2. Per-replicate means for directness ----

dir_rep_means <- dir_df %>%
  dplyr::group_by(treatment, replicate) %>%
  dplyr::summarise(
    mean_directness = mean(directness, na.rm = TRUE),
    n_tracks        = dplyr::n(),
    sd_directness   = sd(directness, na.rm = TRUE),
    .groups         = "drop"
  )

message("\nReplicate-level directness means:")
print(dir_rep_means)

## ---- 3. Treatment-level summary (mean of replicate means) ----

dir_treat_summary <- dir_rep_means %>%
  dplyr::group_by(treatment) %>%
  dplyr::summarise(
    treatment_mean = mean(mean_directness),
    treatment_sd   = sd(mean_directness),
    n_rep          = dplyr::n(),
    treatment_se   = treatment_sd / sqrt(n_rep),
    .groups        = "drop"
  )

message("\nTreatment-level directness summary:")
print(dir_treat_summary)

## ---- 4. ANOVA on replicate means ----

dir_aov <- aov(mean_directness ~ treatment, data = dir_rep_means)

message("\nANOVA summary for directness:")
print(summary(dir_aov))

## ---- 5. Tidy ANOVA output ----

dir_anova_tidy <- broom::tidy(dir_aov)
message("\nTidy ANOVA table:")
print(dir_anova_tidy)

## ---- 6. Tukey post-hoc ----

dir_tukey <- TukeyHSD(dir_aov)

message("\nRaw TukeyHSD output:")
print(dir_tukey)

# Tidy Tukey using broom 
dir_tukey_tidy <- broom::tidy(dir_tukey)

message("\nTidy Tukey table:")
print(dir_tukey_tidy)

## ---- 7. Save outputs ----

# Replicate means
readr::write_rds(
  dir_rep_means,
  here::here("data_clean", "direction_rep_means.rds")
)
readr::write_csv(
  dir_rep_means,
  here::here("data_clean", "direction_rep_means.csv")
)

# Treatment summary
readr::write_rds(
  dir_treat_summary,
  here::here("data_clean", "direction_treat_summary.rds")
)
readr::write_csv(
  dir_treat_summary,
  here::here("data_clean", "direction_treat_summary.csv")
)

# ANOVA tidy
readr::write_rds(
  dir_anova_tidy,
  here::here("data_clean", "direction_anova_tidy.rds")
)
readr::write_csv(
  dir_anova_tidy,
  here::here("data_clean", "direction_anova_tidy.csv")
)

# Tukey tidy
readr::write_rds(
  dir_tukey_tidy,
  here::here("data_clean", "direction_tukey_tidy.rds")
)
readr::write_csv(
  dir_tukey_tidy,
  here::here("data_clean", "direction_tukey_tidy.csv")
)

message("\n05_directionality_stats.R complete.")
