* ---------------------------------------------------------------------
* Title:    Run Main Second Stage Regressions (Symptomatic-Seropositivity)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Runs second stage regressions with symptomatic-seropositivity
*           at endline as an outcome, with controls for sex and average
*           household size.
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

* Calculate Average Household Size
*---------------------------------------------------------------------
preserve
bys union caseid: gen hh_ind = (_n == 1)
bys union caseid: gen hh_n_adults = _N
keep if hh_ind == 1
gcollapse (mean) hh_size = hh_n_adults, by(union)
label var hh_size "No. Adults per HH"
tempfile HHSize
save `HHSize'
restore

merge m:1 union using `HHSize', keep(1 3) gen(_calc_hh_size)
assert _calc_hh_size == 3

* Set up Regressions
* ---------------------------------------------------------------------
local doc_title "full"
local replace_choice "replace"
local subsample "Full"

* Run Regressions
*---------------------------------------------------------------------

* (1) Symptomatic-Seropositivity (Pooled, Linear)
* ---------------------------------------------------------------------
* With Baseline Controls
reghdfe posXsymp treatment proper_mask_base prop_resp_ill_base_2 hh_size sex, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\add_controls\1a_symp_sero_pool.dta", table(symp_sero_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* No Baseline Controls
reghdfe posXsymp treatment, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\add_controls\1b_symp_sero_pool_no_base.dta", table(symp_sero_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* (2) Symptomatic-Seropositivity (By Mask Type, Linear)
* ---------------------------------------------------------------------
* With Baseline Controls
reghdfe posXsymp treat_surg treat_cloth proper_mask_base prop_resp_ill_base_2 hh_size sex, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\add_controls\2a_symp_sero_mask.dta", table(symp_sero_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* No Baseline Controls
reghdfe posXsymp treat_surg treat_cloth, absorb(pairID) vce(cluster union)
regsave using "${table_blood_end}\robustness\add_controls\2b_symp_sero_mask_no_base.dta", table(symp_sero_`doc_title', format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* (3) Symptomatic-Seropositivity (Pooled, Proportional)
* ---------------------------------------------------------------------
preserve
* Drop Pairs Which Don't Have any Adults that are Symptomatic-Seropositive
bys pairID: egen count_sympsero = total(posXsymp)
drop if count_sympsero == 0

* With Baseline Controls
glm posXsymp treatment proper_mask_base prop_resp_ill_base_2 hh_size sex i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympSero = J(1,6,.)
mat SympSero[1,1] = _b[treatment]
mat SympSero[1,2] = r["ll","posXsymp:treatment"]
mat SympSero[1,3] = r["ul","posXsymp:treatment"]
mat SympSero[1,4] = r["pvalue","posXsymp:treatment"]
mat SympSero[1,5] = `=e(N)'
mat SympSero[1,6] = `=e(N_clust)'


* No Baseline Controls
glm posXsymp treatment i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympSeroNoBase = J(1,6,.)
mat SympSeroNoBase[1,1] = _b[treatment]
mat SympSeroNoBase[1,2] = r["ll","posXsymp:treatment"]
mat SympSeroNoBase[1,3] = r["ul","posXsymp: treatment"]
mat SympSeroNoBase[1,4] = r["pvalue","posXsymp: treatment"]
mat SympSeroNoBase[1,5] = `=e(N)'
mat SympSeroNoBase[1,6] = `=e(N_clust)'


* (4) Symptomatic-Seropositivity (By Mask Type, Proportional)
* ---------------------------------------------------------------------
* Mask Type, With Baseline Controls
glm posXsymp treat_surg treat_cloth proper_mask_base prop_resp_ill_base_2 hh_size sex i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympSeroMask = J(1,10,.)
mat SympSeroMask[1,1] = _b[treat_surg]
mat SympSeroMask[1,2] = r["ll","posXsymp:treat_surg"]
mat SympSeroMask[1,3] = r["ul","posXsymp:treat_surg"]
mat SympSeroMask[1,4] = r["pvalue","posXsymp:treat_surg"]
mat SympSeroMask[1,5] = _b[treat_cloth]
mat SympSeroMask[1,6] = r["ll","posXsymp:treat_cloth"]
mat SympSeroMask[1,7] = r["ul","posXsymp:treat_cloth"]
mat SympSeroMask[1,8] = r["pvalue","posXsymp:treat_cloth"]
mat SympSeroMask[1,9] = `=e(N)'
mat SympSeroMask[1,10] = `=e(N_clust)'

* Mask Type, No Baseline Controls
glm posXsymp treat_surg treat_cloth i.pairID, family(poisson) link(log) vce(cluster union)
mat r = r(table)
mat SympSeroMaskNoBase = J(1,10,.)
mat SympSeroMaskNoBase[1,1] = _b[treat_surg]
mat SympSeroMaskNoBase[1,2] = r["ll","posXsymp:treat_surg"]
mat SympSeroMaskNoBase[1,3] = r["ul","posXsymp:treat_surg"]
mat SympSeroMaskNoBase[1,4] = r["pvalue","posXsymp:treat_surg"]
mat SympSeroMaskNoBase[1,5] = _b[treat_cloth]
mat SympSeroMaskNoBase[1,6] = r["ll","posXsymp:treat_cloth"]
mat SympSeroMaskNoBase[1,7] = r["ul","posXsymp:treat_cloth"]
mat SympSeroMaskNoBase[1,8] = r["pvalue","posXsymp:treat_cloth"]
mat SympSeroMaskNoBase[1,9] = `=e(N)'
mat SympSeroMaskNoBase[1,10] = `=e(N_clust)'
restore

* Run Summary Stats
* ---------------------------------------------------------------------
qui gstats tab posXsymp, s(mean) nomissing mata(M) columns(var) by(treatment)
qui mata MStats  = (1 \ 1), (0 \ 1), M.output
mata: MStats

* Save Results
* ---------------------------------------------------------------------
* Pooled 
clear
svmat double SympSero
save "${table_blood_end}\robustness\add_controls\3a_symp_sero_pool.dta", replace

* Pooled, Without Baseline Controls
clear
svmat double SympSero
save "${table_blood_end}\robustness\add_controls\3b_symp_sero_pool_no_base.dta", replace

* Mask Type
clear
svmat double SympSeroMask
save "${table_blood_end}\robustness\add_controls\4a_symp_sero_mask.dta", replace

* Mask Type, Without Baseline Controls
clear
svmat double SympSeroMaskNoBase
save "${table_blood_end}\robustness\add_controls\4b_symp_sero_mask_no_base.dta", replace

* Summary Stats
clear
mata stata(sprintf("set obs %g", rows(MStats)))
mata _addTypes = ("double", "double", "double")
mata _addNames = ("subgroup", "treatment", "mean_posXsymp")
mata (void) st_addvar(_addTypes, _addNames)
mata st_store(., _addNames, MStats)
gen subgroup_str = "full"
drop subgroup
order subgroup_str treatment mean*
format mean* %5.4f
save "${table_blood_end}\robustness\add_controls\summ_stats_symp_sero.dta", replace


