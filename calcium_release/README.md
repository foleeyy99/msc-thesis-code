# Calcium Release Assay Analysis

This folder contains R scripts and exported figures associated with Fura-2-dextran calcium-release assays in permeabilised *Phytophthora infestans* hyphal preparations.

## Purpose

The scripts document the workflow used to process kinetic fluorescence recordings generated using a CLARIOstar Plus multimode plate reader. Fluorescence values recorded following alternating excitation at 340 nm and 380 nm were used to calculate F340/F380 ratio traces.

## Contents

* `R/`
  Contains R scripts used for data import, F340/F380 ratio calculation and figure generation.

* `Figures/`
  Contains exported figures generated from the R scripts and included in the thesis or supplementary material.

## Analysis pipelines

### IP₃ and ionomycin stimulation traces

`R/01_ip3_ionomycin_fura2_traces.R`

This script imports fluorescence recordings from three biological samples, calculates F340/F380 ratios, marks the timing of IP₃ and ionomycin addition, generates ratio-trace plots, and exports the resulting figure.

### MnCl₂ quench traces

`R/02_mncl2_quench_fura2_traces.R`

This script processes MnCl₂ quench recordings used during troubleshooting to assess Fura-2-dextran fluorescence responsiveness under the recording conditions.

## Data availability

Raw CLARIOstar exports and processed data files are not included in this repository. The scripts are provided to document the analysis and figure-generation workflow used for the thesis.

## Software

The analysis was performed in R using RStudio. Required packages are loaded at the beginning of each script.
