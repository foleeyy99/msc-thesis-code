## ------------------------------------------------------------
## Fura-2 IP3 + Ionomycin traces
## Project root: Fura 2/
##  - Raw csv/       -> raw CSV files
##  - Figures/       -> output figures
##  - R/             -> scripts, processed data
## ------------------------------------------------------------

# install.packages(c("tidyverse", "here"))

library(tidyverse)
library(here)    


## ------------------------------------------------------------
## Step 1: Define filenames (full paths)
## ------------------------------------------------------------

files <- c(
  here("Raw csv", "Sample_1_IP3_and_Ionomycin.csv"),
  here("Raw csv", "Sample_2_IP3_and_Ionomycin.csv"),
  here("Raw csv", "Sample_3_IP3_and_Ionomycin.csv")
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
##  Plot Theme
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


## ------------------------------------------------------------
## Plot: raw Fura-2 ratio vs time
## ------------------------------------------------------------

ip3_time  <- 60
iono_time <- 300
x_min     <- 0
x_max     <- 600

y_min <- 0.85
y_max <- 1.3

  p_raw_nice <- ggplot(
    fura_bl_labeled,
    aes(x = time_s, y = ratio, colour = sample)
  ) +
    
    # Vertical dashed lines at IP3 and ionomycin times
    geom_vline(
      xintercept = ip3_time,
      linetype   = "dashed",
      linewidth  = 0.4
    ) +
    geom_vline(
      xintercept = iono_time,
      linetype   = "dashed",
      linewidth  = 0.4
    ) +
    
    # Text labels for stimuli
    annotate(
      "text",
      x     = ip3_time,
      y     = y_max - 0.01,
      label = "5~mu*M~IP[3]",
      parse = TRUE,
      hjust = -0.1,
      vjust = 1,
      size  = 4
    ) +
    annotate(
      "text",
      x     = iono_time,
      y     = y_max - 0.01,
      label = "1~mu*M~Ionomycin",
      parse = TRUE,
      hjust = -0.1,
      vjust = 1,
      size  = 4
    ) +
    
    # Raw trace lines
    geom_line(linewidth = 0.54, alpha = 1) +
    
    # Facets for each sample
    facet_wrap(~ sample, ncol = 1) +
    
    # REMOVE ALL TITLES
    labs(
      x = NULL,
      y = NULL,
      title = NULL
    ) +
    
    # Axes numeric scales
    scale_x_continuous(
      limits       = c(x_min, x_max),
      breaks       = seq(x_min, x_max, by = 30),
      minor_breaks = seq(x_min, x_max, by = 10),
      expand       = expansion(mult = c(0, 0))
    ) +
    scale_y_continuous(
      limits       = c(y_min, y_max),
      breaks       = seq(y_min, y_max, by = 0.1),
      minor_breaks = seq(y_min, y_max, by = 0.5)
    ) +
    
    # REMOVE LEGEND 
    scale_colour_manual(
      values = c(
        "Sample 1" = "#00b060",
        "Sample 2" = "#0072B2",
        "Sample 3" = "#ff6f00"
      ),
      guide = "none"   # <<-- This is the key line
    ) +
    
    theme_fura() +
    
    theme(
      legend.position = "none",
      axis.title = element_blank()
    )
  

p_raw_nice


## ------------------------------------------------------------
## Save figures
## ------------------------------------------------------------

ggsave(
  filename = here("Figures", "Raw_Fura2_Traces.png"),
  plot     = p_raw_nice,
  width    = 7.5,
  height   = 8,
  dpi      = 600
)


ggsave(
  filename = here("Figures", "Raw_Fura2_Traces.pdf"),
  plot     = p_raw_nice,
  width    = 7.5,
  height   = 8
)


## ------------------------------------------------------------
## Save processed data 
## ------------------------------------------------------------

## Processed data were generated locally but are not included in the repository.
