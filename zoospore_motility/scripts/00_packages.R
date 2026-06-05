## -----------------------------------------------------------
## 00_packages.R
## Master package loader for Zsp Motility project
## -----------------------------------------------------------

## ---- Package list ----

## Some are probably not necessary, load them to just in case.

core_pkgs <- c(
  # Core data wrangling / IO
  "tidyverse",   
  "janitor",     
  "readr",      
  "readxl",      
  "writexl",     
  "lubridate",   
  "here",        
  "glue"         
)

stats_pkgs <- c(
  "lme4",        
  "lmerTest",    
  "emmeans",     
  "multcomp",    
  "performance", 
  "broom",       
  "broom.mixed"  
)

viz_pkgs <- c(
  "ggpubr",      
  "patchwork",   
  "scales",      
  "viridis",     
  "cowplot"      
)

qc_pkgs <- c(
  "skimr"        
)


extra_pkgs <- c(
  "magick"      
)

packages <- c(core_pkgs, stats_pkgs, viz_pkgs, qc_pkgs, extra_pkgs)


## ---- Install if missing & load ---- %>% 

install_if_missing <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

invisible(lapply(packages, install_if_missing))
invisible(lapply(packages, library, character.only = TRUE))

message("All packages loaded successfully.")


## ---- Project-wide options & ggplot theme ----

# Use project-rooted paths by default
# Register the project root based on this exact file path
here::i_am("scripts/00_packages.R")


# Global ggplot theme
theme_set(
  ggplot2::theme_bw(base_size = 12) +
    ggplot2::theme(
      panel.grid = ggplot2::element_blank(),
      plot.title = ggplot2::element_text(face = "bold"),
      strip.background = ggplot2::element_rect(fill = "grey90", colour = NA)
    )
)


message("Project options and ggplot theme set.")
