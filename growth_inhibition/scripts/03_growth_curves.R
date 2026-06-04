## 03_growth_curves.R
## Plot growth curves and related figures from processed diameters data

# Load packages
source("scripts/00_packages.R")

# ---- 1) Load processed data ----

diam_clean_path    <- here::here("data_processed", "diam_clean.csv")
diam_analysis_path <- here::here("data_processed", "diam_analysis.csv")

diam_clean    <- readr::read_csv(diam_clean_path, show_col_types = FALSE)
diam_analysis <- readr::read_csv(diam_analysis_path, show_col_types = FALSE)

# Quick sanity checks
glimpse(diam_analysis)
dplyr::count(diam_analysis, compound)
dplyr::count(diam_analysis, compound, conc_uM)

# ---- 2) Create treatment labels for plotting ----

diam_analysis <- diam_analysis %>%
  mutate(
    treatment_label = case_when(
      compound == "CTRL" ~ "dH[2]*O",
      compound == "mzb"  ~ "Mancozeb~100*mu*M",
      compound == "IS6" & conc_uM == 1000 ~ "IS[6]~1~mM",
      compound == "IS6" ~ paste0("IS[6]~", conc_uM, "~mu*M")
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
    ),
    # ordered strains with correct labels
    strain = factor(
      strain,
      levels = c("2930", "MYA", "NL"),
      labels = c("2930", "MYA 4127", "NL 07454")
    )
  )

# ---- 3) Plot, font & export settings ----

font_sizes <- list(
  title      = 20,
  subtitle   = 16,
  axis_text  = 12,
  axis_title = 16,
  strip      = 13,
  legend     = 12
)

plot_settings <- list(
  base_size       = 12,
  x_limits        = c(0, 12),
  x_major_breaks  = c(0, 4, 8, 12),
  x_minor_breaks  = 0:12,
  y_limits        = c(0, 90),
  y_major_breaks  = seq(0, 90, by = 10),
  y_minor_breaks  = seq(0, 90, by = 5)
)

export_settings <- list(
  width  = 260,   
  height = 220,  
  units  = "mm",
  dpi    = 600    
)

# Manual colour palette for treatments
treatment_cols <- c(
  "dH[2]*O"           = "#808080",  
  "Mancozeb~100*mu*M" = "#FF1F1F",  
  "IS[6]~10~mu*M"     = "#ff7a05",  
  "IS[6]~20~mu*M"     = "#ffe033",  
  "IS[6]~50~mu*M"     = "#00cc00",  
  "IS[6]~100~mu*M"    = "#00e6e6",  
  "IS[6]~200~mu*M"    = "#3333ff",  
  "IS[6]~500~mu*M"    = "#ff80ff",  
  "IS[6]~1~mM"        = "#b24dff"   
)

# ---- 4) Growth curves: colony diameter vs time, by strain & treatment ----

