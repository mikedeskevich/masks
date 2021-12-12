* ---------------------------------------------------------------------
* Title:    Run Main Second Stage Regressions (Symptomatic-Status)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Runs second stage regressions with symptomatic Status
*           at endline as an outcome by sex.
* ---------------------------------------------------------------------                                          
* Set up Loop
*---------------------------------------------------------------------
mat Symp = J(2,6,.)
mat SympNoBase = J(2,6,.)
mat SympMask = J(2,10,.)
mat SympMaskNoBase = J(2,10,.)


forvalues i = 1/2{

* Load Data
use "${data_blood_end}\01_clean\endlineBlood_data.dta", clear
	
* Define Regression Sample
*---------------------------------------------------------------------
* Drop All Individuals Identified in Baseline that We Did Not Collect
* Symptom Data on in the Midline or Endline Surveys
drop if mi_symp == 1 


* Set up Regressions
* ---------------------------------------------------------------------
if `i' == 1{
	local doc_title "male"
	local subsample "Male"
	keep if sex == 0
}
if `i' == 2{
	local doc_title "female"
	local subsample "Female"
	keep if sex == 1
}

* Set up Regressions
* ---------------------------------------------------------------------
local replace_choice "append"
if `i' == 1{
	local replace_choice "replace"
}


* Run Regressions
*---------------------------------------------------------------------

* With Baseline Controls
reghdfe symp treatment proper_mask_base prop_resp_ill_base_2, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\sex\5a_symp_pool.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* No Baseline Controls
reghdfe symp treatment, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\sex\5b_symp_pool_no_base.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* (6) Symptomatic Status (By Mask Type, Linear)
* ---------------------------------------------------------------------
* With Baseline Controls
reghdfe symp treat_surg treat_cloth proper_mask_base prop_resp_ill_base_2, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\sex\6a_symp_mask.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* No Baseline Controls
reghdfe symp treat_surg treat_cloth, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\sex\6b_symp_mask_no_base.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* (7) Symptomatic Status (Pooled, Proportional)
* ---------------------------------------------------------------------
preserve
* Drop Pairs Which Don't Have any Adults that are Symptomatic
bys pairID: egen count_symp = total(symp)
drop if count_symp == 0

* With Baseline Controls
glm symp treatment proper_mask_base prop_resp_ill_base_2 i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat Symp[`i',1] = _b[treatment]
mat Symp[`i',2] = r["ll","symp:treatment"]
mat Symp[`i',3] = r["ul","symp:treatment"]
mat Symp[`i',4] = r["pvalue","symp:treatment"]
mat Symp[`i',5] = `=e(N)'
mat Symp[`i',6] = `=e(N_clust)'

* No Baseline Controls
glm symp treatment i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympNoBase[`i',1] = _b[treatment]
mat SympNoBase[`i',2] = r["ll","symp:treatment"]
mat SympNoBase[`i',3] = r["ul","symp:treatment"]
mat SympNoBase[`i',4] = r["pvalue","symp:treatment"]
mat SympNoBase[`i',5] = `=e(N)'
mat SympNoBase[`i',6] = `=e(N_clust)'

* (8) Symptomatic Status (By Mask Type, Proportional)
* ---------------------------------------------------------------------
glm symp treat_surg treat_cloth proper_mask_base prop_resp_ill_base_2 i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympMask[`i',1] = _b[treat_surg]
mat SympMask[`i',2] = r["ll","symp:treat_surg"]
mat SympMask[`i',3] = r["ul","symp:treat_surg"]
mat SympMask[`i',4] = r["pvalue","symp:treat_surg"]
mat SympMask[`i',5] = _b[treat_cloth]
mat SympMask[`i',6] = r["ll","symp:treat_cloth"]
mat SympMask[`i',7] = r["ul","symp:treat_cloth"]
mat SympMask[`i',8] = r["pvalue","symp:treat_cloth"]
mat SympMask[`i',9] = `=e(N)'
mat SympMask[`i',10] = `=e(N_clust)'

* Mask Type, No Baseline Controls
glm symp treat_surg treat_cloth i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympMaskNoBase[`i',1] = _b[treat_surg]
mat SympMaskNoBase[`i',2] = r["ll","symp:treat_surg"]
mat SympMaskNoBase[`i',3] = r["ul","symp:treat_surg"]
mat SympMaskNoBase[`i',4] = r["pvalue","symp:treat_surg"]
mat SympMaskNoBase[`i',5] = _b[treat_cloth]
mat SympMaskNoBase[`i',6] = r["ll","symp:treat_cloth"]
mat SympMaskNoBase[`i',7] = r["ul","symp:treat_cloth"]
mat SympMaskNoBase[`i',8] = r["pvalue","symp:treat_cloth"]
mat SympMaskNoBase[`i',9] = `=e(N)'
mat SympMaskNoBase[`i',10] = `=e(N_clust)'
restore

* Run Summary Stats
* ---------------------------------------------------------------------
qui gstats tab symp, s(mean) nomissing mata(M) columns(var) by(treatment)
qui mata MStats`i'  = (`i' \ `i'), (0 \ 1), M.output

}


* Save Results
* ---------------------------------------------------------------------
* Pooled 
clear
svmat double Symp
save "${table_blood_end}\robustness\sex\7a_symp_pool.dta", replace

* Pooled, Without Baseline Controls
clear
svmat double SympNoBase
save "${table_blood_end}\robustness\sex\7b_symp_pool_no_base.dta", replace

* Mask Type
clear
svmat double SympMask
save "${table_blood_end}\robustness\sex\8a_symp_mask.dta", replace

* Mask Type, Without Baseline Controls
clear
svmat double SympMaskNoBase
save "${table_blood_end}\robustness\sex\8b_symp_mask_no_base.dta", replace

* Summary Stats
mata MStats = MStats1 \ MStats2

clear
mata stata(sprintf("set obs %g", rows(MStats)))
mata _addTypes = ("double", "double", "double")
mata _addNames = ("subgroup", "treatment", "mean_symp")
mata (void) st_addvar(_addTypes, _addNames)
mata st_store(., _addNames, MStats)
gen subgroup_str = ""

replace subgroup_str = "Male" if subgroup == 1
replace subgroup_str = "Female" if subgroup == 2

drop subgroup
order subgroup_str treatment mean*
format mean* %5.4f
save "${table_blood_end}\robustness\sex\summ_stats_symp.dta", replace

