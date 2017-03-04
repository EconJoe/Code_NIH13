

cd D:\Research\Projects\NIHMandate\NIH14\Data
use estsample, clear
keep if year>=2000 & year<=2013

gen ta=1-oa
gen post=(year>2008)
gen treated=(nih==1 & post==1)
gen nottreated=1-treated

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_3_both_001 ment_5_both_001 ment_10_both_001 ment_all_both_001 ment_0_both_0001 ment_3_both_0001 ment_5_both_0001 ment_10_both_0001 ment_all_both_0001"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_ja pt_rsnnonus pt_rev pt_engabs pt_cr pt_comp pt_ct pt_irreg"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"
local spec `"`backcites' `author' "'
keep treated `spec'
save temp, replace

*// Write R Code
*// dependencies: foreign
quietly: file open rcode using  test.R, write replace
quietly: file write rcode ///
    `"library(readstata13)"' _newline ///
    `"library(foreign)"' _newline ///
    `"mydata = read.dta13("D:/Research/Projects/NIHMandate/NIH14/Data/temp2.dta")"' _newline ///
    `"mylogit = glm(treated ~ ., data=mydata, family="binomial")"' _newline ///
	`"output = data.frame(names(mylogit\$coefficients), summary(mylogit)\$coefficients, logLik(mylogit))"' _newline ///
    `"write.dta(output,"D:/Research/Projects/NIHMandate/NIH14/Data/testin.dta")"' _newline ///
	`"quit("no")"'
quietly: file close rcode

* Estimate base model
use temp, clear
keep treated
save temp2, replace
quietly: shell "C:\Program Files\R\R-3.3.2\bin\x64\R.exe" CMD BATCH test.R
use testin.dta, clear
decode names_mylogit_coefficients_, gen(varname)
drop names_mylogit_coefficients_
order varname
rename Estimate estimate
rename Std__Error se
rename z_value z
rename Pr___z__ p
rename logLik_mylogit_ ll
gen num=0
save linterms, replace

local num=1

set more off
foreach var in `spec' {

	display in red "`var'"
	use temp, clear
	keep treated `var'
	su
	save temp2, replace

	*// Run R
	quietly: shell "C:\Program Files\R\R-3.3.2\bin\x64\R.exe" CMD BATCH test.R

	use testin.dta, clear
	decode names_mylogit_coefficients_, gen(varname)
	drop names_mylogit_coefficients_
	order varname
	rename Estimate estimate
	rename Std__Error se
	rename z_value z
	rename Pr___z__ p
	rename logLik_mylogit_ ll
	gen num=`num'
	local num=`num'+1
	append using linterms
	save linterms, replace
}

use linterms, clear
egen rll=min(ll)
gen lrstat = 2*(ll-rll)
egen max_lrstat=max(lrstat)
gen keepvar=(lrstat==max_lrstat & varname!="(Intercept)")
replace keepvar=0 if max_lrstat<1
keep if keepvar==1
levelsof varname, local(levels)
foreach i in `levels' {
	local rvar=`i'
}

*// Write R Code
*// dependencies: foreign
quietly: file open rcode using  test.R, write replace
quietly: file write rcode ///
    `"library(readstata13)"' _newline ///
    `"library(foreign)"' _newline ///
    `"mydata = read.dta13("D:/Research/Projects/NIHMandate/NIH14/Data/temp2.dta")"' _newline ///
    `"mylogit = glm(treated ~ `rvar', data=mydata, family="binomial")"' _newline ///
	`"output = data.frame(names(mylogit\$coefficients), summary(mylogit)\$coefficients, logLik(mylogit))"' _newline ///
    `"write.dta(output,"D:/Research/Projects/NIHMandate/NIH14/Data/testin.dta")"' _newline ///
	`"quit("no")"'
quietly: file close rcode

































local ll=0
local logspec=""
local iter=0

while (`iter'<=2) {

	local iter=`iter'+1
	
	set more off
	foreach var in `spec' {
		*display in red "`var'"
		logit treated `logspec' `var'
		local ll_curr=`e(ll)'
		if (`ll_curr'<`ll') {
			local ll=`ll_curr'
			local keepvar = "`var'"
		}
	}
	local logspec= "`logspec' `keepvar'"
	display in red "`ll'"
	display in red "`keepvar'"
}



logit treated `spec'
predict pr, pr
predict lodds, xb
tempfile hold
