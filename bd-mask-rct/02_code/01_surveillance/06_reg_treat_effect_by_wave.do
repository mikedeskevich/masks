* ---------------------------------------------------------------------
* Title:    Regressions - Treatment Effect on Mask Wearing by Wave
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Regression of treatment effects on mask surveillance and
*           social distancing by wave.
* ---------------------------------------------------------------------

* Loop through all locations
* ---------------------------------------------------------------------
forvalues wave = 1/7{

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

* Filter by Wave
* ---------------------------------------------------------------------
keep if wave == `wave'

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
local replace_choice "append"
if `wave' == 1{
	local replace_choice "replace"
}

local doc_title "wave_`wave'"
local subsample "Wave `wave'"


* Merge in Baseline Respiratory Symptoms (from HH Data)
* ---------------------------------------------------------------------
merge m:1 union using "${data_base}\01_clean\union_baseHH_data.dta", keepusing(prop_resp_ill_base_2) keep(1 3) gen(_b_resp_symp)
assert _b_resp_symp == 3
drop _b_resp_symp


* Regressions - Mask Wearing
* ---------------------------------------------------------------------
* Spec 1: Proper Mask Wearing
reghdfe proper_mask_prop treatment proper_mask_base prop_resp_ill_base_2 [aweight = n_surv_total], absorb(pairID) vce(r)
regsave using "${table_surv}\8a_mask_surv_by_wave.dta", table(mask_surv_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'

* Spec 2: Proper Mask Wearing, No Baseline Control
reghdfe proper_mask_prop treatment if !mi(proper_mask_base) [aweight = n_surv_total], absorb(pairID) vce(r)
regsave using "${table_surv}\8b_mask_surv_by_wave_no_base.dta", table(mask_surv_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* Regressions - Social Distancing
* ---------------------------------------------------------------------
* Spec 1: Social Distancing
reghdfe soc_dist_prop treatment soc_dist_base prop_resp_ill_base_2 [aweight = n_surv_total], absorb(pairID) vce(r)
regsave using "${table_surv}\9a_soc_dist_by_wave.dta", table(soc_dist_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample') `replace_choice'


* Spec 2: Social Distancing, No Baseline Control
reghdfe soc_dist_prop treatment if !mi(soc_dist_base)  [aweight = n_surv_total], absorb(pairID) vce(r)
regsave using "${table_surv}\9b_soc_dist_by_wave_no_base.dta", table(soc_dist_`doc_title', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, `subsample')  `replace_choice'

* Summary Stats - By Treatment Status
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
list, ab(32)
restore

}
