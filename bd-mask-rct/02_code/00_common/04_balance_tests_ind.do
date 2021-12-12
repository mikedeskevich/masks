* ---------------------------------------------------------------------
* Title:    Balance Tests (Individual-Level)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Runs balance tests on baseline variables at the individual level.
* ---------------------------------------------------------------------

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


* Run Regressions
*---------------------------------------------------------------------
* (1) Baseline Symptomatic-Seropositivity
reghdfe posXsymp_base treatment, absorb(pairID) vce(cluster union)
regsave using "${table_com}\2_balance_test_ind.dta", table(symp_sero, format(%6.5f) parentheses(stderr) asterisk()) addlabel(subsample, "Baseline Symptomatic-Seroprevalence") replace


* (2) Baseline WHO-defined COVID Symptomatic Status
reghdfe resp_ill_base_2 treatment, absorb(pairID) vce(cluster union)
regsave using "${table_com}\2_balance_test_ind.dta", table(covid_symp, format(%6.5f) parentheses(stderr) asterisk()) addlabel(subsample, "Baseline WHO COVID Symptoms") append


* (3) Baseline Mask Wearing Rate
reghdfe proper_mask_base treatment, absorb(pairID) vce(cluster union)
regsave using "${table_com}\2_balance_test_ind.dta", table(mask_surv, format(%6.5f) parentheses(stderr) asterisk()) addlabel(subsample, "Baseline Mask Wearing") append

* F-Test
* ---------------------------------------------------------------------
* Symptomatic-Seropositivity Status
qui reg posXsymp_base treatment i.pairID
estimates store r1

* WHO-COVID Symptoms
qui reg resp_ill_base_2 treatment i.pairID
estimates store r2

* Proper Mask Wearing
qui reg proper_mask_base treatment i.pairID
estimate store r3

* F-Test
qui suest r1 r2 r3, vce(cluster union)
test treatment
