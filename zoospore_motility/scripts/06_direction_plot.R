## -----------------------------------------------------------
## 06_direction_plot.R
## Directionality (directness) plot: bars + SEM + stars vs CTRL
## -----------------------------------------------------------

source(here::here("scripts/00_packages.R"))

## ---- 1. Load data prepared in 05_direction_stats.R ----

dir_rep_means <- readr::read_rds(
  here::here("data_clean", "direction_rep_means.rds")
)

dir_treat_summary <- readr::read_rds(
  here::here("data_clean", "direction_treat_summary.rds")
)

dir_tukey_tidy <- readr::read_rds(
  here::here("data_clean", "direction_tukey_tidy.rds")
)

## ---- 2. Set treatment order and x-axis labels ----

treat_levels <- c("CTRL", "DMSO", "MZB", "IS6", "U73122", "U73433")

dir_rep_means <- dir_rep_means %>%
  dplyr::mutate(
    treatment = factor(treatment, levels = treat_levels)
  )

dir_treat_summary <- dir_treat_summary %>%
  dplyr::mutate(
    treatment = factor(treatment, levels = treat_levels)
  )

# Named x-axis labels 
treat_labels <- c(
  "CTRL"   = "CTRL",
  "DMSO"   = "1% DMSO",
  "MZB"    = "100 \u03BCM MZB",   # 100 µM MZB
  "IS6"    = "1 mM IS6",          # plain text
  "U73122" = "20 \u03BCM U73122", # 20 µM U73122
  "U73433" = "20 \u03BCM U73433"  # 20 µM U73433
)

## ---- 3. Derive asterisks vs CTRL from Tukey results ----


pw <- dir_tukey_tidy %>%
  dplyr::filter(term == "treatment")

p_to_stars <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.001) return("***")
  if (p < 0.01)  return("**")
  if (p < 0.05)  return("*")
  return("")
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

dir_treat_summary <- dir_treat_summary %>%
  dplyr::left_join(ctrl_comp_df, by = "treatment")

## ---- 4. Y-axis scaling for directness (0–1) ----

# Directness is [0, 1], so use a fixed 0–1 scale with 0.1 steps
y_breaks <- seq(0, 1, by = 0.1)
y_upper  <- 1

# Star positions slightly above SD
dir_treat_summary <- dir_treat_summary %>%
  dplyr::mutate(
    annot_y = treatment_mean + treatment_sd + 0.03
  )

# Ensure annot_y doesn't go above 1 - cap at 1
dir_treat_summary <- dir_treat_summary %>%
  dplyr::mutate(
    annot_y = dplyr::if_else(annot_y > 1, 0.97, annot_y)
  )

## ---- 5. Colour palette (matching velocity, with updated U73433) ----

fill_cols <- c(
  "CTRL"   = "#1F77B4",  
  "DMSO"   = "#FF7F0E",  
  "MZB"    = "#D62728",  
  "IS6"    = "#17BECF",  
  "U73122" = "#2CA02C",  
  "U73433" = "#DEE024"  
)

## ---- 6. Build the plot: bars + SD + stars (no lines, no points) ----

p_dir <- ggplot() +
  # Bars: mean directness per treatment
  geom_col(
    data = dir_treat_summary,
    aes(x = treatment, y = treatment_mean, fill = treatment),
    width = 0.6,
    alpha = 0.9
  ) +
  # Error bars: SD of replicate means
  geom_errorbar(
    data = dir_treat_summary,
    aes(
      x = treatment,
      ymin = treatment_mean - treatment_sd,
      ymax = treatment_mean + treatment_sd
    ),
    width = 0.15,
    linewidth = 0.5
  ) +
  
  # Stars above bars (vs CTRL)
  geom_text(
    data = dir_treat_summary,
    aes(
      x = treatment,
      y = annot_y,
      label = stars
    ),
    size = 6
  ) +
  scale_fill_manual(values = fill_cols) +
  scale_x_discrete(labels = treat_labels) +
  scale_y_continuous(
    breaks = y_breaks,
    limits = c(0, y_upper),
    expand = expansion(mult = c(0, 0.02))
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


print(p_dir)

## ============================================================
## Save DIRECTIONALITY plot
## ============================================================

# Output directory
out_dir <- here::here("figs")

# Export settings — tweak here anytime
plot_width  <- 7      # inches
plot_height <- 5      # inches
plot_dpi    <- 500
transparent_bg <- FALSE

# File paths
png_path <- file.path(out_dir, "directionality_plot.png")
pdf_path <- file.path(out_dir, "directionality_plot.pdf")
svg_path <- file.path(out_dir, "directionality_plot.svg")

## ---- PNG ----
ggplot2::ggsave(
  filename = png_path,
  plot     = p_dir,
  width    = plot_width,
  height   = plot_height,
  dpi      = plot_dpi,
  bg       = if (transparent_bg) "transparent" else "white"
)

## ---- PDF ----
ggplot2::ggsave(
  filename = pdf_path,
  plot     = p_dir,
  width    = plot_width,
  height   = plot_height,
  dpi      = plot_dpi
)



message("Directionality plot saved to: ", out_dir)

