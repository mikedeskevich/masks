* ---------------------------------------------------------------------
* Title:    Clean Data - Basline HH Visit
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Cleans baseline household data for analysis.
* Note:     We use two definitions of respiratory illness, one as a general 
*           definition of ARI, and one that captures probable cases of COVID-19.
*           (1) Influenza Like Illness - Any of the following
*           (1a) Fever and Dry Cough OR Wet Cough OR 
*           (1b) Shortness of Breath OR Sore Throat OR Runny Nose
*           (2) WHO-Defined Likely COVID-19 Case Definition - Any of the following:
*           (2a) Acute onset of fever AND Cough
*           (2b) Acute onset of 3 or more of the following: fever, cough, 
*                general weakness/fatigue, headache, myalgia, sore throat, 
*                coryza, dyspnea, anorexia/nausea/vomiting, diarrhea, 
*                altered mental status.
*           (2c) Recent loss of smell and taste
* ---------------------------------------------------------------------

* Load Data
* ---------------------------------------------------------------------
use "${data_base}\00_raw\baseHH_data.dta", clear

keep if surveyresult == 1 //Only Keep Households That Are Found
keep if consent == 1 //Only Keep Households That Consent
drop surveyresult consent

* Define Respiratory Illness
* ---------------------------------------------------------------------
* Var Labels
local t "a"
local varlabel "w/in 7 days of baseline visit"
local name "base"


* Definition 1 - Count Number of People with Influenza Like Illness (ILI)
* ---------------------------------------------------------------------
* Note: Defined as one of the following:
*       (1a) Fever AND [Dry Cough OR Wet Cough];
*       (1b) Shortness of Breath OR Sore Throat OR Runny Nose

gen resp_ill_base_1 = 0
forvalues mem = 1 / 10 {
    qui gen fever_m_`mem' = (sm_`t'_1_m_`mem' == 1) //Fever
	* Dry Cough, or Wet Cough
	qui egen cough_m_`mem' = rowtotal(sm_`t'_2_m_`mem' sm_`t'_3_m_`mem') //Cough
	qui gen byte resp_ill_`name'_1_m_`mem' = 0
	qui replace resp_ill_`name'_1_m_`mem' = 1 if fever_m_`mem' == 1 & cough_m_`mem' >= 1
	assert !mi(resp_ill_`name'_1_m_`mem')
	
	* Number of HH Member That Had Respiratory Illness
	qui replace resp_ill_`name'_1 = resp_ill_`name'_1 + resp_ill_`name'_1_m_`mem'
	assert resp_ill_`name'_1 <= member_count
	
	label var resp_ill_`name'_1_m_`mem' "Adult`mem' had ILI `varlabel'"
}

cap drop cough_m_*
cap drop fever_m_*

label var resp_ill_base_1 "Num. Adults w/ ILI `varlabel'"


* Definition 2 - Count Number of People w/ WHO-Defined Probable COVID Case
* ---------------------------------------------------------------------
* Note: Defined as one of the following:
*       (2a) Fever AND [Dry Cough OR Wet Cough];
*       (2b) 3 or more of the following: 
*            fever, cough, general weakness/fatigue, headache, myalgia, 
*            sore throat, coryza, dyspnea, anorexia/nausea/vomiting, diarrhea, 
*            altered mental status.
*       (2c) Loss of Smell and Taste

gen resp_ill_`name'_2  = 0

forvalues mem = 1 / 10 {
	* Definition 2A - Acute onset of fever AND Cough
	* ---------------------------------------------------------------------
	qui gen cough_m_`mem' = (sm_`t'_2_m_`mem' == 1) | (sm_`t'_3_m_`mem'==1) //Dry Cough or Wet Cough
	qui egen fever_cough_m_`mem' = rowtotal(sm_`t'_1_m_`mem' cough_m_`mem') //Fever + Cough
	qui gen byte resp_ill_2a_m_`mem' = 0
	qui replace resp_ill_2a_m_`mem' = 1 if fever_cough_m_`mem' > 1
	cap drop cough_m_`mem'
	cap drop fever_cough_m_`mem'
	
	
	* Definition 2B - Acute onset of 3 or more symptoms
	* ---------------------------------------------------------------------
	qui egen symp_sum_m_`mem' = rowtotal(sm_`t'_1_m_`mem' sm_`t'_2_m_`mem' sm_`t'_3_m_`mem' sm_`t'_4_m_`mem' sm_`t'_5_m_`mem' sm_`t'_6_m_`mem'  sm_`t'_7_m_`mem'  sm_`t'_8_m_`mem' sm_`t'_9_m_`mem' sm_`t'_10_m_`mem')
	qui gen byte resp_ill_2b_m_`mem' = 0
	qui replace resp_ill_2b_m_`mem' = 1 if symp_sum_m_`mem' >= 3
	cap drop symp_sum_m_*
	
	* Definition 2C - Recent Loss of Smell or Taste
	* ---------------------------------------------------------------------
	* Definition 2C - Recent Loss of Smell or Taste
	qui gen byte resp_ill_2c_m_`mem' = 0
	qui replace resp_ill_2c_m_`mem' = 1 if sm_`t'_11_m_`mem' == 1
	
	* Likely COVID-Case - Any of 2A, 2B, 2C holds
	* ---------------------------------------------------------------------
	qui egen any_symp_m_`mem' = rowtotal(resp_ill_2a_m_`mem' resp_ill_2b_m_`mem' resp_ill_2c_m_`mem')
	qui gen byte resp_ill_`name'_2_m_`mem' = 0
	qui replace resp_ill_`name'_2_m_`mem' = 1 if any_symp_m_`mem' >= 1
	* Number of HH Member w/ Likely Covid Case
	qui replace resp_ill_`name'_2 = resp_ill_`name'_2 + resp_ill_`name'_2_m_`mem'
	
	cap drop resp_ill_2a_m_`mem' resp_ill_2b_m_`mem' resp_ill_2c_m_`mem' any_symp_m_*
	
	label var resp_ill_`name'_2_m_`mem' "Adult`mem' had COVID-19 symp `varlabel'"
}

label var resp_ill_`name'_2  "Num. Adults w/ COVID-19 symp `varlabel'"


* Checks
* ---------------------------------------------------------------------
* Definition 1
assert !mi(resp_ill_`name'_1)
assert resp_ill_`name'_1 <= member_count
egen check_count = rowtotal(resp_ill_base_1_m*)
assert resp_ill_`name'_1 == check_count
drop check_count

* Definition 2
assert !mi(resp_ill_`name'_2)
assert resp_ill_`name'_2  <= member_count
egen check_count = rowtotal(resp_ill_base_2_m*)
assert resp_ill_`name'_2 == check_count
drop check_count

drop sm_`t'_*



* Save Clean Baseline Household Dataset
* ---------------------------------------------------------------------
save "${data_base}\01_clean\baseHH_data.dta", replace

