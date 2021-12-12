* ---------------------------------------------------------------------
* Title:    Main
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Note:     To run an analysis, run main.do while specifying the table
*           or figure you are trying to replicate. For example, to generate
*           the output in Table 2, run
*           do main.do table2
* ---------------------------------------------------------------------

* Specify Options
* ---------------------------------------------------------------------
include 02_code\options.do

* Error Checking
* ---------------------------------------------------------------------
cap syntax anything
if _rc{
	display as error "Specify Analysis to Run"
	exit 111
}

local valid: list posof "`anything'" in option
if !`valid'{
    display as error "Specify Valid Analysis to Run"
	exit 111
}

local analysis: copy local anything

* Run Log
* ---------------------------------------------------------------------
cap log close _all
local date : display %tdCYND date(c(current_date), "DMY")
local logName "`analysis'_`date'"
cap mkdir 02_code\logs\
log using "02_code\logs\\`logName'.log", text replace

* Run Preamble
* ---------------------------------------------------------------------
include 02_code\00_preamble.do

* Generates Union-Level Baseline Summary Stats
* Note: Verifies that all union level baseline summary stats exist.
*       If not, generate the data.
* ---------------------------------------------------------------------
* Baseline Mask Wearing
local cachedFile ${data_surv}\01_clean\union_surv_data_base.dta
cap confirm file "`cachedFile'"
if (_rc) {
	local cachedFile ${data_surv}\01_clean\surv_data.dta
	cap confirm file "`cachedFile'"
	if (_rc) {
		do ${code_surv}\01_clean_data.do
	}
	do ${code_surv}\07_stats_union_level.do
}

* Mask Wearing Throughout Intervention
local cachedFile ${data_surv}\01_clean\union_surv_data.dta
cap confirm file "`cachedFile'"
if (_rc) {
	local cachedFile ${data_surv}\01_clean\surv_data.dta
	cap confirm file "`cachedFile'"
	if (_rc) {
		do ${code_surv}\01_clean_data.do
	}
	do ${code_surv}\07_stats_union_level.do
}

* Baseline COVID-19 Symptoms
local cachedFile ${data_base}\01_clean\union_baseHH_data.dta
cap confirm file "`cachedFile'"
if (_rc) {	
	local cachedFile ${data_base}\01_clean\baseHH_data_ind.dta
	cap confirm "`cachedFile'"
	if (_rc) {
		do ${code_base}\01_clean_data.do
		do ${code_base}\02_list_hh_member.do
	}
	do ${code_base}\03_stats_union_level.do
}

* Generate Clean Surveillance Data
* Note: Verifies that all datasets needed in the regressions related
*       to mask surveillance exist. If not, then generate the data.
* ---------------------------------------------------------------------
local surv_analysis: list posof "`analysis'" in surv
if `surv_analysis' > 0 {
    local cachedFile ${data_surv}\01_clean\surv_data.dta
    cap confirm file "`cachedFile'"
    if (_rc) {
        do 02_code\surveillance\01_clean_data.do
	}
}

* Generate Clean Endline Blood  Data
* Note: Verfies that all datasets needed in the regressions relating
*       to endline symptomatic-seropositivity and symptomatic status
*       exist. If not, generate the data.
* ---------------------------------------------------------------------
local blood_analysis: list posof "`analysis'" in blood
if `blood_analysis' > 0 {
    local cachedFile ${data_blood_end}\01_clean\bloodDraw_elig_ind.dta
    cap confirm file "`cachedFile'"
    if (_rc) {
    	do ${code_phone}\01_clean_data.do
    	do ${code_phone}\02_list_hh_member.do
    	do ${code_followup}\01_clean_data.do
    	do ${code_followup}\02_list_hh_member.do
        do ${code_blood_end}\01_list_elig_hh_member.do
    }

    local cachedFile ${data_blood_end}\01_clean\endlineBlood_data.dta
    cap confirm file "`cachedFile'"
    if (_rc) {
        do ${code_blood_end}\02_clean_data_endline.do
    }
	
}

