## -----------------------------------------------------------
## 04_velocity_plots.R
## Velocity plot: bars + SD + asterisks vs CTRL + small segments
## -----------------------------------------------------------

source(here::here("scripts/00_packages.R"))

# Load data prepared in 03_velocity_stats.R
vel_rep_means <- readr::read_rds(
  here::here("data_clean", "velocity_rep_means.rds")
)

vel_treat_summary <- readr::read_rds(
  here::here("data_clean", "velocity_treat_summary.rds")
)

vel_tukey_tidy <- readr::read_rds(
  here::here("data_clean", "velocity_tukey_tidy.rds")
)

## ---- 1. Set treatment order and x-axis labels ----

treat_levels <- c("CTRL", "DMSO", "MZB", "IS6", "U73122", "U73433")

vel_rep_means <- vel_rep_means %>%
  dplyr::mutate(
    treatment = factor(treatment, levels = treat_levels)
  )

vel_treat_summary <- vel_treat_summary %>%
  dplyr::mutate(
    treatment = factor(treatment, levels = treat_levels)
  )

# Named labels 
treat_labels <- c(
  "CTRL"   = "CTRL",
  "DMSO"   = "1% DMSO",
  "MZB"    = "100 \u03BCM MZB",   # 100 µM MZB
  "IS6"    = "1 mM IS6",          # Plain text, no subscript
  "U73122" = "20 \u03BCM U73122", # 20 µM U73122
  "U73433" = "20 \u03BCM U73433"  # 20 µM U73433
)

## ---- 2. Derive asterisks vs CTRL from Tukey results ----

pw <- vel_tukey_tidy %>%
  dplyr::filter(term == "treatment")

p_to_stars <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.001) return("***")
  if (p < 0.01)  return("**")
  if (p < 0.05)  return("*")
  return("")  # ns
}

ctrl_comp_df <- purrr::map_dfr(treat_levels, function(trt) {
  if (trt == "CTRL") {
    return(tibble::tibble(treatment = trt, stars = ""))
  } else {
    contrast_name <- paste0(trt, "-CTRL")
    p_row <- pw %>% dplyr::filter(contrast == contrast_name)
    
    p_val <- if (nrow(p_row) == 1) p_row$adj.p.value else NA_real_
    tibble::tibble(
      treatment = trt,
      stars = p_to_stars(p_val)
    )
  }
}) %>%
  dplyr::mutate(
    treatment = factor(treatment, levels = treat_levels)
  )

vel_treat_summary <- vel_treat_summary %>%
  dplyr::left_join(ctrl_comp_df, by = "treatment")



## ---- 3. Y-axis scaling: 25 µm/s ticks + minimal padding ----

max_y_for_bars <- max(vel_treat_summary$treatment_mean + vel_treat_summary$treatment_sd)
y_upper <- ceiling(max_y_for_bars / 25) * 25
y_breaks <- seq(0, y_upper, by = 25)

vel_treat_summary <- vel_treat_summary %>%
  dplyr::mutate(
    annot_y = treatment_mean + treatment_sd + 10
  )

y_limit_upper <- max(vel_treat_summary$annot_y, na.rm = TRUE) + 4

# Annotation height for stars and segments (above errorbar)
vel_treat_summary <- vel_treat_summary %>%
  dplyr::mutate(
    annot_y = treatment_mean + treatment_se + 10  # offset above SD
  )

# Overall upper limit: just enough to fit the highest star
max_annot_y <- max(vel_treat_summary$annot_y, na.rm = TRUE)
y_limit_upper <- max(y_upper, ceiling(max_annot_y / 5) * 5) + 2

## ---- 4. Colour palette  ----

fill_cols <- c(
  "CTRL"   = "#1F77B4",  
  "DMSO"   = "#FF7F0E",  
  "MZB"    = "#D62728",  
  "IS6"    = "#17BECF",  
  "U73122" = "#2CA02C",  
  "U73433" = "#DEE024"  
)

## ---- 5. Build the plot: bars + SD + stars only ----

p_vel <- ggplot() +
  # Bars: treatment means
  geom_col(
    data = vel_treat_summary,
    aes(x = treatment, y = treatment_mean, fill = treatment),
    width = 0.6,
    alpha = 0.9
  ) +
  # Error bars: SD (already computed in vel_treat_summary)
  geom_errorbar(
    data = vel_treat_summary,
    aes(
      x = treatment,
      ymin = treatment_mean - treatment_sd,
      ymax = treatment_mean + treatment_sd
    ),
    width = 0.15,
    linewidth = 0.5
  ) +
  
  # Stars only, no segments
  geom_text(
    data = vel_treat_summary,
    aes(
      x = treatment,
      y = treatment_mean + treatment_sd + 8,
      label = stars
    ),
    size = 6
  ) +
  
  
  
  scale_fill_manual(values = fill_cols) +
  scale_x_discrete(labels = treat_labels) +
  scale_y_continuous(
    breaks = y_breaks,
    limits = c(0, y_upper),
    expand = expansion(mult = c(0, 0.02))  # minimal padding at bottom/top
  ) +
  
  
  theme_bw() +
  theme(
    plot.title   = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    
    # ---- UPDATED styling ----
    axis.text.x = element_text(
      face = "bold",
      size = 11,
      colour = "black",
      angle = 30,
      hjust = 1
    ),
    axis.text.y = element_text(
      face = "bold",
      size = 11,
      colour = "black"
    ),
    
    legend.position = "none"
  )


print(p_vel)




## ============================================================
## Save VELOCITY plot
## ============================================================

# Output directory
out_dir <- here::here("figs")

# Export settings 
plot_width  <- 7      # inches
plot_height <- 5      # inches
plot_dpi    <- 600
transparent_bg <- FALSE  # TRUE if you want transparent background

# File paths
png_path <- file.path(out_dir, "velocity_plot.png")
pdf_path <- file.path(out_dir, "velocity_plot.pdf")
svg_path <- file.path(out_dir, "velocity_plot.svg")

## ---- PNG ----
ggplot2::ggsave(
  filename = png_path,
  plot     = p_vel,
  width    = plot_width,
  height   = plot_height,
  dpi      = plot_dpi,
  bg       = if (transparent_bg) "transparent" else "white"
)

## ---- PDF ----
ggplot2::ggsave(
  filename = pdf_path,
  plot     = p_vel,
  width    = plot_width,
  height   = plot_height,
  dpi      = plot_dpi
)


message("Velocity plot saved to: ", out_dir)


