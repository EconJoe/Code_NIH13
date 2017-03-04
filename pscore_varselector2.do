

clear
program define hello
  di "Hello `1'"
  end

hello sir
program drop hello


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
save covariates_all, replace



* ESTIMATE THE BASE MODEL
* Keep only the needed covariates and save to temp file
use covariates_all, clear
keep treated
save covariates_hold, replace
* Write R code for logit estimation
quietly: file open rcode using  logit.R, write replace
quietly: file write rcode ///
    `"library(readstata13)"' _newline ///
    `"library(foreign)"' _newline ///
    `"mydata = read.dta13("D:/Research/Projects/NIHMandate/NIH14/Data/covariates_hold.dta")"' _newline ///
    `"mylogit = glm(treated ~ ., data=mydata, family="binomial")"' _newline ///
	`"output = data.frame(names(mylogit\$coefficients), summary(mylogit)\$coefficients, logLik(mylogit))"' _newline ///
    `"write.dta(output,"D:/Research/Projects/NIHMandate/NIH14/Data/varselection.dta")"' _newline ///
	`"quit("no")"'
quietly: file close rcode
* Invoke R and run logit file
quietly: shell "C:\Program Files\R\R-3.3.2\bin\x64\R.exe" CMD BATCH logit.R
* Clean output from R and save
use varselection.dta, clear
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

* ESTIMATE THE LINEAR TERMS
local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_3_both_001 ment_5_both_001 ment_10_both_001 ment_all_both_001 ment_0_both_0001 ment_3_both_0001 ment_5_both_0001 ment_10_both_0001 ment_all_both_0001"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_ja pt_rsnnonus pt_rev pt_engabs pt_cr pt_comp pt_ct pt_irreg"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"
local spec `"`backcites' `author' "'

local num=1

set more off
foreach rvar in `spec' {

	local rvar = "`permvar' " + "`rvar'"
	
	* Keep only the needed covariates and save to temp file
	display in red "`rvar'"
	use covariates_all, clear
	keep treated `rvar'
	save covariates_hold, replace
	su
	
	quietly: file open rcode using  test.R, write replace
	quietly: file write rcode ///
		`"library(readstata13)"' _newline ///
		`"library(foreign)"' _newline ///
		`"mydata = read.dta13("D:/Research/Projects/NIHMandate/NIH14/Data/covariates_hold.dta")"' _newline ///
		`"mylogit = glm(treated ~ `rvar', data=mydata, family="binomial")"' _newline ///
		`"output = data.frame(names(mylogit\$coefficients), summary(mylogit)\$coefficients, logLik(mylogit))"' _newline ///
		`"write.dta(output,"D:/Research/Projects/NIHMandate/NIH14/Data/varselection.dta")"' _newline ///
		`"quit("no")"'
	quietly: file close rcode
	
	* Invoke R and run logit file
	quietly: shell "C:\Program Files\R\R-3.3.2\bin\x64\R.exe" CMD BATCH logit.R
	* Clean output from R and save
	use varselection.dta, clear
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

* Determine which (if any) covariates to keep be performing a liklihood ratio test
use linterms, clear
* Log liklihood of the unrestricted model
egen rll=min(ll)
* Compute the LR stat for each specification
gen lrstat = 2*(ll-rll)
* Identify the maximum LR stat among all specifications
egen max_lrstat=max(lrstat)
gen keepvar=(lrstat==max_lrstat & varname!="(Intercept)")
* Only include the variable with the max LR stat IF it is larger than the threshold value of 1
replace keepvar=0 if max_lrstat<1
keep if keepvar==1

* Include the variable in all subsequent specifications
levelsof varname, local(levels)
foreach i in `levels' {
	local rvar="`i'"
}

local permvar = "Test " + "`rvar'"
display in red "`permvar'"






