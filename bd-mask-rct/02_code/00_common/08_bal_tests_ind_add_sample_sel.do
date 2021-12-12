* ---------------------------------------------------------------------
* Title:    Additional Balance Tests w/ Sample Selection (Individual-Level)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Runs additional balance tests on baseline variables at the
*           individual level, with sample selection (removing villages
*           with over 350 households per village, and all people younger
*           than 30.)
* ---------------------------------------------------------------------

* Load Data Individuals w/ Symptomatic and Symptomatic-Seropositivity Status
*---------------------------------------------------------------------
use "${data_blood_end}\01_clean\endlineBlood_data.dta", clear

* Set up Regressions
*---------------------------------------------------------------------
* Drop All Individuals Identified in Baseline that We Did Not Collect
* Symptom Data on in the Midline or Endline Surveys
drop if mi_symp == 1 

* Drop All Individuals that Were Symptomatic in Midline or Endline,
* But We Did not Draw Their Blood
drop if elig_no_blood == 1

* Drop All Individuals that we thought we drew blood from, but couldn't
* match to a sample
drop if recorded_blood_no_result == 1

* Calculate Household Count & Remove Villages with More than 350 Households
*---------------------------------------------------------------------
bys union caseid: gen hh_ind = (_n == 1)
bys union: egen hh_count = total(hh_ind)
label var hh_count "No. Households per Union"
drop hh_ind
drop if hh_count >= 350


* Drop Individuals Younger than 30
*---------------------------------------------------------------------
drop if age == 1 

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

* Calculate Proportion of People By Age
*---------------------------------------------------------------------
bys union: egen prop_below_30 = mean(age == 1)
bys union: egen prop_below_40 = mean(age <= 2)
label var prop_below_30 "Prop. of Adults Between 18-29 in Union"
label var prop_below_40 "Prop. of Adults Between 18-39 in Union"

* Run Regressions
*---------------------------------------------------------------------
* (1) Household Count
reghdfe hh_count treatment, absorb(pairID) vce(cluster union)
regsave using "${table_com}\4_balance_test_ind_add_sample_sel.dta", table(hh_count, format(%6.0f) parentheses(stderr) asterisk()) addlabel(subsample, "Household Count")replace

* (2) Sex
reghdfe sex treatment, absorb(pairID) vce(cluster union)
regsave using "${table_com}\4_balance_test_ind_add_sample_sel.dta", table(sex, format(%6.4f) parentheses(stderr) asterisk()) addlabel(subsample, "Proportion Female") append


* (3) Age
reghdfe prop_below_40 treatment, absorb(pairID) vce(cluster union)
regsave using "${table_com}\4_balance_test_ind_add_sample_sel.dta", table(below_40, format(%6.4f) parentheses(stderr) asterisk()) addlabel(subsample, "Proportion Below 40") append

* (4) Household Size
reghdfe hh_size treatment, absorb(pairID) vce(cluster union)
regsave using "${table_com}\4_balance_test_ind_add_sample_sel.dta", table(hh_size, format(%6.4f) parentheses(stderr) asterisk()) addlabel(subsample, "No. Adults per HH") append

* F-Test
* ---------------------------------------------------------------------
* Household Count
qui reg hh_count treatment i.pairID
estimates store r1

* Sex
qui reg sex treatment i.pairID
estimates store r2

* Age
qui reg prop_below_40 treatment i.pairID
estimates store r3

* Household Size
qui reg hh_size treatment i.pairID
estimates store r4

* F-Test
qui suest r1 r2 r3 r4, vce(cluster union)
test treatment
