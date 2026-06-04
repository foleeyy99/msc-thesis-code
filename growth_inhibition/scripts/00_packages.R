## 00_packages.R
## Load (and if needed, install) all packages for the project

packages <- c(
  "tidyverse",  # ggplot2, dplyr, readr, etc.
  "readxl",     # reading Excel files
  "janitor",    # clean_names(), tabyl(), etc.
  "here",       # file paths relative to project
  "lme4",       # mixed models
  "lmerTest",   # p-values for lmer
  "emmeans",    # post-hoc tests
  "patchwork",   # combining plots, if needed
  "writexl",     # writing xlsx files
  "ggtext",
  "pracma",
  "DescTools"
)

installed <- rownames(installed.packages())
to_install <- packages[!(packages %in% installed)]

if (length(to_install) > 0) {
  install.packages(to_install, dependencies = TRUE)
}

invisible(lapply(packages, library, character.only = TRUE))

