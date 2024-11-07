
# MDMA Amygdala Subtype Paper

This repository contains the main scripts and code required to replicate the analyses presented in the manuscript entitled: **"Negative affect circuit subtypes predict acute neural, behavioral, and affective responses to MDMA in humans."**

The scripts are organized according to the main analysis steps described in the manuscript's Results section.

## Repository Structure

- **RMD/**: Contains the main R Markdown files that perform all analysis and produce figures and tables for the paper.
  - `MDMA_baseline_amy_stratification_paper_figure_forupload.Rmd`: R Markdown file that runs the main analyses and produces the figures and tables for the paper, including:
    - Baseline amygdala stratification (Fig. 2b).
    - Baseline demographic and symptom characteristics by baseline stratification (Table 1, Fig. 2c, Suppl. Fig. 1).
    - MDMA of 120mg vs placebo induced acute neural, behavioral, and affective response. (Fig. 3a-3h, Suppl. Fig. 2a-2h, and Suppl. Table 1)
    - MDMA of 120mg vs placebo induced acute neural, behavioral, and affective response, with multiple imputations (Suppl. Table 2 and 3)
    - Blinding analysis (Suppl. Table 4)

- **R/**: Contains R scripts used for data preprocessing and loading different datasets required for the analysis.
  - `MDMA_read_biotype_forupload.R`: Script to load and filter biotype data.
  - `mdma_read_redcap_data_forupload.R`: Script to load and preprocess data from REDCap collected questionnaire data, including 5D-ASC, VAS, and face likability.
  - `mdma_read_webneuro_data_forupload.R`: Script to load and filter data from WebNeuro, a neurocognitive assessment tool.
  

## Installation and Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/WilliamsPanLab/MDMA-Amygdala-subtype.git
   cd MDMA-Amygdala-subtype
   ```


## Running the Analysis
   **Main Analysis and Figure Generation**:
   - Open and run the R Markdown file in the **RMD/** folder:
     - `MDMA_baseline_amy_stratification_paper_figure_forupload.Rmd`
   - This file will run the full analysis and generate all tables and figures required for the manuscript.
   - If you encounter any errors during knitting, ensure all the `source` files are correctly linked and accessible.

## Notes

- **Data Accessibility**: The scripts assume you have access to the raw datasets required for analysis. Please contact the authors if you need more information about the datasets.
- **Troubleshooting**: If you encounter issues during knitting, particularly related to loading functions or missing columns, double-check that all `source` scripts in the **R/** directory are correctly referenced in the R Markdown file.

