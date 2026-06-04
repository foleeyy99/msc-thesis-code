## 02_clean_diameters.R
## Clean the raw diameters file into a tidy format

source("scripts/00_packages.R")

# ---------------------------------------------------------------------
# 0) Read raw data
# ---------------------------------------------------------------------

raw_path <- here::here("data_raw", "Diameters.xlsx")

diam_raw <- readxl::read_excel(raw_path)

# Drop the top 4 rows (title, header, units, spacer)
diam_core <- diam_raw[-c(1:4), ]

# ---------------------------------------------------------------------
# 1) CONTROLS block: columns 10:17
# ---------------------------------------------------------------------

controls_block <- diam_core %>%
  dplyr::select(CONTROLS:...17) %>%  # 8 columns: Compound..AVG
  dplyr::rename(
    compound  = CONTROLS,
    strain    = ...11,
    conc_uM   = ...12,
    time_days = ...13,
    g1        = ...14,
    g2        = ...15,
    g3        = ...16,
    avg_mm    = ...17
  )

controls_clean <- controls_block %>%
  mutate(
    compound      = as.factor(compound),
    strain        = as.factor(strain),
    conc_recorded = as.numeric(conc_uM),   
    conc_uM       = as.numeric(conc_uM),   
    time_days     = as.numeric(time_days),
    g1            = as.numeric(g1),
    g2            = as.numeric(g2),
    g3            = as.numeric(g3),
    avg_mm        = as.numeric(avg_mm),
    # controls have no flag/outlier info in the sheet
    flag          = NA_character_,
    is_outlier    = FALSE
  ) %>%
  # overwrite conc for true controls: they had 200 µL dH2O, no active compound
  mutate(
    conc_uM = dplyr::case_when(
      compound == "CTRL" ~ 0,   
      TRUE               ~ conc_uM
    )
  ) %>%
  # drop rows where all key fields are NA
  filter(!(is.na(compound) & is.na(strain) & is.na(time_days)))



# ---------------------------------------------------------------------
# 2) MANCOZEB block: columns 1:8
# ---------------------------------------------------------------------

mzb_block <- diam_core %>%
  dplyr::select(MANCOZEB:...8) %>%  # 8 columns: Compound..AVG
  dplyr::rename(
    compound  = MANCOZEB,
    strain    = ...2,
    conc_uM   = ...3,
    time_days = ...4,
    g1        = ...5,
    g2        = ...6,
    g3        = ...7,
    avg_mm    = ...8
  )

mzb_clean <- mzb_block %>%
  mutate(
    compound      = as.factor(compound),
    strain        = as.factor(strain),
    conc_recorded = as.numeric(conc_uM),
    conc_uM       = as.numeric(conc_uM),
    time_days     = as.numeric(time_days),
    g1            = as.numeric(g1),
    g2            = as.numeric(g2),
    g3            = as.numeric(g3),
    avg_mm        = as.numeric(avg_mm),
    # no explicit flag column in this block in the sheet
    flag          = NA_character_,
    is_outlier    = FALSE
  ) %>%
  # drop rows where all key fields are NA
  filter(!(is.na(compound) & is.na(strain) & is.na(conc_uM) & is.na(time_days)))



# ---------------------------------------------------------------------
# 3) IS6, strain 2930 block
# ---------------------------------------------------------------------

is6_2930_block <- diam_core %>%
  dplyr::select(`P. infestans 2930`:`...26`, flag = ...27) %>%  # data cols + flag col
  dplyr::rename(
    compound  = `P. infestans 2930`,
    strain    = ...20,
    conc_uM   = ...21,
    time_days = ...22,
    g1        = ...23,
    g2        = ...24,
    g3        = ...25,
    avg_mm    = ...26
  )

is6_2930_clean <- is6_2930_block %>%
  mutate(
    compound      = as.factor(compound),
    strain        = as.factor(strain),
    conc_recorded = as.numeric(conc_uM),
    conc_uM       = as.numeric(conc_uM),
    time_days     = as.numeric(time_days),
    g1            = as.numeric(g1),
    g2            = as.numeric(g2),
    g3            = as.numeric(g3),
    avg_mm        = as.numeric(avg_mm),
    flag          = as.character(flag),
    is_outlier    = flag == "OUTLIER"
  ) %>%
  # drop structurally empty rows
  filter(!(is.na(compound) & is.na(strain) & is.na(conc_uM) & is.na(time_days)))



