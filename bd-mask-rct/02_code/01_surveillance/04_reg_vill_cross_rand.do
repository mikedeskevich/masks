* ---------------------------------------------------------------------
* Title:    Regressions - Village Cross Randomization
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Regression of village cross randomzation interventions.
* ---------------------------------------------------------------------

* Loop through all locations
* ---------------------------------------------------------------------
forvalues loc = 1/6{

* Load Clean Surveillance Data
* ---------------------------------------------------------------------
use  "${data_surv}\01_clean\surv_data.dta", clear

* Restrict to Unions that Have Full Surveillance Data
* ---------------------------------------------------------------------
* Restrict to Unions that Have Full Surveillance Data
* Note: Drop All Unions and Their Pairs that are Missing Baseline Surveillance Data
*       or All Surveillance Data During the Intervention Period (Week 1 - Week 8)
merge m:1 union using "${data_com}\01_clean\union_reg_sample.dta", keep(1 3) nogen
drop if surv_incomplete_pair == 1
drop surv_incomplete*

* Filter by Location
* ---------------------------------------------------------------------
* [1] Includes All Locations
if `loc' == 1{
	//Blank
}

* [2] Excludes Locations where Active Promotion was taking place
else if `loc' == 2{
	* TODO: CHECK PROMOTION DATA
	drop if site_name == 1 & prayer_time == 4 //Drop all Surveillance at Mosques During Jumma Prayer Time
}

* [3] Mosques
else if `loc' == 3{
	keep if site_name == 1 //Mosques Only
}

* [4] Markets
else if `loc' == 4{
	keep if site_name == 2 //Markets Only
}

* [5] Other Locations (Tea Stall, Restaurant, Main Road to Enter Village)
else if `loc' == 5{
	drop if site_name == 1  
	drop if site_name == 2
}

* [6] Excluding Mosques
else if `loc' == 6{
	drop if site_name == 1 //Drop Mosques
}

* Create Factor Variables for Each Village-Level Randomizations
* ---------------------------------------------------------------------
local vill_cross_rand "surgical signage incentive text_village"
local vill_cross_rand_fe
foreach rand of varlist `vill_cross_rand'{
	local vill_cross_rand_fe `vill_cross_rand_fe' i.`rand'
}


* Generate Baseline Mask Wearing Rate for Control
* ---------------------------------------------------------------------
preserve
* Generate Baseline Mask Wearing Stats
keep if week_gen == 1
gcollapse (sum) n_surv_total (sum) n_surv_female (sum) n_surv_male (sum) n_proper_mask (sum) n_proper_mask_f (sum) n_proper_mask_m (sum) n_proper_improper_mask (sum) n_proper_improper_mask_f (sum) n_proper_improper_mask_m (sum) n_improper_mask (sum) n_improper_mask_m (sum) n_improper_mask_f (sum) n_soc_dist, by(union treatment pairID)
gisid union

bys union: gen proper_mask_base = n_proper_mask/n_surv_total
bys union: gen proper_improper_mask_base = n_proper_improper_mask/n_surv_total
bys union: gen improper_mask_base = n_improper_mask/n_surv_total
bys union: gen soc_dist_base = n_soc_dist/n_surv_total

fasterxtile med_proper_mask_base = proper_mask_base, nq(2)
gen dum_med_base = (med_proper_mask_base == 2)

bys union: gen proper_mask_base_f = n_proper_mask_f/n_surv_female
bys union: gen proper_improper_mask_base_f = n_proper_improper_mask_f/n_surv_female
bys union: gen improper_mask_base_f = n_improper_mask_f/n_surv_female
assert !mi(proper_mask_base_f) if n_surv_female > 0
assert !mi(proper_improper_mask_base_f) if n_surv_female > 0
assert !mi(improper_mask_base_f) if n_surv_female > 0

