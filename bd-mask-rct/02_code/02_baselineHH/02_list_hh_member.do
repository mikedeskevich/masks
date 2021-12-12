* ---------------------------------------------------------------------
* Title:    List Household Members as Recorded in the Baseline Survey
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose: 	Converts data on baseline household visit from wide to long.
* ---------------------------------------------------------------------

* Load Data
* ---------------------------------------------------------------------
use  "${data_base}\01_clean\baseHH_data.dta", clear

* Create list
* ---------------------------------------------------------------------
local vill_rand "surgical cloth signage incentive text_village treat_color mask_treat_color surgical_pair cloth_pair"
local hh_rand "altruism_hh text_hh text_hh_ind commit_hh" 
keep district union treatment pairID wave `vill_rand' `hh_rand' caseid name* age* sex* resp_ill_base_1_m_* resp_ill_base_2_m*
gisid union caseid

* Convert Wide to Long
greshape long name age sex resp_ill_base_1_m_ resp_ill_base_2_m_, i(district union treatment pairID caseid) j(member)
drop if name == ""
drop member
gduplicates drop
rename (resp_ill_base_1_m_ resp_ill_base_2_m_) (resp_ill_base_1 resp_ill_base_2)


* Fix Labels
label var resp_ill_base_1 "Adult had ILI w/in 7 days of baseline visit"
label var resp_ill_base_2 "Adult had COVID-19 symp w/in 7 days of baseline visit"
label var age "10-Year Age Bins (Lower Bound Inclusive)"

gen rand = uniform()
bys union caseid name (rand): gen count = _n
drop if count > 1
drop rand
drop count
isid union caseid name
disp _N

* Save Data
* ---------------------------------------------------------------------
save "${data_base}\01_clean\baseHH_data_ind.dta", replace
