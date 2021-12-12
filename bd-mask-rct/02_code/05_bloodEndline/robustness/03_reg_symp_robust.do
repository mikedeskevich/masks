* ---------------------------------------------------------------------
* Title:    Run Main Second Stage Regressions (Symptomatic-Status)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Runs second stage regressions with WHO-defined COVID
*           symptomatic status at endline as an outcome, using equivalent
*           sample to the regressions w/ symptomatic-seroprevalence as 
*           an outcome.
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


* (5) Symptomatic Status (Pooled, Linear)
* ---------------------------------------------------------------------
* With Baseline Controls
reghdfe symp treatment proper_mask_base prop_resp_ill_base_2, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\symp_sero_sample\5a_symp_pool.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* No Baseline Controls
reghdfe symp treatment, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\symp_sero_sample\5b_symp_pool_no_base.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* (6) Symptomatic Status (By Mask Type, Linear)
* ---------------------------------------------------------------------
* With Baseline Controls
reghdfe symp treat_surg treat_cloth proper_mask_base prop_resp_ill_base_2, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\symp_sero_sample\6a_symp_mask.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* No Baseline Controls
reghdfe symp treat_surg treat_cloth, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\symp_sero_sample\6b_symp_mask_no_base.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* (7) Symptomatic Status (Pooled, Proportional)
* ---------------------------------------------------------------------
preserve
* Drop Pairs Which Don't Have any Adults that are Symptomatic
bys pairID: egen count_symp = total(symp)
drop if count_symp == 0

* With Baseline Controls
glm symp treatment proper_mask_base prop_resp_ill_base_2 i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat Symp = J(1,6,.)
mat Symp[1,1] = _b[treatment]
mat Symp[1,2] = r["ll","symp:treatment"]
mat Symp[1,3] = r["ul","symp:treatment"]
mat Symp[1,4] = r["pvalue","symp:treatment"]
mat Symp[1,5] = `=e(N)'
mat Symp[1,6] = `=e(N_clust)'

* No Baseline Controls
glm symp treatment i.pairID, family(poisson) link(log) vce(cluster union)
mat SympNoBase = J(1,6,.)
mat SympNoBase[1,1] = _b[treatment]
mat SympNoBase[1,2] = r["ll","symp:treatment"]
mat SympNoBase[1,3] = r["ul","symp:treatment"]
mat SympNoBase[1,4] = r["pvalue","symp:treatment"]
mat SympNoBase[1,5] = `=e(N)'
mat SympNoBase[1,6] = `=e(N_clust)'

* (8) Symptomatic Status (By Mask Type, Proportional)
* ---------------------------------------------------------------------
glm symp treat_surg treat_cloth proper_mask_base prop_resp_ill_base_2 i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympMask = J(1,10,.)
mat SympMask[1,1] = _b[treat_surg]
mat SympMask[1,2] = r["ll","symp:treat_surg"]
mat SympMask[1,3] = r["ul","symp:treat_surg"]
mat SympMask[1,4] = r["pvalue","symp:treat_surg"]
mat SympMask[1,5] = _b[treat_cloth]
mat SympMask[1,6] = r["ll","symp:treat_cloth"]
mat SympMask[1,7] = r["ul","symp:treat_cloth"]
mat SympMask[1,8] = r["pvalue","symp:treat_cloth"]
mat SympMask[1,9] = `=e(N)'
mat SympMask[1,10] = `=e(N_clust)'

* Mask Type, No Baseline Controls
glm symp treat_surg treat_cloth i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympMaskNoBase = J(1,10,.)
mat SympMaskNoBase[1,1] = _b[treat_surg]
mat SympMaskNoBase[1,2] = r["ll","symp:treat_surg"]
mat SympMaskNoBase[1,3] = r["ul","symp:treat_surg"]
mat SympMaskNoBase[1,4] = r["pvalue","symp:treat_surg"]
mat SympMaskNoBase[1,5] = _b[treat_cloth]
mat SympMaskNoBase[1,6] = r["ll","symp:treat_cloth"]
mat SympMaskNoBase[1,7] = r["ul","symp:treat_cloth"]
mat SympMaskNoBase[1,8] = r["pvalue","symp:treat_cloth"]
mat SympMaskNoBase[1,9] = `=e(N)'
mat SympMaskNoBase[1,10] = `=e(N_clust)'
restore


* Run Summary Stats
* ---------------------------------------------------------------------
qui gstats tab symp, s(mean) nomissing mata(M) columns(var) by(treatment)
qui mata MStats  = (1 \ 1), (0 \ 1), M.output


* Save Results
* ---------------------------------------------------------------------
* Pooled 
clear
svmat double Symp
save "${table_blood_end}\robustness\symp_sero_sample\7a_symp_pool.dta", replace

* Pooled, Without Baseline Controls
clear
svmat double SympNoBase
save "${table_blood_end}\robustness\symp_sero_sample\7b_symp_pool_no_base.dta", replace

* Mask Type
clear
svmat double SympMask
save "${table_blood_end}\robustness\symp_sero_sample\8a_symp_mask.dta", replace

* Mask Type, Without Baseline Controls
clear
svmat double SympMaskNoBase
save "${table_blood_end}\robustness\symp_sero_sample\8b_symp_mask_no_base.dta", replace

* Summary Stats
clear
mata stata(sprintf("set obs %g", rows(MStats)))
mata _addTypes = ("double", "double", "double")
mata _addNames = ("subgroup", "treatment", "mean_symp")
mata (void) st_addvar(_addTypes, _addNames)
mata st_store(., _addNames, MStats)
gen subgroup_str = "full"
drop subgroup
order subgroup_str treatment mean*
format mean* %5.4f
save "${table_blood_end}\robustness\symp_sero_sample\summ_stats_symp.dta", replace
