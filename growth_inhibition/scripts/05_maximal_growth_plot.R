## -----------------------------------------------------------
## 05_maximal_growth_plot.R
## -----------------------------------------------------------

source(here::here("scripts", "00_packages.R"))

## ---- 1. Load summary + Tukey results from 04_maximal_growth_stats.R ----

summary_path <- here::here("data_processed", "max_growth_summary.csv")
tukey_path   <- here::here("data_processed", "max_growth_tukey.csv")

max_growth <- readr::read_csv(summary_path, show_col_types = FALSE)

tukey_tbl  <- readr::read_csv(tukey_path, show_col_types = FALSE) %>%
  dplyr::rename(p_adj = `p adj`)   # make p_adj easier to use


## ---- 2. Set treatment order + pretty labels (match 03_growth_curves.R) ----

treat_levels <- c(
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

max_growth <- max_growth %>%
  dplyr::mutate(
    treatment = factor(treatment, levels = treat_levels),
    treatment_label = dplyr::case_when(
      treatment == "dH2O"           ~ "dH[2]*O",
      treatment == "Mancozeb_100uM" ~ "Mancozeb~100*mu*M",
      treatment == "IS6_10uM"       ~ "IS[6]~10~mu*M",
      treatment == "IS6_20uM"       ~ "IS[6]~20~mu*M",
      treatment == "IS6_50uM"       ~ "IS[6]~50~mu*M",
      treatment == "IS6_100uM"      ~ "IS[6]~100~mu*M",
      treatment == "IS6_200uM"      ~ "IS[6]~200~mu*M",
      treatment == "IS6_500uM"      ~ "IS[6]~500~mu*M",
      treatment == "IS6_1000uM"     ~ "IS[6]~1~mM",
      TRUE                          ~ NA_character_
    ),
    treatment_label = factor(
      treatment_label,
      levels = c(
        "dH[2]*O",
        "Mancozeb~100*mu*M",
        "IS[6]~10~mu*M",
        "IS[6]~20~mu*M",
        "IS[6]~50~mu*M",
        "IS[6]~100~mu*M",
        "IS[6]~200~mu*M",
        "IS[6]~500~mu*M",
        "IS[6]~1~mM"
      )
    )
  )

## ---- 3. Derive asterisks vs control (dH2O) from Tukey results ----

p_to_stars <- function(p) {
  if (is.na(p)) return("")
  if (p < 0.001) return("***")
  if (p < 0.01)  return("**")
  if (p < 0.05)  return("*")
  return("")
}

ctrl_trt <- "dH2O"

ctrl_comp_df <- purrr::map_dfr(treat_levels, function(trt) {
  if (trt == ctrl_trt) {
    tibble::tibble(treatment = trt, stars = "")
  } else {
    comp1 <- paste0(trt, "-", ctrl_trt)
    comp2 <- paste0(ctrl_trt, "-", trt)
    
    p_row <- tukey_tbl %>%
      dplyr::filter(comparison %in% c(comp1, comp2))
    
    p_val <- if (nrow(p_row) == 1) p_row$p_adj else NA_real_
    
    tibble::tibble(
      treatment = trt,
      stars     = p_to_stars(p_val)
    )
  }
}) %>%
  dplyr::mutate(
    treatment = factor(treatment, levels = treat_levels)
  )

max_growth <- max_growth %>%
  dplyr::left_join(ctrl_comp_df, by = "treatment")

## ---- 4. Y-axis scaling and annotation heights ----

# Error bars = mean ± SD
max_y_for_bars <- max(max_growth$mean_mm + max_growth$sd_mm, na.rm = TRUE)

# Fix y-axis to 0–100 so we can put n labels at y = 95
y_limit_upper <- 100
y_breaks      <- seq(0, 100, by = 10)

# Position stars just above SD
max_growth <- max_growth %>%
  dplyr::mutate(
    annot_y = mean_mm + sd_mm + 5
  )

## ---- 5. Colour palette: match 03_growth_curves.R ----

treatment_cols <- c(
  "dH[2]*O"           = "#808080",  # grey
  "Mancozeb~100*mu*M" = "#FF1F1F",  # red
  "IS[6]~10~mu*M"     = "#ff7a05",
  "IS[6]~20~mu*M"     = "#ffe033",
  "IS[6]~50~mu*M"     = "#00cc00",
  "IS[6]~100~mu*M"    = "#00e6e6",
  "IS[6]~200~mu*M"    = "#3333ff",
  "IS[6]~500~mu*M"    = "#ff80ff",
  "IS[6]~1~mM"        = "#b24dff"
)

## ---- 6. Build the plot: bars + SD + stars + n at y=95 ----

p_max <- ggplot(max_growth,
                aes(x = treatment_label,
                    y = mean_mm,
                    fill = treatment_label)) +
  # Bars: mean colony diameter
  geom_col(
    width  = 0.6,
    alpha  = 0.9,
    colour = "black"
  ) +
  # Error bars: mean ± SD
  geom_errorbar(
    aes(
      ymin = mean_mm - sd_mm,
      ymax = mean_mm + sd_mm
    ),
    width     = 0.15,
    linewidth = 0.5
  ) +
  # Stars (vs dH2O)
  geom_text(
    aes(
      y     = annot_y,
      label = stars
    ),
    size = 6
  ) +
  # n labels at y = 95 (biological n: strains)
  geom_text(
    aes(
      y     = 95,
      label = paste0("n=", n)
    ),
    size     = 4.5,
    fontface = "bold",
    vjust    = 0
  ) +
  scale_fill_manual(values = treatment_cols) +
  scale_x_discrete(labels = function(x) parse(text = x)) +
  scale_y_continuous(
    breaks = y_breaks,
    limits = c(0, y_limit_upper),
    expand = expansion(mult = c(0, 0.02))
  ) +
  theme_bw() +
  theme(
    plot.title   = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    
    axis.text.x = element_text(
      face   = "bold",
      size   = 11,
      colour = "black",
      angle  = 30,
      hjust  = 1
    ),
    axis.text.y = element_text(
      face   = "bold",
      size   = 11,
      colour = "black"
    ),
    
    legend.position = "none"
  )

print(p_max)

## ---- 7. Save plot (PNG + PDF + SVG) ----

out_dir <- here::here("figs")
if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE)

plot_width  <- 7      # inches
plot_height <- 5      # inches
plot_dpi    <- 600
transparent_bg <- FALSE

png_path <- file.path(out_dir, "maximal_growth_day12.png")
pdf_path <- file.path(out_dir, "maximal_growth_day12.pdf")
svg_path <- file.path(out_dir, "maximal_growth_day12.svg")

ggplot2::ggsave(
  filename = png_path,
  plot     = p_max,
  width    = plot_width,
  height   = plot_height,
  dpi      = plot_dpi,
  bg       = if (transparent_bg) "transparent" else "white"
)

ggplot2::ggsave(
  filename = pdf_path,
  plot     = p_max,
  width    = plot_width,
  height   = plot_height,
  dpi      = plot_dpi
)

message("Maximal growth plot saved to: ", out_dir)
