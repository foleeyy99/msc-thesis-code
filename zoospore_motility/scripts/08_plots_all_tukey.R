## -----------------------------------------------------------
## 08_plots_all_tukey.R
## Supplementary plots showing all Tukey HSD pairwise comparisons
## Velocity + directionality/directness
##
## Output:
##   figs/velocity_plot_all_tukey.png
##   figs/velocity_plot_all_tukey.pdf
##   figs/directionality_plot_all_tukey.png
##   figs/directionality_plot_all_tukey.pdf
##
##   tables/velocity_all_tukey_plot_brackets.csv
##   tables/directionality_all_tukey_plot_brackets.csv
## -----------------------------------------------------------

source(here::here("scripts/00_packages.R"))

## -----------------------------------------------------------
## 1. Output folders
## -----------------------------------------------------------

figs_dir <- here::here("figs")
if (!dir.exists(figs_dir)) dir.create(figs_dir, recursive = TRUE)

tables_dir <- here::here("tables")
if (!dir.exists(tables_dir)) dir.create(tables_dir, recursive = TRUE)

## -----------------------------------------------------------
## 2. Shared treatment order, labels, colours
## -----------------------------------------------------------

treat_levels <- c("CTRL", "DMSO", "MZB", "IS6", "U73122", "U73433")

treat_labels <- c(
  "CTRL"   = "CTRL",
  "DMSO"   = "1% DMSO",
  "MZB"    = "100 \u03BCM MZB",
  "IS6"    = "1 mM IS6",
  "U73122" = "20 \u03BCM U73122",
  "U73433" = "20 \u03BCM U73433"
)

fill_cols <- c(
  "CTRL"   = "#1F77B4",
  "DMSO"   = "#FF7F0E",
  "MZB"    = "#D62728",
  "IS6"    = "#17BECF",
  "U73122" = "#2CA02C",
  "U73433" = "#DEE024"
)

## -----------------------------------------------------------
## 3. Plot tuning parameters
## -----------------------------------------------------------

bracket_label_size <- 4.6
bracket_line_size  <- 0.6
bracket_tip_length <- 0.005

plot_width  <- 7
plot_height <- 8
plot_dpi    <- 600

## -----------------------------------------------------------
## 4. Helper functions
## -----------------------------------------------------------

check_treatment_names <- function(df, treat_levels, object_name) {
  
  observed <- sort(unique(as.character(df$treatment)))
  unexpected <- setdiff(observed, treat_levels)
  missing <- setdiff(treat_levels, observed)
  
  message("\nTreatments found in ", object_name, ":")
  print(observed)
  
  if (length(unexpected) > 0) {
    stop(
      "Unexpected treatment name(s) in ", object_name, ": ",
      paste(unexpected, collapse = ", "),
      "\nExpected only: ",
      paste(treat_levels, collapse = ", ")
    )
  }
  
  if (length(missing) > 0) {
    stop(
      "Missing expected treatment name(s) in ", object_name, ": ",
      paste(missing, collapse = ", ")
    )
  }
}

p_to_stars <- function(p) {
  dplyr::case_when(
    is.na(p)   ~ "",
    p < 0.001 ~ "***",
    p < 0.01  ~ "**",
    p < 0.05  ~ "*",
    TRUE      ~ "ns"
  )
}

format_adj_p <- function(p) {
  dplyr::case_when(
    is.na(p)   ~ "p = NA",
    p < 0.001 ~ "p < 0.001",
    TRUE      ~ paste0("p = ", formatC(p, format = "f", digits = 3))
  )
}

