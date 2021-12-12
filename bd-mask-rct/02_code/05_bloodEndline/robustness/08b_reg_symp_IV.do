* ---------------------------------------------------------------------
* Title:    IV Regression (Symptomatic-Status)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Runs IV regressions with symptomatic status as outcome
*           and treatment status as the instrument.
* ---------------------------------------------------------------------

* Load Data Individuals w/ Symptomatic and Symptomatic-Seropositivity Status
*---------------------------------------------------------------------
use "${data_blood_end}\01_clean\endlineBlood_data.dta", clear


* Define Regression Sample
*---------------------------------------------------------------------
* Drop All Individuals Identified in Baseline that We Did Not Collect
* Symptom Data on in the Midline or Endline Surveys
drop if mi_symp == 1 


* Set up Regressions
* ---------------------------------------------------------------------
local doc_title "full"
local replace_choice "replace"
local subsample "Full"


* (5) Symptomatic Status (Pooled, Linear)
* ---------------------------------------------------------------------
* With Baseline Controls
ivreghdfe symp (proper_mask_prop = treatment) proper_mask_base prop_resp_ill_base_2, absorb(pairID) cluster(union)
regsave using "${table_blood_end}\robustness\iv\2a_symp_pool.dta", table(symp_sero_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* No Baseline Controls
ivreghdfe symp (proper_mask_prop = treatment), absorb(pairID) cluster(union)
regsave using "${table_blood_end}\robustness\iv\2b_symp_pool_no_base.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