* Table 1, Table S5, Table S6
* ---------------------------------------------------------------------
if (`"`analysis'"' == "table1") | (`"`analysis'"' == "tables5") | (`"`analysis'"' == "tables6") | (`"`analysis'"' == "tables11"){
	* Run Regressions
    do ${code_surv}\02_reg_treat_effect.do	
}	

* Table 2 & Table S7
* ---------------------------------------------------------------------
if (`"`analysis'"' == "table2") | (`"`analysis'"' == "tables7"){
	* Create Folders
	cap mkdir ${table_blood_end}\main\

    * Run Regressions
    do ${code_blood_end}\03a_reg_symp_sero.do

    * Format Results in Tables
    local pooled_results 3a_symp_sero_pool 3b_symp_sero_pool_no_base
    local mask_results 4a_symp_sero_mask 4b_symp_sero_mask_no_base
    foreach var of local pooled_results{
        qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(main)
    }
    foreach var of local mask_results{
        qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(main)
    }
}


* Table 3 & Table S8
* ---------------------------------------------------------------------
if (`"`analysis'"' == "table3") | (`"`analysis'"' == "tables8"){
	* Create Folders
	cap mkdir ${table_blood_end}\main\
	
    * Run Regressions
    do ${code_blood_end}\03b_reg_symp.do
	
    * Format Results in Tables
    local pooled_results 7a_symp_pool 7b_symp_pool_no_base
    local mask_results 8a_symp_mask 8b_symp_mask_no_base
    foreach var of local pooled_results{
        qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(main)
    }
    
    foreach var of local mask_results{
        qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(main)
    }
}

* Table 4
* ---------------------------------------------------------------------
if ( `"`analysis'"' == "table4" ) | (`"`analysis'"' == "tables26"){
	* Create Folders
	cap mkdir ${table_blood_end}\main\
	cap mkdir ${table_blood_end}\robustness\
	cap mkdir ${table_blood_end}\robustness\age_bin\
	cap mkdir ${table_blood_end}\simulation\
	cap mkdir ${table_blood_end}\simulation\age_bin\

	* Generate Simulated Data
    local cachedFile ${data_blood_end}\01_clean\endlineBlood_data_sim.dta
    cap confirm file "`cachedFile'"
    if (_rc) {
        do ${code_blood_end}\simulation\01_gen_data_impute.do
    }
	
	* Run Regressions
	do ${code_blood_end}\03a_reg_symp_sero.do
	do ${code_blood_end}\robustness\01a_reg_symp_sero_age_bin.do
	do ${code_blood_end}\simulation\02a_reg_symp_sero_sim.do
	do ${code_blood_end}\simulation\03a_reg_symp_sero_sim_age_bin.do
	
	* Format Results in Tables
    local pooled_results 3a_symp_sero_pool 3b_symp_sero_pool_no_base
    local mask_results 4a_symp_sero_mask 4b_symp_sero_mask_no_base
    foreach var of local pooled_results{
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(main)
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(below_40 btwn_40_50 btwn_50_60 above_60) path(robustness\age_bin)
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(simulation)
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(below_40 btwn_40_50 btwn_50_60 above_60) path(simulation\age_bin)
    }

    foreach var of local mask_results{
    	qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(main)
		qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(below_40 btwn_40_50 btwn_50_60 above_60) path(robustness\age_bin)
        qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(simulation)
        qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(below_40 btwn_40_50 btwn_50_60 above_60) path(simulation\age_bin)
    }
}

* Table S1 & Table S3
* ---------------------------------------------------------------------
if ( `"`analysis'"' == "tables1" ) | ( `"`analysis'"' == "tables3" ){
	do ${code_com}\09_enrollment_consent_rates.do
}

* Table S2
* ---------------------------------------------------------------------
if ( `"`analysis'"' == "tables2" ){
	do ${code_com}\10_enrollment_consent_rates_hh.do
}

