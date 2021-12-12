* ---------------------------------------------------------------------
* Title:    Generate Union-Level Statistics on the Baseline Household Visit
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Generates dtas on household members demographics and baseline
*           respiratory illness during the baseline household visit.
* ---------------------------------------------------------------------

* Use Dataset (For Quick Reruns in the Same Day, Otherwise Comment Out)
* ---------------------------------------------------------------------
use  "${data_base}\01_clean\baseHH_data_ind.dta", clear


* Restrict to Unions that Have Full Surveillance Data
* ---------------------------------------------------------------------
* Note: Drop All Unions and Their Pairs that are Missing Baseline Surveillance Data
*       or All Surveillance Data During the Intervention Period (Week 1 - Week 8)
merge m:1 union using "${data_com}\01_clean\union_reg_sample.dta", keep(1 3) nogen
drop if surv_incomplete_pair == 1
drop surv_incomplete*


* Union-Level Summary Stats
* ---------------------------------------------------------------------
bys caseid: gen n_hh = (_n == 1)
gen member_count = 1

gcollapse (sum) n_resp_ill_base_1 = resp_ill_base_1 (sum) n_resp_ill_base_2 = resp_ill_base_2 (sum) n_hh (sum) member_count (sum) n_female = sex (median) med_age = age (mean) avg_age = age, by(district union treatment pairID)
gisid union

gen prop_female          = n_female/member_count
gen prop_resp_ill_base_1 = n_resp_ill_base_1/member_count
gen prop_resp_ill_base_2 = n_resp_ill_base_2/member_count
gen hh_size = member_count/n_hh

label var n_resp_ill_base_1 "Num. Adults w/ ILI symp w/in 7 days of baseline visit"
label var n_resp_ill_base_2 "Num. Adults w/ COVID-19 symp w/in 7 days of baseline visit"
label var n_female "Num. Female in Baseline HH Visit"
label var member_count "Num. Adult in Baseline HH Visit"
label var prop_female "Proportion Females in Baseline HH Visit"
label var prop_resp_ill_base_1 "Proportion of Adults w/ ILI symp w/in 7 days of baseline visit"
label var prop_resp_ill_base_2 "Proportion of Adults w/ COVID-19 symp w/in 7 days of baseline visit"
label var hh_size "Avg. Num. Adults in HH"
label var n_hh "Num. HHs"
label var avg_age "Average Age of Adults (Bins)"
label var med_age "Median Age of Adults (Bins)"

* Save Union-Level Stats
* ---------------------------------------------------------------------
save "${data_base}\01_clean\union_baseHH_data.dta", replace

