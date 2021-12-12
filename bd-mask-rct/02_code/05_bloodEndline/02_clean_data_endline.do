* ---------------------------------------------------------------------
* Title:    Clean Data - Endline Blood Collection
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Cleans endline blood collection data for analysis.
* ---------------------------------------------------------------------

* All People We Drew Blood From in Endline
* ---------------------------------------------------------------------
use "${data_blood_end}\00_raw\blood_endline_comb.dta", clear

* Merge in Barcode Results
* ---------------------------------------------------------------------
merge m:1 barcode using "${data_blood_end}\00_raw\endline_blood_results.dta", keep(1 2 3) gen(_endline_result)

drop if _endline_result == 2
gen recorded_blood_no_result = (_endline_result == 1)
label var recorded_blood_no_result "Individual coded as having blood draw, but we can't match to a sample"
gen dum_endline_blood = (_endline_result == 3)
label var dum_endline_blood "Individual had endline blood draw"
drop _endline_result


* Drop Duplicate People - Assume Most Conservative Option
* ---------------------------------------------------------------------
* Drop Duplicate Observations
gduplicates drop
local ind "union caseid name"

* (1) If Multiple Draws, With At Least One Non-Missing, Drop All Missings
gen mi_positive = mi(positive)
bys `ind' (mi_positive): gen to_drop = 1 if mi_positive[1] == 0 & mi_positive == 1 & _N > 1 & _n > 1
drop if to_drop == 1
drop to_drop

* (2) If Multiple Draws, Only Keep Results from Samples that Are Large Enough
bys `ind' (enough): gen to_drop = 1 if enough[1] == 0 & enough[_N] == 1 & _N > 1 & enough == 0
drop if to_drop == 1
drop to_drop

* (3) If Multiple Draws, And All Are Enough or Not Enough, Keep One that is Negative
bys `ind' (enough positive): gen to_drop = 1 if enough[1] == enough[_N] & mi_positive == 0 & _N > 1 & _n > 1
drop if to_drop == 1
drop to_drop

* (4) If Multiple Draws That Have Same Result and are all enough or not enough, choose one to keep randomly
gen rand = uniform()
bys `ind' (enough positive rand): gen to_drop = 1 if enough[1] == enough[_N] & positive[1] == positive[_N] & _n > 1
drop if to_drop == 1
drop to_drop
drop rand
drop mi_positive


* ID Individuals Missing Blood Spot Result
* ---------------------------------------------------------------------
isid name
assert recorded_blood_no_result == 1 if mi(positive)
assert recorded_blood_no_result == 0 if !mi(positive)
assert dum_endline_blood == 1 if !mi(positive)
assert dum_endline_blood == 0 if mi(positive)

*replace positive = 0 if mi(positive)
label var positive "Seropositive Blood Spot at Endline"

tempfile Seropositivity
save `Seropositivity'

* All People Identified in HH Survey
* ---------------------------------------------------------------------
use "${data_blood_end}\01_clean\bloodDraw_elig_ind.dta", clear

* Merge in Seropositivity Results
merge m:1 union caseid name using `Seropositivity', gen(_pos) keep(1 3)


* Identify Individuals Eligible for Blood Draw that We Didn't Draw Blood From
gen elig_no_blood = (symp == 1) & (_pos == 1)
label var elig_no_blood "Individual Eligible for Endline Blood Draw, but has no blood sample"
assert positive == . if elig_no_blood == 1
drop _pos



* Define Variables
* ---------------------------------------------------------------------
replace positive = 0 if mi(positive)
gen posXsymp = symp * positive
assert !mi(posXsymp)
label var posXsymp "Adult was symptomatic-seropositive at endline"


gen treat_surg = treatment * surgical
gen treat_cloth = treatment * cloth
label var treat_surg "Treatment Status X Sugical Masks"
label var treat_cloth "Treatment Status X Cloth Masks"

* Merge in Baseline Seropositivity
* ---------------------------------------------------------------------
merge 1:1 union caseid name using "${data_com}\00_raw\baselineBlood_data_ind.dta", keep(1 3) gen(_baseline_blood)
assert !mi(posXsymp_base)

* Generate Age Bins
* ---------------------------------------------------------------------
gen above_40 = age >= 3
gen above_50 = age >= 4
gen above_60 = age >= 5
gen below_40 = age < 3
gen below_50 = age < 4
gen below_60 = age < 5
gen btwn_18_30 = (age == 1)
gen btwn_30_40 = (age == 2)
gen btwn_40_60 = (age == 3) | (age == 4)
gen btwn_40_50 = age == 3
gen btwn_50_60 = age == 4
gen btwn_60_70 = (age == 5)
gen above_70 = (age >= 6)
assert (below_40 + btwn_40_50 + btwn_50_60 + above_60 == 1)
assert (btwn_18_30 + btwn_30_40 + btwn_40_50 + btwn_50_60 + btwn_60_70 + above_70 == 1)
assert (above_40 + below_40 == 1)
assert (above_50 + below_50 == 1)
assert (above_60 + below_60 == 1)

* Create Regression Sample
* ---------------------------------------------------------------------
* Restrict to Unions that Have Full Surveillance Data
* Note: Drop All Unions and Their Pairs that are Missing Baseline Surveillance Data
*       or All Surveillance Data During the Intervention Period (Week 1 - Week 8)
merge m:1 union using "${data_com}\01_clean\union_reg_sample.dta", keep(1 3) nogen
drop if surv_incomplete_pair == 1
drop surv_incomplete*


* Merge in Union-Level Summary Stats
* ---------------------------------------------------------------------
* Baseline Mask Wearing
merge m:1 union using "${data_surv}\01_clean\union_surv_data_base.dta", keepusing(proper_mask_base soc_dist_base) keep(1 3) gen(_surv_base)
assert _surv_base == 3
drop _surv_base
assert !mi(proper_mask_base)
assert !mi(soc_dist_base)

* Intervention Mask Wearing
merge m:1 union using "${data_surv}\01_clean\union_surv_data.dta", keepusing(proper_mask_prop soc_dist_prop) keep(1 3) gen(_surv)
assert _surv == 3
drop _surv
assert !mi(proper_mask_prop)
assert !mi(soc_dist_prop)

* Baseline Respiratory Symptoms
merge m:1 union using "${data_base}\01_clean\union_baseHH_data.dta", keepusing(prop_resp_ill_base_2) keep(1 3) gen(_hh_base)
assert _hh_base == 3
drop _hh_base
assert !mi(prop_resp_ill_base_2)

* Save Data
* ---------------------------------------------------------------------
save  "${data_blood_end}\01_clean\endlineBlood_data.dta", replace
