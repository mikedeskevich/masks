* ---------------------------------------------------------------------
* Title:    Summary Statistics on Baseline Variables
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Generates summary statistics on baseline variables using
*           individual-level data.
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


* Generate Summary Statistics
*---------------------------------------------------------------------
gen count = 1
gcollapse (mean) proper_mask_base (mean) posXsymp_base (mean) resp_ill_base_2, by(treatment)

format * %6.5f
format treatment %1.0f
list, ab(32)




