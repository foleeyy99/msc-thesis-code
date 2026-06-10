# Zoospore Motility Analysis

This folder contains R scripts, exported figures and statistical summary tables associated with the *Phytophthora infestans* zoospore motility assays described in the thesis.

Zoospore motility assays assessed the effects of mancozeb, IS6, U73122, U73433, DMSO and control conditions on *P. infestans* zoospore swimming behaviour. Brightfield time-lapse videos were manually tracked in ImageJ using the Manual Tracking plugin to generate x-y coordinate data for individual zoospores across sequential frames. These coordinate data were saved in `.xlsx` files before being reformatted using `01_ibidi_txt_files.R` into `.txt` files suitable for import into the ibidi Chemotaxis and Migration Tool. The ibidi software was then used to calculate motility parameters including accumulated distance, Euclidean distance, directionality and velocity. Exported ibidi statistics were subsequently cleaned, summarised, statistically analysed and plotted in R.

## Repository contents

* `scripts/`
  Contains R scripts used for data reformatting, ibidi file preparation, import of ibidi outputs, statistical analysis, figure generation, supplementary Tukey visualisation and summary-table export.

* `figs/`
  Contains exported figures generated from the R scripts, including velocity plots, directionality plots and supplementary figures displaying all Tukey HSD pairwise comparisons.

* `tables/`
  Contains exported summary and statistical tables for velocity and directionality analyses, including treatment summaries, ANOVA outputs and Tukey post-hoc comparison outputs.

## Data availability

Raw videos, raw manually tracked coordinate files, ibidi intermediate files, full ibidi exports and processed `.rds` objects are not included in this repository.

The scripts are provided to document the data processing, statistical analysis and figure generation workflow used for the thesis. Because raw and intermediate data files are not included, the scripts are not directly executable from the repository alone without the original local project files, or equivalently named files.

## Local project structure

The scripts were originally run from a local R project using the following folders:

* `scripts`
* `data_raw`
* `data_clean`
* `ibidi`
* `ibidi_exports`
* `figs`
* `tables`

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
   Calculates replicate-level mean velocities, generates treatment-level velocity summaries, performs one-way ANOVA and runs Tukey HSD post-hoc comparisons.

5. `04_velocity_plots.R`
   Generates the main velocity bar plot using treatment-level means, standard deviation error bars and significance annotations relative to the untreated control.

6. `05_direction_stats.R`
   Calculates replicate-level mean directionality/directness values, generates treatment-level directionality summaries, performs one-way ANOVA and runs Tukey HSD post-hoc comparisons.

7. `06_direction_plot.R`
   Generates the main directionality/directness bar plot using treatment-level means, standard deviation error bars and significance annotations relative to the untreated control.

8. `07_stats_tables.R`
   Exports clean summary, ANOVA and Tukey post-hoc tables for both velocity and directionality analyses.

9. `08_plots_all_tukey.R`
   Generates supplementary velocity and directionality bar plots displaying all Tukey HSD pairwise comparisons. These plots were produced to visualise the complete set of post-hoc comparisons while keeping the main thesis figures concise.

## Included outputs

The `figs/` folder contains exported motility figures generated from the plotting scripts. These include:

* main velocity plots showing treatment effects relative to the control;
* main directionality plots showing treatment effects relative to the control;
* supplementary velocity plots displaying all Tukey HSD pairwise comparisons;
* supplementary directionality plots displaying all Tukey HSD pairwise comparisons.

The `tables/` folder contains exported CSV tables summarising velocity and directionality results, including:

* treatment-level summary tables;
* ANOVA summary tables;
* Tukey HSD post-hoc comparison tables;
* bracket-position tables used to generate the supplementary all-pairwise Tukey comparison figures.

## Statistical analysis

Velocity and directionality data were summarised at the biological replicate level before treatment-level analysis. One-way ANOVA was used to test for an overall effect of treatment, followed by Tukey HSD post-hoc comparisons. Main thesis figures display significance annotations relative to the control group for conciseness. Supplementary figures generated using `08_plots_all_tukey.R` display the full set of Tukey pairwise comparisons.

## Software

The analysis was performed in R using RStudio. Required R packages are loaded in `scripts/00_packages.R`.
