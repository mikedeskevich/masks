* ---------------------------------------------------------------------
* Title:    Clean Data - Surveillance
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Cleans surveillance data for analysis.
* ---------------------------------------------------------------------

* Load Data
* ---------------------------------------------------------------------
use "${data_surv}\00_raw\surv_data.dta", clear

* Count Mask-Wearing and Social-Distancing
* ---------------------------------------------------------------------
gen n_surv_total = 0
gen n_surv_female = 0
gen n_surv_male = 0
gen n_surv_sex = 0
gen n_proper_mask = 0
gen n_proper_mask_f = 0
gen n_proper_mask_m = 0
gen n_proper_mask_sex = 0
gen n_project_mask = 0
gen n_project_mask_f = 0
gen n_project_mask_m = 0
gen n_improper_mask = 0
gen n_improper_mask_f = 0
gen n_improper_mask_m = 0
gen n_proper_improper_mask = 0
gen n_proper_improper_mask_f = 0
gen n_proper_improper_mask_m = 0
gen n_soc_dist = 0
gen n_mask_blue = 0
gen n_mask_green = 0
gen n_mask_purple = 0
gen n_mask_red = 0

forvalues num = 1 / 500000 {
	
	cap confirm var mask_a`num'
    if (_rc) continue, break
	
	* Total Observations
    qui gen count_`num' = 0
    qui replace count_`num' = 1 if (mask_a`num' == 1) | (mask_a`num' == 2) | (mask_a`num' == 3) | (mask_a`num' == 4)
	qui replace n_surv_total = count_`num' + n_surv_total
	
    * Num Female
    qui gen n_surv_female_`num' = 0
    qui replace n_surv_female_`num' = 1 if (mask_d`num' == 1) & (count_`num' == 1)
	qui replace n_surv_female = n_surv_female_`num' + n_surv_female
	
    * Num Male
    qui gen n_surv_male_`num' = 0
    qui replace n_surv_male_`num' = 1 if (mask_d`num' == 0) & (count_`num' == 1)
	qui replace n_surv_male = n_surv_male_`num' + n_surv_male

	* Num With Sex Recorded
	qui gen n_surv_sex_`num' = 0
    qui replace n_surv_sex_`num' = 1 if ((mask_d`num' == 0) | (mask_d`num' == 1)) & (count_`num' == 1)
	qui replace n_surv_sex = n_surv_sex_`num' + n_surv_sex
	
	* Proper Mask Usage
	qui gen proper_mask_`num' = 0
	qui replace proper_mask_`num' = 1 if (mask_a`num' == 1) | (mask_a`num' == 2)
	assert !mi(proper_mask_`num')
	qui replace n_proper_mask = proper_mask_`num' + n_proper_mask

	* Proper Mask Usage, Females Only
	qui gen proper_mask_f_`num' = 0
	qui replace proper_mask_f_`num' = 1 if (n_surv_female_`num' == 1) & (proper_mask_`num' == 1)
	assert !mi(proper_mask_f_`num')
	qui replace n_proper_mask_f = proper_mask_f_`num' + n_proper_mask_f
	qui drop proper_mask_f_`num'

	* Proper Mask Usage, Males Only
	qui gen proper_mask_m_`num' = 0
	qui replace proper_mask_m_`num' = 1 if (n_surv_male_`num' == 1) & (proper_mask_`num' == 1)
	assert !mi(proper_mask_m_`num')
	qui replace n_proper_mask_m = proper_mask_m_`num' + n_proper_mask_m
	qui drop proper_mask_m_`num'

	* Proper Mask Usage, If Recorded Sex
	qui gen proper_mask_sex_`num' = 0
	qui replace proper_mask_sex_`num' = 1 if (n_surv_sex_`num' == 1) & (proper_mask_`num' == 1)
	assert !mi(proper_mask_sex_`num')
	qui replace n_proper_mask_sex = proper_mask_sex_`num' + n_proper_mask_sex
	qui drop proper_mask_sex_`num'
	
	* Project Mask
	qui gen project_mask_`num' = 0
	qui replace project_mask_`num' = 1 if (mask_a`num' == 1)
	assert !mi(project_mask_`num')
	qui replace n_project_mask = project_mask_`num' + n_project_mask

	* Project Mask, Females Only
	qui gen project_mask_f_`num' = 0
	qui replace project_mask_f_`num' = 1 if (n_surv_female_`num' == 1) & (mask_a`num' == 1)
	assert !mi(project_mask_f_`num')
	qui replace n_project_mask_f = project_mask_f_`num' + n_project_mask_f
	qui drop project_mask_f_`num'

	* Project Mask, Males Only
	qui gen project_mask_m_`num' = 0
	qui replace project_mask_m_`num' = 1 if (n_surv_male_`num' == 1) & (mask_a`num' == 1)
	assert !mi(project_mask_m_`num')
	qui replace n_project_mask_m = project_mask_m_`num' + n_project_mask_m
	qui drop project_mask_m_`num'

	* Improper Mask Usage
	qui gen improper_mask_`num' = 0
	qui replace improper_mask_`num'  = 1 if (mask_a`num' == 3)
	qui replace n_improper_mask = improper_mask_`num' + n_improper_mask

	* Improper Mask Usage, Female Only
	qui gen improper_mask_f_`num' = 0
	qui replace improper_mask_f_`num'  = 1 if (n_surv_female_`num' == 1) & (improper_mask_`num' == 1)
	qui replace n_improper_mask_f = improper_mask_f_`num' + n_improper_mask_f
	qui drop improper_mask_f_`num'
	
	* Improper Mask Usage, Male Only
	qui gen improper_mask_m_`num' = 0
	qui replace improper_mask_m_`num'  = 1 if (n_surv_male_`num' == 1) & (improper_mask_`num' == 1)
	qui replace n_improper_mask_m = improper_mask_m_`num' + n_improper_mask_m
	qui drop improper_mask_m_`num'
	
	* Proper + Improper Mask Usage
	qui gen proper_improper_mask_`num' = 0
	qui replace proper_improper_mask_`num'  = 1 if (mask_a`num' == 1) | (mask_a`num' == 2) | (mask_a`num' == 3)
	qui replace n_proper_improper_mask = proper_improper_mask_`num' + n_proper_improper_mask
	
	* Proper + Improper Mask Usage, Females Only
	qui gen proper_improper_mask_f_`num' = 0
	qui replace proper_improper_mask_f_`num'  = 1 if (n_surv_female_`num' == 1) & (proper_improper_mask_`num' == 1)
	qui replace n_proper_improper_mask_f = proper_improper_mask_f_`num' + n_proper_improper_mask_f
	qui drop proper_improper_mask_f_`num'

	* Proper + Improper Mask Usage, Males Only
	qui gen proper_improper_mask_m_`num' = 0
	qui replace proper_improper_mask_m_`num'  = 1 if (n_surv_male_`num' == 1) & (proper_improper_mask_`num' == 1)
	qui replace n_proper_improper_mask_m = proper_improper_mask_m_`num' + n_proper_improper_mask_m
	qui drop proper_improper_mask_m_`num'

	* Social Distancing
	qui gen soc_dist_`num' = 0
	qui replace soc_dist_`num' = 1 if (mask_c`num'==1)
	qui replace n_soc_dist = soc_dist_`num' + n_soc_dist
	
	* Mask Colour
	qui gen mask_blue_`num' = 0
	qui gen mask_red_`num' = 0
	qui gen mask_green_`num' = 0
	qui gen mask_purple_`num' = 0
	
	qui replace mask_blue_`num' = 1 if (mask_b`num' == 1)
	qui replace mask_red_`num' = 1 if (mask_b`num' == 2)
	qui replace mask_green_`num' = 1 if (mask_b`num' == 3)
	qui replace mask_purple_`num' = 1 if (mask_b`num' == 4)
	
	qui replace n_mask_blue = mask_blue_`num' + n_mask_blue
	qui replace n_mask_red = mask_red_`num' + n_mask_red
	qui replace n_mask_green = mask_green_`num' + n_mask_green
	qui replace n_mask_purple = mask_purple_`num' + n_mask_purple
	
	qui drop count_`num'
	qui drop n_surv_female_`num'
	qui drop n_surv_male_`num'
	qui drop n_surv_sex_`num'
	qui drop proper_mask_`num'
	qui drop project_mask_`num'
	qui drop improper_mask_`num'
	qui drop proper_improper_mask_`num'
	qui drop soc_dist_`num'
	qui drop mask_blue_`num'
	qui drop mask_red_`num'
	qui drop mask_green_`num'
	qui drop mask_purple_`num'
}

drop mask_a*
drop mask_b*
drop mask_c*
drop mask_d*

* Check
assert n_surv_total        == total_observations
assert n_proper_mask       <= total_observations
assert n_proper_mask_sex   <= total_observations
assert n_proper_mask_f     <= total_observations
assert n_proper_mask_f     <= n_surv_female
assert n_proper_mask_m     <= total_observations
assert n_proper_mask_f     <= n_proper_mask
assert n_proper_mask_m     <= n_proper_mask
assert n_improper_mask     <= total_observations
assert n_improper_mask_f   <= total_observations
assert n_improper_mask_m   <= total_observations
assert n_improper_mask_f   <= n_improper_mask
assert n_improper_mask_m   <= n_improper_mask
assert n_proper_improper_mask   <= total_observations
assert n_proper_improper_mask_f <= total_observations
assert n_proper_improper_mask_m <= total_observations
assert n_proper_improper_mask_f <= n_proper_improper_mask
assert n_proper_improper_mask_m <= n_proper_improper_mask
assert n_mask_blue <= total_observations
assert n_mask_red <= total_observations
assert n_mask_green <= total_observations
assert n_mask_purple <= total_observations
assert n_project_mask == n_mask_blue + n_mask_red + n_mask_green + n_mask_purple
assert n_project_mask_f <= total_observations
assert n_project_mask_m <= total_observations
assert n_project_mask_f <= n_project_mask
assert n_project_mask_m <= n_project_mask
assert n_soc_dist <= total_observations
assert n_surv_sex == n_surv_female + n_surv_male
assert n_proper_mask_sex == n_proper_mask_f + n_proper_mask_m

assert !mi(n_proper_mask)
assert !mi(n_proper_mask_f)
assert !mi(n_proper_mask_m)
assert !mi(n_improper_mask)
assert !mi(n_improper_mask_f)
assert !mi(n_improper_mask_m)
assert !mi(n_proper_improper_mask)
assert !mi(n_proper_improper_mask_f)
assert !mi(n_proper_improper_mask_m)
assert !mi(n_mask_blue)
assert !mi(n_mask_red)
assert !mi(n_mask_green)
assert !mi(n_mask_purple)
assert !mi(n_soc_dist)
assert !mi(n_surv_sex)


* Save Clean Surveillance Dataset
* ---------------------------------------------------------------------
save "${data_surv}\01_clean\surv_data.dta", replace
