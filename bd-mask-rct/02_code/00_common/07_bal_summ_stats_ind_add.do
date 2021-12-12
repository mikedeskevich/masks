* ---------------------------------------------------------------------
* Title:    Additional Summary Statistics (Individual-Level)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Runs additional balance tests on baseline variables at the
*           individual level.
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


* Calculate Household Count
*---------------------------------------------------------------------
bys union caseid: gen hh_ind = (_n == 1)
bys union: egen hh_count = total(hh_ind)
label var hh_count "No. Households per Union"
drop hh_ind

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

* Generate Summary Stats
gcollapse (mean) hh_count (mean) sex (mean) prop_below_30 (mean) hh_size, by(treatment)

format *hh_count* %6.0f
format sex prop_below_30 hh_size %6.4f
format treatment %6.0f
list, ab(32)
