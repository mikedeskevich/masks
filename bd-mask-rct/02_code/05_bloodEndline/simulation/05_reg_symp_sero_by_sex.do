* ---------------------------------------------------------------------
* Title:    Run Main Second Stage Regressions (Symptomatic-Seropositivity)
*           with simulated data by sex
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Runs second stage regressions with symptomatic-seropositivity
*           at endline as an outcome by sex, with simulated data.
* ---------------------------------------------------------------------

                                                                                                                        
* Set up Loop
*---------------------------------------------------------------------
mat SympSero = J(2,6,.)
mat SympSeroNoBase = J(2,6,.)
mat SympSeroMask = J(2,10,.)
mat SympSeroMaskNoBase = J(2,10,.)

forvalues i = 1/2{

* Load Data
use "${data_blood_end}\01_clean\endlineBlood_data_sim.dta", clear
	
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

* (1) Symptomatic-Seropositivity (Pooled, Linear)
* ---------------------------------------------------------------------
* With Baseline Controls
reghdfe posXsymp treatment proper_mask_base prop_resp_ill_base_2, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\simulation\sex\1a_symp_sero_pool.dta", table(symp_sero_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* No Baseline Controls
reghdfe posXsymp treatment, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\simulation\sex\1b_symp_sero_pool_no_base.dta", table(symp_sero_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* (2) Symptomatic-Seropositivity (By Mask Type, Linear)
* ---------------------------------------------------------------------
* With Baseline Controls
reghdfe posXsymp treat_surg treat_cloth proper_mask_base prop_resp_ill_base_2, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\simulation\sex\2a_symp_sero_mask.dta", table(symp_sero_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* No Baseline Controls
reghdfe posXsymp treat_surg treat_cloth, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\simulation\sex\2b_symp_sero_mask_no_base.dta", table(symp_sero_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* (3) Symptomatic-Seropositivity (Pooled, Proportional)
* ---------------------------------------------------------------------
preserve
* Drop Pairs Which Don't Have any Adults that are Symptomatic-Seropositive
bys pairID: egen count_sympsero = total(posXsymp)
drop if count_sympsero == 0

* With Baseline Controls
glm posXsymp treatment proper_mask_base prop_resp_ill_base_2 i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympSero[`i',1] = _b[treatment]
mat SympSero[`i',2] = r["ll","posXsymp:treatment"]
mat SympSero[`i',3] = r["ul","posXsymp:treatment"]
mat SympSero[`i',4] = r["pvalue","posXsymp:treatment"]
mat SympSero[`i',5] = `=e(N)'
mat SympSero[`i',6] = `=e(N_clust)'

* No Baseline Controls
glm posXsymp treatment i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympSeroNoBase[`i',1] = _b[treatment]
mat SympSeroNoBase[`i',2] = r["ll","posXsymp:treatment"]
mat SympSeroNoBase[`i',3] = r["ul","posXsymp: treatment"]
mat SympSeroNoBase[`i',4] = r["pvalue","posXsymp: treatment"]
mat SympSeroNoBase[`i',5] = `=e(N)'
mat SympSeroNoBase[`i',6] = `=e(N_clust)'


* (4) Symptomatic-Seropositivity (By Mask Type, Proportional)
* ---------------------------------------------------------------------
* Mask Type, With Baseline Controls
glm posXsymp treat_surg treat_cloth proper_mask_base prop_resp_ill_base_2 i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympSeroMask[`i',1] = _b[treat_surg]
mat SympSeroMask[`i',2] = r["ll","posXsymp:treat_surg"]
mat SympSeroMask[`i',3] = r["ul","posXsymp:treat_surg"]
mat SympSeroMask[`i',4] = r["pvalue","posXsymp:treat_surg"]
mat SympSeroMask[`i',5] = _b[treat_cloth]
mat SympSeroMask[`i',6] = r["ll","posXsymp:treat_cloth"]
mat SympSeroMask[`i',7] = r["ul","posXsymp:treat_cloth"]
mat SympSeroMask[`i',8] = r["pvalue","posXsymp:treat_cloth"]
mat SympSeroMask[`i',9] = `=e(N)'
mat SympSeroMask[`i',10] = `=e(N_clust)'

* Mask Type, No Baseline Controls
glm posXsymp treat_surg treat_cloth i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympSeroMaskNoBase[`i',1] = _b[treat_surg]
mat SympSeroMaskNoBase[`i',2] = r["ll","posXsymp:treat_surg"]
mat SympSeroMaskNoBase[`i',3] = r["ul","posXsymp:treat_surg"]
mat SympSeroMaskNoBase[`i',4] = r["pvalue","posXsymp:treat_surg"]
mat SympSeroMaskNoBase[`i',5] = _b[treat_cloth]
mat SympSeroMaskNoBase[`i',6] = r["ll","posXsymp:treat_cloth"]
mat SympSeroMaskNoBase[`i',7] = r["ul","posXsymp:treat_cloth"]
mat SympSeroMaskNoBase[`i',8] = r["pvalue","posXsymp:treat_cloth"]
mat SympSeroMaskNoBase[`i',9] = `=e(N)'
mat SympSeroMaskNoBase[`i',10] = `=e(N_clust)'
restore

* Run Summary Stats
* ---------------------------------------------------------------------
qui gstats tab posXsymp, s(mean) nomissing mata(M) columns(var) by(treatment)
qui mata MStats`i'  = (`i' \ `i'), (0 \ 1), M.output


}


* Save Results
* ---------------------------------------------------------------------
* Pooled 
clear
svmat double SympSero
save "${table_blood_end}\simulation\sex\3a_symp_sero_pool.dta", replace

* Pooled, Without Baseline Controls
clear
svmat double SympSero
save "${table_blood_end}\simulation\sex\3b_symp_sero_pool_no_base.dta", replace

* Mask Type
clear
svmat double SympSeroMask
save "${table_blood_end}\simulation\sex\4a_symp_sero_mask.dta", replace

* Mask Type, Without Baseline Controls
clear
svmat double SympSeroMaskNoBase
save "${table_blood_end}\simulation\sex\4b_symp_sero_mask_no_base.dta", replace

* Summary Stats
mata MStats = MStats1 \ MStats2

clear
mata stata(sprintf("set obs %g", rows(MStats)))
mata _addTypes = ("double", "double", "double")
mata _addNames = ("subgroup", "treatment", "mean_posXsymp")
mata (void) st_addvar(_addTypes, _addNames)
mata st_store(., _addNames, MStats)
gen subgroup_str = ""

replace subgroup_str = "Male" if subgroup == 1
replace subgroup_str = "Female" if subgroup == 2

drop subgroup
order subgroup_str treatment mean*
format mean* %5.4f
save "${table_blood_end}\simulation\sex\summ_stats_symp_sero.dta", replace

