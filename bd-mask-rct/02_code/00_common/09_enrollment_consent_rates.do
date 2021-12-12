* ---------------------------------------------------------------------
* Title:    Enrollment and Consent Rates (Individual Level)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Generates summary statistics on enrollment in study and
*           consent rates of blood draws.
* ---------------------------------------------------------------------

* People Approached in Baseline Household Visit
* ---------------------------------------------------------------------
use "${data_base}\01_clean\baseHH_data_ind.dta", clear
isid union caseid name

tempfile Baseline
save `Baseline'

* People We Collected Midline and Endline Symptoms For
* ---------------------------------------------------------------------
use "${data_blood_end}\01_clean\bloodDraw_elig_ind.dta", clear
drop if mi_symp == 1
isid union caseid name

tempfile SympCollect
save `SympCollect'

* People That Are Symptomatic
* ---------------------------------------------------------------------
use "${data_blood_end}\01_clean\bloodDraw_elig_ind.dta", clear
keep if symp == 1
isid union caseid name

tempfile Symp
save `Symp'


* Number Blood Spots Collected
* ---------------------------------------------------------------------
use "${data_blood_end}\00_raw\blood_endline_comb.dta", clear

keep union caseid name treatment
gduplicates drop
isid union caseid name

tempfile BloodCollect
save `BloodCollect'

* Number Blood Spots Tested
* ---------------------------------------------------------------------
use  "${data_blood_end}\01_clean\endlineBlood_data.dta", clear
keep if dum_endline_blood == 1

tempfile BloodTest
save `BloodTest'

* Measure Enrollment
* ---------------------------------------------------------------------
use `Baseline', clear

* Collecting Symptoms
merge 1:1 union caseid name using `SympCollect', keep(1 3) gen(_symp_coll)
gen symp_collect = (_symp_coll == 3)

* Symptomatic
merge 1:1 union caseid name using `Symp', keep(1 3) gen(_symp)
gen symptomatic = (_symp == 3)
assert symptomatic == 0 if symp_collect == 0
assert symptomatic == symp if mi_symp == 0

* Symptomatic Blood Spots Collected
merge 1:1 union caseid name using `BloodCollect', keep(1 3) gen(_blood_coll)
gen blood_collect = (_blood_coll == 3) & symptomatic == 1

* Symptomatic Blood Spots Tested
merge 1:1 union caseid name using `BloodTest', keep(1 3) gen(_blood_test)
gen blood_test = (_blood_test == 3) & blood_collect == 1


* Summary Stats
gen count = 1
preserve
keep union caseid name treatment symp_collect symptomatic blood_collect blood_test count
gcollapse (sum) count (sum) symp_collect (sum) symptomatic (sum) blood_collect (sum) blood_test, by(treatment)
gsort -treatment
list, ab(32)
restore

* Measure Consent Rates
* ---------------------------------------------------------------------
* By Treatment Status
preserve
gcollapse (sum) symptomatic (sum) blood_collect, by(treatment)
gen prop_consent = blood_collect/symptomatic
format prop_consent %5.3f
list, ab(32)
restore

* By Sex & Treatment Status
preserve
gcollapse (sum) symptomatic (sum) blood_collect, by(treatment sex)
gen prop_consent = blood_collect/symptomatic
format prop_consent %5.3f
sort sex treatment
list, ab(32) sepby(sex)
restore

* By Sex
preserve
gcollapse (sum) symptomatic (sum) blood_collect, by(sex)
gen prop_consent = blood_collect/symptomatic
format prop_consent %5.3f
list, ab(32) sepby(sex)
restore

* By Age & Treatment Status
preserve
gen age_bin = 1 if (age <= 2)
replace age_bin = 2 if (age == 3)
replace age_bin = 3 if (age == 4)
replace age_bin = 4 if(age >= 5)
assert !mi(age_bin)
gcollapse (sum) symptomatic (sum) blood_collect, by(treatment age_bin)
gen prop_consent = blood_collect/symptomatic
format prop_consent %5.3f
sort age_bin treatment
list, ab(32) sepby(age_bin)
restore

* By Age
preserve
gen age_bin = 1 if (age <= 2)
replace age_bin = 2 if (age == 3)
replace age_bin = 3 if (age == 4)
replace age_bin = 4 if(age >= 5)
assert !mi(age_bin)
gcollapse (sum) symptomatic (sum) blood_collect, by(age_bin)
gen prop_consent = blood_collect/symptomatic
format prop_consent %5.3f
list, ab(32) sepby(age_bin)
restore

* By Wave & Treatment Status
preserve
assert !mi(wave)
gcollapse (sum) symptomatic (sum) blood_collect, by(treatment wave)
gen prop_consent = blood_collect/symptomatic
format prop_consent %5.3f
sort wave treatment
list, ab(32) sepby(wave)
restore

* By Wave
preserve
assert !mi(wave)
gcollapse (sum) symptomatic (sum) blood_collect, by(wave)
gen prop_consent = blood_collect/symptomatic
format prop_consent %5.3f
sort wave
list, ab(32) sepby(wave)
restore



* Measure Symptomatic Rates
* ---------------------------------------------------------------------
preserve
assert !mi(wave)
gcollapse (sum) symptomatic (sum) count, by(wave treatment)
gen prop_symp = symptomatic/count
format prop_symp %5.3f
sort wave
list, ab(32) sepby(wave)
restore
