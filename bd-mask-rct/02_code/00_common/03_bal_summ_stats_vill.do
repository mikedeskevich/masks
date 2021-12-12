* ---------------------------------------------------------------------
* Title:    Summary Statistics on Basline Variables
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Generates summary statistics on baseline variables using
*           union-level data.
* ---------------------------------------------------------------------

* Load Clean Union-Level Data
* ---------------------------------------------------------------------
use "${data_com}\01_clean\union_data_base.dta", clear


gcollapse (sum) member_count  (sum) n_posXsymp_base (sum) n_resp_ill_base_2 (sum) n_surv_total_base (sum) n_proper_mask_base , by(treatment)

gen prop_resp_ill_base_2 = n_resp_ill_base_2/member_count
gen prop_mask_base = n_posXsymp_base/n_surv_total_base
gen prop_sympXsero_base = n_posXsymp_base/member_count


format prop* %6.5f
list treatment prop*, ab(32)
