* ---------------------------------------------------------------------
* Title:    List Household Members as Recorded in the Phone Survey
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose: 	Converts data on baseline household visit from wide to long.
* ---------------------------------------------------------------------

* Load Data
* ---------------------------------------------------------------------
use  "${data_phone}\01_clean\phoneSurvey_data.dta", clear

* Create list
* ---------------------------------------------------------------------
keep district union treatment pairID caseid name* followup_week resp_ill_phone_1_m_* resp_ill_phone_2_m*
isid union caseid followup_week

* Convert Wide to Long
greshape long name resp_ill_phone_1_m_ resp_ill_phone_2_m_, i(district union treatment pairID caseid followup_week) j(member)
drop if name == ""
drop member
gduplicates drop
rename (resp_ill_phone_1_m_ resp_ill_phone_2_m_) (resp_ill_phone_1 resp_ill_phone_2)

* Collapse to Individual Level
gcollapse (max) resp_ill_phone_1 (max) resp_ill_phone_2, by(district union treatment pairID caseid name)

* Fix Labels
label var resp_ill_phone_1 "Adult had ILI in phone survey"
label var resp_ill_phone_2 "Adult had COVID-19 symp in phone survey"

isid union caseid name
disp _N
distinct caseid


* Save Data
* ---------------------------------------------------------------------
save "${data_phone}\01_clean\phoneSurvey_data_ind.dta", replace
