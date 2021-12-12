* ---------------------------------------------------------------------
* Title:    Randomization Inference (Symptomatic-Seropositivity)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Performs 1000 iterations of randomly reassigning treatment
*           status within pairs and runs regressions with symptomatic-
*           seropositivity as outcome.
* ---------------------------------------------------------------------

* Set up Loop
*---------------------------------------------------------------------
matrix serosymp=J(1000,3,.)
matrix serosymp_nobase=J(1000,3,.)


forvalues qq = 1/1000{

* Load Data Individuals w/ Symptomatic and Symptomatic-Seropositivity Status
*---------------------------------------------------------------------
use "${data_blood_end}\01_clean\endlineBlood_data.dta", clear

* Drop All Individuals Identified in Baseline that We Did Not Collect
* Symptom Data on in the Midline or Endline Surveys
drop if mi_symp == 1 

* Drop All Individuals that Were Symptomatic in Midline or Endline,
* But We Did not Draw Their Blood
drop if elig_no_blood == 1

* Drop All Individuals that we thought we drew blood from, but couldn't
* match to a sample
drop if recorded_blood_no_result == 1


* Randomly Assign Treatment Status
* ---------------------------------------------------------------------
drop treatment

preserve
qui keep union pairID
qui gduplicates drop
* Randomly Assign Treatment Status within Pairs
gen rand = uniform()
bys pairID (rand): gen treatment = (_n == 2)
* Checks
bys pairID: assert(_N == 2)
bys pairID: egen count_treat = total(treatment)
assert count_treat == 1
keep union pairID treatment
isid union
tempfile NewTreatment
save `NewTreatment'
restore

qui merge m:1 union using `NewTreatment', keep(1 3) gen(_treat_rand)
assert _treat_rand == 3
drop _treat_rand
assert !mi(treatment)


* Run Regressions
*---------------------------------------------------------------------

* (1) Symptomatic-Seropositivity (Pooled, Linear)
* ---------------------------------------------------------------------
* With Baseline Controls
qui reghdfe posXsymp treatment proper_mask_base prop_resp_ill_base_2, absorb(pairID) vce(cluster union)
matrix serosymp[`qq',1] = `qq'
matrix serosymp[`qq',2] = _b[treatment]
matrix serosymp[`qq',3] = _se[treatment]
	
* No Baseline Controls
qui reghdfe posXsymp treatment, absorb(pairID) vce(cluster union)
matrix serosymp_nobase[`qq',1] = `qq'
matrix serosymp_nobase[`qq',2] = _b[treatment]
matrix serosymp_nobase[`qq',3] = _se[treatment]

}


* Save Data
*---------------------------------------------------------------------
* With Baseline Controls
clear
svmat double serosymp
rename *1 num
rename *2 coeff
rename *3 se
drop if mi(coeff)
save "${table_blood_end}\robustness\rand_inf\1a_symp_sero_pool.dta", replace

* No Baseline Controls
clear
svmat double serosymp_nobase
rename *1 num
rename *2 coeff
rename *3 se
drop if mi(coeff)
save "${table_blood_end}\robustness\rand_inf\1b_symp_sero_pool_no_base.dta", replace
