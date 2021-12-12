* ---------------------------------------------------------------------
* Title:    Generate Endline Blood Collection with Imputed Symptomatic-
*           Seropositvitiy Data
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Imputes symptomatic-seropositivity status for all Individuals
*           who we did not draw blood draw or could not analyze their blood.
* ---------------------------------------------------------------------

* Cleaned Endline Blood Collection
* ---------------------------------------------------------------------
use "${data_blood_end}\01_clean\endlineBlood_data.dta", clear

* Calculate Mean Rate of Seropositivity Among Symptomatic Blood Draws
* ---------------------------------------------------------------------
gen blood_draw_symp = (symp == 1) & (dum_endline_blood == 1)
label var blood_draw_symp "Symptomatic Individual Had Endline Blood Draw"

summarize positive if blood_draw_symp == 1
gen mean_symp = r(mean)
label var mean_symp "Average Seropositivity Rate Conditional on Having an Endline Blood Draw"

* Among Adults that Did not Consent to Blood Draw, Randomly Assign the Mean
* Rate of Seropositivity
* ---------------------------------------------------------------------
preserve
* All Individuals Eligible For Endline Blood Draw Who We Did not Draw Blood From
* Or Could Not Analyze Their Blood
keep if symp == 1 & (elig_no_blood == 1 | recorded_blood_no_result == 1)

* Randomly Assign Seropositivity, Up to Mean Rate in Union
bys union: gen percentile = _N * mean_symp
replace percentile = floor(percentile)
gen rand = uniform()
bys union (rand): replace posXsymp = 1 if _n <= percentile
rename posXsymp posXsymp_sim
keep union caseid name posXsymp_sim
assert !mi(posXsymp_sim)
tempfile RandAssignment
save `RandAssignment'
restore

merge m:1 union caseid name using `RandAssignment', keep(1 3) gen(_sim_pos)
replace posXsymp = posXsymp_sim if !mi(posXsymp_sim)
drop _sim_pos posXsymp_sim
drop mean_symp

label var posXsymp "Adult was symptomatic-seropositive at endline (Simulated)"

* Save
* ---------------------------------------------------------------------
save "${data_blood_end}\01_clean\endlineBlood_data_sim.dta", replace
