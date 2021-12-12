* ---------------------------------------------------------------------
* Title:    Regressions - Household Cross Randomization
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Regression of household cross randomzation interventions.
* ---------------------------------------------------------------------

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

* Create Factor Variables for Each Household-Level Randomizations
* ---------------------------------------------------------------------
local hh_cross_rand "text_hh altruism_hh commit_hh"
local hh_cross_rand_fe
foreach rand of varlist `hh_cross_rand'{
	local hh_cross_rand_fe `hh_cross_rand_fe' i.`rand'
}

* Collapse to Union Level
* ---------------------------------------------------------------------
drop if week_gen == 1 //Drop Baseline Data (Before Intervention Start)
drop if week_gen == 7 //Drop Week 10 Data (Post Intervention End)
drop if week_gen == 8 //Drop Followup-1 Data (Post Intervention End)
keep if treatment == 1 //Keep Treatment Unions

gcollapse (sum) n_surv_total (sum) n_project_mask (sum) n_mask_*, by(union `hh_cross_rand' surgical treatment pairID treat_color mask_treat_color)
gisid union
assert n_project_mask == n_mask_blue + n_mask_red + n_mask_green + n_mask_purple

* Count Number of People Wearing Colored Masks
* ---------------------------------------------------------------------
* Number of People Wearing Treatment Color
levelsof treat_color, local(colors)
gen n_treat_color = 0
foreach color of local colors{
	replace n_treat_color = n_mask_`color' if treat_color == "`color'"
}

* Number of People Wearing Control Color
gen n_control_color = 0
replace n_control_color = n_mask_red    if treat_color == "purple" & surgical == 0 //Cloth Masks: RED or PURPLE
replace n_control_color = n_mask_purple if treat_color == "red"    & surgical == 0 //Cloth Masks: RED or PURPLE
replace n_control_color = n_mask_blue   if treat_color =="green"   & surgical == 1 //Surgical Masks: GREEN or BLUE
replace n_control_color = n_mask_green  if treat_color == "blue"   & surgical == 1 //Surgical Masks: GREEN or BLUE


* Count Proportion Wearing Treatment and Control Mask Colors
bys union: gen treat_color_mask_prop   = n_treat_color/n_surv_total
bys union: gen contr_color_mask_prop   = n_control_color/n_surv_total
bys union: gen treat_diff_prop         = treat_color_mask_prop - contr_color_mask_prop

assert !mi(treat_color_mask_prop)
assert !mi(contr_color_mask_prop)
assert !mi(treat_diff_prop)

* Regressions
* ---------------------------------------------------------------------
* Spec 1 - Control for Mask Color & Mask Type
disp "reghdfe treat_diff_prop `hh_cross_rand_fe' i.surgical ib2.mask_treat_color if treatment == 1 [aweight = n_surv_total], noabsorb vce(r)"
reghdfe treat_diff_prop `hh_cross_rand_fe' i.surgical ib2.mask_treat_color  if treatment == 1 [aweight = n_surv_total], noabsorb vce(r)
regsave using "${table_surv}\7_hh_cross_rand.dta", table(color, format(%5.3f) parentheses(stderr) asterisk()) replace

* Save Coefficients and SEs from Regression
* ---------------------------------------------------------------------
keep if _n <=6
gen id = _n
gen coeff = .
gen se = .
gen var = ""
keep id var coeff se

* Variable Names
replace var = "50% of HHs in Union Receive Texts" if _n == 1
replace var = "100% of HHs Receive Texts"         if _n == 2
replace var = "Altruistic Messaging"              if _n == 3
replace var = "Verbal Commitment"                 if _n == 4
replace var = "Blue Mask Color"                   if _n == 5
replace var = "Purple Mask Color"                 if _n == 6

* Coefficients
replace coeff = _b[50.text_hh]                    if _n == 1
replace coeff = _b[100.text_hh]                   if _n == 2
replace coeff = _b[1.altruism_hh]                 if _n == 3
replace coeff = _b[1.commit_hh]                   if _n == 4
replace coeff = _b[1.mask_treat_color]            if _n == 5
replace coeff = _b[3.mask_treat_color]            if _n == 6

* Standard Errors
replace se = _se[50.text_hh]                      if _n == 1
replace se = _se[100.text_hh]                     if _n == 2
replace se = _se[1.altruism_hh]                   if _n == 3
replace se = _se[1.commit_hh]                     if _n == 4
replace se = _se[1.mask_treat_color]              if _n == 5
replace se = _se[3.mask_treat_color]              if _n == 6

* Upper & Lower CI Bound
gen se_upper = coeff + 1.96 * se
gen se_lower = coeff - 1.96 * se

* Resort Values
gen long newid = _N - _n + 1 
sort newid
drop id
rename newid id

* Graph Household-Level Cross Randomization Graph
* ---------------------------------------------------------------------
local ci rcap se_upper se_lower id, horizontal lcolor(`"`dark_blue'"') lpattern(solid) lwidth(0.5 0.5 0.5 0.5)
local mean scatter id coeff , mcolor(`"`dark_blue'"') mfcolor(`"`dark_blue'"') mlcolor(`"`dark_blue'"') mlwidth(0.25)

local legend order(1 "Coefficient" 2 "95% Confidence Intervals")
local legend `legend' cols(1) ring(1) position(1) bmargin(small)

* Save Graph
twoway (`mean') (`ci'), legend(`legend') scheme(burd4) xtitle("Effect") ytitle("") xline(0, lcolor(`"`dark_red'"') lwidth(0.25) lpattern(dash)) ylabel(1 (1) 6, valuelabel) ylabel(1 `" "Mask Color:" "Purple vs Red" "' 2 `" "Mask Color:" "Blue vs Green" "' 3 `" "Verbal Commitment" "' 4 `" "Altruistic Messaging" "' 5 `" "50% of Households" "in Village Receive Texts" "' 6 `" "100% of Households" "in Village Receive Texts" "')
graph export "${out_surv}\hh_cross_rand_effect.svg", fontface("LM Roman 10")  replace

log close _all
