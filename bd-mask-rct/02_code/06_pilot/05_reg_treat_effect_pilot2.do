* ---------------------------------------------------------------------
* Title:    Regressions - Treatment Effect on Mask Wearing (Pilot 2)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Regression of treatment effects on mask wearing during
*           pilot 2.
* ---------------------------------------------------------------------

* Load Data
*---------------------------------------------------------------------
use "${data_pilot}\01_clean\surv_pilot2.dta", clear


* Collapse to Union Level, Baseline
* ---------------------------------------------------------------------
preserve
keep if post == 0
gcollapse (sum) n_surv_total (sum) n_proper_mask (sum) n_soc_dist, by(vill_id treatment)
gisid vill_id

gen proper_mask_prop_base = n_proper_mask/n_surv_total
gen soc_dist_prop_base = n_soc_dist/n_surv_total
assert !mi(proper_mask_prop_base)
assert !mi(soc_dist_prop_base)

tempfile BaselineStats
save `BaselineStats'
restore

* Collapse to Union Level, Endline
* ---------------------------------------------------------------------
preserve
keep if post == 1
gcollapse (sum) n_surv_total (sum) n_proper_mask (sum) n_soc_dist, by(vill_id treatment)
gisid vill_id

merge 1:1 vill_id using `BaselineStats', keep(1 3) gen(_base)
assert !mi(proper_mask_prop_base)
assert !mi(soc_dist_prop_base)
	
gen proper_mask_prop = n_proper_mask/n_surv_total
gen soc_dist_prop = n_soc_dist/n_surv_total
assert !mi(proper_mask_prop)
assert !mi(soc_dist_prop)
assert !mi(treatment)


* Regressions
* ---------------------------------------------------------------------
* Spec 1: Proper Mask Wearing
reg proper_mask_prop treatment proper_mask_prop_base [aweight = n_surv_total], r
boottest treatment

* Spec 2: Proper Mask Wearing, No Baseline Controls
reg proper_mask_prop treatment [aweight = n_surv_total], r
boottest treatment


* Summary Statistics
* ---------------------------------------------------------------------
gcollapse (sum) n_surv_total (sum) n_proper_mask (sum) n_soc_dist, by(treatment)
gisid treatment

gen proper_mask_prop_base = n_proper_mask/n_surv_total
gen soc_dist_prop_base = n_soc_dist/n_surv_total
list treatment prop*, ab(32)
