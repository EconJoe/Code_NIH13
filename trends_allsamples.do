

* This file computes estimates using open access indicator as the outcome variable.

cd D:\Research\Projects\NIHMandate\NIH15\Data
use estsample_large, clear
keep if year>=2000 & year<=2013
gen ta=1-oa
gen post=(year>2008)
gen nih=(nih_pubtype==1 | nih_grantlist==1)

tempfile hold1
save `hold1', replace



cd D:\Research\Projects\NIHMandate\NIH14\Data
use estsample, clear
keep if year>=2000 & year<=2013

gen ta=1-oa
gen lsim=ln(similarityscore)
gen lval=ln(validsimilar_total)
gen post=(year>2008)

tempfile hold2
save `hold2', replace


clear
set obs 14
gen year=_n+1999
gen nih=1
cd D:\Research\Projects\NIHMandate\NIH14\Output
save oa_trends_all, replace
clear
set obs 14
gen year=_n+1999
gen nih=0
cd D:\Research\Projects\NIHMandate\NIH14\Output
append using oa_trends_all
save oa_trends_all, replace

use `hold1', clear
collapse (mean) ta, by(year nih)
rename ta ta_all
cd D:\Research\Projects\NIHMandate\NIH14\Output
merge 1:1 year nih using oa_trends_all
drop _merge
save oa_trends_all, replace

use `hold2', clear
collapse (mean) ta, by(year nih)
rename ta ta_matched
cd D:\Research\Projects\NIHMandate\NIH14\Output
merge 1:1 year nih using oa_trends_all
drop _merge
save oa_trends_all, replace

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"

local spec7 `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

forvalues i=7/7 {

	set more off
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	
	if (`i'==1) {
		local replace "replace"
	}
	else {
		local replace ""
	}
	
	use `hold1', clear
	reg ta `spec`i'', cluster(ui4)
	predict  r_`i'_OLS_all, r
	collapse (mean) r_`i'_OLS, by(nih year)
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	merge 1:1 year nih using oa_trends_all
	drop _merge
	save oa_trends_all, replace
	
	use `hold2', clear
	reg ta `spec`i'', cluster(ui4)
	predict  r_`i'_OLS_match, r
	collapse (mean) r_`i'_OLS, by(nih year)
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	merge 1:1 year nih using oa_trends_all
	drop _merge
	save oa_trends_all, replace
	
	use `hold1', clear
	areg ta `spec`i'', cluster(ui4) absorb(ui4)
	predict  r_`i'_UI_all, r
	collapse (mean) r_`i'_UI, by(nih year)
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	merge 1:1 year nih using oa_trends_all
	drop _merge
	save oa_trends_all, replace
	
	use `hold2', clear
	areg ta `spec`i'', cluster(ui4) absorb(ui4)
	predict  r_`i'_UI_match, r
	collapse (mean) r_`i'_UI, by(nih year)
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	merge 1:1 year nih using oa_trends_all
	drop _merge
	save oa_trends_all, replace
	
}


twoway (connected ta_matched year if nih==1) ///
	   (connected ta_matched year if nih==0, msymbol(triangle)) ///
	   (connected ta_all year if nih==1) ///
	   (connected ta_all year if nih==0, msymbol(triangle)), ///
		xlabel(2000(1)2013, angle(forty_five)) ///
		xline(2008) ///
		xtitle("Year") ///
		ytitle("") ///
		legend(order(1 "NIH (Matched)" 2 "Control (Matched)" 3 "NIH (All)" 4 "Control (All)")) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))


twoway (connected ta_matched year if nih==1 & year<=2007) ///
	   (connected ta_matched year if nih==0 & year<=2007, msymbol(triangle)) ///
	   (connected ta_all year if nih==1 & year<=2007, msymbol(circle_hollow)) ///
	   (connected ta_all year if nih==0 & year<=2007, msymbol(triangle_hollow)), ///
		xlabel(2000(1)2007, angle(forty_five)) ///
		xtitle("Year") ///
		ytitle("") ///
		legend(order(1 "NIH (Matched)" 2 "Control (Matched)" 3 "NIH (All)" 4 "Control (All)")) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))

		
twoway (connected r_7_OLS_match year if nih==1) ///
	   (connected r_7_OLS_match year if nih==0, msymbol(triangle)) ///
	   (connected r_7_OLS_all year if nih==1) ///
	   (connected r_7_OLS_all year if nih==0, msymbol(triangle)), ///
		xlabel(2000(1)2013, angle(forty_five)) ///
		xline(2008) ///
		xtitle("Year") ///
		ytitle("") ///
		legend(order(1 "NIH (Matched)" 2 "Control (Matched)" 3 "NIH (All)" 4 "Control (All)")) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))


