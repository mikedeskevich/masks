* ---------------------------------------------------------------------
* Title:    Clean Data - Pilot 2 Surveillance
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Cleans pilot 2 surveillance data and merges in variables.
* ---------------------------------------------------------------------

* Load Data
*---------------------------------------------------------------------
use "${data_pilot}\00_raw\surv_pilot2.dta", clear


* Count Mask Wearing and Physical Distancing
*---------------------------------------------------------------------
gen n_surv_total = 0
gen n_proper_mask = 0
gen n_project_mask = 0
gen n_improper_mask = 0
gen n_proper_improper_mask = 0
gen n_soc_dist = 0

forvalues num = 1 / 500000 {
	
	cap confirm var mask_a`num'
    if (_rc) continue, break
	
	* Total Observations
    qui gen count_`num' = 0
    qui replace count_`num' = 1 if (mask_a`num' == 1) | (mask_a`num' == 2) | (mask_a`num' == 3) | (mask_a`num' == 4) | (mask_a`num' == 5)
	qui replace n_surv_total = count_`num' + n_surv_total
	qui drop count_`num'
	
	* Proper Mask Wearing
	qui gen proper_mask_`num' = 0
	qui replace proper_mask_`num' = 1 if (mask_a`num' == 1)
	assert !mi(proper_mask_`num')
	qui replace n_proper_mask = proper_mask_`num' + n_proper_mask
	qui drop proper_mask_`num'
	
	* Improper Mask Wearing
	qui gen improper_mask_`num' = 0
	qui replace improper_mask_`num'  = 1 if (mask_a`num' == 2) | (mask_a`num' == 3) | (mask_a`num' == 4) 
	qui replace n_improper_mask = improper_mask_`num' + n_improper_mask
	qui drop improper_mask_`num'
	
	* Proper + Improper Mask Wearing
	qui gen proper_improper_mask_`num' = 0
	qui replace proper_improper_mask_`num'  = 1 if (mask_a`num' == 1) | (mask_a`num' == 2) | (mask_a`num' == 3) | (mask_a`num' == 4) 
	qui replace n_proper_improper_mask = proper_improper_mask_`num' + n_proper_improper_mask
	qui drop proper_improper_mask_`num'

	* Social Distancing
	qui gen soc_dist_`num' = 0
	qui replace soc_dist_`num' = 1 if (social_distance`num'==1)
	qui replace n_soc_dist = soc_dist_`num' + n_soc_dist
	qui drop soc_dist_`num'
	
}


drop mask_a*
drop mask_c*
drop mask_d*
drop social_distance*

* Check
assert n_proper_mask            <= n_surv_total
assert n_improper_mask          <= n_surv_total
assert n_proper_improper_mask   <= n_surv_total
assert n_project_mask           <= n_surv_total
assert n_soc_dist               <= n_surv_total
assert n_project_mask           <= n_proper_mask
assert n_proper_mask + n_improper_mask == n_proper_improper_mask
assert !mi(n_proper_mask)
assert !mi(n_improper_mask)
assert !mi(n_proper_improper_mask)
assert !mi(n_soc_dist)

* Indicate if surveillance is pre- or post- intervention
* ---------------------------------------------------------------------
gen post = 0 if (baseline == 0)
replace post = 1 if (baseline == 1) | (baseline == 2)
label define post 0 "No" 1 "Yes"
label values post post
label var post "Surveillance Occurs Post Intervention"
assert !mi(post)

* Indicate periods of surveillance
* ---------------------------------------------------------------------
rename baseline period
label define period 0 "baseline" 1 "followup-1" 2 "followup-2"
label values period period
label var period "Period of Surveillance"
assert !mi(period)

* Save Data
* ---------------------------------------------------------------------
order vill_id treatment date site_name period post
save "${data_pilot}\01_clean\surv_pilot2.dta", replace