* Table S4
* ---------------------------------------------------------------------
if ( `"`analysis'"' == "tables4" ){
	do ${code_blood_base}\01_clean_data_baseline.do
	do ${code_com}\01_stats_union_level_baseline.do
	do ${code_com}\02_bal_tests_vill.do
	do ${code_com}\03_bal_summ_stats_vill.do
}

* Table S9
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables9"){
	* Create Folders
	cap mkdir ${table_blood_end}\robustness\
	cap mkdir ${table_blood_end}\robustness\symp_sero_sample\
	
    * Run Regressions
    do ${code_blood_end}\robustness\03_reg_symp_robust.do

    * Format Results in Tables
    local pooled_results 7a_symp_pool 7b_symp_pool_no_base
    local mask_results 8a_symp_mask 8b_symp_mask_no_base
    foreach var of local pooled_results{
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(robustness\symp_sero_sample)
    }
    
    foreach var of local mask_results{
		qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(robustness\symp_sero_sample)
    }
}

* Table S10
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables10"){
	local cachedFile ${data_pilot}\01_clean\surv_pilot_comb.dta
	cap confirm file "`cachedFile'"
    if (_rc) {
        do ${code_pilot}\01_clean_data_pilot1.do
		do ${code_pilot}\02_clean_data_pilot2.do
		do ${code_pilot}\03_clean_data_comb.do
    }
	
	* Run Regressions
	do ${code_pilot}\04_reg_treat_effect_pilot1.do
	do ${code_pilot}\05_reg_treat_effect_pilot2.do
	do ${code_pilot}\06_reg_treat_effect_comb.do
}

* Table S12
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables12"){
	* Create Folders
	cap mkdir ${table_blood_end}\main\
	cap mkdir ${table_blood_end}\robustness\
	cap mkdir ${table_blood_end}\robustness\age_dec
	
    * Run Regressions
	do ${code_blood_end}\03a_reg_symp_sero.do
    do ${code_blood_end}\robustness\02a_reg_symp_sero_age_dec.do

    * Format Results in Tables
    local pooled_results 3a_symp_sero_pool 3b_symp_sero_pool_no_base
    local mask_results 4a_symp_sero_mask 4b_symp_sero_mask_no_base
    foreach var of local pooled_results{
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(main)
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(btwn_18_30 btwn_30_40 btwn_40_50 btwn_50_60 btwn_60_70 above_70) path(robustness\age_dec)
    }
    
    foreach var of local mask_results{
		qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(main)
		qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(btwn_18_30 btwn_30_40 btwn_40_50 btwn_50_60 btwn_60_70 above_70) path(robustness\age_dec)
    }
}

* Table S13 & Table S15
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables13") | (`"`analysis'"' == "tables15") {
	* Create Folders
	cap mkdir ${table_blood_end}\main\
	cap mkdir ${table_blood_end}\robustness\
	cap mkdir ${table_blood_end}\robustness\age_bin
	
    * Run Regressions
	do ${code_blood_end}\03b_reg_symp.do
    do ${code_blood_end}\robustness\01b_reg_symp_age_bin.do
	
	* Format Results in Tables
    local pooled_results 7a_symp_pool 7b_symp_pool_no_base
    local mask_results 8a_symp_mask 8b_symp_mask_no_base
    foreach var of local pooled_results{
        qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(main)
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(below_40 btwn_40_50 btwn_50_60 above_60) path(robustness\age_bin)
    }
    
    foreach var of local mask_results{
        qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(main)
		qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(below_40 btwn_40_50 btwn_50_60 above_60) path(robustness\age_bin)
    }
}

* Table S14
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables14"){
    * Create Folders
	cap mkdir ${table_blood_end}\main\
	cap mkdir ${table_blood_end}\robustness\
	cap mkdir ${table_blood_end}\robustness\age_dec
	
    * Run Regressions
	do ${code_blood_end}\03b_reg_symp.do
    do ${code_blood_end}\robustness\02b_reg_symp_age_dec.do

    * Format Results in Tables
    local pooled_results 7a_symp_pool 7b_symp_pool_no_base
    local mask_results 8a_symp_mask 8b_symp_mask_no_base
    foreach var of local pooled_results{
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(main)
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(btwn_18_30 btwn_30_40 btwn_40_50 btwn_50_60 btwn_60_70 above_70) path(robustness\age_dec)
    }
    
    foreach var of local mask_results{
	    qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(main)
		qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(btwn_18_30 btwn_30_40 btwn_40_50 btwn_50_60 btwn_60_70 above_70) path(robustness\age_dec)
    }
}

* Table S16 & Figure S4
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables16") | (`"`analysis'"' == "figures4"){
    * Run Regressions
    include ${code_surv}\04_reg_vill_cross_rand.do
}

