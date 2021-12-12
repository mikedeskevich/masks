* ---------------------------------------------------------------------
* Title:    Regressions - Treatment Effect on Mask Wearing
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Regression of treatment effects on mask wearing within
*           full sample and by location type.
* ---------------------------------------------------------------------

* Loop through all locations
* ---------------------------------------------------------------------
forvalues loc = 1/8{

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

* [7] Surgical Villages
else if `loc' == 7{
	keep if surgical_pair == 1 //Only Surgical Villages and their Pairs
}

* [8] Cloth Villages
else if `loc' == 8{
	keep if cloth_pair == 1 //Only Cloth Villages and their Pairs
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


gcollapse (sum) n_surv_total (sum) n_surv_female (sum) n_surv_male (sum) n_surv_sex (sum) n_proper_mask (sum) n_proper_mask_f (sum) n_proper_mask_m (sum) n_proper_improper_mask (sum) n_proper_improper_mask_f (sum) n_proper_improper_mask_m (sum) n_improper_mask (sum) n_improper_mask_m (sum) n_improper_mask_f (sum) n_soc_dist, by(union treatment pairID wave *base* surgical* cloth*)
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
else if (`loc' == 7){
	local doc_title "by_surg" //Only Surgical Mask Villages and their Pairs
	local replace_choice "append"
	local subsample "Surgical Villages"
}
else if (`loc' == 8){
	local doc_title "by_cloth" //Only Surgical Mask Villages and their Pairs
	local replace_choice "append"
	local subsample "Cloth Villages"
}



* Merge in Baseline Respiratory Symptoms (from HH Data)
* ---------------------------------------------------------------------
merge m:1 union using "${data_base}\01_clean\union_baseHH_data.dta", keepusing(prop_resp_ill_base_2) keep(1 3) gen(_b_resp_symp)
assert _b_resp_symp == 3
drop _b_resp_symp


* Regressions - Mask Wearing
* ---------------------------------------------------------------------
* Spec 1: Proper Mask Wearing
reghdfe proper_mask_prop treatment proper_mask_base prop_resp_ill_base_2 [aweight = n_surv_total], absorb(pairID) vce(r)
regsave using "${table_surv}\1a_mask_surv.dta", table(mask_surv_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* Spec 2: Proper Mask Wearing, No Baseline Control
reghdfe proper_mask_prop treatment if !mi(proper_mask_base) [aweight = n_surv_total], absorb(pairID) vce(r)
regsave using "${table_surv}\1b_mask_surv_no_base.dta", table(mask_surv_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* Regressions - Social Distancing
* ---------------------------------------------------------------------
* Spec 1: Social Distancing
reghdfe soc_dist_prop treatment soc_dist_base prop_resp_ill_base_2 [aweight = n_surv_total], absorb(pairID) vce(r)
regsave using "${table_surv}\2a_soc_dist.dta", table(soc_dist_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* Spec 2: Social Distancing, No Baseline Control
reghdfe soc_dist_prop treatment if !mi(soc_dist_base)  [aweight = n_surv_total], absorb(pairID) vce(r)
regsave using "${table_surv}\2b_soc_dist_no_base.dta", table(soc_dist_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample')  `replace_choice'

* Regressions - Number of People Surveilled
* ---------------------------------------------------------------------
* Spec 1: Number of People Surveilled
reghdfe n_surv_total treatment n_surv_total_base , absorb(pairID) vce(r)
regsave using "${table_surv}\3a_n_surv.dta", table(n_surv_`doc_title', format(%5.0f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* Spec 2: Number of People Surveilled, No Baseline Control
reghdfe n_surv_total treatment, absorb(pairID) vce(r)
regsave using "${table_surv}\3b_n_surv_no_base.dta", table(n_surv_`doc_title', format(%5.0f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample')  `replace_choice'

* Additional Subsample Regressions - Use the Full Sample Data
* ---------------------------------------------------------------------
if (`loc' == 1){
    
* Regressions - Above Median Baseline Mask Wearing
* ---------------------------------------------------------------------
* Spec 1: Proper Mask Wearing
reghdfe proper_mask_prop treatment proper_mask_base prop_resp_ill_base_2 if dum_med_base == 1 [aweight = n_surv_total], absorb(pairID) vce(r)
regsave using "${table_surv}\4a_mask_surv_subgroup.dta", table(mask_surv_above_med_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, Above Median) replace


* Spec 2: Proper Mask Wearing, No Baseline Control
reghdfe proper_mask_prop treatment if dum_med_base == 1 [aweight = n_surv_total], absorb(pairID) vce(r)
regsave using "${table_surv}\4b_mask_surv_subgroup_no_base.dta", table(mask_surv_above_med_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, Above Median) replace

* Regressions - Below Median Baseline Mask Wearing
* ---------------------------------------------------------------------
* Spec 1: Proper Mask Wearing
reghdfe proper_mask_prop treatment proper_mask_base prop_resp_ill_base_2 if dum_med_base == 0 [aweight = n_surv_total], absorb(pairID) vce(r)
regsave using "${table_surv}\4a_mask_surv_subgroup.dta", table(mask_surv_below_med_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, Below Median) append

* Spec 2: Proper Mask Wearing, No Baseline Control
reghdfe proper_mask_prop treatment if dum_med_base == 0 [aweight = n_surv_total], absorb(pairID) vce(r)
regsave using "${table_surv}\4b_mask_surv_subgroup_no_base.dta", table(mask_surv_below_med_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, Below Median) append
}


* Gender-Specific Regressions - Excludes Mosque Data
* ---------------------------------------------------------------------
if (`loc' == 6){
* Regressions - Female Only
* ---------------------------------------------------------------------
* Spec 1: Proper Mask Wearing
reghdfe proper_mask_prop_f treatment proper_mask_base prop_resp_ill_base_2 [aweight = n_surv_female], absorb(pairID) vce(r)
regsave using "${table_surv}\4a_mask_surv_subgroup.dta", table(mask_surv_f_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, Female Only) append

* Spec 2: Proper Mask Wearing, No Baseline Control
reghdfe proper_mask_prop_f treatment [aweight = n_surv_female], absorb(pairID) vce(r)
regsave using "${table_surv}\4b_mask_surv_subgroup_no_base.dta", table(mask_surv_f_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, Female Only) append

* Regressions - Male Only
* ---------------------------------------------------------------------
* Spec 1: Proper Mask Wearing
reghdfe proper_mask_prop_m treatment proper_mask_base prop_resp_ill_base_2 [aweight = n_surv_male], absorb(pairID) vce(r)
regsave using "${table_surv}\4a_mask_surv_subgroup.dta", table(mask_surv_m_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, Male Only) append


* Spec 2: Proper Mask Wearing, No Baseline Control
reghdfe proper_mask_prop_m treatment [aweight = n_surv_male], absorb(pairID) vce(r)
regsave using "${table_surv}\4b_mask_surv_subgroup_no_base.dta", table(mask_surv_m_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, Male Only) append
}


* Summary Stats on Mask Wearing - By Treatment Status
* ---------------------------------------------------------------------
preserve
gcollapse (mean) avg_obs = n_surv_total (sum) n_surv_total (sum) n_surv_female (sum) n_surv_male (sum) n_surv_sex (sum) n_proper_mask (sum) n_proper_mask_f (sum) n_proper_mask_m (sum) n_proper_improper_mask (sum) n_proper_improper_mask_f (sum) n_proper_improper_mask_m (sum) n_improper_mask (sum) n_improper_mask_m (sum) n_improper_mask_f (sum) n_soc_dist, by(treatment)


bys treatment: gen proper_mask_prop = n_proper_mask/n_surv_total
bys treatment: gen proper_improper_mask = n_proper_improper_mask/n_surv_total
bys treatment: gen improper_mask_prop = n_improper_mask/n_surv_total
bys treatment: gen soc_dist_prop = n_soc_dist/n_surv_total

bys treatment: gen proper_mask_prop_f = n_proper_mask_f/n_surv_female
bys treatment: gen proper_improper_mask_f = n_proper_improper_mask_f/n_surv_female
bys treatment: gen improper_mask_prop_f = n_improper_mask_f/n_surv_female

bys treatment: gen proper_mask_prop_m = n_proper_mask_m/n_surv_male
bys treatment: gen proper_improper_mask_m = n_proper_improper_mask_m/n_surv_male
bys treatment: gen improper_mask_prop_m = n_improper_mask_m/n_surv_male

gen sample = "`subsample'"
format *prop %5.3f
order sample treatment proper_mask_prop soc_dist_prop avg_obs

tempfile SummStats`loc'
save `SummStats`loc''
list, ab(32)
restore


* Summary Stats on Mask Wearing - By Treatment Status X Above/Below-Median Baseline Mask Wearing
* ---------------------------------------------------------------------
if (`loc' == 1){
preserve
gcollapse (mean) avg_obs = n_surv_total (sum) n_surv_total (sum) n_proper_mask, by(treatment dum_med_base)
bys treatment dum_med_base: gen proper_mask_prop = n_proper_mask/n_surv_total

list, ab(32)
restore
}
}

* Save Summary Stats
* ---------------------------------------------------------------------
use `SummStats1', clear
forvalues loc = 2/8{
	append using `SummStats`loc''
}
save "${table_surv}\summ_stats.dta", replace
