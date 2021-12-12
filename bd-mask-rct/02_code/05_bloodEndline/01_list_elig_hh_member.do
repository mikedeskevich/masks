* ---------------------------------------------------------------------
* Title:    List Individuals Eligible for Blood Draw
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose: 	Generates lists of individuals identified in baseline household
*           visit that are eligible for blood draws - i.e. have WHO-defined
*           COVID symptoms in midline and endline surveys, or had a blood-
*           draw in the baseline.
* ---------------------------------------------------------------------

* Individuals Which Had Baseline Blood Draws
* ---------------------------------------------------------------------
use "${data_com}\00_raw\blood_baseline.dta", clear

* Append Individuals Identified in Phone Survey
* ---------------------------------------------------------------------
append using "${data_phone}\01_clean\phoneSurvey_data_ind.dta", gen(_phone)

* Append in Individuals Identified in In-Person Followup
* ---------------------------------------------------------------------
append using "${data_followup}\01_clean\followupSurvey_data_ind.dta", gen(_followup)
replace baseline = 0 if mi(baseline)

* Identify if Individuals Ever Have WHO-Defined COVID Symptoms in Midline
* or Endline Surveys
* ---------------------------------------------------------------------
gen byte symp = (resp_ill_phone_2 == 1) | (resp_ill_followup_2 == 1)
gcollapse (max) symp (max) baseline, by(district union treatment pairID caseid name)
label var symp "Adult had COVID-19 symp in midline or endline surveys"
label var baseline "Adult had baseline blood draw"

gen eligible = (symp == 1) | (baseline == 1)
label var eligible "Adult eligible for endline blood draw"


tempfile ListEligible
save `ListEligible'

* Load Individual-Level Data of All Baseline Members
* ---------------------------------------------------------------------
use "${data_base}\01_clean\baseHH_data_ind.dta", clear

merge m:1 union caseid name using `ListEligible', keep(1 3) gen(_elig)
gen mi_symp = (_elig == 1)
label var mi_symp "Did not collect data on symptoms from individual in basline or endline visits"
replace symp = 0 if _elig == 1
replace baseline = 0 if _elig == 1
replace eligible = 0 if _elig == 1
assert !mi(symp)
assert !mi(eligible)
assert !mi(baseline)
drop _elig

assert eligible == 1 if symp == 1
assert eligible == 1 if baseline == 1


* Save Data
* ---------------------------------------------------------------------
save "${data_blood_end}\01_clean\bloodDraw_elig_ind.dta", replace