* Table S17
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables17") | (`"`analysis'"' == "figures5"){
    * Run Regressions
    include ${code_surv}\05_reg_hh_cross_rand.do
}

* Table S18
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables18"){
    * Run Regressions
    do ${code_com}\04_balance_tests_ind.do
    do ${code_com}\05_bal_summ_stats_ind.do
}


* Table S19
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables19"){
    * Run Regressions
    do ${code_com}\06_bal_tests_ind_add.do
    do ${code_com}\07_bal_summ_stats_ind_add.do
}


* Table S20
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables20"){
    * Run Regressions
	do ${code_com}\08_bal_tests_ind_add_sample_sel.do
}


* Table S21
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables21"){
	* Create Folders
	cap mkdir ${table_blood_end}\main\
	cap mkdir ${table_blood_end}\robustness\
	cap mkdir ${table_blood_end}\robustness\add_controls
	cap mkdir ${table_blood_end}\robustness\add_sample_selection
	
	
    * Run Regressions
    do ${code_blood_end}\robustness\04_reg_symp_sero_add_cont.do
    do ${code_blood_end}\robustness\05_reg_symp_sero_add_sample_selection.do

    * Format Results in Tables
    local pooled_results 3a_symp_sero_pool 3b_symp_sero_pool_no_base
    local mask_results 4a_symp_sero_mask 4b_symp_sero_mask_no_base
    foreach var of local pooled_results{
        qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(robustness\add_controls)
        qui do ${code_blood_end}\format\1a_format_pool.do `var';args(full) path(robustness\add_sample_selection)
    }
    
    foreach var of local mask_results{
        qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(robustness\add_controls)
        qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(robustness\add_sample_selection)
    }
}


* Table S22
* ---------------------------------------------------------------------
* Persistence of Mask Wearing
if ( `"`analysis'"' == "tables22" ) | ( `"`analysis'"' == "figures6" ){
    include ${code_surv}\03_reg_treat_effect_persistence.do
}

* Table S23
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables23"){
    do ${code_surv}\06_reg_treat_effect_by_wave.do
}

* Table S24
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables24"){
	* Create Folders
	cap mkdir ${table_blood_end}\main\
	cap mkdir ${table_blood_end}\robustness\
	cap mkdir ${table_blood_end}\robustness\wave\
	cap mkdir ${table_blood_end}\simulation\
	cap mkdir ${table_blood_end}\simulation\wave\
	
	* Generate Simulated Data
    local cachedFile ${data_blood_end}\01_clean\endlineBlood_data_sim.dta
    cap confirm file "`cachedFile'"
    if (_rc) {
        do ${code_blood_end}\simulation\01_gen_data_impute.do
    }
	
	do ${code_blood_end}\03a_reg_symp_sero.do
    do ${code_blood_end}\robustness\06_reg_symp_sero_by_wave.do
	do ${code_blood_end}\simulation\02a_reg_symp_sero_sim.do
    do ${code_blood_end}\simulation\04_reg_symp_sero_sim_by_wave.do


    * Format Results in Tables
    local pooled_results 3a_symp_sero_pool 3b_symp_sero_pool_no_base
    local mask_results 4a_symp_sero_mask 4b_symp_sero_mask_no_base
    foreach var of local pooled_results{
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(main)
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(simulation)
        qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(wave1 wave2 wave3 wave4 wave5 wave6 wave7) path(robustness\wave)
        qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(wave1 wave2 wave3 wave4 wave5 wave6 wave7) path(simulation\wave)
    }
    
    foreach var of local mask_results{
		qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(main)
		qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(simulation)
        qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(wave1 wave2 wave3 wave4 wave5 wave6 wave7) path(robustness\wave)
        qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(wave1 wave2 wave3 wave4 wave5 wave6 wave7) path(simulation\wave)
    }
}


