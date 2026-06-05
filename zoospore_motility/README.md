# Zoospore Motility Analysis

This folder contains R scripts, exported figures and statistical summary tables associated with the *Phytophthora infestans* zoospore motility assays described in the thesis.

Zoospore motility assays assessed the effects of mancozeb, IS6, U73122, U73343, DMSO and dH2O conditions on *P. infestans* zoospore swimming behaviour. Brightfield time-lapse videos were manually tracked in ImageJ (using the Manual Tracking plugin) to generate x-y coordinate data, for each frame, for individual zoospores. These coordinate data were saved in `.xlsx` files, before being reformatted (see script `01_ibidi_txt_files.R`) into `.txt` files for import into the ibidi Chemotaxis and Migration Tool; here, motility parameters including accumulated distance, Euclidean distance, directionality and velocity were calculated. Exported ibidi statistics were subsequently cleaned, summarised, analysed and plotted in R.


## Repository contents

* `scripts/`
  Contains R scripts used for data reformatting, ibidi file preparation, import of ibidi outputs, statistical analysis, figure generation and summary-table export.

* `figs/`
  Contains exported figures generated from the R scripts, including velocity and directionality plots.

* `tables/`
  Contains exported summary and statistical tables for velocity and directionality analyses.

## Data availability

Raw videos, raw data files, ibidi intermediate files, and processed `.rds` objects are not included in this repository.

The scripts are provided to document the data processing, statistical analysis and figure generation workflow used for the thesis. Because raw and intermediate data files are not included, the scripts are not directly executable from the repository alone without the original local project files, or equivalently named files.

## Local project structure

The scripts were originally run from a local R project using the following folders: `scripts`, `data_raw`, `data_clean`, `ibidi`, `ibidi_exports`, `figs` and `tables`.

The GitHub repository contains the scripts and selected exported outputs only.

## Script order

The scripts were run in the following order:

1. `00_packages.R`
   Loads the R packages used throughout the zoospore motility analysis pipeline and sets project-wide plotting options.

2. `01_ibidi_txt_files.R`
   Converts manually tracked zoospore coordinate data from Excel files into ibidi-compatible plain text files for import into the ibidi Chemotaxis and Migration Tool.

3. `02_ibidi_data_import.R`
   Imports velocity and directionality statistics exported from the ibidi Chemotaxis and Migration Tool and saves cleaned data objects for downstream analysis.

4. `03_velocity_stats.R`
   Calculates replicate-level mean velocities, generates treatment-level velocity summaries, performs one-way ANOVA and runs Tukey post-hoc comparisons.

5. `04_velocity_plots.R`
   Generates the velocity bar plot using treatment-level means, standard deviation error bars and significance annotations versus the untreated control.

6. `05_direction_stats.R`
   Calculates replicate-level mean directionality/directness values, generates treatment-level directionality summaries, performs one-way ANOVA and runs Tukey post-hoc comparisons.

7. `06_direction_plot.R`
   Generates the directionality/directness bar plot using treatment-level means, standard deviation error bars and significance annotations versus the untreated control.

8. `07_stats_tables.R`
   Exports clean summary, ANOVA and Tukey post-hoc tables for both velocity and directionality analyses.

## Included outputs

The `figs/` folder contains exported motility figures generated from the plotting scripts.

The `tables/` folder contains exported CSV tables summarising velocity and directionality results, including treatment summaries, ANOVA outputs and Tukey post-hoc comparisons.

## Software

The analysis was performed in R using RStudio. Required R packages are loaded in `scripts/00_packages.R`.
