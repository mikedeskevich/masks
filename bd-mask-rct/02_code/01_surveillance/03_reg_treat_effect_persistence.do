* ---------------------------------------------------------------------
* Title:    Regressions - Persistence of Mask Wearing
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Note:     Regressions of persistence of mask wearing over time.
* ---------------------------------------------------------------------

forvalues cons_panel = 0/1{
    
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

* Save week_gen value labels to locals
* ---------------------------------------------------------------------
qui levelsof week_gen, local(levels)
local lab : value label week_gen
local i=0
foreach l of local levels{
    local i = `i' + 1
    local week_label`i' `: label `lab' `l''
}

* Generate Baseline Mask Wearing Rate for Control
* ---------------------------------------------------------------------
preserve
keep if week_gen == 1 //Keep Baseline Data
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

* Collapse Data to Union-Week Level
* ---------------------------------------------------------------------
drop if week_gen == 1 //Drop all Baseline Data

* Run Among All Villages in Sample (Consistent Sample)
* ---------------------------------------------------------------------
if `cons_panel' == 1{
bys union week_gen: gen count = _n == 1
gen week_2 = (week_gen == 2) & count == 1
gen week_3 = (week_gen == 3) & count == 1
gen week_4 = (week_gen == 4) & count == 1
gen week_5 = (week_gen == 5) & count == 1
gen week_6 = (week_gen == 6) & count == 1
gen week_7 = (week_gen == 7) & count == 1
gen week_8 = (week_gen == 8) & count == 1

bys union: egen ever_week_2 = total(week_2)
bys union: egen ever_week_3 = total(week_3)
bys union: egen ever_week_4 = total(week_4)
bys union: egen ever_week_5 = total(week_5)
bys union: egen ever_week_6 = total(week_6)
bys union: egen ever_week_7 = total(week_7)
bys union: egen ever_week_8 = total(week_8)

* Drop Villages that Have Data for Later Weeks But Not Earlier Ones
drop if ever_week_8 == 0
drop if ever_week_8 == 1 & (ever_week_2 == 0 | ever_week_3 == 0 | ever_week_4 == 0 | ever_week_5 == 0 | ever_week_6 == 0 | ever_week_7 == 0)
drop if ever_week_7 == 1 & (ever_week_2 == 0 | ever_week_3 == 0 | ever_week_4 == 0 | ever_week_5 == 0 | ever_week_6 == 0)
drop if ever_week_6 == 1 & (ever_week_2 == 0 | ever_week_3 == 0 | ever_week_4 == 0 | ever_week_5 == 0)
drop if ever_week_5 == 1 & (ever_week_2 == 0 | ever_week_3 == 0 | ever_week_4 == 0)
drop if ever_week_4 == 1 & (ever_week_2 == 0 | ever_week_3 == 0)
drop if ever_week_3 == 1 & (ever_week_2 == 0)

drop ever_week_*
drop week_?
drop count
}


* Collapse to Union-Week Level
gcollapse (sum) n_surv_total (sum) n_proper_mask (sum) n_proper_improper_mask (sum) n_improper_mask (sum) n_soc_dist, by(union treatment pairID wave week_gen *base* surgical* cloth*)
gisid union week_gen

bys union week_gen: gen proper_mask_prop = n_proper_mask/n_surv_total
bys union week_gen: gen soc_dist_prop = n_soc_dist/n_surv_total
replace proper_mask_prop = 0 if n_surv_total == 0
replace soc_dist_prop = 0 if n_surv_total == 0
assert !mi(proper_mask_prop)
assert !mi(soc_dist_prop)

if `cons_panel' == 1{
bys union (week_gen): assert week_gen[1] == 2
bys union (week_gen): assert week_gen[_N] == 8
bys union: assert _N == 7
}


* Set up Regressions
* ---------------------------------------------------------------------
if `cons_panel' == 0{
    local doc_title "incons_panel"
    local v "b"
}
if `cons_panel' == 1{
    local doc_title "cons_panel"
    local v "a"
}



* Merge in Baseline Respiratory Symptoms (from HH Data)
* ---------------------------------------------------------------------
merge m:1 union using "${data_base}\01_clean\union_baseHH_data.dta", keepusing(prop_resp_ill_base_2) keep(1 3) gen(_b_resp_symp)
assert _b_resp_symp == 3
drop _b_resp_symp


* Regressions - Mask Wearing
* ---------------------------------------------------------------------
* Total Effect Across all Weeks
reghdfe proper_mask_prop treatment proper_mask_base prop_resp_ill_base_2 [aweight = n_surv_total], absorb(pairID) vce(r)
regsave  using "${table_surv}\5`v'_mask_surv_pers_`doc_title'.dta", table(mask_surv, format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, "Full") replace


