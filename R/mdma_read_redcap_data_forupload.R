# Load REDCap data
questionnaire_data <- import(file.path(data_dir, "P50MDMA-AllQuestionnaires_DATA_2022-11-14_2250.csv"))

# Clean and rename columns
questionnaire_data <- questionnaire_data %>%
  rename(
    Subjects = "study_id",
    Visit_raw = "redcap_event_name",
    Gender = "sex_v2",
    Age = "age_v2",
    Race = "race_v2",
    Ethnicity = "ethnicity_v2",
    HAMA = "hama_score",
    HAMD = "hamd_total",
    PHQ9 = "phq_score",
    GAD7 = "sc_tot_score",
    CADSS = "cadssclinpre_raw",
    DASS_stress = "dass_strsstotal",
    DASS_anxiety = "dass_anxtotal",
    DASS_depression = "dass_deptotal",
    DAS_execution = "das_exec_score",
    DAS_emotion = "das_emo_score",
    DAS_beh_cognition = "das_behcogini_score",
    SHAPS = "shaps_total",
    DARS = "dars_raw_score",
    DARS_hobbies = "dars_raw_hobbies",
    DARS_food = "dars_raw_food",
    DARS_social = "dars_raw_social",
    DARS_sensory = "dars_raw_sensory",
    BPRS = "bprs_raw",
    CRC_guess = "randomization_crc",
    Participant_guess = "randomization_participant",
    MD_guess = "randomization_md"
  ) %>%
  mutate(
    Visit_category = gsub("s._(.+)_arm_2", "\\1", Visit_raw),
    Visit = gsub("_.*", "\\1", Visit_raw),
    Subjects = as.numeric(str_remove(gsub('\\(c\\)*', '', Subjects), "^0+")),
    across(c("Participant_guess", "CRC_guess", "MD_guess"), ~ recode(.x, "1" = "120mg", "2" = "80mg", "3" = "Placebo")),
    across(c("Participant_guess", "CRC_guess", "MD_guess"), ~ factor(.x, levels = dosage_3sessions)),
    ELS = (els1 > 0) + (els2 > 0) + (els3 > 0) + (els4 > 0) + (els5 > 0) +
      (els6 > 0) + (els7 > 0) + (els8 > 0) + (els9 > 0) + (els10 > 0) +
      (els11 > 0) + (els12 > 0) + (els13 > 0) + (els14 > 0) + (els15 > 0) +
      (els16 > 0) + (els17 > 0) + (els18 > 0) + (els19 > 0)
  ) %>%
  filter(as.numeric(Subjects) <= num_subjects) %>%
  mutate(Subjects = factor(Subjects, levels = subject_list)) %>%
  arrange(Subjects)
  # filter(Subjects != 4)

# Merge dosage data
questionnaire_data <- merge(questionnaire_data, dosage_data, by = c("Subjects", "Visit"), all = TRUE)

# Extract important timing data for CADSS
important_timing <- questionnaire_data %>%
  select(Subjects, Visit_category, Visit, infusionstart, cadsstimepre) %>%
  filter(grepl("preadmin_presca|postadmin_presc", Visit_category))

important_timing %>%
  export(file = file.path(data_dir, "P50MDMA_Important_Timestamp.csv"))

# Scan notes
scan_notes <- questionnaire_data %>%
  select(Subjects, Visit, matches("datadiff_details_")) %>%
  filter(Visit == 'events') %>%
  select(-Visit, -datadiff_details_screen) %>%
  mutate(notes_combined = paste(datadiff_details_s1, datadiff_details_s2, datadiff_details_s3, datadiff_details_bl, sep = '')) %>%
  filter(notes_combined != '') %>%
  select(-notes_combined) %>%
  pivot_longer(-Subjects, names_to = 'Visit', values_to = 'notes') %>%
  mutate(Visit = case_when(
    Visit == 'datadiff_details_bl' ~ 's0',
    Visit == 'datadiff_details_s1' ~ 's1',
    Visit == 'datadiff_details_s2' ~ 's2',
    Visit == 'datadiff_details_s3' ~ 's3',
    TRUE ~ NA_character_
  ))


# Merge scan notes with dosage data and save
scan_notes_unblinded <- merge(scan_notes, dosage_data, by = c("Subjects", "Visit"), all.x = TRUE) %>%
  select(-Visit) %>%
  pivot_wider(names_from = Dosage, values_from = notes) %>%
  arrange(Subjects)

scan_notes_unblinded %>%
  export(file = file.path(data_dir, "P50MDMA_Unblind_ScanNotes.csv"))


# extracting baseline demographic and clinical symptoms
desired_columns_baseline <- c("Subjects", "Visit", "Gender", "Age", "pclc_total", "ELS", "PHQ9", "GAD7")
questionnaire_baseline <- questionnaire_data %>%
  select(desired_columns_baseline) %>%
  filter(Visit %in% c('eligibility', 'screening', 's0')) %>%
  group_by(Subjects) %>%
  fill(Gender, Age, .direction = "up") %>%
  filter(Visit == 's0') %>%
  mutate(Subjects = factor(Subjects, levels = subject_list)) %>%
  arrange(Subjects) %>%
  select(-Visit) %>%
  ungroup()

questionnaire_baseline %>%
  export(file = file.path(data_dir, "MDMA_Questionnaires_baseline.csv"))


