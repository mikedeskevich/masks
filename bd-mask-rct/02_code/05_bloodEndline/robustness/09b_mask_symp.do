* ---------------------------------------------------------------------
* Title:    Symptomatic-Status by Mask Wearing & Social Distancing
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Regression of symptomatic status by change in mask
*           wearing and social distancing during the intervention.
* ---------------------------------------------------------------------

* Load Data Individuals w/ Symptomatic and Symptomatic-Seropositivity Status
*---------------------------------------------------------------------
use "${data_blood_end}\01_clean\endlineBlood_data.dta", clear

* Drop All Individuals Identified in Baseline that We Did Not Collect
* Symptom Data on in the Midline or Endline Surveys
drop if mi_symp == 1 

* Set up Regressions
* ---------------------------------------------------------------------
local doc_title "full"
local replace_choice "replace"
local subsample "Full"

* Calculate Change in Mask Wearing and Social Distancing
* ---------------------------------------------------------------------
gen diff_mask = proper_mask_prop - proper_mask_base
gen diff_soc_dist = soc_dist_prop - soc_dist_base
bys union (diff_mask): assert diff_mask[1] == diff_mask
bys union (diff_soc_dist): assert diff_soc_dist[1] == diff_soc_dist

* Run Regressions
*---------------------------------------------------------------------

* (4) Symptomatic by Change in Mask Wearing
* ---------------------------------------------------------------------
reghdfe symp diff_mask proper_mask_base prop_resp_ill_base_2, noabsorb vce(cluster union)
regsave using "${table_blood_end}\robustness\diff_first_stage\2_symp.dta", table(symp_mask, format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, "Change in Mask Wearing") replace
	
* (5) Symptomatic by Change in Social Distancing
* ---------------------------------------------------------------------
reghdfe symp diff_soc_dist proper_mask_base prop_resp_ill_base_2, noabsorb vce(cluster union)
regsave using "${table_blood_end}\robustness\diff_first_stage\2_symp.dta", table(symp_soc, format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, "Change in Soc. Dist.") append

* (6) Symptomatic by Change in Mask Wearing & Change in Social Distancing
* ---------------------------------------------------------------------
reghdfe symp diff_mask diff_soc_dist proper_mask_base prop_resp_ill_base_2, noabsorb vce(cluster union)
regsave using "${table_blood_end}\robustness\diff_first_stage\2_symp.dta", table(symp_mask_soc, format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, "Change in Mask Wearing and Soc. Dist.") append


* Collapse to Union Level
*---------------------------------------------------------------------
gcollapse (mean) symp, by(union treatment diff_mask diff_soc_dist)
isid union

* Generate Graph
*---------------------------------------------------------------------
* Define Legend
local legend order(1 "Treatment Villages" 2 "Control Villages")
local legend `legend' cols(1) ring(1) position(1) bmargin(small)

* (3) Symptomatic by Change in Mask Wearing
* ---------------------------------------------------------------------
local treat_scatter scatter symp diff_mask if treatment == 1, mlcolor(`"`dark_red'"') mfcolor(`"`light_red'"') msymbol(O)
local cont_scatter scatter symp diff_mask if treatment == 0, mlcolor(`"`dark_blue'"') mfcolor(`"`light_blue'"') msymbol(O)

* Save Graph
twoway (`treat_scatter') (`cont_scatter'), legend(`legend') scheme(burd4) ytitle("Proportion w/ WHO-Defined COVID Symptoms") xtitle("Average Change in Mask Wearing from Baseline") 
graph export "${out_blood_end}\symp_change_mask_wearing.svg", fontface("LM Roman 10")  replace


* (4) Symptomatic by Change in Social Distancing
* ---------------------------------------------------------------------
local treat_scatter scatter symp diff_soc_dist if treatment == 1, mlcolor(`"`dark_red'"') mfcolor(`"`light_red'"') msymbol(O)
local cont_scatter scatter symp diff_soc_dist if treatment == 0, mlcolor(`"`dark_blue'"') mfcolor(`"`light_blue'"') msymbol(O)

* Save Graph
twoway (`treat_scatter') (`cont_scatter'), legend(`legend') scheme(burd4) ytitle("Proportion w/ WHO-Defined COVID Symptoms") xtitle("Average Change in Social Distancing from Baseline") 
graph export "${out_blood_end}\symp_change_soc_dist.svg", fontface("LM Roman 10")  replace
