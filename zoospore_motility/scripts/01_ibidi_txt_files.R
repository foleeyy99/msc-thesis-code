## -----------------------------------------------------------
## 01_ibidi_txt_files.R
## Create ibidi txt files for all treatments & replicates
## -----------------------------------------------------------

source(here::here("scripts/00_packages.R"))

ibidi_dir <- here::here("ibidi")
if (!dir.exists(ibidi_dir)) dir.create(ibidi_dir)

## ---- clean one 8-column replicate block ----

clean_rep_block <- function(df_block) {
  df_block %>%
    dplyr::rename(
      rep   = 1,
      track = 2,
      slice = 3,
      x     = 4,
      y     = 5,
      dist  = 6,
      vel   = 7,
      pixel = 8
    ) %>%
    dplyr::select(rep, track, slice, x, y) %>%
    dplyr::filter(
      !is.na(rep),
      !is.na(track),
      !is.na(slice),
      !is.na(x),
      !is.na(y)
    )
}

## ---- read & tidy one treatment file ----

read_treatment_file <- function(filename, treatment_label) {
  
  path <- here::here("data_raw", filename)
  
  df_raw <- readxl::read_excel(path)
  
  rep_start_cols <- which(stringr::str_detect(names(df_raw), "Rep #"))
  
  rep_dfs <- purrr::map(rep_start_cols, function(start_col) {
    block <- df_raw[, start_col:(start_col + 7)]
    clean_rep_block(block)
  })
  
  # bind and tag with treatment
  dplyr::bind_rows(rep_dfs) %>%
    dplyr::mutate(
      treatment = treatment_label,
      rep       = as.integer(rep),
      track     = as.integer(track),
      slice     = as.integer(slice)
    )
}

## ---- convert tidy rep table to ibidi format ----

make_ibidi_table <- function(df_rep) {
  df_rep %>%
    dplyr::arrange(track, slice) %>%
    dplyr::mutate(
      ConsecutiveNumber = dplyr::row_number(),
      TrackNumber       = as.integer(track),
      SliceNumber       = as.integer(slice),
      `X-Value`         = as.integer(round(x)),
      `Y-Value`         = as.integer(round(y))
    ) %>%
    dplyr::select(
      ConsecutiveNumber,
      TrackNumber,
      SliceNumber,
      `X-Value`,
      `Y-Value`
    )
}

## ---- Step 1: read all 6 treatment files into one tidy table ----

treat_files <- c(
  CTRL   = "CTRL.xlsx",
  DMSO   = "DMSO.xlsx",
  MZB    = "MZB.xlsx",
  U73122 = "U73122.xlsx",
  U73433 = "U73433.xlsx",
  IS6    = "IS6.xlsx"
)

all_tidy_list <- purrr::imap(
  treat_files,
  ~ read_treatment_file(filename = .x, treatment_label = .y)
)

zsp_ibidi_tidy <- dplyr::bind_rows(all_tidy_list)

# Optional: save tidy version for later analysis
readr::write_rds(
  zsp_ibidi_tidy,
  here::here("data_clean", "zsp_ibidi_tidy.rds")
)

treatments <- sort(unique(zsp_ibidi_tidy$treatment))

## ---- Step 2a: write txt files (one per treatment × replicate) ----

for (trt in treatments) {
  
  df_trt <- zsp_ibidi_tidy %>% dplyr::filter(treatment == trt)
  reps_trt <- sort(unique(df_trt$rep))
  
  # one file per replicate
  for (r in reps_trt) {
    df_rep <- df_trt %>% dplyr::filter(rep == r)
    
    ibidi_tab <- make_ibidi_table(df_rep)
    
    out_path <- file.path(ibidi_dir, glue::glue("{trt}_rep{r}.txt"))
    
    # first line: arbitrary text
    readr::write_lines(
      x = glue::glue("{trt} replicate {r}"),
      file = out_path
    )
    
    # (no header)
    readr::write_tsv(
      ibidi_tab,
      file      = out_path,
      append    = TRUE,
      col_names = FALSE
    )
    
    message("Written: ", out_path)
  }
}

## ---- Step 2b: write combined txt files (all reps per treatment) ----

for (trt in treatments) {
  
  df_trt <- zsp_ibidi_tidy %>% dplyr::filter(treatment == trt)
  
  # how many tracks per rep (max over all reps for this treatment)
  max_tracks_per_rep <- df_trt %>%
    dplyr::group_by(rep) %>%
    dplyr::summarise(max_track = max(track, na.rm = TRUE), .groups = "drop") %>%
    dplyr::pull(max_track) %>%
    max(na.rm = TRUE)
  
  # index tracks so that each rep occupies its own block:
  df_trt_reindexed <- df_trt %>%
    dplyr::mutate(
      track_reindexed = track + (rep - 1L) * max_tracks_per_rep
    )
  
  # drop the original 'track' column and rename track_reindexed to track
  df_for_ibidi <- df_trt_reindexed %>%
    dplyr::select(-track) %>%
    dplyr::rename(track = track_reindexed)
  
  ibidi_trt_all <- make_ibidi_table(df_for_ibidi)
  
  combined_path <- file.path(ibidi_dir, glue::glue("{trt}_all_reps.txt"))
  
  readr::write_lines(glue::glue("{trt} all replicates (renumbered tracks)"),
                     combined_path)
  
  readr::write_tsv(
    ibidi_trt_all,
    file      = combined_path,
    append    = TRUE,
    col_names = FALSE
  )
  
  message("Written combined file: ", combined_path)
}
