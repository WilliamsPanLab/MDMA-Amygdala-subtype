
# MDMA Amygdala Subtype Paper

This repository contains the main scripts and code required to replicate the analyses presented in the manuscript entitled: **"Negative affect circuit subtypes predict acute neural, behavioral, and affective responses to MDMA in humans."**

The scripts are organized according to the main analysis steps described in the manuscript's Results section.

## Repository Structure

- **R/**: Contains R scripts used for data preprocessing and loading different datasets required for the analysis.
  - `MDMA_read_biotype_forupload.R`: Script to load and preprocess biotype data.
  - `mdma_read_redcap_data_forupload.R`: Script to load and preprocess data from REDCap, a data collection platform.
  - `mdma_read_webneuro_data_forupload.R`: Script to load and preprocess data from WebNeuro, a neurocognitive assessment tool.
  
- **RMD/**: Contains R Markdown files that combine code, narrative, and outputs to produce figures and tables for the paper.
  - `MDMA_baseline_amy_stratification_paper_figure_forupload.Rmd`: R Markdown file that runs the main analyses and produces the figures and tables for the paper, including:
    - Baseline analyses.
    - Amygdala stratification.
    - Visualization of results.

## Installation and Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/your-repo-name.git
   cd your-repo-name
   ```

2. **Install R dependencies**: The R scripts require several R packages, including `tidyverse`, `lme4`, `broom.mixed`, `here`, `mice`, and `knitr`. You can install them using the following code:
   ```r
   install.packages(c("tidyverse", "lme4", "broom.mixed", "here", "mice", "knitr"))
   ```

## Running the Analysis

1. **Data Preprocessing**:
   - Run the scripts in the **R/** directory to preprocess each dataset.
   - Make sure to update any file paths in the scripts to match your local directory structure, if needed.

2. **Main Analysis and Figure Generation**:
   - Open and knit the R Markdown file in the **RMD/** folder:
     - `MDMA_baseline_amy_stratification_paper_figure_forupload.Rmd`
   - This file will run the full analysis and generate all tables and figures required for the manuscript.
   - If you encounter any errors during knitting, ensure all the `source` files are correctly linked and accessible.

## Notes

- **Data Accessibility**: The scripts assume you have access to the raw datasets required for analysis. Please contact the authors if you need more information about the datasets.
- **Troubleshooting**: If you encounter issues during knitting, particularly related to loading functions or missing columns, double-check that all `source` scripts in the **R/** directory are correctly referenced in the R Markdown file.

