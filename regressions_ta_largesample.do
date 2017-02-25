



* This file computes estimates using open access indicator as the outcome variable.

cd D:\Research\Projects\NIHMandate\NIH14\Data
use estsample_large, clear
keep if year>=2000 & year<=2013
gen ta=1-oa
gen post=(year>2008)
gen nih=(nih_pubtype==1 | nih_grantlist==1)


*reg ta i.nih##i.post i.year, cluster(ui4)

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"

local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"

local spec1 `""'
local spec2 `"`backcites'"'
local spec3 `"`backcites' `ment'"'
local spec4 `"`backcites' `ment' `mesh'"'
local spec5 `"`backcites' `ment' `mesh' `author'"'
local spec6 `"`backcites' `ment' `mesh' `author' `pubtype'"'
local spec7 `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

local predyntest = "1.nih#2001.year 1.nih#2002.year 1.nih#2003.year 1.nih#2004.year 1.nih#2005.year 1.nih#2006.year 1.nih#2007.year"

gen tgroup=.
replace tgroup=1 if nih==1 & post==0
replace tgroup=2 if nih==1 & post==1
replace tgroup=3 if nih==0 & post==0
replace tgroup=4 if nih==0 & post==1

local spec `"`match' `backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

*keep tgroup `spec'
mlogit tgroup `spec'
predict pr1, outcome(#1)
predict pr2, outcome(#2)
predict pr3, outcome(#3)
predict pr4, outcome(#4)

gen weight=.
replace weight=pr1/pr1 if tgroup==1
replace weight=pr1/pr2 if tgroup==2
replace weight=pr1/pr3 if tgroup==3
replace weight=pr1/pr4 if tgroup==4

tempfile hold
save `hold', replace

clear
set obs 14
gen year=_n+1999
gen nih=1
cd D:\Research\Projects\NIHMandate\NIH14\Output
save oa_trends_large, replace
clear
set obs 14
gen year=_n+1999
gen nih=0
cd D:\Research\Projects\NIHMandate\NIH14\Output
append using oa_trends_large
save oa_trends_large, replace

use `hold', clear
collapse (mean) ta, by(year nih)
cd D:\Research\Projects\NIHMandate\NIH14\Output
merge 1:1 year nih using oa_trends_large
drop _merge
save oa_trends_large, replace

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

cd D:\Research\Projects\NIHMandate\NIH14\Output
use oa_trends_large, clear

local vars `" "ta" "r_1_OLS" "r_1_UI" "r_1_UI4" "r_7_OLS" "r_7_UI" "r_7_UI4" "'
foreach var in `vars' {

	twoway (connected `var' year if nih==1) ///
		   (connected `var' year if nih==0, msymbol(triangle)), ///
			xlabel(2000(1)2013, angle(forty_five)) ///
			xline(2008) ///
			xtitle("Year") ///
			ytitle("") ///
			legend(order(1 "NIH" 2 "PRA Control")) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph export "D:\Research\Projects\NIHMandate\NIH14\Output\tapaths_all_`var'.pdf", as(pdf) replace

	twoway (connected `var' year if nih==1 & year<=2007) ///
		   (connected `var' year if nih==0 & year<=2007, msymbol(triangle)), ///
			xlabel(2000(1)2007, angle(forty_five)) ///
			xtitle("Year") ///
			ytitle("") ///
			legend(order(1 "NIH" 2 "PRA Control")) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph export "D:\Research\Projects\NIHMandate\NIH14\Output\tapaths_pre_`var'.pdf", as(pdf) replace
}

local vars `" "ta_w" "r_1_OLS_w" "r_1_UI_w" "r_1_UI4_w" "r_7_OLS_w" "r_7_UI_w" "r_7_UI4_w" "'
foreach var in `vars' {

	twoway (connected `var' year if nih==1) ///
		   (connected `var' year if nih==0, msymbol(triangle)), ///
			xlabel(2000(1)2013, angle(forty_five)) ///
			xline(2008) ///
			xtitle("Year") ///
			ytitle("") ///
			legend(order(1 "NIH" 2 "PRA Control")) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph export "D:\Research\Projects\NIHMandate\NIH14\Output\tapaths_all_`var'.pdf", as(pdf) replace

	twoway (connected `var' year if nih==1 & year<=2007) ///
		   (connected `var' year if nih==0 & year<=2007, msymbol(triangle)), ///
			xlabel(2000(1)2007, angle(forty_five)) ///
			xtitle("Year") ///
			ytitle("") ///
			legend(order(1 "NIH" 2 "PRA Control")) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph export "D:\Research\Projects\NIHMandate\NIH14\Output\tapaths_pre_`var'.pdf", as(pdf) replace
}














* This file computes estimates using open access indicator as the outcome variable.

cd D:\Research\Projects\NIHMandate\NIH14\Data
use estsample_large, clear
keep if year>=2000 & year<=2013
gen ta=1-oa
gen post=(year>2008)
gen nih=(nih_pubtype==1 | nih_grantlist==1)


*reg ta i.nih##i.post i.year, cluster(ui4)

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"

local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"

local spec1 `""'
local spec2 `"`backcites'"'
local spec3 `"`backcites' `ment'"'
local spec4 `"`backcites' `ment' `mesh'"'
local spec5 `"`backcites' `ment' `mesh' `author'"'
local spec6 `"`backcites' `ment' `mesh' `author' `pubtype'"'
local spec7 `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

local predyntest = "1.nih#2001.year 1.nih#2002.year 1.nih#2003.year 1.nih#2004.year 1.nih#2005.year 1.nih#2006.year 1.nih#2007.year"

gen tgroup=.
replace tgroup=1 if nih==1 & post==0
replace tgroup=2 if nih==1 & post==1
replace tgroup=3 if nih==0 & post==0
replace tgroup=4 if nih==0 & post==1

local spec `"`match' `backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

*keep tgroup `spec'
mlogit tgroup `spec'
predict pr1, outcome(#1)
predict pr2, outcome(#2)
predict pr3, outcome(#3)
predict pr4, outcome(#4)

gen weight=.
replace weight=pr1/pr1 if tgroup==1
replace weight=pr1/pr2 if tgroup==2
replace weight=pr1/pr3 if tgroup==3
replace weight=pr1/pr4 if tgroup==4

tempfile hold
save `hold', replace

clear
gen parmseq =.
cd D:\Research\Projects\NIHMandate\NIH14\Output
save regcoeffs_ta_large, replace

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
	parmby "reg ta i.nih#i.year i.year `spec`i'', cluster(ui4)", norestore
	gen spec1=`i'
	gen spec2="OLS"
	gen weighted="No"
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	append using regcoeffs_ta_large
	save regcoeffs_ta_large, replace

	use `hold', clear
	parmby "areg ta i.nih#i.year i.year `spec`i'', cluster(ui4) absorb(ui4)", norestore
	gen spec1=`i'
	gen spec2="Agg MeSH FE"
	gen weighted="No"
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	append using regcoeffs_ta_large
	save regcoeffs_ta_large, replace

	use `hold', clear
	parmby "areg ta i.nih#i.year i.year `spec`i'', cluster(ui4) absorb(ui4)", norestore
	gen spec1=`i'
	gen spec2="Raw MeSH FE"
	gen weighted="No"
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	append using regcoeffs_ta_large
	save regcoeffs_ta_large, replace
	
	
	use `hold', clear
	parmby "reg ta i.nih#i.year i.year `spec`i'' [aweight=weight], cluster(ui4)", norestore
	gen spec1=`i'
	gen spec2="OLS"
	gen weighted="Yes"
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	append using regcoeffs_ta_large
	save regcoeffs_ta_large, replace

	use `hold', clear
	parmby "areg ta i.nih#i.year i.year `spec`i'' [aweight=weight], cluster(ui4) absorb(ui4)", norestore
	gen spec1=`i'
	gen spec2="Agg MeSH FE"
	gen weighted="Yes"
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	append using regcoeffs_ta_large
	save regcoeffs_ta_large, replace

	use `hold', clear
	parmby "areg ta i.nih#i.year i.year `spec`i'' [aweight=weight], cluster(ui4) absorb(ui4)", norestore
	gen spec1=`i'
	gen spec2="Raw MeSH FE"
	gen weighted="Yes"
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	append using regcoeffs_ta_large
	save regcoeffs_ta_large, replace
	
}


use regcoeffs_ta_large, clear
keep if regexm(parm, "1.nih#")
gen year = regexs(0) if regexm(parm, "[0-9][0-9][0-9][0-9]")
destring year, replace
by spec1 year weighted, sort: egen min=min(min95)
by spec1 year weighted, sort: egen max=max(max95)

forvalues i=1/5 {
	
	twoway (rarea max min year if spec1==`i' & spec2=="OLS" & weighted=="No", fcolor(ltblue) fintensity(10) lwidth(none) lcolor(ltblue)) ///
		   (connected estimate year if spec1==`i' & spec2=="OLS" & weighted=="No", lcolor(navy) mcolor(navy) msymbol(circle_hollow)) ///
		   (connected estimate year if spec1==`i' & spec2=="Raw MeSH FE" & weighted=="No", lcolor(navy) mcolor(navy) msymbol(triangle_hollow)) ///
		   (connected estimate year if spec1==`i' & spec2=="Agg MeSH FE" & weighted=="No", lcolor(navy) mcolor(navy) msymbol(square_hollow)), ///
			xlabel(2000(1)2013, angle(forty_five)) ///
			xline(2008) ///
			xtitle("Year") ///
			ytitle("") ///
			legend(off) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph export "D:\Research\Projects\NIHMandate\NIH14\Output\tacoeff_`i'.pdf", as(pdf) replace
	
	
	twoway (rarea max min year if spec1==`i' & spec2=="OLS" & weighted=="Yes", fcolor(ltblue) fintensity(10) lwidth(none) lcolor(ltblue)) ///
		   (connected estimate year if spec1==`i' & spec2=="OLS" & weighted=="Yes", lcolor(navy) mcolor(navy) msymbol(circle_hollow)) ///
		   (connected estimate year if spec1==`i' & spec2=="Raw MeSH FE" & weighted=="Yes", lcolor(navy) mcolor(navy) msymbol(triangle_hollow)) ///
		   (connected estimate year if spec1==`i' & spec2=="Agg MeSH FE" & weighted=="Yes", lcolor(navy) mcolor(navy) msymbol(square_hollow)), ///
			xlabel(2000(1)2013, angle(forty_five)) ///
			xline(2008) ///
			xtitle("Year") ///
			ytitle("") ///
			legend(off) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph export "D:\Research\Projects\NIHMandate\NIH14\Output\tacoeff_`i'_weighted.pdf", as(pdf) replace
}

forvalues i=6/7 {

	twoway (rarea max min year if spec1==`i' & spec2=="OLS" & weighted=="No", fcolor(ltblue) fintensity(10) lwidth(none) lcolor(ltblue)) ///
		   (connected estimate year if spec1==`i' & spec2=="OLS" & weighted=="No", lcolor(navy) mcolor(navy) msymbol(circle_hollow)) ///
		   (connected estimate year if spec1==`i' & spec2=="Raw MeSH FE" & weighted=="No", lcolor(navy) mcolor(navy) msymbol(triangle_hollow)) ///
		   (connected estimate year if spec1==`i' & spec2=="Agg MeSH FE" & weighted=="No", lcolor(navy) mcolor(navy) msymbol(square_hollow)), ///
			xlabel(2000(1)2013, angle(forty_five)) ///
			xline(2008) ///
			xtitle("Year") ///
			ytitle("") ///
			legend(order(2 "OLS" 3 "Raw MeSH FE" 4 "Aggregated MeSH FE")) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph export "D:\Research\Projects\NIHMandate\NIH14\Output\tacoeff_`i'.pdf", as(pdf) replace
	
	twoway (rarea max min year if spec1==`i' & spec2=="OLS" & weighted=="Yes", fcolor(ltblue) fintensity(10) lwidth(none) lcolor(ltblue)) ///
		   (connected estimate year if spec1==`i' & spec2=="OLS" & weighted=="Yes", lcolor(navy) mcolor(navy) msymbol(circle_hollow)) ///
		   (connected estimate year if spec1==`i' & spec2=="Raw MeSH FE" & weighted=="Yes", lcolor(navy) mcolor(navy) msymbol(triangle_hollow)) ///
		   (connected estimate year if spec1==`i' & spec2=="Agg MeSH FE" & weighted=="Yes", lcolor(navy) mcolor(navy) msymbol(square_hollow)), ///
			xlabel(2000(1)2013, angle(forty_five)) ///
			xline(2008) ///
			xtitle("Year") ///
			ytitle("") ///
			legend(order(2 "OLS" 3 "Raw MeSH FE" 4 "Aggregated MeSH FE")) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph export "D:\Research\Projects\NIHMandate\NIH14\Output\tacoeff_`i'_weighted.pdf", as(pdf) replace
}






* This file computes estimates using open access indicator as the outcome variable.



* This file computes estimates using open access indicator as the outcome variable.

cd D:\Research\Projects\NIHMandate\NIH14\Data
use estsample_large, clear
keep if year>=2000 & year<=2013
gen ta=1-oa
gen post=(year>2008)
gen nih=(nih_pubtype==1 | nih_grantlist==1)


*reg ta i.nih##i.post i.year, cluster(ui4)

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"

local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"

local spec1 `""'
local spec2 `"`backcites'"'
local spec3 `"`backcites' `ment'"'
local spec4 `"`backcites' `ment' `mesh'"'
local spec5 `"`backcites' `ment' `mesh' `author'"'
local spec6 `"`backcites' `ment' `mesh' `author' `pubtype'"'
local spec7 `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

local predyntest = "1.nih#2001.year 1.nih#2002.year 1.nih#2003.year 1.nih#2004.year 1.nih#2005.year 1.nih#2006.year 1.nih#2007.year"

gen tgroup=.
replace tgroup=1 if nih==1 & post==0
replace tgroup=2 if nih==1 & post==1
replace tgroup=3 if nih==0 & post==0
replace tgroup=4 if nih==0 & post==1

local spec `"`match' `backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

*keep tgroup `spec'
mlogit tgroup `spec'
predict pr1, outcome(#1)
predict pr2, outcome(#2)
predict pr3, outcome(#3)
predict pr4, outcome(#4)

gen weight=.
replace weight=pr1/pr1 if tgroup==1
replace weight=pr1/pr2 if tgroup==2
replace weight=pr1/pr3 if tgroup==3
replace weight=pr1/pr4 if tgroup==4

forvalues i=1/7 {

	set more off
	cd D:\Research\Projects\NIHMandate\NIH14\Output
	
	if (`i'==1) {
		local replace "replace"
	}
	else {
		local replace ""
	}

	* Unweighted Regressions
	reg ta i.nih##i.year `spec`i'', cluster(ui4)
	test `predyntest'
	local F=round(r(F), 0.0001)
	local p=round(r(p), 0.0001)
	reg ta i.nih##i.post i.year `spec`i'', cluster(ui4)
	outreg2 using ta_ols_large.tex, `replace' tex(landscape) keep(i.nih##i.post `spec`i'') label dec(4) nocons addtext(Pre-dynamics F-stat, `F', Pre-dynamics P-value, `p')
	
	areg ta i.nih##i.year `spec`i'', cluster(ui4) absorb(ui4)
	test `predyntest'
	local F=round(r(F), 0.0001)
	local p=round(r(p), 0.0001)
	areg ta i.nih##i.post i.year `spec`i'', cluster(ui4) absorb(ui4)
	outreg2 using ta_feui4_large.tex, `replace' tex(landscape) keep(i.nih##i.post `spec`i'') label dec(4) nocons addtext(Pre-dynamics F-stat, `F', Pre-dynamics P-value, `p')
	
	areg ta i.nih##i.year `spec`i'', cluster(ui4) absorb(ui)
	test `predyntest'
	local F=round(r(F), 0.0001)
	local p=round(r(p), 0.0001)
	areg ta i.nih##i.post i.year `spec`i'', cluster(ui4) absorb(ui)
	outreg2 using ta_feui_large.tex, `replace' tex(landscape) keep(i.nih##i.post `spec`i'') label dec(4) nocons addtext(Pre-dynamics F-stat, `F', Pre-dynamics P-value, `p')
	
	
	* Weighted regressions
	reg ta i.nih##i.year `spec`i'' [aweight=weight], cluster(ui4)
	test `predyntest'
	local F=round(r(F), 0.0001)
	local p=round(r(p), 0.0001)
	reg ta i.nih##i.post i.year `spec`i'' [aweight=weight], cluster(ui4)
	outreg2 using ta_ols_weighted_large.tex, `replace' tex(landscape) keep(i.nih##i.post `spec`i'') label dec(4) nocons addtext(Pre-dynamics F-stat, `F', Pre-dynamics P-value, `p')
	
	areg ta i.nih##i.year `spec`i'' [aweight=weight], cluster(ui4) absorb(ui4)
	test `predyntest'
	local F=round(r(F), 0.0001)
	local p=round(r(p), 0.0001)
	areg ta i.nih##i.post i.year `spec`i'' [aweight=weight], cluster(ui4) absorb(ui4)
	outreg2 using ta_feui4_weighted_large.tex, `replace' tex(landscape) keep(i.nih##i.post `spec`i'') label dec(4) nocons addtext(Pre-dynamics F-stat, `F', Pre-dynamics P-value, `p')
	
	areg ta i.nih##i.year `spec`i'' [aweight=weight], cluster(ui4) absorb(ui)
	test `predyntest'
	local F=round(r(F), 0.0001)
	local p=round(r(p), 0.0001)
	areg ta i.nih##i.post i.year `spec`i'' [aweight=weight], cluster(ui4) absorb(ui)
	outreg2 using ta_feui_weighted_large.tex, `replace' tex(landscape) keep(i.nih##i.post `spec`i'') label dec(4) nocons addtext(Pre-dynamics F-stat, `F', Pre-dynamics P-value, `p')
}


