
* This program runs logistic regression in R. This is because Stata often doesn't coverge.
* We only need to pass in the variables that will be on the RHS of the regression
program define logitR
	* Write R code for logit estimation
	quietly: file open rcode using  logit.R, write replace
	quietly: file write rcode ///
		`"library(readstata13)"' _newline ///
		`"library(foreign)"' _newline ///
		`"mydata = read.dta13("D:/Research/Projects/NIHMandate/NIH14/Data/covariates_all.dta")"' _newline ///
		`"mylogit = glm(treated ~ `1', data=mydata, family="binomial")"' _newline ///
		`"output = data.frame(names(mylogit\$coefficients), summary(mylogit)\$coefficients, logLik(mylogit))"' _newline ///
		`"write.dta(output,"D:/Research/Projects/NIHMandate/NIH14/Data/varselection.dta")"' _newline ///
		`"quit("no")"'
	quietly: file close rcode
	* Invoke R and run logit file
	quietly: shell "C:\Program Files\R\R-3.3.2\bin\x64\R.exe" CMD BATCH logit.R
	end
*program drop logitR

program define cleanlogitoutput
	decode names_mylogit_coefficients_, gen(varname)
	drop names_mylogit_coefficients_
	order varname
	rename Estimate estimate
	rename Std__Error se
	rename z_value z
	rename Pr___z__ p
	rename logLik_mylogit_ ll
	end

	
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
local covariatepool `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'
keep treated `covariatepool'
save covariates_all, replace


* ESTIMATE THE BASE MODEL
* Keep only the needed covariates and save to temp file
use covariates_all, clear
local RHS ="1"
logitR `RHS'
use varselection.dta, clear
cleanlogitoutput
gen num=0
gen iter=0
save linterms, replace

clear
gen varname=""
save finalvars, replace

* ESTIMATE THE LINEAR TERMS
local selectedvars=""
local iter=1
local exit="No"
while ("`exit'"=="No") {

	display in red "Iteration `iter'"

	local num=1
	set more off
	foreach cov in `covariatepool' {

		use covariates_all, clear
		local RHS = "`selectedvars'" + "+" + "`cov'"
		*display in red "`RHS'"
		logitR `RHS'
		use varselection.dta, clear
		cleanlogitoutput
		gen num=`num'
		local num=`num'+1
		append using linterms
		save linterms, replace
	}
	
	* Identify the iteration
	use linterms, clear
	replace iter=`iter' if iter==.
	save linterms, replace

	* Determine which (if any) covariates to keep be performing a liklihood ratio test
	*local iter=2
	use linterms, clear
	keep if iter>=`iter'-1
	by iter, sort: egen double max_ll=max(ll)
	keep if ll==max_ll
	* Log liklihood of the unrestricted model
	egen double rll=min(ll)
	duplicates tag varname, gen(dup)
	keep if dup==0
	drop dup
	* Compute the LR stat for each specification
	gen lrstat = 2*(ll-rll)
	gen keepvar=(lrstat>1)

	* Set up loop exit criteria
	if (_N==0) {
		local exit="Yes"
	}
	
	* Include the variable in all subsequent specifications
	levelsof varname, local(levels)
	foreach i in `levels' {
		local keepvar="`i'"
	}
	local selectedvars = "`selectedvars'" + "+" + "`keepvar'"
	display in red "`selectedvars'"
	
	append using finalvars
	save finalvars, replace
	
	local iter=`iter'+1
}



