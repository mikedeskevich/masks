* ---------------------------------------------------------------------
* Title:    Run Main Second Stage Regressions (Symptomatic-Status)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Runs second stage regressions with WHO-defined COVID
*           symptomatic status at endline as an outcome, by decile of age.
* ---------------------------------------------------------------------

* Set up Loop
*---------------------------------------------------------------------
local age_bin btwn_18_30 btwn_30_40 btwn_40_50 btwn_50_60 btwn_60_70 above_70
mat Symp = J(6,6,.)
mat SympNoBase = J(6,6,.)
mat SympMask = J(6,10,.)
mat SympMaskNoBase = J(6,10,.)

foreach age of local age_bin{
	
* Load Data Individuals w/ Symptomatic and Symptomatic-Seropositivity Status
*---------------------------------------------------------------------
use "${data_blood_end}\01_clean\endlineBlood_data.dta", clear

* Drop All Individuals Identified in Baseline that We Did Not Collect
* Symptom Data on in the Midline or Endline Surveys
drop if mi_symp == 1 

* Set up Regressions
* ---------------------------------------------------------------------
local doc_title "`age'"
local subsample "`age'"
keep if `age' == 1
	
local i = `i' + 1
local replace_choice "append"
if `i' == 1{
	local replace_choice "replace"
}

* Run Regressions
*---------------------------------------------------------------------

* (5) Symptomatic Status (Pooled, Linear)
* ---------------------------------------------------------------------
* With Baseline Controls
reghdfe symp treatment proper_mask_base prop_resp_ill_base_2, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\age_dec\5a_symp_pool.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* No Baseline Controls
reghdfe symp treatment, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\age_dec\5b_symp_pool_no_base.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* (6) Symptomatic Status (By Mask Type, Linear)
* ---------------------------------------------------------------------
* With Baseline Controls
reghdfe symp treat_surg treat_cloth proper_mask_base prop_resp_ill_base_2, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\age_dec\6a_symp_mask.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* No Baseline Controls
reghdfe symp treat_surg treat_cloth, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\age_dec\6b_symp_mask_no_base.dta", table(symp_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* (7) Symptomatic Status (Pooled, Proportional)
* ---------------------------------------------------------------------
* Drop Pairs Which Don't Have any Adults that are Symptomatic
bys pairID: egen count_symp = total(symp)
drop if count_symp == 0

* With Baseline Controls
glm symp treatment proper_mask_base prop_resp_ill_base_2 i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat Symp[1,1] = _b[treatment]
mat Symp[1,2] = r["ll","symp:treatment"]
mat Symp[1,3] = r["ul","symp:treatment"]
mat Symp[1,4] = r["pvalue","symp:treatment"]
mat Symp[1,5] = `=e(N)'
mat Symp[1,6] = `=e(N_clust)'

* No Baseline Controls
glm symp treatment i.pairID, family(poisson) link(log) vce(cluster union)
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


* Summary Stats
* ---------------------------------------------------------------------
qui gstats tab symp, s(mean) nomissing mata(M) columns(var) by(treatment)
qui mata MStats`i'  = (`i' \ `i'), (0 \ 1), M.output
}

* Save Results
* ---------------------------------------------------------------------
* Pooled 
clear
svmat double Symp
save "${table_blood_end}\robustness\age_dec\7a_symp_pool.dta", replace

* Pooled, Without Baseline Controls
clear
svmat double SympNoBase
save "${table_blood_end}\robustness\age_dec\7b_symp_pool_no_base.dta", replace

* Mask Type
clear
svmat double SympMask
save "${table_blood_end}\robustness\age_dec\8a_symp_mask.dta", replace

* Mask Type, Without Baseline Controls
clear
svmat double SympMaskNoBase
save "${table_blood_end}\robustness\age_dec\8b_symp_mask_no_base.dta", replace


* Summary Stats
mata MStats = MStats1
forvalues j=2/`i'{
    mata MStats = MStats \ MStats`j'
}

clear
mata stata(sprintf("set obs %g", rows(MStats)))
mata _addTypes = ("double", "double", "double")
mata _addNames = ("subgroup", "treatment", "mean_symp")
mata (void) st_addvar(_addTypes, _addNames)
mata st_store(., _addNames, MStats)
gen subgroup_str = ""
local k = 0

foreach age of local age_bin{
    local k = `k' + 1
    replace subgroup_str = "`age'" if subgroup == `k'
}
drop subgroup
order subgroup_str treatment mean*
format mean* %5.4f
save "${table_blood_end}\robustness\age_dec\summ_stats_symp.dta", replace