* Table S25
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables25"){
	do ${code_com}\09_enrollment_consent_rates.do
}

* Table S27
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables27"){
	* Create Folders
	cap mkdir ${table_blood_end}\main\
	cap mkdir ${table_blood_end}\robustness\
	cap mkdir ${table_blood_end}\robustness\sex\
	cap mkdir ${table_blood_end}\simulation\
	cap mkdir ${table_blood_end}\simulation\sex\
	
	do ${code_blood_end}\03a_reg_symp_sero.do
    do ${code_blood_end}\robustness\07a_reg_symp_sero_by_sex.do
    do ${code_blood_end}\simulation\05_reg_symp_sero_by_sex.do

    * Format Results in Tables
    local pooled_results 3a_symp_sero_pool 3b_symp_sero_pool_no_base
    local mask_results 4a_symp_sero_mask 4b_symp_sero_mask_no_base
    foreach var of local pooled_results{
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(main)
        qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(male female) path(robustness\sex)
        qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(male female) path(simulation\sex)
    }
    
    foreach var of local mask_results{
		qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(main)
        qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(male female) path(robustness\sex)
        qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(male female) path(simulation\sex)

    }
}


* Table S28
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables28"){
	* Create Folders
	cap mkdir ${table_blood_end}\main\
	cap mkdir ${table_blood_end}\robustness\
	cap mkdir ${table_blood_end}\robustness\sex\
	
	do ${code_blood_end}\03b_reg_symp.do
    do ${code_blood_end}\robustness\07b_reg_symp_by_sex.do

    * Format Results in Tables
	local pooled_results 7a_symp_pool 7b_symp_pool_no_base
    local mask_results 8a_symp_mask 8b_symp_mask_no_base
    foreach var of local pooled_results{
		qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(full) path(main)
        qui do ${code_blood_end}\format\1a_format_pool.do `var'; args(male female) path(robustness\sex)
    }
    
    foreach var of local mask_results{
		qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(full) path(main)
        qui do ${code_blood_end}\format\1b_format_mask.do `var'; args(male female) path(robustness\sex)
    }
}

* Table S29
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables29") | (`"`analysis'"' == "figures7"){
	* Create Folders
	cap mkdir ${table_blood_end}\robustness\
	cap mkdir ${table_blood_end}\robustness\diff_first_stage\
	
    include ${code_blood_end}\robustness\09a_mask_symp_sero.do
    include ${code_blood_end}\robustness\09b_mask_symp.do
}

* Table S30
* ---------------------------------------------------------------------
if (`"`analysis'"' == "tables30"){
	* Create Folders
	cap mkdir ${table_blood_end}\robustness\
	cap mkdir ${table_blood_end}\robustness\iv\
	
    do ${code_blood_end}\robustness\08a_reg_symp_sero_IV.do
    do ${code_blood_end}\robustness\08b_reg_symp_IV.do
}


* Figure S3
* ---------------------------------------------------------------------
if (`"`analysis'"' == "figures3"){
	* Create Folders
	cap mkdir ${table_blood_end}\robustness\
	cap mkdir ${table_blood_end}\robustness\rand_inf\

	* Run Regressions
    do ${code_blood_end}\robustness\10a_reg_rand_inf_symp_sero.do
    do ${code_blood_end}\robustness\10b_reg_rand_inf_symp.do
	
	* Generate Figures
    include ${code_blood_end}\robustness\11a_graph_rand_inf_symp_sero.do
    include ${code_blood_end}\robustness\11b_graph_rand_inf_symp.do
}


cap log close _all
