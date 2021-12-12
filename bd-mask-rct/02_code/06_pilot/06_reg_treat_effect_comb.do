* ---------------------------------------------------------------------
* Title:    Regressions - Difference in Treatment Effects
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Regression of difference in treatment effects between the
*           pilots and the main intervention.
* ---------------------------------------------------------------------

* Load Data
*---------------------------------------------------------------------
use "${data_pilot}\01_clean\surv_pilot_comb.dta", clear

* Run Regressions
*---------------------------------------------------------------------
* Pilot 1
reghdfe proper_mask_prop treat_pilot_1 treatment proper_mask_base i.pilot_1 i.pilot_2 [aweight = n_surv_total], noabsorb vce(r)

* Pilot 1, No Baseline Controls
reghdfe proper_mask_prop treat_pilot_1 treatment i.pilot_1 i.pilot_2 [aweight = n_surv_total], noabsorb vce(r)

* Pilot 2
reghdfe proper_mask_prop treat_pilot_2 treatment proper_mask_base i.pilot_1 i.pilot_2 [aweight = n_surv_total], noabsorb vce(r)

* Pilot 2, No Baseline Controls
reghdfe proper_mask_prop treat_pilot_2 treatment i.pilot_1 i.pilot_2 [aweight = n_surv_total], noabsorb vce(r)
