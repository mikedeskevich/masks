* ---------------------------------------------------------------------
* Title:    Generate Union-Level Statistics on Mask Wearing
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Generates dtas on mask wearing statistics at the union-level
*           during the baseline and intervention period.
* ---------------------------------------------------------------------

* Use Dataset (For Quick Reruns in the Same Day, Otherwise Comment Out)
* ---------------------------------------------------------------------
use  "${data_surv}\01_clean\surv_data.dta", clear

* Restrict to Unions that Have Full Surveillance Data
* ---------------------------------------------------------------------
* Note: Drop All Unions and Their Pairs that are Missing Baseline Surveillance Data
*       or All Surveillance Data During the Intervention Period (Week 1 - Week 8)
merge m:1 union using "${data_com}\01_clean\union_reg_sample.dta", keep(1 3) nogen
drop if surv_incomplete_pair == 1
drop surv_incomplete*


* Union-Level Summary Stats on Baseline Mask Wearing
* ---------------------------------------------------------------------
preserve
keep if week_gen == 1
gcollapse (sum) n_surv_total (sum) n_surv_female (sum) n_surv_male (sum) n_proper_mask (sum) n_proper_mask_f (sum) n_proper_mask_m (sum) n_proper_improper_mask (sum) n_proper_improper_mask_f (sum) n_proper_improper_mask_m (sum) n_improper_mask (sum) n_improper_mask_m (sum) n_improper_mask_f (sum) n_soc_dist, by(union treatment pairID)
gisid union

bys union: gen proper_mask_base = n_proper_mask/n_surv_total
bys union: gen proper_improper_mask_base = n_proper_improper_mask/n_surv_total
bys union: gen improper_mask_base = n_improper_mask/n_surv_total
bys union: gen soc_dist_base = n_soc_dist/n_surv_total

bys union: gen proper_mask_base_f = n_proper_mask_f/n_surv_female
bys union: gen proper_improper_mask_base_f = n_proper_improper_mask_f/n_surv_female
bys union: gen improper_mask_base_f = n_improper_mask_f/n_surv_female
assert !mi(proper_mask_base_f) if n_surv_female > 0
assert !mi(proper_improper_mask_base_f) if n_surv_female > 0
assert !mi(improper_mask_base_f) if n_surv_female > 0

bys union: gen proper_mask_base_m = n_proper_mask_m/n_surv_male
bys union: gen proper_improper_mask_base_m = n_proper_improper_mask_m/n_surv_male
bys union: gen improper_mask_base_m = n_improper_mask_m/n_surv_male
assert !mi(proper_mask_base_m) if n_surv_male > 0
assert !mi(proper_improper_mask_base_m) if n_surv_male > 0
assert !mi(improper_mask_base_m) if n_surv_male > 0

rename n_surv_total n_surv_total_base
rename n_proper_mask n_proper_mask_base
assert !mi(n_surv_total_base)

save "${data_surv}\01_clean\union_surv_data_base.dta", replace
restore

* Union-Level Summary Stats on Mask Wearing During Intervention Period
* ---------------------------------------------------------------------
preserve
keep if week_gen >= 2 & week_gen <=6 //Drop Baseline Data (Pre Intervention), Week 10 Data (Post Intervention), and Follow-up Data (Post Intervention)
gcollapse (sum) n_surv_total (sum) n_surv_female (sum) n_surv_male (sum) n_proper_mask (sum) n_proper_mask_f (sum) n_proper_mask_m (sum) n_proper_improper_mask (sum) n_proper_improper_mask_f (sum) n_proper_improper_mask_m (sum) n_improper_mask (sum) n_improper_mask_m (sum) n_improper_mask_f (sum) n_soc_dist, by(union treatment pairID)
gisid union

bys union: gen proper_mask_prop = n_proper_mask/n_surv_total
bys union: gen proper_improper_mask_prop = n_proper_improper_mask/n_surv_total
bys union: gen improper_mask_prop = n_improper_mask/n_surv_total
bys union: gen soc_dist_prop = n_soc_dist/n_surv_total

bys union: gen proper_mask_prop_f = n_proper_mask_f/n_surv_female
bys union: gen proper_improper_mask_prop_f = n_proper_improper_mask_f/n_surv_female
bys union: gen improper_mask_prop_f = n_improper_mask_f/n_surv_female
assert !mi(proper_mask_prop_f) if n_surv_female > 0
assert !mi(proper_improper_mask_prop_f) if n_surv_female > 0
assert !mi(improper_mask_prop_f) if n_surv_female > 0

bys union: gen proper_mask_prop_m = n_proper_mask_m/n_surv_male
bys union: gen proper_improper_mask_prop_m = n_proper_improper_mask_m/n_surv_male
bys union: gen improper_mask_prop_m = n_improper_mask_m/n_surv_male
assert !mi(proper_mask_prop_m) if n_surv_male > 0
assert !mi(proper_improper_mask_prop_m) if n_surv_male > 0
assert !mi(improper_mask_prop_m) if n_surv_male > 0
assert !mi(n_surv_total)

save "${data_surv}\01_clean\union_surv_data_intervention.dta", replace
restore



* Union-Level Summary Stats
use "${data_surv}\01_clean\union_surv_data_intervention.dta", clear
merge m:1 union using "${data_surv}\01_clean\union_surv_data_base.dta", keep(1 3) gen(_base)
assert _base == 3
drop _base
save "${data_surv}\01_clean\union_surv_data.dta", replace
