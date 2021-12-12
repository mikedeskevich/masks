* ---------------------------------------------------------------------
* Title:    Combines Union-Level Statistics on Baseline 
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Generates dtas on household members demographics and baseline
*           respiratory illness during the baseline household visit.
* ---------------------------------------------------------------------

* Combine Union-Level Statistics
* ---------------------------------------------------------------------
* Baseline Household Visit
use "${data_base}\01_clean\union_baseHH_data.dta", clear

* Baseline Mask Wearing
merge 1:1 union using "${data_surv}\01_clean\union_surv_data_base.dta", keep(1 3) gen(_base_surv)
assert _base_surv == 3
drop _base_surv

* Baseline Symptomatic-Seropositivity
merge 1:1 union using "${data_com}\00_raw\union_baseline_blood_stats.dta", keep(1 3) gen(_base_blood)
assert _base_blood == 3
drop _base_blood

assert _N == 572


* Save Data
* ---------------------------------------------------------------------
save "${data_com}\01_clean\union_data_base.dta", replace
