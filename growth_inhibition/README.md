# In-Plate Growth Inhibition Analysis

This folder contains R scripts and exported figures associated with the in-plate growth inhibition assay described in the thesis.

The assay assessed the effect of myo-inositol hexasulphate hexapotassium salt (IS6) on radial hyphal growth of *Phytophthora infestans* isolates grown on supplemented Rye A agar plates. Mancozeb was included as a positive control for inhibition of growth.

## Repository contents

* `scripts/`
  Contains the R scripts used for package loading, data exploration, data cleaning, statistical analysis and figure generation.

* `figs/`
  Contains exported figures generated from the R scripts.

## Data availability

Raw and processed data files are not included in this repository. The scripts are provided to document the data-cleaning, statistical-analysis and figure-generation workflow used for the thesis.

Because the raw Excel workbook and processed CSV files are not included, the scripts are not directly executable from the repository alone without the original local data files.

## Expected local project structure

The scripts were originally run from a local R project. In that project, the scripts were stored in a `scripts` folder, raw Excel files were stored in a `data_raw` folder, processed outputs were written to a `data_processed` folder, and exported figures were saved to a `figs` folder.

In order for the pipeline to work, the folder structure above must be created on the local device.

## Script order

The scripts were run in the following order:

1. `00_packages.R`
   Loads the R packages used throughout the growth-inhibition analysis pipeline.

2. `01_explore_raw.R`
   Performs an initial inspection of the raw Excel workbook containing colony-diameter measurements.

3. `02_clean_diameters.R`
   Cleans the raw diameter workbook, separates treatment blocks, flags outliers and creates clean datasets.

4. `03_growth_curves.R`
   Generates colony growth curves showing diameter over time for each isolate and treatment (Supplementary Figures of Thesis Document).

5. `04_maximal_growth_stats.R`
   Performs day-12 maximal-growth statistical analysis using the clean dataset.

6. `05_maximal_growth_plot.R`
   Generates the day-12 maximal-growth bar plot, including mean colony diameter, standard deviation and significance annotations.


## Software

The analysis was performed in R using RStudio. Required R packages are loaded in `scripts/00_packages.R`.
