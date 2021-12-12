* ---------------------------------------------------------------------
* Title:    Format Output (Pooled)
* Blame:    Emily Crawford (emily.crawford@yale.edu)
* Purpose:  Formats regression output generated from proportional
*           pooled regressions.
* ---------------------------------------------------------------------

* Define Locals
local 0: subinstr local 0 ";" ","
syntax anything, args(str) path(str) []
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
rename *1 coeff
rename *2 ll
rename *3 ul
rename *4 pvalue
rename *5 N
rename *6 Nunion

* Re-Express Coefficients as Adjusted Prevalence Ratios
replace coeff = 1 + coeff
replace ll = 1 + ll
replace ul = 1 + ul
format coeff ll ul pvalue %5.3f
tostring coeff, replace format(%5.3f) force
tostring ll, replace format(%5.3f) force
tostring ul, replace format(%5.3f) force

* Indiciate Signficance
replace coeff = coeff + "*" if pvalue <= 0.1
replace coeff = coeff + "*" if pvalue <= 0.05
replace coeff = coeff + "*" if pvalue <= 0.01
tostring ll, replace format(%5.3f) force
tostring ul, replace format(%5.3f) force

gen ci = "[" + ll + ", " + ul + "]"
drop  ll ul pvalue
order coeff ci N Nunion

* Transpose
sxpose, clear force

* Rename Variables
gen var = "Treatment APR " if _n == 1
replace var = "Treatment CI" if _n == 2
replace var = "N Individuals" if _n == 3
replace var = "N Villages" if _n == 4

disp "`args'"

rename (_var*) (`args')
order var `args'


* Overwrite Existing Data with Correct Format
*---------------------------------------------------------------------
save `"${table_blood_end}\\`path'\\`file'.dta"', replace