* Effect by Week
forvalues i=2/8{
	reghdfe proper_mask_prop treatment proper_mask_base prop_resp_ill_base_2 if week_gen == `i' [aweight = n_surv_total], absorb(pairID) vce(r)
	regsave  using "${table_surv}\5`v'_mask_surv_pers_`doc_title'.dta", table(mask_surv_`i', format(%5.3f) parentheses(stderr) asterisk()) addlabel(subsample, "`week_label`i''") append

	* Save Regression Results
	gen treat_`i' = _b[treatment] //Coefficient
	gen se_`i' = _se[treatment]
	gen se_`i'_up = treat_`i' + 1.96 * se_`i' //Confidence Interval
	gen se_`i'_lo = treat_`i' - 1.96 * se_`i' //Confidence Interval
}

if `cons_panel' == 1{
* Graph Setup
* ---------------------------------------------------------------------
* Create Matrix Value
forvalues i=2/8{
    local opts s(mean) nomissing mata(M)
    qui gstats tab treat_`i' se_`i'_up se_`i'_lo, `opts' columns(var)
    qui mata MWeek`i'  = `i', M.output
}
mata MWeek = MWeek2 \ MWeek3 \ MWeek4 \ MWeek5 \ MWeek6 \ MWeek7 \ MWeek8


* Generate Stata Dataset of Values
clear
mata stata(sprintf("set obs %g", rows(MWeek)))
mata _addTypes = ("double", "double" , "double", "double")
mata _addNames = ("week", "treat_effect", "treat_se_upper", "treat_se_lower")
mata (void) st_addvar(_addTypes, _addNames)
mata st_store(., _addNames, MWeek)

* Replace Week Variable with Its Labels
gen week_label = .
replace week_label = 0 if week  == 1
replace week_label = 1 if week  == 2
replace week_label = 2 if week  == 3
replace week_label = 4 if week  == 4
replace week_label = 6 if week  == 5
replace week_label = 8 if week  == 6
replace week_label = 10 if week == 7
replace week_label = 12 if week == 8
drop week
rename week_label week

local xopts xlabel(1(1)10 12 "20-27" 13 " ", add)


* Generate Treatment Effect Graph
* ---------------------------------------------------------------------
* Generate Graph
local term_line line treat_effect week, xaxis(1) lcolor(`"`dark_blue'"') fcolor(ltblue) lwidth(0.5 0.5 0.5 0.5) lpattern(solid) ylabel(0(0.1)0.5) `xopts'
local ci rcap treat_se_upper treat_se_lower week, lcolor(`"`dark_blue'"') lpattern(solid) lwidth(0.5 0.5 0.5 0.5)

local legend order(1 "Intervention Effect")
local legend `legend' cols(1) ring(1) position(1) bmargin(small)

* Save Graph
twoway (`term_line') (`ci'), legend(`legend') scheme(burd4) ytitle("Proportion Surveilled Properly Wearing a Mask") xtitle("Week Relative to Baseline") xline(8 ,lcolor(`"`dark_red'"') lwidth(0.25) lpattern(dash)) text(0.42 8 "End of Intervention", placement(east) size(.2cm) orientation(vertical))
graph export "${out_surv}\treat_pers_`doc_title'.svg", fontface("LM Roman 10") replace
}
}
