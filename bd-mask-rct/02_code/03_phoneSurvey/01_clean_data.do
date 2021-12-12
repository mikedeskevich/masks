* ---------------------------------------------------------------------
* Title:    Clean Data - Phone Survey
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Cleans phone survey data for analysis.
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
use "${data_phone}\00_raw\phoneSurvey_data.dta", clear


* Define Respiratory Illness
* ---------------------------------------------------------------------
local time "a b"
foreach t of local time{ //Record Symptom Data at 7-day and 4-week recall
	
* Var Labels
if (`"`t'"' == "a"){
	local varlabel "w/in 4 weeks of phonesurvey"
	local name "month"
}
if (`"`t'"' == "b"){
	local varlabel "w/in 7 days of phonesurvey"
	local name "week"
}

forvalues symp = 1/11{
	forvalues mem = 1/10{
		cap confirm variable sm_`t'_`symp'_m_`mem'
        if (_rc){
			gen sm_`t'_`symp'_m_`mem' = .

		}
		else{
			continue
		}
	}
}


* Definition 1 - Count Number of People with Influenza Like Illness (ILI)
* ---------------------------------------------------------------------
* Note: Defined as one of the following:
*       (1a) Fever AND [Dry Cough OR Wet Cough];
*       (1b) Shortness of Breath OR Sore Throat OR Runny Nose

gen resp_ill_`name'_1 = 0
forvalues mem = 1 / 10 {
    qui gen fever_m_`mem' = (sm_`t'_1_m_`mem' == 1) //Fever
	* Dry Cough, or Wet Cough
	qui egen cough_m_`mem' = rowtotal(sm_`t'_2_m_`mem' sm_`t'_3_m_`mem') //Cough
	qui gen resp_ill_`name'_1_m_`mem' = 0
	qui replace resp_ill_`name'_1_m_`mem' = 1 if fever_m_`mem' == 1 & cough_m_`mem' >= 1
	assert !mi(resp_ill_`name'_1_m_`mem')
	
	* Number of HH Member That Had Respiratory Illness
	qui replace resp_ill_`name'_1 = resp_ill_`name'_1 + resp_ill_`name'_1_m_`mem'
	assert resp_ill_`name'_1 <= member_count
	
	label var resp_ill_`name'_1_m_`mem' "Adult`mem' had ILI `varlabel'"
}

cap drop cough_m_*
cap drop fever_m_*

label var resp_ill_`name'_1 "Num. Adults w/ ILI `varlabel'"


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
	qui gen resp_ill_2a_m_`mem' = 0
	qui replace resp_ill_2a_m_`mem' = 1 if fever_cough_m_`mem' > 1
	cap drop cough_m_`mem'
	cap drop fever_cough_m_`mem'
	
	
	* Definition 2B - Acute onset of 3 or more symptoms
	* ---------------------------------------------------------------------
	qui egen symp_sum_m_`mem' = rowtotal(sm_`t'_1_m_`mem' sm_`t'_2_m_`mem' sm_`t'_3_m_`mem' sm_`t'_4_m_`mem' sm_`t'_5_m_`mem' sm_`t'_6_m_`mem'  sm_`t'_7_m_`mem'  sm_`t'_8_m_`mem' sm_`t'_9_m_`mem' sm_`t'_10_m_`mem')
	qui gen resp_ill_2b_m_`mem' = 0
	qui replace resp_ill_2b_m_`mem' = 1 if symp_sum_m_`mem' >= 3
	cap drop symp_sum_m_*
	
	* Definition 2C - Recent Loss of Smell or Taste
	* ---------------------------------------------------------------------
	* Definition 2C - Recent Loss of Smell or Taste
	qui gen resp_ill_2c_m_`mem' = 0
	qui replace resp_ill_2c_m_`mem' = 1 if sm_`t'_11_m_`mem' == 1
	
	* Likely COVID-Case - Any of 2A, 2B, 2C holds
	* ---------------------------------------------------------------------
	qui egen any_symp_m_`mem' = rowtotal(resp_ill_2a_m_`mem' resp_ill_2b_m_`mem' resp_ill_2c_m_`mem')
	qui gen resp_ill_`name'_2_m_`mem' = 0
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
egen check_count = rowtotal(resp_ill_`name'_1_m*)
assert resp_ill_`name'_1 == check_count
drop check_count

* Definition 2
assert !mi(resp_ill_`name'_2)
assert resp_ill_`name'_2  <= member_count
egen check_count = rowtotal(resp_ill_`name'_2_m*)
assert resp_ill_`name'_2 == check_count
drop check_count


drop sm_`t'_*

}


* Count if Ever Had Respiratory Illness via Phone Survey
* (4-Week or 7-Day Recall)
* ---------------------------------------------------------------------
gen resp_ill_phone_1 = 0
gen resp_ill_phone_2 = 0
forvalues mem = 1 / 10 {
	gen resp_ill_phone_1_m_`mem' =  (resp_ill_week_1_m_`mem' == 1) | (resp_ill_month_1_m_`mem' == 1)
	gen resp_ill_phone_2_m_`mem' =  (resp_ill_week_2_m_`mem' == 1) | (resp_ill_month_2_m_`mem' == 1)
	label var resp_ill_phone_1_m_`mem' "Adult`mem' had ILI symp in phone survey"
	label var resp_ill_phone_2_m_`mem' "Adult`mem' had COVID-19 symp in phone survey"
	assert !mi(resp_ill_phone_1_m_`mem')
	assert !mi(resp_ill_phone_2_m_`mem')
	
	replace resp_ill_phone_1 = resp_ill_phone_1 + 1 if resp_ill_phone_1_m_`mem' == 1
	replace resp_ill_phone_2 = resp_ill_phone_2 + 1 if resp_ill_phone_2_m_`mem' == 1
}

label var resp_ill_phone_1 "Num. Adults w/ ILI symp in phone survey"
label var resp_ill_phone_2 "Num. Adults w/ COVID-19 symp in phone survey"
assert !mi(resp_ill_phone_1)
assert !mi(resp_ill_phone_2)


* Fix Week 9 HH-IDs
* ---------------------------------------------------------------------
* Drop Duplicates
gduplicates drop
distinct caseid
bys union caseid followup_week (resp_ill_phone_2 resp_ill_phone_1): gen to_drop = (_n < _N) & _N > 1
drop if to_drop == 1
drop to_drop
isid union caseid followup_week
distinct caseid


* Save Data
* ---------------------------------------------------------------------
save "${data_phone}\01_clean\phoneSurvey_data.dta", replace
