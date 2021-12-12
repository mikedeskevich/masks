* ---------------------------------------------------------------------
* Title:    Code Preamble
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Defines locals for code. Redefine "main".
* ---------------------------------------------------------------------

* Define Paths
* ---------------------------------------------------------------------
global main   "FILL"
global data   "${main}\01_data"
global code   "${main}\02_code"
global out    "${main}\03_output"
global table  "${main}\04_table"
global logdir "${code}\logs"

* Common
global data_com  "${data}\00_common"
global code_com  "${code}\00_common"
global out_com   "${out}\00_common"
global table_com "${table}\00_common"

* Surveillance
global data_surv  "${data}\01_surveillance"
global code_surv  "${code}\01_surveillance"
global out_surv   "${out}\01_surveillance"
global table_surv "${table}\01_surveillance"

* Baseline Household Visit
global data_base  "${data}\02_baselineHH"
global code_base  "${code}\02_baselineHH"
global out_base   "${out}\02_baselineHH"
global table_base "${table}\02_baselineHH"

* Phone Survey
global data_phone  "${data}\03_phoneSurvey"
global code_phone   "${code}\03_phoneSurvey"
global out_phone   "${out}\03_phoneSurvey"
global table_phone "${table}\03_phoneSurvey"

* In-Person Followup Visit
global data_followup  "${data}\04_followupVisit"
global code_followup  "${code}\04_followupVisit"
global out_followup   "${out}\04_followupVisit"
global table_followup "${table}\04_followupVisit"

* Endline Blood
global data_blood_end   "${data}\05_bloodEndline"
global code_blood_end   "${code}\05_bloodEndline"
global out_blood_end    "${out}\05_bloodEndline"
global table_blood_end  "${table}\05_bloodEndline"

* Pilot
global data_pilot   "${data}\06_pilot"
global code_pilot   "${code}\06_pilot"
global out_pilot    "${out}\06_pilot"
global table_pilot  "${table}\06_pilot"

* Setup
* ---------------------------------------------------------------------
clear all
set more off
set maxvar 32767
set linesize 200
local date : display %tdCYND date(c(current_date), "DMY")

* Create Data Folders
* ---------------------------------------------------------------------
cap mkdir ${data_com}\00_raw
cap mkdir ${data_com}\01_clean
cap mkdir ${data_surv}\00_raw
cap mkdir ${data_surv}\01_clean
cap mkdir ${data_base}\00_raw
cap mkdir ${data_base}\01_clean
cap mkdir ${data_phone}\00_raw
cap mkdir ${data_phone}\01_clean
cap mkdir ${data_followup}\00_raw
cap mkdir ${data_followup}\01_clean
cap mkdir ${data_blood_end}\00_raw
cap mkdir ${data_blood_end}\01_clean
cap mkdir ${data_pilot}\00_raw
cap mkdir ${data_pilot}\01_clean
cap mkdir ${table_com}
cap mkdir ${table_surv}
cap mkdir ${table_base}
cap mkdir ${table_phone}
cap mkdir ${table_followup}
cap mkdir ${table_blood_end}
cap mkdir ${table_pilot}
cap mkdir ${out_com}
cap mkdir ${out_surv}
cap mkdir ${out_base}
cap mkdir ${out_phone}
cap mkdir ${out_followup}
cap mkdir ${out_blood_end}
cap mkdir ${out_pilot}


* Set Seeds
* ---------------------------------------------------------------------
set seed 880
set sortseed 880

* Define Colors
* ---------------------------------------------------------------------
*RGB Colors
local dark_blue 13 71 161
local light_blue 100 181 246

local dark_red 183 28 28
local light_red 229 115 115

local dark_orange 230 81 0
local light_orange 251 140 0