twoway (connected r_7_OLS_match year if nih==1 & year<=2007) ///
	   (connected r_7_OLS_match year if nih==0 & year<=2007, msymbol(triangle)) ///
	   (connected r_7_OLS_all year if nih==1 & year<=2007, msymbol(circle_hollow)) ///
	   (connected r_7_OLS_all year if nih==0 & year<=2007, msymbol(triangle_hollow)), ///
		xlabel(2000(1)2007, angle(forty_five)) ///
		xtitle("Year") ///
		ytitle("") ///
		legend(order(1 "NIH (Matched)" 2 "Control (Matched)" 3 "NIH (All)" 4 "Control (All)")) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
		
		
twoway (connected r_7_UI_match year if nih==1) ///
	   (connected r_7_UI_match year if nih==0, msymbol(triangle)) ///
	   (connected r_7_UI_all year if nih==1, msymbol(circle_hollow)) ///
	   (connected r_7_UI_all year if nih==0, msymbol(triangle_hollow)), ///
		xlabel(2000(1)2013, angle(forty_five)) ///
		xline(2008) ///
		xtitle("Year") ///
		ytitle("") ///
		legend(order(1 "NIH (Matched)" 2 "Control (Matched)" 3 "NIH (All)" 4 "Control (All)")) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
		

twoway (connected r_7_UI_match year if nih==1 & year<=2007) ///
	   (connected r_7_UI_match year if nih==0 & year<=2007, msymbol(triangle)) ///
	   (connected r_7_UI_all year if nih==1 & year<=2007, msymbol(circle_hollow)) ///
	   (connected r_7_UI_all year if nih==0 & year<=2007, msymbol(triangle_hollow)), ///
		xlabel(2000(1)2007, angle(forty_five)) ///
		xtitle("Year") ///
		ytitle("") ///
		legend(order(1 "NIH (Matched)" 2 "Control (Matched)" 3 "NIH (All)" 4 "Control (All)")) ///
		graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
		
		
		
use `hold', clear
collapse (mean) ta [aweight=weight], by(year nih)
rename ta ta_w
cd D:\Research\Projects\NIHMandate\NIH14\Output
merge 1:1 year nih using oa_trends_large
drop _merge
save oa_trends_large, replace


forvalues i=1/7 {

	set more off
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	
	if (`i'==1) {
		local replace "replace"
	}
	else {
		local replace ""
	}
	
	use `hold', clear
	reg ta `spec`i'', cluster(ui4)
	predict  r_`i'_OLS, r
	collapse (mean) r_`i'_OLS, by(nih year)
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	merge 1:1 year nih using oa_trends_large
	drop _merge
	save oa_trends_large, replace
	
	use `hold', clear
	reg ta `spec`i'' [aweight=weight], cluster(ui4)
	predict  r_`i'_OLS_w, r
	collapse (mean) r_`i'_OLS_w, by(nih year)
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	merge 1:1 year nih using oa_trends_large
	drop _merge
	save oa_trends_large, replace
	
	
	use `hold', clear
	areg ta `spec`i'', cluster(ui4) absorb(ui4)
	predict  r_`i'_UI4, r
	collapse (mean) r_`i'_UI4, by(nih year)
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	merge 1:1 year nih using oa_trends_large
	drop _merge
	save oa_trends_large, replace
	
	use `hold', clear
	areg ta `spec`i'' [aweight=weight], cluster(ui4) absorb(ui4)
	predict  r_`i'_UI4_w, r
	collapse (mean) r_`i'_UI4_w, by(nih year)
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	merge 1:1 year nih using oa_trends_large
	drop _merge
	save oa_trends_large, replace
	
	
	use `hold', clear
	areg ta `spec`i'', cluster(ui4) absorb(ui4)
	predict  r_`i'_UI, r
	collapse (mean) r_`i'_UI, by(nih year)
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	merge 1:1 year nih using oa_trends_large
	drop _merge
	save oa_trends_large, replace
	
	use `hold', clear
	areg ta `spec`i'' [aweight=weight], cluster(ui4) absorb(ui4)
	predict  r_`i'_UI_w, r
	collapse (mean) r_`i'_UI_w, by(nih year)
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	merge 1:1 year nih using oa_trends_large
	drop _merge
	save oa_trends_large, replace
}
