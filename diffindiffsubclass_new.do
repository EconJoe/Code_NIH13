
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

tempfile hold
save `hold', replace

save temp, replace



use temp, clear

* Initial values
local strata=1
local exit="No"
local iter=1

* Stopping rules
local F_thresh=3
local N_thresh=10

* Temporary files
gen hold_stratum=`strata'
save split, replace
clear
gen stratum_global=.
save nosplit, replace

set more off
while ("`exit'"=="No") {

	display in red "Iteration `iter'"
	local iter=`iter'+1

	use split, clear

	gen hold_F=.
	set more off
	forvalues i=1/`strata' {
		qui oneway lodds tgroup if hold_stratum==`i'
		local F=`r(F)'
		replace hold_F=`F' if hold_stratum==`i'
	}

	* Identify which strata to split. Strata will be split if BOTH of the following hold:
	*   1) F-stat for one-way ANOVA is ABOVE the threshold (homogeneity criteria)
	*   2) The minimum number of observations in each of the 4 groups is ABOVE the threshold (min N critera)

	* Test criteria 1
	gen hold_split_homog=(hold_F > `F_thresh')
	by hold_stratum, sort: egen hold_splitvalue = median(pr)

	* Test criteria 2
	gen hold_stratum_test=.
	replace hold_stratum_test=1 if pr<=hold_splitvalue & hold_split_homog==1
	replace hold_stratum_test=2 if pr>hold_splitvalue & hold_split_homog==1
	***
	* This handles edge cases when the choice of equality matters. Can happen when the median (split value) equals the min or max.
	* Without this, all observations can be assigned to the same stratum in an infinite loop.
	qui su hold_stratum_test
	local min=`r(min)'
	local max=`r(max)'
	if (`min'==1 & `max'==1) {
		drop hold_stratum_test
		gen hold_stratum_test=.
		replace hold_stratum_test=1 if pr<hold_splitvalue & hold_split_homog==1
		replace hold_stratum_test=2 if pr>=hold_splitvalue & hold_split_homog==1
	}
	***
	qui tab tgroup, gen(hold_tg_)
	gen hold_split_minN=1
	forvalues i=1/4 {
		by hold_stratum, sort: egen hold_tot_tg`i'=total(hold_tg_`i')
		* This becomes 0 if ANY group falls below the minimum observations threshold
		replace hold_split_minN=0 if hold_tot_tg`i'<`N_thresh'
	}

	* Combine test criteria
	gen hold_split=(hold_split_homog==1 & hold_split_minN==1)

	tempfile hold
	save `hold', replace

	* Export the strata that will not be split
	use `hold', clear
	keep if hold_split==0
	if (_N>0) {
		gen iter=`iter'
		rename hold_stratum stratum_local
		rename hold_F F
		rename hold_tot_tg1 tot_tg1
		rename hold_tot_tg2 tot_tg2
		rename hold_tot_tg3 tot_tg3
		rename hold_tot_tg4 tot_tg4
		drop hold_*
		append using nosplit
		drop stratum_global
		egen stratum_global=group(stratum_local iter)
		save nosplit, replace
	}

	* Start wokring on strata to split
	use `hold', clear
	* Impose stopping rule. If no strata are identified to be split
	tab hold_split
	qui su hold_split
	local min=`r(min)'
	local max=`r(max)'
	if (`min'==0 & `max'==0) {
		local exit="Yes"
	}
	keep if hold_split==1
	if (_N>0) {

		* Identify new strata
		egen new_stratum = group(hold_stratum hold_stratum_test)
		qui su new_stratum
		local strata=`r(max)'
		
		su hold_F new_stratum hold_tot_tg*
		drop hold_*
		rename new_stratum hold_stratum
		save split, replace
	}
}

erase split.dta


use nosplit, clear

reg pr
predict res, r
twoway (kdensity res if nih==1 & post==1) ///
       (kdensity res if nih==1 & post==0) ///
	   (kdensity res if nih==0 & post==1) ///
	   (kdensity res if nih==0 & post==0), ///
	   legend(order(1 "Treated After" 2 "Treated Before" 3 "Control After" 4 "Control Before"))

areg pr, absorb(stratum_global)
predict res_fe, r

twoway (kdensity res_fe if nih==1 & post==1) ///
       (kdensity res_fe if nih==1 & post==0) ///
	   (kdensity res_fe if nih==0 & post==1) ///
	   (kdensity res_fe if nih==0 & post==0), ///
	   legend(order(1 "Treated After" 2 "Treated Before" 3 "Control After" 4 "Control Before"))




clear
gen parmseq=.
save coeffs_subclass, replace

use nosplit, clear
gen trimmed=(pr>0.90 | pr<0.10)
drop if trimmed==1
collapse (mean) pr, by(stratum_global)
sort pr
gen stratum=_n
twoway(connected pr stratum)
merge 1:m stratum_global using nosplit
drop if _merge==2
drop _merge

su stratum
local strata_max=`r(max)'
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
forvalues i=1/`strata_max' {
	
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

su att
local att=`r(mean)'
gen upper95=att+2*sd
gen lower95=att-2*sd
su upper95
local upper95=`r(mean)'
su lower95
local lower95=`r(mean)'

twoway (connected estimate stratum), ///
       yline(0) yline(`att') yline(`lower95') yline(`upper95')






