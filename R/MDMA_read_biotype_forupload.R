# Biotype data processing
# Standardized biotypes
file_filter <- c('connhc_n50_dof6-s0', 'connhc_n50_dof6-s1', 'connhc_n50_dof6-s2', 'connhc_n50_dof6-s3')
biotype_std <- data.frame(matrix(ncol = 5, nrow = 0))

for (i in seq_along(file_filter)) {
  filter <- file_filter[i]
  session <- as.character(i - 1)
  
  biotype_std_filter <- list.files(path = file.path(data_dir, "biotype"), pattern = filter, full.names = TRUE) %>%
    import() %>%
    mutate(Visit = paste0('s', session)) %>%
    rename(Subjects = subject) %>%
    filter(grepl('MDMA', Subjects)) %>%
    mutate(Subjects = as.numeric(gsub("MDMA0", "", Subjects))) %>%
    arrange(Subjects, Visit)
  
  biotype_std <- rbind(biotype_std, biotype_std_filter)
}

biotype_std <- merge(biotype_std, dosage_data, by = c("Subjects", "Visit"), all.y = TRUE) %>%
  mutate(Std = 'std') %>%
  select(-Visit) %>%
  filter(Subjects != 4) %>%
  arrange(as.numeric(Subjects)) %>%
  mutate(Dosage = factor(Dosage, levels = dosage_4sessions))

# Export the standardized biotype data
biotype_std %>%
  export(file = file.path(data_dir, "biotype/biotypes-connhc_n50_dof6-all-2024-11-04.csv"))

# Focus on nonconscious threat-evoked measures
sel_col <- c("act-nonconscious-threat_vs_neutral-176064_Right_Amygdala",
             "act-nonconscious-threat_vs_neutral-779062_Left_Amygdala",
             "act-nonconscious-threat_vs_neutral-911981_Right_sgACC",
             "ppi-nonconscious-threat_vs_neutral-911981_Right_sgACC-176064_Right_Amygdala",
             "ppi-nonconscious-threat_vs_neutral-911981_Right_sgACC-779062_Left_Amygdala")
biotype_all <- biotype_std %>%
  select(Subjects, Dosage, all_of(sel_col), nonconscious_discarded_percent)

# Remove data with severe motion: motion spikes > 0.25
replace_method <- 'NA'  # Use 'NA' for replacing severe motion data with NA, otherwise mean replacement
motion_thresh <- 0.25

if (replace_method == 'NA') {
  biotype_all <- biotype_all %>%
    group_by(Dosage) %>%
    mutate(across(all_of(sel_col), ~ case_when(nonconscious_discarded_percent > motion_thresh ~ NA, TRUE ~ .))) %>%
    ungroup()
} else {
  biotype_all <- biotype_all %>%
    group_by(Dosage) %>%
    mutate(across(all_of(sel_col), ~ case_when(
      nonconscious_discarded_percent > motion_thresh ~ mean(.[nonconscious_discarded_percent <= motion_thresh], na.rm = TRUE),
      TRUE ~ .
    ))) %>%
    ungroup()
}

# Export the cleaned biotype data
biotype_all %>%
  export(file = file.path(data_dir, "biotype/biotypes-all-2024-11-04.csv"))
