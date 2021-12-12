* ---------------------------------------------------------------------
* Title:    List Household Members as Recorded in the Phone Survey
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose: 	Converts data on baseline household visit from wide to long.
* ---------------------------------------------------------------------

* Load Data
* ---------------------------------------------------------------------
use  "${data_followup}\01_clean\followupSurvey_data.dta", clear

* Create list
* ---------------------------------------------------------------------
drop if member_count == 0
keep district union treatment pairID caseid name* resp_ill_followup_1_m_* resp_ill_followup_2_m*
isid union caseid

* Convert Wide to Long
greshape long name resp_ill_followup_1_m_ resp_ill_followup_2_m_, i(district  union treatment pairID caseid) j(member)

drop if name == ""
drop member

gduplicates drop
rename (resp_ill_followup_1_m_ resp_ill_followup_2_m_) (resp_ill_followup_1 resp_ill_followup_2)


* Collapse to Individual Level
gcollapse (max) resp_ill_followup_1 (max) resp_ill_followup_2, by(district union treatment pairID caseid name)


* Fix Labels
label var resp_ill_followup_1 "Adult had ILI in in-person followup visit"
label var resp_ill_followup_2 "Adult had COVID-19 symp in in-person followup visit"

isid union caseid name
disp _N


* Save Data
* ---------------------------------------------------------------------
save "${data_followup}\01_clean\followupSurvey_data_ind.dta", replace
