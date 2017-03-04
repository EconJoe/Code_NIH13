
* This program runs logistic regression in R. This is because Stata often doesn't coverge.
* We only need to pass in the variables that will be on the RHS of the regression
program define logitR
	* Write R code for logit estimation
	quietly: file open rcode using  logit.R, write replace
	quietly: file write rcode ///
		`"library(readstata13)"' _newline ///
		`"library(foreign)"' _newline ///
		`"mydata = read.dta13("D:/Research/Projects/NIHMandate/NIH14/Data/covariates_all.dta")"' _newline ///
		`"mylogit = glm(treated ~ polym(`1', degree=1) + polym(`2', degree=2), data=mydata, family="binomial")"' _newline ///
		`"lodds = data.frame(predict(mylogit))"' _newline ///
		`"pr = data.frame(predict(mylogit, type="response"))"' _newline ///
		`"newdata = data.frame(mydata, lodds, pr)"' _newline ///
		`"write.dta(newdata,"D:/Research/Projects/NIHMandate/NIH14/Data/pscore_fullsat.dta")"' _newline ///
		`"quit("no")"'
	quietly: file close rcode
	* Invoke R and run logit file
	quietly: shell "C:\Program Files\R\R-3.3.2\bin\x64\R.exe" CMD BATCH logit.R
	end
*program drop logitR


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
local covariatepool_cont `"`backcites' `ment' `mesh' `author' `meshaug1'"'
local covariatepool_dummy `"`pubtype'"'


*local backcites "bc_count bc_oa_count"
*local pubtype "pt_ja"
*local covariatepool_cont `"`backcites'"'
*local covariatepool_dummy `"`pubtype'"'

keep pmid treated `covariatepool_cont' `covariatepool_dummy'
save covariates_all, replace




local covs_cont_log =""
local varnum=0
foreach cov in `covariatepool_cont' {
	*display in red "`cov'"
	if (`varnum'==0) {
		local covs_cont_log="`cov'"
		local varnum=1
	}
	else {
		local covs_cont_log="`covs_cont_log'" + ", " + "`cov'"
	}
}
display in red "`covs_cont_log'"

local covs_dummy_log =""
local varnum=0
foreach cov in `covariatepool_dummy' {
	*display in red "`cov'"
	if (`varnum'==0) {
		local covs_dummy_log="`cov'"
		local varnum=1
	}
	else {
		local covs_dummy_log="`covs_dummy_log'" + ", " + "`cov'"
	}
}
display in red "`covs_dummy_log'"


logitR "`covs_dummy_log'" "`covs_cont_log'"


use pscore_fullsat, clear
