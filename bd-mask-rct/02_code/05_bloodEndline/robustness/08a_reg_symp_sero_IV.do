* ---------------------------------------------------------------------
* Title:    IV Regression (Symptomatic-Seropositivity)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Runs IV regressions with symptomatic-seropositivity as outcome
*           and treatment status as the instrument.
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

* Set up Regressions
* ---------------------------------------------------------------------
local doc_title "full"
local replace_choice "replace"
local subsample "Full"

* Run Regressions
*---------------------------------------------------------------------

* (1) Symptomatic-Seropositivity (IV)
* ---------------------------------------------------------------------
* With Baseline Controls
ivreghdfe posXsymp (proper_mask_prop = treatment) proper_mask_base prop_resp_ill_base_2, absorb(pairID) cluster(union)
regsave using "${table_blood_end}\robustness\iv\1a_symp_sero_pool.dta", table(symp_sero_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* No Baseline Controls
ivreghdfe posXsymp (proper_mask_prop = treatment), absorb(pairID) cluster(union)
regsave using "${table_blood_end}\robustness\iv\1b_symp_sero_pool_no_base.dta", table(symp_sero_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'
