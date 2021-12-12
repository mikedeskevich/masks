* ---------------------------------------------------------------------
* Title:    Symptomatic-Seropositivity by Mask Wearing & Social Distancing
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Regression of symptomatic-seropositivity by change in mask
*           wearing and social distancing during the intervention.
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

* Calculate Change in Mask Wearing and Social Distancing
* ---------------------------------------------------------------------
gen diff_mask = proper_mask_prop - proper_mask_base
gen diff_soc_dist = soc_dist_prop - soc_dist_base
bys union (diff_mask): assert diff_mask[1] == diff_mask
bys union (diff_soc_dist): assert diff_soc_dist[1] == diff_soc_dist

* Run Regressions
*---------------------------------------------------------------------

* (1) Symptomatic-Seropositivity by Change in Mask Wearing
* ---------------------------------------------------------------------
reghdfe posXsymp diff_mask proper_mask_base prop_resp_ill_base_2, noabsorb vce(cluster union)
regsave using "${table_blood_end}\robustness\diff_first_stage\1_symp_sero.dta", table(symp_sero_mask, format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, "Change in Mask Wearing") replace

	
* (2) Symptomatic-Seropositivity by Change in Social Distancing
* ---------------------------------------------------------------------
reghdfe posXsymp diff_soc_dist proper_mask_base prop_resp_ill_base_2, noabsorb vce(cluster union)
regsave using "${table_blood_end}\robustness\diff_first_stage\1_symp_sero.dta", table(symp_sero_soc, format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, "Change in Soc. Dist.") append

* (3) Symptomatic-Seropositivity by Change in Mask Wearing & Change in
*     Social Distancing
* ---------------------------------------------------------------------
reghdfe posXsymp diff_mask diff_soc_dist proper_mask_base prop_resp_ill_base_2, noabsorb vce(cluster union)
regsave using "${table_blood_end}\robustness\diff_first_stage\1_symp_sero.dta", table(symp_sero_mask_soc, format(%5.4f) parentheses(stderr) asterisk()) addlabel(subsample, "Change in Mask Wearing and Soc. Dist.") append


* Collapse to Union Level
*---------------------------------------------------------------------
gcollapse (mean) posXsymp, by(union treatment diff_mask diff_soc_dist)
isid union

* Generate Graph
*---------------------------------------------------------------------
* Define Legend
local legend order(1 "Treatment Villages" 2 "Control Villages")
local legend `legend' cols(1) ring(1) position(1) bmargin(small)

* (1) Symptomatic-Seropositivity by Change in Mask Wearing
* ---------------------------------------------------------------------
local treat_scatter scatter posXsymp diff_mask if treatment == 1, mlcolor(`"`dark_red'"') mfcolor(`"`light_red'"') msymbol(O)
local cont_scatter scatter posXsymp diff_mask if treatment == 0, mlcolor(`"`dark_blue'"') mfcolor(`"`light_blue'"') msymbol(O)

* Save Graph
twoway (`treat_scatter') (`cont_scatter'), legend(`legend') scheme(burd4) ytitle("Proportion Symptomatic Seropositive") xtitle("Average Change in Mask Wearing from Baseline") 
graph export "${out_blood_end}\symp_sero_change_mask_wearing.svg", fontface("LM Roman 10")  replace

* (2) Symptomatic-Seropositivity by Change in Social Distancing
* ---------------------------------------------------------------------
local treat_scatter scatter posXsymp diff_soc_dist if treatment == 1, mlcolor(`"`dark_red'"') mfcolor(`"`light_red'"') msymbol(O)
local cont_scatter scatter posXsymp diff_soc_dist if treatment == 0, mlcolor(`"`dark_blue'"') mfcolor(`"`light_blue'"') msymbol(O)

* Save Graph
twoway (`treat_scatter') (`cont_scatter'), legend(`legend') scheme(burd4) ytitle("Proportion Symptomatic Seropositive") xtitle("Average Change in Social Distancing from Baseline") 
graph export "${out_blood_end}\symp_sero_change_soc_dist.svg", fontface("LM Roman 10")  replace

