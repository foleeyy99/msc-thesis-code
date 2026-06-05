## -----------------------------------------------------------
## 03_velocity_stats.R
## Replicate-level mean velocities + ANOVA + Tukey (no plotting)
## -----------------------------------------------------------

source(here::here("scripts/00_packages.R"))

## ---- 1. Load cleaned velocity data ----

vel_path <- here::here("data_clean", "ibidi_velocity_stats.rds")

if (!file.exists(vel_path)) {
  stop("Cannot find ibidi_velocity_stats.rds at: ", vel_path)
}

ibidi_velocity_stats <- readr::read_rds(vel_path)

message("Columns in ibidi_velocity_stats:")
print(names(ibidi_velocity_stats))


## ---- 2. Rename velocity column to correct units ----
## Original: velocity_m_sec  (but actually µm/s)
## New: velocity_um_s

if (!"velocity_m_sec" %in% names(ibidi_velocity_stats)) {
  stop("Expected column 'velocity_m_sec' not found. Check names().")
}

ibidi_velocity_stats <- ibidi_velocity_stats %>%
  dplyr::rename(velocity_um_s = velocity_m_sec)


## ---- 3. Compute replicate-level mean velocities ----

vel_rep_means <- ibidi_velocity_stats %>%
  dplyr::group_by(treatment, replicate) %>%
  dplyr::summarise(
    mean_velocity = mean(velocity_um_s, na.rm = TRUE),
    n_tracks      = dplyr::n(),
    sd_velocity   = sd(velocity_um_s, na.rm = TRUE),
    .groups       = "drop"
  )

message("\nReplicate-level means:")
print(vel_rep_means)

# Save replicate means
readr::write_rds(
  vel_rep_means,
  here::here("data_clean", "velocity_rep_means.rds")
)

readr::write_csv(
  vel_rep_means,
  here::here("data_clean", "velocity_rep_means.csv")
)


## ---- 4. Treatment-level summary (mean ± SD across replicates) ----

vel_treat_summary <- vel_rep_means %>%
  dplyr::group_by(treatment) %>%
  dplyr::summarise(
    treatment_mean = mean(mean_velocity),
    treatment_sd   = sd(mean_velocity),
    n_rep          = dplyr::n(),
    treatment_se   = treatment_sd / sqrt(n_rep),
    .groups        = "drop"
  )

message("\nTreatment-level summary:")
print(vel_treat_summary)

# Save treatment summary for plotting later
readr::write_rds(
  vel_treat_summary,
  here::here("data_clean", "velocity_treat_summary.rds")
)

readr::write_csv(
  vel_treat_summary,
  here::here("data_clean", "velocity_treat_summary.csv")
)


## ---- 5. One-way ANOVA on replicate means ----

vel_aov <- aov(mean_velocity ~ treatment, data = vel_rep_means)

message("\nANOVA summary:")
print(summary(vel_aov))

vel_tukey <- TukeyHSD(vel_aov)

message("\nTukey HSD:")
print(vel_tukey)

# Save tidy ANOVA results
vel_aov_tidy   <- broom::tidy(vel_aov)
vel_tukey_tidy <- broom::tidy(vel_tukey)

readr::write_rds(
  vel_aov_tidy,
  here::here("data_clean", "velocity_anova_tidy.rds")
)

readr::write_csv(
  vel_aov_tidy,
  here::here("data_clean", "velocity_anova_tidy.csv")
)

readr::write_rds(
  vel_tukey_tidy,
  here::here("data_clean", "velocity_tukey_tidy.rds")
)

readr::write_csv(
  vel_tukey_tidy,
  here::here("data_clean", "velocity_tukey_tidy.csv")
)

message("\n03_velocity_stats.R complete (no plots).")