make_all_tukey_brackets <- function(tukey_tbl,
                                    treat_levels,
                                    y_start,
                                    y_step,
                                    label_mode = "stars") {
  
  required_cols <- c("term", "contrast", "estimate", "conf.low", "conf.high", "adj.p.value")
  missing_cols <- setdiff(required_cols, names(tukey_tbl))
  
  if (length(missing_cols) > 0) {
    stop(
      "Tukey table is missing required column(s): ",
      paste(missing_cols, collapse = ", ")
    )
  }
  
  bracket_tbl <- tukey_tbl %>%
    dplyr::filter(term == "treatment") %>%
    tidyr::separate(
      contrast,
      into = c("group1", "group2"),
      sep = "-",
      remove = FALSE
    ) %>%
    dplyr::mutate(
      group1 = as.character(group1),
      group2 = as.character(group2),
      group1_index = match(group1, treat_levels),
      group2_index = match(group2, treat_levels),
      comparison_span = abs(group1_index - group2_index),
      p_signif = p_to_stars(adj.p.value),
      p_label  = format_adj_p(adj.p.value)
    )
  
  if (any(is.na(bracket_tbl$group1_index)) || any(is.na(bracket_tbl$group2_index))) {
    bad_groups <- bracket_tbl %>%
      dplyr::filter(is.na(group1_index) | is.na(group2_index)) %>%
      dplyr::pull(contrast)
    
    stop(
      "One or more Tukey contrasts contain treatment names not found in treat_levels: ",
      paste(bad_groups, collapse = ", ")
    )
  }
  
  if (label_mode == "p_value") {
    bracket_tbl <- bracket_tbl %>%
      dplyr::mutate(label_to_plot = p_label)
  } else {
    bracket_tbl <- bracket_tbl %>%
      dplyr::mutate(label_to_plot = p_signif)
  }
  
  bracket_tbl <- bracket_tbl %>%
    dplyr::arrange(comparison_span, group1_index, group2_index) %>%
    dplyr::mutate(
      y.position = y_start + (dplyr::row_number() - 1) * y_step
    ) %>%
    dplyr::select(
      contrast,
      group1,
      group2,
      estimate,
      conf.low,
      conf.high,
      adj.p.value,
      p_signif,
      p_label,
      label_to_plot,
      y.position
    )
  
  return(bracket_tbl)
}

## ===========================================================
## 5. VELOCITY: all Tukey comparisons
## ===========================================================

## ---- Load velocity objects produced by 03_velocity_stats.R ----

vel_treat_summary <- readr::read_rds(
  here::here("data_clean", "velocity_treat_summary.rds")
)

vel_tukey_tidy <- readr::read_rds(
  here::here("data_clean", "velocity_tukey_tidy.rds")
)

check_treatment_names(
  df = vel_treat_summary,
  treat_levels = treat_levels,
  object_name = "velocity_treat_summary"
)

vel_treat_summary <- vel_treat_summary %>%
  dplyr::mutate(
    treatment = factor(treatment, levels = treat_levels)
  )

## ---- Build all Tukey bracket table ----

vel_max_data <- max(
  vel_treat_summary$treatment_mean + vel_treat_summary$treatment_sd,
  na.rm = TRUE
)

# First bracket starts slightly closer to the bar/error-bar region.
vel_y_step  <- max(4, vel_max_data * 0.070)
vel_y_start <- 250

vel_brackets <- make_all_tukey_brackets(
  tukey_tbl    = vel_tukey_tidy,
  treat_levels = treat_levels,
  y_start      = vel_y_start,
  y_step       = vel_y_step,
  label_mode   = "stars"
)

message("\nVelocity all-Tukey bracket table:")
print(vel_brackets)

readr::write_csv(
  vel_brackets,
  file.path(tables_dir, "velocity_all_tukey_plot_brackets.csv")
)

vel_y_upper <- max(vel_brackets$y.position, na.rm = TRUE) + vel_y_step
vel_y_upper <- ceiling(vel_y_upper / 25) * 25
vel_y_breaks <- seq(0, 250, by = 25)

## ---- Plot velocity with all Tukey comparisons ----

p_vel_all_tukey <- ggplot() +
  geom_col(
    data = vel_treat_summary,
    aes(x = treatment, y = treatment_mean, fill = treatment),
    width = 0.6,
    alpha = 0.9
  ) +
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
  ggpubr::stat_pvalue_manual(
    data = vel_brackets,
    label = "label_to_plot",
    xmin = "group1",
    xmax = "group2",
    y.position = "y.position",
    tip.length = bracket_tip_length,
    bracket.size = bracket_line_size,
    size = bracket_label_size,
    vjust = 0.3
  ) +
  scale_fill_manual(values = fill_cols) +
  scale_x_discrete(labels = treat_labels) +
  scale_y_continuous(
    breaks = seq(0, 250, by = 25),
    minor_breaks = NULL,
    limits = c(0, vel_y_upper),
    expand = expansion(mult = c(0, 0.02))
  ) +
  theme_bw() +
  theme(
    plot.title   = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
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
    legend.position = "none",
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10)
  )