bys union: gen proper_mask_base_m = n_proper_mask_m/n_surv_male
bys union: gen proper_improper_mask_base_m = n_proper_improper_mask_m/n_surv_male
bys union: gen improper_mask_base_m = n_improper_mask_m/n_surv_male
assert !mi(proper_mask_base_m) if n_surv_male > 0
assert !mi(proper_improper_mask_base_m) if n_surv_male > 0
assert !mi(improper_mask_base_m) if n_surv_male > 0

rename n_surv_total n_surv_total_base
assert !mi(n_surv_total_base)

tempfile BaselineMask
save `BaselineMask'
restore


merge m:1 union using `BaselineMask', keep(1 3) gen(_baseline_data)

* Collapse to Union Level
* ---------------------------------------------------------------------
drop if week_gen == 1 //Drop Baseline Data (Before Intervention Start)
drop if week_gen == 7 //Drop Week 10 Data (Post Intervention End)
drop if week_gen == 8 //Drop Followup-1 Data (Post Intervention End)


gcollapse (sum) n_surv_total (sum) n_surv_female (sum) n_surv_male (sum) n_surv_sex (sum) n_proper_mask (sum) n_proper_mask_f (sum) n_proper_mask_m (sum) n_proper_improper_mask (sum) n_proper_improper_mask_f (sum) n_proper_improper_mask_m (sum) n_improper_mask (sum) n_improper_mask_m (sum) n_improper_mask_f (sum) n_soc_dist, by(union `vill_cross_rand' treatment pairID wave *base* surgical* cloth*)
gisid union

bys union: gen proper_mask_prop = n_proper_mask/n_surv_total
bys union: gen proper_improper_mask = n_proper_improper_mask/n_surv_total
bys union: gen improper_mask_prop = n_improper_mask/n_surv_total
bys union: gen soc_dist_prop = n_soc_dist/n_surv_total
assert !mi(proper_mask_prop)
assert !mi(improper_mask_prop)
assert !mi(proper_improper_mask)
assert !mi(soc_dist_prop)

bys union: gen proper_mask_prop_f = n_proper_mask_f/n_surv_female
bys union: gen proper_improper_mask_f = n_proper_improper_mask_f/n_surv_female
bys union: gen improper_mask_prop_f = n_improper_mask_f/n_surv_female
assert !mi(proper_mask_prop_f) if n_surv_female > 0
assert !mi(proper_improper_mask_f) if n_surv_female > 0
assert !mi(improper_mask_prop_f) if n_surv_female > 0

bys union: gen proper_mask_prop_m = n_proper_mask_m/n_surv_male
bys union: gen proper_improper_mask_m = n_proper_improper_mask_m/n_surv_male
bys union: gen improper_mask_prop_m = n_improper_mask_m/n_surv_male
assert !mi(proper_mask_prop_m) if n_surv_male > 0
assert !mi(proper_improper_mask_m) if n_surv_male > 0
assert !mi(improper_mask_prop_m) if n_surv_male > 0

* Set up Regressions
* ---------------------------------------------------------------------
if (`loc' == 1){
	local doc_title "base"
	local replace_choice "replace"
	local subsample "Full"
} 
else if (`loc' == 2){
	local doc_title "excl_active_promo"
	local replace_choice "append"
	local subsample "No Active Promotion"
}
else if (`loc' == 3){
	local doc_title "by_loc_mosques" //Mosques Only
	local replace_choice "append"
	local subsample "Mosques"
}
else if (`loc' == 4){
	local doc_title "by_loc_markets" //Markets Only
	local replace_choice "append"
	local subsample "Markets"
}
else if (`loc' == 5){
	local doc_title "by_loc_other" //Other Locations (tea stall, restaurant, main road to enter the village)
	local replace_choice "append"
	local subsample "Other Locations"
}
else if (`loc' == 6){
	local doc_title "excl_mosques" //Exclude Mosques
	local replace_choice "append"
	local subsample "No Mosques"
}


* Merge in Baseline Respiratory Symptoms (from HH Data)
* ---------------------------------------------------------------------
merge m:1 union using "${data_base}\01_clean\union_baseHH_data.dta", keepusing(prop_resp_ill_base_2) keep(1 3) gen(_b_resp_symp)
assert _b_resp_symp == 3
drop _b_resp_symp


* Regressions
* ---------------------------------------------------------------------
* Spec 1: Proper Mask Wearing
disp "reghdfe proper_mask_prop `vill_cross_rand_fe' proper_mask_base prop_resp_ill_base_2 if treatment == 1 [aweight = n_surv_total], noabsorb vce(r)"
reghdfe proper_mask_prop `vill_cross_rand_fe' proper_mask_base prop_resp_ill_base_2 if treatment == 1 [aweight = n_surv_total], noabsorb vce(r)
regsave using "${table_surv}\6a_vill_cross_rand.dta", table(mask_surv_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* Spec 2: Proper Mask Wearing, No Baseline Control
disp "reghdfe proper_mask_prop `vill_cross_rand_fe' if treatment == 1 [aweight = n_surv_total], noabsorb vce(r)"
reghdfe proper_mask_prop `vill_cross_rand_fe' if treatment == 1 [aweight = n_surv_total], noabsorb vce(r)
regsave using "${table_surv}\6b_vill_cross_rand_no_base.dta", table(mask_surv_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* Save Coefficients and SEs from Regression
* ---------------------------------------------------------------------
if (`loc' == 1){
gen id = _n
keep if id <= 5
gen coeff = .
gen se = .
gen var = ""
keep id var coeff se

* Variable Names
replace var = "Surgical Masks"        if _n == 1
replace var = "Public Signage"        if _n == 2
replace var = "Monetary Incentive"    if _n == 3
replace var = "Certificate Incentive" if _n == 4
replace var = "Text Reminders"        if _n == 5

* Coefficients
replace coeff = _b[1.surgical]        if _n == 1
replace coeff = _b[1.signage]         if _n == 2
replace coeff = _b[1.incentive]       if _n == 3
replace coeff = _b[2.incentive]       if _n == 4
replace coeff = _b[100.text_village]  if _n == 5

* Standard Errors
replace se = _se[1.surgical]          if _n == 1
replace se = _se[1.signage]           if _n == 2
replace se = _se[1.incentive]         if _n == 3
replace se = _se[2.incentive]         if _n == 4
replace se = _se[100.text_village]    if _n == 5

* Upper & Lower CI Bound
gen se_upper = coeff + 1.96 * se
gen se_lower = coeff - 1.96 * se


* Graph Village-Level Cross Randomization Graph
* ---------------------------------------------------------------------
* Generate Graph
local ci rcap se_upper se_lower id, horizontal lcolor(`"`dark_blue'"') lpattern(solid) lwidth(0.5 0.5 0.5 0.5)
local mean scatter id coeff , mcolor(`"`dark_blue'"') mfcolor(`"`dark_blue'"') mlcolor(`"`dark_blue'"') mlwidth(0.25)

local legend order(1 "Coefficient" 2 "95% Confidence Intervals")
local legend `legend' cols(1) ring(1) position(1) bmargin(small)

* Save Graph
twoway (`mean') (`ci'), legend(`legend') scheme(burd4) xtitle("Effect") ytitle("") xline(0, lcolor(`"`dark_red'"') lwidth(0.25) lpattern(dash)) ylabel(1 (1) 5, valuelabel) ylabel(1 `" "Mask Type:" "Surgical" "' 2 `" "Public Signage" "' 3 `" "Incentive Type:" "Monetary" "' 4 `" "Incentive Type:" "Certificate" "' 5 `" "100% of Households" "in Village Receive Texts" "')
graph export "${out_surv}\vill_cross_rand_effect.svg", fontface("LM Roman 10")  replace
}

}
