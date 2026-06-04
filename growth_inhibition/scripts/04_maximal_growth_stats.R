## -----------------------------------------------------------
## 04_maximal_growth_stats.R
## -----------------------------------------------------------

source(here::here("scripts", "00_packages.R"))

## ---- 1) Load data ----

diam <- readr::read_csv(
  here::here("data_processed", "diam_analysis.csv"),
  show_col_types = FALSE
)

## ---- 2) Filter to Day 12 ----

diam_day12 <- diam %>%
  dplyr::filter(time_days == 12)

## ---- 3) Create treatment factor ----

diam_day12 <- diam_day12 %>%
  dplyr::mutate(
    treatment = dplyr::case_when(
      compound == "CTRL" ~ "dH2O",
      compound == "mzb"  ~ "Mancozeb_100uM",
      TRUE               ~ paste0("IS6_", conc_uM, "uM")
    ),
    treatment = factor(
      treatment,
      levels = c(
        "dH2O",
        "Mancozeb_100uM",
        "IS6_10uM",
        "IS6_20uM",
        "IS6_50uM",
        "IS6_100uM",
        "IS6_200uM",
        "IS6_500uM",
        "IS6_1000uM"
      )
    )
  )

## ---- 4) Prepare analysis dataset ----

stats_df <- diam_day12 %>%
  dplyr::select(strain, treatment, avg_mm) %>%
  dplyr::filter(!is.na(avg_mm))

## ---- 5) ONE-WAY ANOVA ----

aov_fit <- aov(avg_mm ~ treatment, data = stats_df)

anova_tbl <- summary(aov_fit)[[1]] %>%
  as.data.frame() %>%
  tibble::rownames_to_column("term")

## ---- 6) Tukey HSD ----

tukey_tbl <- TukeyHSD(aov_fit, "treatment")$treatment %>%
  as.data.frame() %>%
  tibble::rownames_to_column("comparison")

## ---- 7) Summary table ----

summary_df <- stats_df %>%
  dplyr::group_by(treatment) %>%
  dplyr::summarise(
    n        = dplyr::n(),
    mean_mm  = mean(avg_mm),
    sd_mm    = sd(avg_mm),
    se_mm    = sd_mm / sqrt(n),
    t_crit   = qt(0.975, df = n - 1),
    ci95_lo  = mean_mm - t_crit * se_mm,
    ci95_hi  = mean_mm + t_crit * se_mm,
    .groups  = "drop"
  )

## ---- 8) Save results ----

out_dir <- here::here("data_processed")
if (!dir.exists(out_dir)) dir.create(out_dir)

readr::write_csv(anova_tbl,   file.path(out_dir, "max_growth_anova.csv"))
readr::write_csv(tukey_tbl,   file.path(out_dir, "max_growth_tukey.csv"))
readr::write_csv(summary_df,  file.path(out_dir, "max_growth_summary.csv"))

message("Corrected ANOVA/Tukey saved.")
