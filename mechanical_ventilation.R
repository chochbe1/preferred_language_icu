# Create table of mechanically ventilated patients

# Load the data.table package
library(data.table)

# Load Raw CLIF Files

respiratory_support <- fread("/share/projects/data/circe/v20240331/clif/respiratory_support.csv.gz") 
hospitalization <- fread("/share/projects/data/circe/v20240331/clif/hospitalization.csv.gz") 
patient <- fread("/share/projects/data/circe/v20240331/clif/patient.csv.gz") 

# Convert CLIF Files for data.table format
setDT(patient)
setDT(hospitalization)
setDT(respiratory_support)

# Step 1: Clean Patient Table to Choose Most Recent Race, Ethnicity, Sex, and Language associated with a patient_ID

# Merge Patient and Hospitalization Tables
patient_hosp <- merge(patient, hospitalization, by = "patient_id", all.x = TRUE)

# Identify Patients with Conflicting Categories
patients_with_conflicts <- patient_hosp[, .(
  race_conflict = uniqueN(race_category) > 1,
  ethnicity_conflict = uniqueN(ethnicity_category) > 1,
  sex_conflict = uniqueN(sex_category) > 1,
  language_conflict = uniqueN(language_name) > 1
), by = patient_id]

conflicted_patients <- patients_with_conflicts[
  race_conflict == TRUE | ethnicity_conflict == TRUE |
    sex_conflict == TRUE | language_conflict == TRUE, 
  .(patient_id)]

# Sort by patient_ID and admission_dttm to get most recent admission first
setorder(patient_hosp, patient_id, -admission_dttm)

# Cleaned Patient Table
patient_clean <- patient_hosp[, .SD[1], by = patient_id]

# Will need to add a cleaning step here to create language_category column

# Step 2: Filter respiratory_support for device_category == "IMV"
filtered_resp <- respiratory_support[device_category == "IMV"]

# Step 3: Sort by hospitalization_id and recorded_dttm to ensure proper ordering
setorder(filtered_resp, hospitalization_id, recorded_dttm)

# Step 4: Calculate the time_intubated variable
filtered_resp[, first_intubation := min(recorded_dttm), by = hospitalization_id]  # Identify the first intubation time
filtered_resp[, time_intubated := as.numeric(difftime(recorded_dttm, first_intubation, units = "hours")), by = hospitalization_id]  # Calculate time since first intubation in hours

# Step 5: Calculate the total intubation time for each hospitalization_id
total_time_intubated <- filtered_resp[, .(total_intubated = sum(time_intubated)), by = hospitalization_id]

# Step 6: Merge total_time_intubated back to the original respiratory support data
filtered_resp <- merge(filtered_resp, total_time_intubated, by = "hospitalization_id")

# Step 7: Filter to keep all data for hospitalization_id where total time intubated is >= 24 hours
final_table <- filtered_resp[total_intubated >= 24]

# Step 8: Identify hospitalization_ids with IMV events (to use in final filtering)
imv_hospitalizations <- unique(final_table$hospitalization_id)

# Step 9: Merge with hospitalization and patient data, but keep only IMV hospitalizations
resp_with_hosp <- final_table[hospitalization, on = "hospitalization_id", allow.cartesian = TRUE]
final_table <- resp_with_hosp[patient_clean, on = "patient_id", allow.cartesian = TRUE]

# Step 10: Filter to only include hospitalization_ids with IMV events
final_table <- final_table[hospitalization_id %in% imv_hospitalizations]

# Step 11: Filter out patients under 18
final_table <- final_table[age_at_admission >= 18]

# Step 12: Filter out trached patients
hosp_with_trach <- final_table[time_intubated == 0 & tracheostomy == TRUE, unique(hospitalization_id)]
final_table <- final_table[!hospitalization_id %in% hosp_with_trach]

# Step 13: Select and order the final columns
final_table <- final_table[, .(patient_id, race_category, ethnicity_category, sex_category, language_name, age_at_admission, hospitalization_id, recorded_dttm, device_category, time_intubated)]

# Step 14: Optional - order by hospitalization_id and recorded_dttm for final output
setorder(final_table, hospitalization_id, recorded_dttm)

# Display the final table
final_table

# Count the number of unique patient_ids for each race_category
race_summary <- final_table[, .(num_patients = uniqueN(patient_id)), by = race_category]

# Display the result
race_summary

# Count the number of unique patient_ids for each race_category
language_summary <- final_table[, .(num_patients = uniqueN(patient_id)), by = language_name]

# Display the result
language_summary


final_table %>% distinct(patient_id)

