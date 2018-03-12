
set more off

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/
use samples_comparison, clear
gen nih=(grant_countnih>0 | pt_nih==1)
gen post=(year>2008)
gen ta=1-oa
gen treated_dd = (nih==1 & post==1)
gen treated_ddd = (nih==1 & ta==1 & post==1)

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "author_count author_corp"
local pubtype "pt_ja pt_nophs pt_phs pt_arra pt_nous pt_rev pt_engabs pt_cr pt_comp pt_meta pt_eval pt_guide pt_multi pt_obs pt_rct pt_tech pt_twin pt_valid pt_ct pt_irreg"
local language "lang_other lang_eng lang_ger lang_fre lang_rus lang_jpn lang_spa lang_ita lang_chi"
local othergrant "grant_countnonnih"
local type "type_com type_edu type_eduhos type_gov type_hos type_mil type_org type_unk"
local covariates `" `backcites' `ment' `mesh' `author' `pubtype' `language' `othergrant' `type' "'

keep pmid year treated_* sample_* `covariates'
order pmid year treated_* sample_*


* Rename covariates for easy use in SAS
local varnum_lin=1
foreach cov in `covariates' {
	display in red "`cov'"
	label var `cov' "`cov'"
	rename `cov' lin_`varnum_lin'
	local varnum_lin=`varnum_lin'+1
}
order lin_*, sequential
order pmid year treated_* sample_*


local varnum_lin_max=`varnum_lin'-1
local varnum_quad=`varnum_lin'
display in red "`varnum_lin_max'"

set more off
local jstart=1
forvalues i=1/`varnum_lin_max' {
	forvalues j=`jstart'/`varnum_lin_max' {
		* Create the 2nd order term for every possible variable combination.
		* Obviously indicator variables will create perfect collinearity, so we'll drop them below
		gen quad_`varnum_quad' = lin_`i'*lin_`j'
		local label1: variable label lin_`i'
		local label2: variable label lin_`j'
		label var quad_`varnum_quad' "`label1' x `label2'"
		* Compress as we go to save time
		compress quad_`varnum_quad'
		local varnum_quad=`varnum_quad'+1
	}	
	local jstart=`jstart'+1
}

local varnum_quad_max=`varnum_quad'-1
local varnum_quad_min=`varnum_lin_max'+1

display in red "Linear Terms: 1 - `varnum_lin_max'"
display in red "Quadratic Terms: `varnum_quad_min' - `varnum_quad_max'"

* Identify and drop collinear variables
set matsize 5000
_rmcoll lin_1-lin_`varnum_lin_max' quad_`varnum_quad_min'-quad_`varnum_quad_max'
local collinset = "`r(varlist)'"
display in red "`collinset'"
set more off
foreach i in `collinset' {
	if regexm("`i'", "^o\.(.*)") {
		local dropvar = regexs(1)
		drop `dropvar'
		display in red "Drop: `dropvar'"
	}
}


* Rename any dropped linear terms
local varnum=1
foreach var of varlist lin_* {
	display in red "`var'"
	capture confirm variable `var'
	if !_rc {
		rename `var' lin_`varnum'_
	}
	local varnum=`varnum'+1
}
local varnum_lin_max=`varnum'-1
display in red "`varnum_lin_max'"
forvalues i=1/`varnum_lin_max'	 {
	rename lin_`i'_ lin_`i'
}


* Rename any dropped quadratic terms
local varnum=1
foreach var of varlist quad_* {
	display in red "`var'"
	capture confirm variable `var'
	if !_rc {
		rename `var' quad_`varnum'_
	}
	local varnum=`varnum'+1
}
local varnum_quad_max=`varnum'-1
display in red "`varnum_quad_max'"
forvalues i=1/`varnum_quad_max' {
	rename quad_`i'_ quad_`i'
}

compress
save pscore_covariates, replace






