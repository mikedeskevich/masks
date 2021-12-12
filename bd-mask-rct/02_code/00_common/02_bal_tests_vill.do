* ---------------------------------------------------------------------
* Title:    Village-Level Balance Tests
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Runs balance tests on baseline variables at the village level.
* ---------------------------------------------------------------------

* Load Clean Union-Level Data
* ---------------------------------------------------------------------
use "${data_com}\01_clean\union_data_base.dta", clear

* Regressions
* ---------------------------------------------------------------------
* Baseline Symptomatic-Seroprevalence
reghdfe prop_posXsymp_base treatment [aweight = member_count], absorb(pairID) vce(r)
regsave using "${table_com}\1_balance_test_vill.dta", table(symp_sero, format(%6.5f) parentheses(stderr) asterisk()) addlabel(subsample, "Baseline Symptomatic-Seroprevalence") replace

* WHO-Defined COVID Symptoms
reghdfe prop_resp_ill_base_2 treatment [aweight = member_count], absorb(pairID) vce(r)
regsave using "${table_com}\1_balance_test_vill.dta", table(covid_symp, format(%6.5f) parentheses(stderr) asterisk()) addlabel(subsample, "Baseline WHO COVID Symptoms") append

* Baseline Mask Wearing
reghdfe proper_mask_base treatment [aweight = member_count], absorb(pairID) vce(r)
regsave using "${table_com}\1_balance_test_vill.dta", table(mask_surv, format(%6.5f) parentheses(stderr) asterisk()) addlabel(subsample, "Baseline Mask Wearing") append

* F-Test
* ---------------------------------------------------------------------
sureg (prop_posXsymp_base) (prop_resp_ill_base_2 treatment i.pairID) (proper_mask_base treatment i.pairID) [aweight = member_count], small dfk notable
test treatment
