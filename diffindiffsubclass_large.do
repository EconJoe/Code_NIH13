
cd D:\Research\Projects\NIHMandate\NIH15\Data
use estsample_large, clear
keep if year>=2000 & year<=2013
gen ta=1-oa
gen post=(year>2008)
gen nih=(nih_pubtype==1 | nih_grantlist==1)
gen treated=(nih==1 & post==1)
gen nottreated=1-treated
tempfile hold
save `hold', replace

cd D:\Research\Projects\NIHMandate\NIH15\Data
use large_rlogitest, clear
rename dat_pmid pmid
merge 1:1 pmid using `hold'
drop _merge

gen tgroup=.
replace tgroup=1 if nih==1 & post==0
replace tgroup=2 if nih==1 & post==1
replace tgroup=3 if nih==0 & post==0
replace tgroup=4 if nih==0 & post==1

gen odds=dat_pr/(1-dat_pr)
gen lodds=ln(odds)


* Initial values
local strata=1
local exit="No"
local iter=1
gen hold_stratum=`strata'
gen F_current=.

* Stopping rules
local F_thresh=3

set more off
while ("`exit'"=="No") {

	display in red "Iteration `iter'"
	local iter=`iter'+1

	* Perform One-Way ANOVA tests for each stratum
	gen hold_F=.
	set more off
	forvalues i=1/`strata' {
		qui oneway lodds tgroup if hold_stratum==`i'
		local F=`r(F)'
		replace hold_F=`F' if hold_stratum==`i'
	}
		
	* Identify the strata that will be split
	* Compute Potential Split value for each stratum. 
	* This is just the median of the estimated propensity score
	* Split the strata that need to be split
	gen hold_split=(hold_F > `F_thresh')
	by hold_stratum, sort: egen hold_splitvalue = median(dat_pr)
	* The zeros denote the strata that will not be split. 1 2 denote how the strata to be split will actually be split.
	gen hold_stratum_new = 0
	replace hold_stratum_new=1 if dat_pr<=hold_splitvalue & hold_split==1
	replace hold_stratum_new=2 if dat_pr>hold_splitvalue & hold_split==1

	* Identify new strata
	egen stratum_current = group(hold_stratum hold_stratum_new)

	* Impose stopping rule. If no strata are identified to be split
	tab hold_split
	qui su hold_split
	local min=`r(min)'
	local max=`r(max)'
	if (`min'==0 & `max'==0) {
		local exit="Yes"
	}
	su hold_F stratum_current
	replace F_current=hold_F
	drop hold_*
	rename stratum_current hold_stratum

	qui su hold_stratum
	local strata=`r(max)'
	*if (`strata'==115) {
    *	local exit="Yes"
	*}
}
