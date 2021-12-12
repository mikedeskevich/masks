* ---------------------------------------------------------------------
* Title:    Format Output (By Mask Type)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Formats regression output generated from proportional
*           regressions by mask type.
* ---------------------------------------------------------------------

* Define Locals
local 0: subinstr local 0 ";" ","
syntax anything, args(str) path(str)
local file: copy local anything

* Load Data
*---------------------------------------------------------------------
use `"${table_blood_end}\\`path'\\`file'.dta"', clear

* If Data is Already in Correct Format, then terminate
cap confirm var var
if !_rc{
	display as error "Data Already in Correct Format"
	exit 111
}

* Fix Formatting
*---------------------------------------------------------------------
* Rename Variables
rename *1 coeff_surg
rename *2 ll_surg
rename *3 ul_surg
rename *4 pvalue_surg
rename *5 coeff_cloth
rename *6 ll_cloth
rename *7 ul_cloth
rename *8 pvalue_cloth
rename *9 N
rename *10 Nunion

* Re-Express Coefficients as Adjusted Prevalence Ratios
replace coeff_surg = 1 + coeff_surg
replace ll_surg = 1 + ll_surg
replace ul_surg = 1 + ul_surg
replace coeff_cloth = 1 + coeff_cloth
replace ll_cloth = 1 + ll_cloth
replace ul_cloth = 1 + ul_cloth
format coeff* ll* ul* pvalue* %5.3f
tostring coeff_surg, replace format(%5.3f) force
tostring ll_surg, replace format(%5.3f) force
tostring ul_surg, replace format(%5.3f) force
tostring coeff_cloth, replace format(%5.3f) force
tostring ll_cloth, replace format(%5.3f) force
tostring ul_cloth, replace format(%5.3f) force



* Indiciate Signficance
replace coeff_surg = coeff_surg + "*" if pvalue_surg <= 0.1
replace coeff_surg = coeff_surg + "*" if pvalue_surg <= 0.05
replace coeff_surg = coeff_surg + "*" if pvalue_surg <= 0.01
replace coeff_cloth = coeff_cloth + "*" if pvalue_cloth <= 0.1
replace coeff_cloth = coeff_cloth + "*" if pvalue_cloth <= 0.05
replace coeff_cloth = coeff_cloth + "*" if pvalue_cloth <= 0.01


gen ci_surg = "[" + ll_surg + ", " + ul_surg + "]"
gen ci_cloth = "[" + ll_cloth + ", " + ul_cloth + "]"
drop  ll* ul* pvalue*
order coeff_surg ci_surg coeff_cloth ci_cloth N Nunion

* Transpose
sxpose, clear force


* Rename Variables
gen var = "Treatment APR for Surgical Villages" if _n == 1
replace var = "Treatment CI for Surgical Villages" if _n == 2
replace var = "Treatment APR for Cloth Villages" if _n == 3
replace var = "Treatment CI for Cloth Villages" if _n == 4
replace var = "N Individuals" if _n == 5
replace var = "N Villages" if _n == 6

rename (_var*) (`args')
order var `args'


* Overwrite Existing Data with Correct Format
*---------------------------------------------------------------------
save `"${table_blood_end}\\`path'\\`file'.dta"', replace