# Extracting measures collected once post-drug administration: 5D-ASC and anger face likability
desired_columns_once <- c("Subjects", "Visit", "Dosage", "Visit_category", "dascscore_impair", "dascscore_anxiety", "faces1_4")

# Selecting and processing data for post-administration measures
data_post_drug_measures <- questionnaire_data %>%
  select(desired_columns_once) %>%
  filter(grepl("postadmin_posts", Visit_category)) %>%
  mutate(Subjects = factor(Subjects, levels = subject_list)) %>%
  arrange(Subjects)

# Export processed data for post-drug measures
data_post_drug_measures %>%
  export(file = file.path(data_dir, "MDMA_Questionnaires_PostDrug_Measures.csv"))

# Handle missing data and calculate 5D-ASC scores for post-drug measures
data_post_drug_measures_backup <- questionnaire_data %>%
  # Select the columns needed for analysis
  select(all_of(desired_columns_once[1:4]), matches('dasc\\d+$')) %>%
  # Filter for post-admin data only
  filter(grepl("postadmin_posts", Visit_category)) %>%
  # Convert Subjects to a factor with specified levels and arrange by Subjects
  mutate(Subjects = factor(Subjects, levels = subject_list)) %>%
  arrange(Subjects)

# Replace missing data with the group mean by Dosage
data_post_drug_measures_backup <- data_post_drug_measures_backup %>%
  group_by(Dosage) %>%
  mutate(across(where(is.numeric), ~ ifelse(is.na(.x), mean(.x, na.rm = TRUE), .x))) %>%
  ungroup()

# Calculate composite scores for 5D-ASC measures
data_post_drug_measures_backup <- data_post_drug_measures_backup %>%
  mutate(
    dascscore_impair = dasc8 + dasc27 + dasc38 + dasc47 + dasc64 + dasc67 + dasc78,
    dascscore_anxiety = dasc32 + dasc43 + dasc44 + dasc46 + dasc56 + dasc89
  )

# Replace missingness in the main data with the updated backup data
measure_replace <- colnames(data_post_drug_measures)[grepl("dascscore_", colnames(data_post_drug_measures))]
data_post_drug_measures[, measure_replace] <- data_post_drug_measures_backup[, measure_replace]

# Normalize the 5D-ASC scores to reflect percentage change
data_post_drug_measures <- data_post_drug_measures %>%
  mutate(
    dascscore_impair = dascscore_impair / 7,  # Normalize by the total number of items contributing to the score
    dascscore_anxiety = dascscore_anxiety / 6  # Normalize similarly for consistency
  ) %>%
  select(-Visit, -Visit_category) 

# Export the processed post-drug measures
data_post_drug_measures %>%
  export(file = file.path(data_dir, "MDMA_Questionnaires_PostDrug_Measures_Normalized.csv"))

# rename the measure to be consistent with measures collected at both pre- and post- timepoints
data_once_pervisit_post_pre <- data_post_drug_measures %>%
  filter(Subjects != 4) %>%
  ungroup()


# Read data for questionnaire items collected multiple times

# Identify VAS columns in the data
vas_columns <- c("vas_bewithothers", "vas_secure")

# Process VAS rating data
VAS_rating <- questionnaire_data %>%
  filter(grepl('continuous', Visit_category), !is.na(redcap_repeat_instance)) %>%
  mutate(Time = vasrating_number) %>%
  select(Subjects, Visit, Dosage, Time, all_of(vas_columns))

# Replace missing values with group mean by Dosage and Time
VAS_rating <- VAS_rating %>%
  group_by(Dosage, Time) %>%
  mutate(across(where(is.numeric), ~ ifelse(is.na(.x), mean(.x, na.rm = TRUE), .x))) %>%
  ungroup()

# rename the VAS measure
data_repeated_per_visit <- VAS_rating

# Export the merged data for repeated measures
data_repeated_per_visit %>%
  export(file = file.path(data_dir, "MDMA_Questionnaires_RepeatedMeasures_Pervisit.csv"))


# Generate post-pre change measures for VAS ratings
vas_post_pre_columns <- colnames(data_repeated_per_visit)[grepl("vas_", colnames(data_repeated_per_visit))]
for (column in vas_post_pre_columns) {
  new_col_name <- paste0(column, "_post_pre")
  data_repeated_per_visit <- data_repeated_per_visit %>%
    group_by(Subjects, Dosage) %>%
    mutate(!!new_col_name := get(column)[Time == 4] - get(column)[Time == 1]) %>%
    ungroup()
}

# Export the post-pre data
data_repeated_post_pre <- data_repeated_per_visit %>%
  filter(Time == 1) %>%
  select(Subjects, Dosage, matches("post_pre$")) %>%
  filter(Subjects != 4)

data_repeated_post_pre %>%
  export(file = file.path(data_dir, "MDMA_Questionnaires_Post-Pre_RepeatedMeasures_Pervisit.csv"))


# Read participants', CRC's, and physician's dosage guesses
dosage_guesses <- questionnaire_data %>%
  filter(!is.na(Dosage) & Visit_category == 'postadmin_presc') %>%
  select(Subjects, Dosage, Participant_guess, CRC_guess, MD_guess) %>%
  mutate(Dosage = factor(Dosage, levels = dosage_3sessions))

