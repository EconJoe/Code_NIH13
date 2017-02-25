
cd D:\Research\Projects\NIHMandate\NIH14\Data
use estsample, clear
keep if year>=2000 & year<=2013

gen ta=1-oa
gen lsim=ln(similarityscore)
gen lval=ln(validsimilar_total)
gen post=(year>2008)
gen treated=(nih==1 & post==1)
gen nottreated=1-treated

gen tgroup=.
replace tgroup=1 if nih==1 & post==0
replace tgroup=2 if nih==1 & post==1
replace tgroup=3 if nih==0 & post==0
replace tgroup=4 if nih==0 & post==1

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"

local spec `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'
logit treated `spec'
predict pr, pr
gen odds=pr/(1-pr)
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
	by hold_stratum, sort: egen hold_splitvalue = median(pr)
	* The zeros denote the strata that will not be split. 1 2 denote how the strata to be split will actually be split.
	gen hold_stratum_new = 0
	replace hold_stratum_new=1 if pr<=hold_splitvalue & hold_split==1
	replace hold_stratum_new=2 if pr>hold_splitvalue & hold_split==1

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
	if (`strata'==115) {
		local exit="Yes"
	}
}
rename hold_stratum stratum



* Initial values
gen hold_stratum=1
local exit="No"
local iter=1

* Stopping rules
local t_thresh=2

while ("`exit'"=="No") {

	display in red "Iteration `iter'"
	local iter=`iter'+1
	
	* Compute the mean log odds ratio for the treated and control groups within each stratum. Then compute the difference.
	gen hold_T_lodds=lodds if treated==1
	gen hold_C_lodds=lodds if treated==0
	by hold_stratum, sort: egen hold_mean_T_lodds=mean(hold_T_lodds)
	by hold_stratum, sort: egen hold_mean_C_lodds=mean(hold_C_lodds)
	gen hold_diff_mean_lodds=hold_mean_T_lodds-hold_mean_C_lodds

	* Compute the total number of observations in the treated and control groups within each stratum
	by hold_stratum, sort: egen hold_NT=total(treated)
	by hold_stratum, sort: egen hold_NC=total(nottreated)

	* Compute the squared difference between the log odds for each observation and the mean log odds for its group (treated or control)
	* By strata, compute the summ of these squared differences
	* By strata, sum the sums
	* By strata, compute S2
	gen hold_sqdiff_T=(lodds-hold_mean_T_lodds)^2 if treated==1
	gen hold_sqdiff_C=(lodds-hold_mean_C_lodds)^2 if treated==0
	by hold_stratum, sort: egen hold_tot_sqdiff_T=total(hold_sqdiff_T)
	by hold_stratum, sort: egen hold_tot_sqdiff_C=total(hold_sqdiff_C)
	gen hold_S2 = (1/(hold_NT+hold_NC-2))*(hold_tot_sqdiff_T + hold_tot_sqdiff_C)

	* Compute the T-stat
	gen hold_t=hold_diff_mean_lodds/sqrt(hold_S2*(1/hold_NC+1/hold_NT))

	* Identify the strata that will be split
	* Compute Potential Split value for each stratum. 
	* This is just the median of the estimated propensity score
	* Split the strata that need to be split
	gen hold_split=(hold_t > `t_thresh')
	by hold_stratum, sort: egen hold_splitvalue = median(pr)
	* The zeros denote the strata that will not be split. 1 2 denote how the strata to be split will actually be split.
	gen hold_stratum_new = 0
	replace hold_stratum_new=1 if pr<=hold_splitvalue & hold_split==1
	replace hold_stratum_new=2 if pr>hold_splitvalue & hold_split==1

	* Identify new strata
	egen stratum_current = group(hold_stratum hold_stratum_new)

	* Impose stopping rule. If no strata are identified to be split
	su hold_split
	local min=`r(min)'
	local max=`r(max)'
	if (`min'==0 & `max'==0) {
		local exit="Yes"
	}
	su hold_t stratum_current
	drop hold_*
	rename stratum_current hold_stratum
}
rename hold_stratum stratum


*xtile stratum = pr, nq(100)

save temp, replace

use temp, clear

reg pr
predict res, r
twoway (kdensity res if nih==1 & post==1) ///
       (kdensity res if nih==1 & post==0) ///
	   (kdensity res if nih==0 & post==1) ///
	   (kdensity res if nih==0 & post==0), ///
	   legend(order(1 "Treated After" 2 "Treated Before" 3 "Control After" 4 "Control Before"))

areg pr, absorb(stratum)
predict res, r

twoway (kdensity res if nih==1 & post==1) ///
       (kdensity res if nih==1 & post==0) ///
	   (kdensity res if nih==0 & post==1) ///
	   (kdensity res if nih==0 & post==0), ///
	   legend(order(1 "Treated After" 2 "Treated Before" 3 "Control After" 4 "Control Before"))


clear
gen parmseq=.
save coeffs_subclass, replace

use temp, clear
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
forvalues i=1/115 {
	
	use `hold' if stratum==`i', clear
	su ta if stratum==`i'
	local obs=`r(N)'
	parmby "reg ta i.nih##i.post i.year `spec' if stratum==`i', cluster(ui4)", norestore
	*local att=_b[1.nih#1.post]
	gen obs=`obs'
	gen stratum=`i'
	
	append using coeffs_subclass
	save coeffs_subclass, replace
}

use coeffs_subclass, clear
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