growth_curves_all <- diam_analysis %>%
  ggplot(aes(
    x = time_days,
    y = avg_mm,
    colour = treatment_label,
    group  = treatment_label
  )) +
  geom_line(linewidth = 0.7) +
  geom_point(size = 2) +
  
  # stack strains vertically
  facet_wrap(~ strain, ncol = 1) +
  
  # x axis: 
  scale_x_continuous(
    limits       = plot_settings$x_limits,
    breaks       = plot_settings$x_major_breaks,
    minor_breaks = setdiff(plot_settings$x_minor_breaks,
                           plot_settings$x_major_breaks),
    expand       = c(0.02, 0.02)
  ) +
  
  # y axis: 
  scale_y_continuous(
    limits       = plot_settings$y_limits,
    breaks       = plot_settings$y_major_breaks,
    minor_breaks = setdiff(plot_settings$y_minor_breaks,
                           plot_settings$y_major_breaks),
    expand       = expansion(mult = c(0.02, 0.05))  # lift traces off baseline
  ) +
  
  # manual colour scale so legend & traces always match
  scale_colour_manual(
    name   = "Treatments",
    values = treatment_cols,
    labels = function(x) parse(text = x),
    guide  = guide_legend(
      nrow           = 2,        # 2 rows to reduce width
      byrow          = TRUE,
      title.position = "top",
      title.hjust    = 0.5
    )
  ) +
  labs(
    x = "Time (days)",
    y = "Colony Diameter (mm)",
    colour = "Treatments",
    title = bquote(bold(bolditalic("P. infestans") ~ "Colony Growth Over Time in 3 Individual Isolates")),
    subtitle = expression(dH[2]*O ~ "Control, Mancozeb (100" * mu * "M) and IS"[6] * " Treatments")
  ) +
  theme_minimal(base_size = plot_settings$base_size) +
  theme(
    
    # axis titles (bold + adjustable size)
    axis.title.x = element_text(face = "bold", size = font_sizes$axis_title),
    axis.title.y = element_text(face = "bold", size = font_sizes$axis_title),
    
    # axis tick labels
    axis.text.x  = element_text(size = font_sizes$axis_text),
    axis.text.y  = element_text(size = font_sizes$axis_text),
    
    # title + subtitle
    plot.title    = element_text(size = font_sizes$title),
    plot.subtitle = element_text(size = font_sizes$subtitle, margin = margin(b = 8)),
    
    # facet strip labels
    strip.text = element_text(face = "bold", size = font_sizes$strip),
    strip.background = element_rect(fill = "grey90", colour = NA),
    
    # grid: keep both major + minor for x and y
    panel.grid.major.x = element_line(linewidth = 0.4),
    panel.grid.minor.x = element_line(linewidth = 0.2),
    panel.grid.major.y = element_line(linewidth = 0.4),
    panel.grid.minor.y = element_line(linewidth = 0.2, linetype = "dotted"),
    
    # spacing between panels
    panel.spacing = grid::unit(0.6, "lines"),
    
    # legend formatting
    legend.position = "bottom",
    legend.direction = "horizontal",
    legend.box       = "horizontal",
    legend.justification = c(0.5, 0),
    legend.box.just      = "center",
    legend.title = element_text(
      face  = "bold",
      size  = font_sizes$legend,
      hjust = 0.5,
      margin = margin(b = 4)
    ),
    legend.text = element_text(size = font_sizes$legend - 1),
    legend.key.width = grid::unit(1.1, "lines"),
    legend.background = element_rect(
      fill   = "grey95",
      colour = "grey70",
      linewidth = 0.5
    ),
    legend.box.margin = margin(t = 5, r = 10, b = 5, l = 10),
    
    # overall plot margins (extra at bottom for legend)
    plot.margin = margin(t = 5, r = 10, b = 30, l = 10)
  )

growth_curves_all

# ---- 6) Export figure(s) ----

# Make sure figs folder exists
dir.create(here::here("figs"), showWarnings = FALSE)

# Export 1: full figure with titles, legend, axis titles
ggplot2::ggsave(
  filename = "growth_curves_by_strain.png",
  plot     = growth_curves_all,
  path     = here::here("figs"),
  width    = export_settings$width,
  height   = export_settings$height,
  units    = export_settings$units,
  dpi      = export_settings$dpi
)

# ---- 7) Clean PowerPoint-friendly version (no title / subtitle / legend / axis titles) ----

clean_for_pp <- theme(
  plot.title    = element_blank(),
  plot.subtitle = element_blank(),
  axis.title.x  = element_blank(),
  axis.title.y  = element_blank(),
  legend.position = "none",
  legend.title = element_blank(),
  legend.text  = element_blank(),
  plot.margin  = margin(t = 5, r = 5, b = 5, l = 5)
)

growth_curves_all_clean <- growth_curves_all + clean_for_pp

ggplot2::ggsave(
  filename = "growth_curves_by_strain_clean.png",
  plot     = growth_curves_all_clean,
  path     = here::here("figs"),
  width    = export_settings$width,
  height   = export_settings$height,
  units    = export_settings$units,
  dpi      = export_settings$dpi
)
