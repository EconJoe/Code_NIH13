
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
	if (`strata'==370) {
    	local exit="Yes"
	}
}



save subclass_large, replace

use subclass_large, clear

reg dat_pr
predict res, r
twoway (kdensity res if nih==1 & post==1) ///
       (kdensity res if nih==1 & post==0) ///
	   (kdensity res if nih==0 & post==1) ///
	   (kdensity res if nih==0 & post==0), ///
	   legend(order(1 "Treated After" 2 "Treated Before" 3 "Control After" 4 "Control Before"))

areg dat_pr, absorb(hold_stratum)
predict res_fe, r

twoway (kdensity res_fe if nih==1 & post==1) ///
       (kdensity res_fe if nih==1 & post==0) ///
	   (kdensity res_fe if nih==0 & post==1) ///
	   (kdensity res_fe if nih==0 & post==0), ///
	   legend(order(1 "Treated After" 2 "Treated Before" 3 "Control After" 4 "Control Before"))




clear
gen parmseq=.
save coeffs_subclass_large, replace

use subclass_large, clear
rename hold_stratum stratum
tempfile hold
save `hold', replace

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"

local spec `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

set more off
forvalues i=1/370 {
	
	use `hold' if stratum==`i', clear
	su ta if stratum==`i'
	local obs=`r(N)'
	parmby "reg ta i.nih##i.post i.year `spec' if stratum==`i', cluster(ui4)", norestore
	*local att=_b[1.nih#1.post]
	gen obs=`obs'
	gen stratum=`i'
	
	append using coeffs_subclass_large
	save coeffs_subclass_large, replace
}

use coeffs_subclass_large, clear
keep if parm=="1.nih#1.post"
egen obs_total=total(obs)
gen weight=obs/obs_total
gen coeffprod=weight*estimate
gen var=stderr^2
gen weight2=weight^2
gen varprod=weight2*var
egen att=total(coeffprod)
egen variance=total(varprod)
gen sd=sqrt(variance)
gen t_att=att/sd

twoway (connected estimate stratum), ///
       yline(0)



