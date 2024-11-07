# Load and process WebNeuro data
webneuro_data_4session <- import(file.path(data_dir, "MDMA_Webneuro_data.csv")) %>%
  mutate(
    Subjects = factor(Subjects, levels = subject_list),
    Dosage = gsub("baseline", "Baseline", Dosage)
  ) %>%
  filter(Subjects != 4) %>%
  arrange(Subjects)

# Extract baseline WebNeuro data
webneuro_baseline <- webneuro_data_4session %>%
  filter(Dosage == "Baseline") %>%
  select(-contains(c('Visit', 'Dosage')))  # Remove Visit and Dosage columns for baseline data

# Process WebNeuro data for sessions excluding the baseline
webneuro_data <- webneuro_data_4session %>%
  filter(Dosage != "Baseline") %>%
  select(-contains(c('Visit', '_norm')))  # Exclude Visit and normalized columns