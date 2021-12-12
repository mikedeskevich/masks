* ---------------------------------------------------------------------
* Title:    Enrollment and Consent Rates (Household Level)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Generates summary statistics on enrollment in study and
*           consent rates of blood draws at the household level.
* ---------------------------------------------------------------------

* People Approached Baseline Household Visit
* ---------------------------------------------------------------------
use "${data_base}\00_raw\baseHH_data.dta", clear
keep union caseid treatment
gduplicates drop
isid union caseid

tempfile BaselineApproach
save `BaselineApproach'


* People Consented Baseline Household Visit
* ---------------------------------------------------------------------
use "${data_base}\01_clean\baseHH_data_ind.dta", clear
keep union caseid treatment
gduplicates drop
isid union caseid

tempfile Baseline
save `Baseline'

* People We Collected Midline and Endline Symptoms For
* ---------------------------------------------------------------------
use "${data_blood_end}\01_clean\bloodDraw_elig_ind.dta", clear
drop if mi_symp == 1
keep union caseid treatment
gduplicates drop
isid union caseid

tempfile SympCollect
save `SympCollect'


* Measure Enrollment
* ---------------------------------------------------------------------
use `BaselineApproach', clear

merge 1:1 union caseid using `Baseline', keep(1 3) gen(_consent_baseline)
gen baseline_visit = (_consent_baseline == 3)

* Collecting Symptoms
merge 1:1 union caseid using `SympCollect', keep(1 3) gen(_symp_coll)
gen symp_collect = (_symp_coll == 3)


* Summary Stats
keep union caseid treatment baseline_visit symp_collect 
gen count = 1
gcollapse (sum) count (sum) baseline_visit (sum) symp_collect, by(treatment)
gsort -treatment
list, ab(32)
