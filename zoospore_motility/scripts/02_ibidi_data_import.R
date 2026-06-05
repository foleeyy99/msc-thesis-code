## -----------------------------------------------------------
## 02_ibidi_data_import.R
## Import ibidi velocity & direction data into clean tibbles
## -----------------------------------------------------------

source(here::here("scripts/00_packages.R"))

## ---- read all txt files from a data subfolder ----

read_ibidi_stats_folder <- function(subdir, stats_type_label) {
  # subdir: "velocity" or "direction"
  # stats_type_label: tag, e.g. "velocity" or "direction"
  
  stats_dir <- here::here("ibidi_exports", "stats", subdir)
  
  if (!dir.exists(stats_dir)) {
    stop("Stats directory does not exist: ", stats_dir)
  }
  
  files <- list.files(stats_dir, pattern = "\\.txt$", full.names = TRUE)
  
  if (length(files) == 0) {
    stop("No .txt files found in: ", stats_dir)
  }
  
  message("Found ", length(files), " files in ", stats_dir)
  
  purrr::map_dfr(files, function(path) {
    
    # Read the tab-delimited data file
    df_raw <- readr::read_tsv(path, show_col_types = FALSE) %>%
      janitor::clean_names()
    
    # Parse treatment + replicate from filename
    fname <- basename(path)
    stem  <- tools::file_path_sans_ext(fname)       # e.g. "ctrl_1_velocity"
    parts <- strsplit(stem, "_")[[1]]
    
    if (length(parts) < 3) {
      warning("Filename does not match expected pattern: ", fname)
      treatment_raw <- NA_character_
      rep_raw       <- NA_character_
    } else {
      treatment_raw <- parts[1]   # "ctrl"
      rep_raw       <- parts[2]   # "1"
      # parts[3] would be "velocity" or "direction"
    }
    
    treatment_label <- toupper(treatment_raw)  # CTRL, DMSO, MZB, etc.
    
    df_raw %>%
      dplyr::mutate(
        treatment = treatment_label,
        replicate = as.integer(rep_raw),
        stats_type = stats_type_label,
        source_file = fname
      ) %>%
      dplyr::relocate(treatment, replicate, stats_type, source_file)
  })
}

## ---- Import velocity data ----

ibidi_velocity_stats <- read_ibidi_stats_folder(
  subdir = "velocity",
  stats_type_label = "velocity"
)

message("Velocity stats imported: ", nrow(ibidi_velocity_stats), " rows.")
print(dplyr::count(ibidi_velocity_stats, treatment, replicate))

## ---- Import direction data ----

ibidi_direction_stats <- read_ibidi_stats_folder(
  subdir = "direction",
  stats_type_label = "direction"
)

message("Direction stats imported: ", nrow(ibidi_direction_stats), " rows.")
print(dplyr::count(ibidi_direction_stats, treatment, replicate))

## -----------------------------------------------------------
## Clean velocity data: remove x1, y1, or any coordinate columns
## -----------------------------------------------------------

drop_coord_cols <- c("x1", "y1", "x_end", "y_end", "x2", "y2")

ibidi_velocity_stats <- ibidi_velocity_stats %>%
  dplyr::select(-dplyr::any_of(drop_coord_cols))

## -----------------------------------------------------------
## Clean direction data: remove endpoint coordinates
## -----------------------------------------------------------

ibidi_direction_stats <- ibidi_direction_stats %>%
  dplyr::select(-dplyr::any_of(drop_coord_cols))




## ---- Save cleaned objects for later use ----

# Make sure data_clean exists
data_clean_dir <- here::here("data_clean")
if (!dir.exists(data_clean_dir)) dir.create(data_clean_dir)

readr::write_rds(
  ibidi_velocity_stats,
  here::here("data_clean", "ibidi_velocity_stats.rds")
)

readr::write_rds(
  ibidi_direction_stats,
  here::here("data_clean", "ibidi_direction_stats.rds")
)

message("Saved ibidi_velocity_stats.rds and ibidi_direction_stats.rds to data_clean/")

# ---- Save cleaned .csv files as well ----

readr::write_csv(
  ibidi_velocity_stats,
  here::here("data_clean", "ibidi_velocity_stats.csv")
)

readr::write_csv(
  ibidi_direction_stats,
  here::here("data_clean", "ibidi_direction_stats.csv")
)

message("Saved CSV versions to data_clean/")