print(p_vel_all_tukey)

## ---- Save velocity plot ----

ggplot2::ggsave(
  filename = file.path(figs_dir, "velocity_plot_all_tukey.png"),
  plot     = p_vel_all_tukey,
  width    = plot_width,
  height   = plot_height,
  dpi      = plot_dpi,
  bg       = "white"
)

ggplot2::ggsave(
  filename = file.path(figs_dir, "velocity_plot_all_tukey.pdf"),
  plot     = p_vel_all_tukey,
  width    = plot_width,
  height   = plot_height,
  dpi      = plot_dpi
)

## ===========================================================
## 6. DIRECTIONALITY/DIRECTNESS: all Tukey comparisons
## ===========================================================

## ---- Load direction objects produced by 05_direction_stats.R ----

dir_treat_summary <- readr::read_rds(
  here::here("data_clean", "direction_treat_summary.rds")
)

dir_tukey_tidy <- readr::read_rds(
  here::here("data_clean", "direction_tukey_tidy.rds")
)

check_treatment_names(
  df = dir_treat_summary,
  treat_levels = treat_levels,
  object_name = "direction_treat_summary"
)

dir_treat_summary <- dir_treat_summary %>%
  dplyr::mutate(
    treatment = factor(treatment, levels = treat_levels)
  )

## ---- Build all Tukey bracket table ----

dir_max_data <- max(
  dir_treat_summary$treatment_mean + dir_treat_summary$treatment_sd,
  na.rm = TRUE
)

# First bracket starts slightly closer to the bar/error-bar region.
dir_y_step  <- 0.055
dir_y_start <- 1

dir_brackets <- make_all_tukey_brackets(
  tukey_tbl    = dir_tukey_tidy,
  treat_levels = treat_levels,
  y_start      = dir_y_start,
  y_step       = dir_y_step,
  label_mode   = "stars"
)

message("\nDirectionality all-Tukey bracket table:")
print(dir_brackets)

readr::write_csv(
  dir_brackets,
  file.path(tables_dir, "directionality_all_tukey_plot_brackets.csv")
)

dir_y_upper <- max(dir_brackets$y.position, na.rm = TRUE) + dir_y_step
dir_y_upper <- ceiling(dir_y_upper * 10) / 10
dir_y_breaks <- seq(0, 1, by = 0.1)

## ---- Plot directionality with all Tukey comparisons ----

p_dir_all_tukey <- ggplot() +
  geom_col(
    data = dir_treat_summary,
    aes(x = treatment, y = treatment_mean, fill = treatment),
    width = 0.6,
    alpha = 0.9
  ) +
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
  ggpubr::stat_pvalue_manual(
    data = dir_brackets,
    label = "label_to_plot",
    xmin = "group1",
    xmax = "group2",
    y.position = "y.position",
    tip.length = bracket_tip_length,
    bracket.size = bracket_line_size,
    size = bracket_label_size,
    vjust = 0.3
  ) +
  scale_fill_manual(values = fill_cols) +
  scale_x_discrete(labels = treat_labels) +
  scale_y_continuous(
    breaks = seq(0, 1, by = 0.1),
    minor_breaks = NULL,
    limits = c(0, dir_y_upper),
    expand = expansion(mult = c(0, 0.02))
  ) +
  theme_bw() +
  theme(
    plot.title   = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
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
    legend.position = "none",
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10)
  )

print(p_dir_all_tukey)

## ---- Save directionality plot ----

ggplot2::ggsave(
  filename = file.path(figs_dir, "directionality_plot_all_tukey.png"),
  plot     = p_dir_all_tukey,
  width    = plot_width,
  height   = plot_height,
  dpi      = plot_dpi,
  bg       = "white"
)

ggplot2::ggsave(
  filename = file.path(figs_dir, "directionality_plot_all_tukey.pdf"),
  plot     = p_dir_all_tukey,
  width    = plot_width,
  height   = plot_height,
  dpi      = plot_dpi
)

## -----------------------------------------------------------
## 7. Completion message
## -----------------------------------------------------------

message("\n08_plots_all_tukey.R complete.")
message("Saved all-Tukey bracket plots to: ", figs_dir)
message("Saved all-Tukey bracket tables to: ", tables_dir)
