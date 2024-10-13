# Load the data.table package
library(data.table)

# Load Raw CLIF Files
hospitalization <- fread("/share/projects/data/circe/v20240331/clif/hospitalization.csv.gz") 
patient <- fread("/share/projects/data/circe/v20240331/clif/patient.csv.gz") 

# Convert both tables to data.table if not already
setDT(patient)
setDT(hospitalization)

# Step 1: Merge patient with hospitalization to include admission_dttm
patient_hosp <- merge(patient, hospitalization, by = "patient_id", all.x = TRUE)

# Step 2: Identify patient_ids with multiple values for race_category, ethnicity_category, sex_category, or language_name
# Group by patient_id and check if there are multiple unique values in any of the key columns
patients_with_conflicts <- patient_hosp[, .(
  race_conflict = uniqueN(race_category) > 1,
  ethnicity_conflict = uniqueN(ethnicity_category) > 1,
  sex_conflict = uniqueN(sex_category) > 1,
  language_conflict = uniqueN(language_name) > 1
), by = patient_id]

# Step 3: Filter to get only the patient_ids with any conflicts
conflicted_patients <- patients_with_conflicts[
  race_conflict == TRUE | ethnicity_conflict == TRUE |
    sex_conflict == TRUE | language_conflict == TRUE, 
  .(patient_id)]

# Step 4: Sort by patient_id and admission_dttm to get the most recent admission first
setorder(patient_hosp, patient_id, -admission_dttm)

# Step 5: Remove duplicates, keeping only the most recent row for each patient_id
patient_clean <- patient_hosp[, .SD[1], by = patient_id]

# Step 6: Select only the relevant columns for the cleaned patient table
patient_clean <- patient_clean[, .(patient_id, race_category, ethnicity_category, sex_category, language_name)]

# Step 7: Merge conflicted patients with the conflict details from the patients_with_conflicts table
conflicted_patient_details <- merge(conflicted_patients, patients_with_conflicts, by = "patient_id", all.x = TRUE)

# Step 8: Merge conflicted_patient_details with patient_hosp to retrieve other details
conflicted_patient_details <- merge(conflicted_patient_details, patient_hosp, by = "patient_id", all.x = TRUE)

# Step 9: Filter the conflicted_patient_details to include only rows with conflicts
conflicted_patient_details <- conflicted_patient_details[
  race_conflict == TRUE | ethnicity_conflict == TRUE | 
    sex_conflict == TRUE | language_conflict == TRUE, 
  .(patient_id, race_category, ethnicity_category, sex_category, language_name, 
    race_conflict, ethnicity_conflict, sex_conflict, language_conflict)]

# Display the conflicted_patient_details table
conflicted_patient_details
