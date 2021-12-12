* ---------------------------------------------------------------------
* Title:    Randomization Inference Graphs (Symptomatic-Status)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Generates graphs of randomization inference of symptomatic-
*           status.
* ---------------------------------------------------------------------

* Save Coefficient from Main Regression Results
*---------------------------------------------------------------------
* With Baseline Controls
use "${table_blood_end}\main\5a_symp_pool.dta", clear
gen main_coeff = symp_no_mi_symp[1]
destring main_coeff, replace force ignore("*")
local main_coeff = main_coeff[1]

* No Baseline Controls
use "${table_blood_end}\main\5b_symp_pool_no_base.dta", clear
gen main_coeff = symp_no_mi_symp[1]
destring main_coeff, replace force ignore("*")
local main_coeff_no_base = main_coeff[1]


* Generate Graph - With Baseline Controls
*---------------------------------------------------------------------
use "${table_blood_end}\robustness\rand_inf\2a_symp_pool.dta", clear

* Save Graph
local coeff_hist histogram coeff, frequency lcolor(`"`dark_blue'"') fcolor(`"`light_blue'"') lpattern(solid)
twoway (`coeff_hist'), scheme(burd4) ytitle("Frequency") xtitle("Simulated Intervention Coefficient") xline(`main_coeff', lcolor(`"`dark_red'"') lwidth(0.25) lpattern(dash)) text(100 `main_coeff' "True Intervention Effect:", placement(east) size(.2cm)) text(96 `main_coeff' `"`main_coeff'"', placement(east) size(.2cm)) legend(off) xline(`main_coeff', lcolor(`"`dark_red'"') lwidth(0.25) lpattern(dash)) ylabel(0 (50) 100)
graph export `"${out_blood_end}\rand_inf_symp.svg"', fontface("LM Roman 10")  replace

* One Sided
egen pctile_one = mean(coeff <= `main_coeff')
summarize pctile_one

* Two Sided
egen pctile_two = mean((coeff <= `main_coeff') | (coeff >= -`main_coeff'))
summarize pctile_two

* Generate Graph - No Baseline Controls
*---------------------------------------------------------------------
use "${table_blood_end}\robustness\rand_inf\2b_symp_pool_no_base.dta", clear

* Save Graph
local coeff_hist histogram coeff, frequency lcolor(`"`dark_blue'"') fcolor(`"`light_blue'"') lpattern(solid)
twoway (`coeff_hist'), scheme(burd4) ytitle("Frequency") xtitle("Simulated Intervention Coefficient") xline(`main_coeff_no_base', lcolor(`"`dark_red'"') lwidth(0.25) lpattern(dash)) text(100 `main_coeff_no_base' "True Intervention Effect:", placement(east) size(.2cm)) text(96 `main_coeff_no_base' `"`main_coeff_no_base'"', placement(east) size(.2cm)) legend(off) xline(`main_coeff_no_base', lcolor(`"`dark_red'"') lwidth(0.25) lpattern(dash)) ylabel(0 (50) 100)
graph export `"${out_blood_end}\rand_inf_symp_no_base.svg"', fontface("LM Roman 10")  replace

* One Sided
egen pctile_one = mean(coeff <= `main_coeff_no_base')
summarize pctile_one

* Two Sided
egen pctile_two = mean((coeff <= `main_coeff_no_base') | (coeff >= -`main_coeff_no_base'))
summarize pctile_two
