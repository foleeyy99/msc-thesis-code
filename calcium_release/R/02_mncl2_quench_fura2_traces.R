## ------------------------------------------------------------
## Fura-2 MnCl2 quench traces
## Project root: Fura 2/
##  - Raw csv/       -> raw CSV files
##  - Figures/       -> output figures
##  - R/             -> scripts (this file), processed data, etc.
## ------------------------------------------------------------

## Install once if needed:
# install.packages(c("tidyverse", "here"))

library(tidyverse)
library(here)    


## ------------------------------------------------------------
## Step 1: Define filenames (full paths using here::here)
## ------------------------------------------------------------

files <- c(
  here("Raw csv", "Sample_1_MnCl.csv"),
  here("Raw csv", "Sample_2_MnCl.csv"),
  here("Raw csv", "Sample_3_MnCl.csv")
)

rep_ids <- c("rep1", "rep2", "rep3")


## ------------------------------------------------------------
## Step 2: Read all CSVs and combine into one dataframe
## ------------------------------------------------------------

fura_raw <- purrr::map2_dfr(files, rep_ids, ~ {
  readr::read_csv(.x) %>%
    transmute(
      replicate = .y,
      time_s    = time_s,
      F340      = F340,
      F380      = F380
    )
})


## ------------------------------------------------------------
## Step A: Recalculate Fura-2 ratio (F340/F380)
## ------------------------------------------------------------

fura_ratio <- fura_raw %>%
  group_by(replicate) %>%
  mutate(
    ratio = F340 / F380
  ) %>%
  ungroup()


## ------------------------------------------------------------
## Step B: Compute baseline ratio (0–60 s) for each replicate
## ------------------------------------------------------------

baseline_start <- 0
baseline_end   <- 60

fura_bl <- fura_ratio %>%
  group_by(replicate) %>%
  mutate(
    baseline_ratio = mean(
      ratio[time_s >= baseline_start & time_s < baseline_end],
      na.rm = TRUE
    )
  ) %>%
  ungroup()

# Optional check:
fura_bl %>%
  group_by(replicate) %>%
  summarise(baseline_ratio = unique(baseline_ratio), .groups = "drop")


## ------------------------------------------------------------
## Relabel replicates, start each at time 0
## ------------------------------------------------------------

fura_bl_labeled <- fura_bl %>%
  mutate(
    sample = dplyr::recode(
      replicate,
      "rep1" = "Sample 1",
      "rep2" = "Sample 2",
      "rep3" = "Sample 3"
    )
  ) %>%
  group_by(sample) %>%
  mutate(
    time_s = time_s - min(time_s, na.rm = TRUE)
  ) %>%
  ungroup()


## ------------------------------------------------------------
## Custom theme
## ------------------------------------------------------------

theme_fura <- function(base_size = 13) {
  theme_bw(base_size = base_size) +
    theme(
      panel.grid.major = element_line(size = 0.25, colour = "grey90"),
      panel.grid.minor = element_line(size = 0.2, colour = "grey95"),
      panel.border     = element_rect(colour = "black", size = 0.7),
      panel.spacing    = unit(0.6, "lines"),
      axis.title       = element_text(face = "bold", size = 18),
      axis.text        = element_text(colour = "black"),
      axis.title.x     = element_text(margin = margin(t = 10)),
      axis.title.y     = element_text(margin = margin(r = 10)),
      strip.background = element_blank(),
      strip.text       = element_text(face = "bold", size = 12),
      plot.title       = element_text(face = "bold", hjust = 0, size = 20),
      plot.margin      = margin(1, 10, 1, 1)
    )
}
# ------------------------------------------------------------
# Plot: MnCl2 quench traces
# ------------------------------------------------------------


mncl_time <- 56  # adjust if MnCl2 was added at a different time

x_min <- 0
x_max <- max(fura_bl_labeled$time_s, na.rm = TRUE)

p_mncl <- ggplot(
  fura_bl_labeled,
  aes(x = time_s, y = ratio, colour = sample)
) +
  
  # Vertical dashed line at MnCl2 addition
  geom_vline(
    xintercept = mncl_time,
    linetype   = "dashed",
    linewidth  = 0.5
  ) +
  
  # Text label for MnCl2 
  annotate(
    "text",
    x     = mncl_time,
    y     = max(fura_bl_labeled$ratio, na.rm = TRUE),
    label = "1~mM~MnCl[2]~(56~s)",
    parse = TRUE,
    hjust = -0.1,
    vjust = 1.2,
    size  = 5
  ) +
  
  # Raw trace lines (all samples in one panel)
  geom_line(linewidth = 0.54, alpha = 1) +
  
  # REMOVE main title and axis titles
  labs(
    x     = NULL,
    y     = NULL,
    title = NULL
  ) +
  
  # X axis: ticks every 15 s (minors every 5 s)
  scale_x_continuous(
    limits       = c(x_min, x_max),
    breaks       = seq(x_min, x_max, by = 15),
    minor_breaks = seq(x_min, x_max, by = 5),
    expand       = expansion(mult = c(0, 0))
  ) +
  
  # Y axis
  scale_y_continuous(
    limits       = c(0.5, 1.25),
    breaks       = seq(0.5, 1.2, by = 0.1),
    minor_breaks = seq(0.5, 1.2, by = 0.05)
  ) +
  
  # Colours for each sample
  scale_colour_manual(
    values = c(
      "Sample 1" = "#00b060",  # green
      "Sample 2" = "#0072B2",  # blue
      "Sample 3" = "#ff6f00"   # orange
    ),
    guide = "none"  # <<-- this kills the legend
  ) +
  
  # Apply theme and remove axis titles/legend
  theme_fura() +
  theme(
    legend.position = "none",          # just in case
    axis.title      = element_blank()  # double insurance
  )

p_mncl

# ------------------------------------------------------------
# Save outputs to Figures/ using here()
# ------------------------------------------------------------

ggsave(
  filename = here("Figures", "MnCl_Fura2_Quench_Traces.png"),
  plot     = p_mncl,
  width    = 7.5,
  height   = 5.5,
  dpi      = 600
)


ggsave(
  filename = here("Figures", "MnCl_Fura2_Quench_Traces.pdf"),
  plot     = p_mncl,
  width    = 7.5,
  height   = 5.5
)


