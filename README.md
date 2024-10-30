# Association of Patient's Preferred Language on Sedation Practices During Mechanical Ventilation.
## Objective
* Primary: Elucidate the association between EHR documented patient preferred language and rates of deep sedation in the first 48-hours of mechanical ventilation 
* Secondary: Determine the association between EHR documented patient preferred language and known long-term complications of early deep sedation including 30-day mortality and total time ventilated
* Secondary: Sub-group analyses among patients' from similar ethnic/racial backgrounds to explore the association of language on rates of deep sedation

## Required CLIF Tables and fields
Please refer to the online CLIF data dictionary, ETL tools, and specific table contacts for more information on constructing the required tables and fields. List all required tables for the project here, and provide a brief rationale for why they are required.

### To identify hospitalizations with periods of mechanical ventilation
* `respiratory_support`
    - `hospitalization_id`, `recorded_dttm`, `tracheostomy`
    - `device_category %in% c("IMV", "Trach Collar")`
* `hospitalization`
     - `patient_id`, `hospitalization_id`, `admission_dttm`, `discharge_dttm`, `age_at_admission`, `discharge_category`
* `patient`

### To build sedation table, secondary analysis endpoints, and control variables (BMI, SOFA, sex, race, ethnicity, 30-day mortality, sedative meds)
* `patient_assessments`
    - `hospitalization_id`, `recorded_dttm`, `numerical_value`
    - `assessment_category %in% c("RASS", "gcs_total")`
* `vitals`
    - `hospitalization_id`, `recorded_dttm`, `vital_value`
    - `vital_catgories %in% c("sbp", "dbp", "height_cm", weight_kg")`
* `labs`
    - `hospitalization_id`, `lab_collect_dttm`, `lab_value_numeric`
    - `lab_category %in% c("creatinine", "bilirubin_total", "platelet_count", "po2_arterial")`
* `continuous_med_administration`
    - `hospitalization_id`, `admin_dttm`, `med_dose`, `med_dose_unit`
    - `med_category %in% c("dopamine", "dobutamine", "epinephrine", "norepineprhine", "propofol", "dexmedetomidine", "ketamine", "midazolam", "pentobarbital", "lorazepam")`
    - `med_group %in% c("paralytics")`
* `ADT`
    - `hospitalization_id`, `hospital_id`
* `hospitalization`
    - `patient_id`, `hospitalization_id`, `age_at_admission`
* `patient`
    - Need complete table including: `language_name`, `death_dttm`, `race_category`, `sex_category`, `ethnicity_category`
* `respiratory_support`
    - `hospitalization_id`, `recorded_dttm`, `fio2_set`
 
## Cohort Identification
Adults with documented IMV periods >24 hours. There are no date constraints.

## Expected Results
under construction

## Detailed Instructions
1. Run [CODE](https://github.com/weissman-lab/preferred_language_icu/tree/main/CODE)
2. Deposit results:

Please deposit your entire result_[SITE_NAME] folder in this [box folder](https://uchicago.box.com/s/fcaum7o8v59n9c1vy7xnboqy2in4t4ju)
