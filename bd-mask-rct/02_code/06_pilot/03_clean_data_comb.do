* ---------------------------------------------------------------------
* Title:    Combine Pilot Data
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Combines Pilot 1, Pilot 2, and Main Intervention Surveillance
*           data.
* ---------------------------------------------------------------------

* Load Pilot 1 Data
* ---------------------------------------------------------------------
use "${data_pilot}\01_clean\surv_pilot1.dta", clear
gen pilot = 1

* Merge in Pilot 2 Data
* ---------------------------------------------------------------------
append using "${data_pilot}\01_clean\surv_pilot2.dta", gen(_p_2)
replace pilot = 2 if mi(pilot)

label define pilot 0 "Main Intervention" 1 "Pilot 1" 2 "Pilot 2"
label values pilot pilot
tab pilot

* Collapse to Union Level, Baseline
* ---------------------------------------------------------------------
preserve
keep if post == 0
gcollapse (sum) n_surv_total (sum) n_proper_mask (sum) n_soc_dist, by(vill_id treatment pilot)
gisid vill_id

gen proper_mask_base = n_proper_mask/n_surv_total
gen soc_dist_base = n_soc_dist/n_surv_total
assert !mi(proper_mask_base)
assert !mi(soc_dist_base)

tempfile BaselineStats
save `BaselineStats'
restore

* Collapse to Union Level, Endline
* ---------------------------------------------------------------------
keep if post == 1
gcollapse (sum) n_surv_total (sum) n_proper_mask (sum) n_soc_dist, by(vill_id treatment)
gisid vill_id

merge 1:1 vill_id using `BaselineStats', keep(1 3) gen(_base)
assert !mi(proper_mask_base)
assert !mi(soc_dist_base)
drop _base
	
gen proper_mask_prop = n_proper_mask/n_surv_total
gen soc_dist_prop = n_soc_dist/n_surv_total
assert !mi(proper_mask_prop)
assert !mi(soc_dist_prop)
assert !mi(treatment)

rename vill_id union

* Merge in Union-Level Data from Main Intervention
* ---------------------------------------------------------------------
append using "${data_surv}\01_clean\union_surv_data.dta"
replace pilot = 0 if mi(pilot)

keep union treatment n_surv_total n_proper_mask n_soc_dist pilot proper_mask_base soc_dist_base proper_mask_prop soc_dist_prop

gen no_pilot = (pilot == 0)
gen pilot_1 = (pilot == 1)
gen pilot_2 = (pilot == 2)

gen treat_pilot_1 = treatment * pilot_1
gen treat_pilot_2 = treatment * pilot_2

* Save Combined Data
* ---------------------------------------------------------------------
save "${data_pilot}\01_clean\surv_pilot_comb.dta", replace