# ---------------------------------------------------------------------
# 4) IS6, strain MYA 4127 block
# ---------------------------------------------------------------------

is6_MYA_block <- diam_core %>%
  dplyr::select(`P. infestans MYA 4127`:`...36`, flag = ...37) %>%  # data cols + flag
  dplyr::rename(
    compound  = `P. infestans MYA 4127`,
    strain    = ...30,
    conc_uM   = ...31,
    time_days = ...32,
    g1        = ...33,
    g2        = ...34,
    g3        = ...35,
    avg_mm    = ...36
  )

is6_MYA_clean <- is6_MYA_block %>%
  mutate(
    compound      = as.factor(compound),
    strain        = as.factor(strain),
    conc_recorded = as.numeric(conc_uM),
    conc_uM       = as.numeric(conc_uM),
    time_days     = as.numeric(time_days),
    g1            = as.numeric(g1),
    g2            = as.numeric(g2),
    g3            = as.numeric(g3),
    avg_mm        = as.numeric(avg_mm),
    flag          = as.character(flag),
    is_outlier    = flag == "OUTLIER"
  ) %>%
  # drop structurally empty rows
  filter(!(is.na(compound) & is.na(strain) & is.na(conc_uM) & is.na(time_days)))




# ---------------------------------------------------------------------
# 5) IS6, strain NL07434 block (OUTLIER flags live here)
# ---------------------------------------------------------------------

is6_NL_block <- diam_core %>%
  dplyr::select(`P. infestans NL07434`:`...46`, flag = ...47) %>%  # data cols + flag
  dplyr::rename(
    compound  = `P. infestans NL07434`,
    strain    = ...40,
    conc_uM   = ...41,
    time_days = ...42,
    g1        = ...43,
    g2        = ...44,
    g3        = ...45,
    avg_mm    = ...46
  )

is6_NL_clean <- is6_NL_block %>%
  mutate(
    compound      = as.factor(compound),
    strain        = as.factor(strain),
    conc_recorded = as.numeric(conc_uM),
    conc_uM       = as.numeric(conc_uM),
    time_days     = as.numeric(time_days),
    g1            = as.numeric(g1),
    g2            = as.numeric(g2),
    g3            = as.numeric(g3),
    avg_mm        = as.numeric(avg_mm),
    flag          = as.character(flag),
    is_outlier    = flag == "OUTLIER"
  ) %>%
  # drop structurally empty rows
  filter(!(is.na(compound) & is.na(strain) & is.na(conc_uM) & is.na(time_days)))



# ---------------------------------------------------------------------
# 6) Combine all blocks into one clean dataset
# ---------------------------------------------------------------------

diam_clean <- dplyr::bind_rows(
  controls_clean,
  mzb_clean,
  is6_2930_clean,
  is6_MYA_clean,
  is6_NL_clean
) %>%
  # standardise factor levels a bit
  mutate(
    compound = forcats::fct_relevel(compound, "CTRL", "mzb"),
    strain   = forcats::fct_relevel(strain, "2930", "MYA", "NL")
  ) %>%
  # treat NA outlier flags as FALSE so they are not dropped later
  mutate(
    is_outlier = dplyr::coalesce(is_outlier, FALSE)
  )

view(diam_clean)

# ---------------------------------------------------------------------
# 7) Analysis-ready dataset: drop outliers, keep everything else
# ---------------------------------------------------------------------

diam_analysis <- diam_clean %>%
  filter(!is_outlier)

glimpse(diam_analysis)
dplyr::count(diam_analysis, compound, strain, conc_uM, time_days)



dplyr::count(diam_analysis, compound, strain, conc_uM, time_days)


# ---------------------------------------------------------------------
# 8) Save processed datasets
# ---------------------------------------------------------------------

# make sure folder exists
dir.create(here::here("data_processed"), showWarnings = FALSE)

# CSV versions
readr::write_csv(diam_clean,    here::here("data_processed", "diam_clean.csv"))
readr::write_csv(diam_analysis, here::here("data_processed", "diam_analysis.csv"))

# XLSX version with both tables in one workbook
writexl::write_xlsx(
  list(
    diam_clean    = diam_clean,
    diam_analysis = diam_analysis
  ),
  path = here::here("data_processed", "diameters_processed.xlsx")
)


