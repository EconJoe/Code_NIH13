
global inpath "/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data"
global outpath "/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output"

cd $inpath
use samples_comparison, clear

* Create "treatment" indicators.
gen nih=(grant_countnih>0 | pt_nih==1)
gen post=(year>2008)
gen ta=1-oa

* Create group variables for fields, country, and journal.
egen group_ui=group(ui)
egen group_ui4=group(ui4)
egen group_country=group(country)
egen group_nlmid=group(nlmid)

* Unfortunatly the reghdfe handles factor variables can be wonky, so we have to do this manually.
gen nih_post = nih*post
gen ta_post = ta*post
gen nih_ta = nih*ta
gen nih_ta_post = nih*ta*post

forvalues i=2003/2013 {
	gen yr_`i' = (year==`i')
	gen nih_yr_`i' = nih*yr_`i'
	gen ta_yr_`i' = ta*yr_`i'
	gen ta_nih_yr_`i' = ta*nih_yr_`i'
}

gen science=(nlmid=="0404511")
gen nature=(nlmid=="0410462")
gen scinat=(science==1 | nature==1)

compress
save temp, replace

use temp, clear
keep if sample_prca_1to1 == 1
save test, replace

      ps_lin_prca_1to1_2013_dd ///
      ps_lin_prca_1to1_2013_dd_t ///
      ps_lin_prca_1to1_2011_ddd ///
      ps_lin_prca_1to1_2011_ddd_t

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "author_count author_corp"
local pubtype "pt_ja pt_nophs pt_phs pt_arra pt_nous pt_rev pt_engabs pt_cr pt_comp pt_meta pt_eval pt_guide pt_multi pt_obs pt_rct pt_tech pt_twin pt_valid pt_ct pt_irreg"
local language "lang_other lang_eng lang_ger lang_fre lang_rus lang_jpn lang_spa lang_ita lang_chi"
local othergrant "grant_countnonnih"
local type "type_com type_edu type_eduhos type_gov type_hos type_mil type_org type_unk"
local covariates `" `backcites' `ment' `mesh' `author' `pubtype' `language' `othergrant' `type' "'

use test, clear
keep if ps_lin_prca_1to1_2013_dd == 1
keep pmid scinat ta nih post yr_* nih_post nih_yr_* ta_yr_* ta_nih_yr_* `covariates' group_* year
save test2, replace

clear 
gen estimate = .
save coeffs_test, replace

set more off
local depvars ta
foreach depvar in `depvars' {

	use test2, clear
	parmby "reg `depvar' i.nih##i.post i.year `covariates' i.group_country, cluster(group_ui4)", norestore
	local obs = e(N)
	gen obs = `obs'
	gen depvar = "`depvar'"
	gen fe = "No"
	gen model = "Linear"
	gen converged = 1
	append using coeffs_test
	save coeffs_test, replace

	use test2, clear
	parmby "reghdfe `depvar' i.nih##i.post i.year `covariates' i.group_country, cluster(group_ui4) absorb(group_ui) keepsingletons", norestore
	local obs = e(N)
	gen obs = `obs'
	gen depvar = "`depvar'"
	gen fe = "Yes"
	gen model = "Linear"
	gen converged = 1
	append using coeffs_test
	save coeffs_test, replace

	use test2, clear
	parmby "poisson `depvar' i.nih##i.post i.year `covariates' i.group_country, cluster(group_ui4) iter(25)", norestore
	local obs = e(N)
	gen obs = `obs'
	gen depvar = "`depvar'"
	parmest, norestore
	gen fe = "No"
	gen model = "Poisson"
	gen converged = e(converged)
	append using coeffs_test
	save coeffs_test, replace
}

	use test2, clear
	*tab group_country, gen(county_)
	parmby "poi2hdfe `depvar' nih post nih_post yr_* `covariates', cluster(group_ui4) id1(group_ui) id2(group_country)", norestore
	local obs = e(N)
	gen obs = `obs'
	gen depvar = "`depvar'"
	gen fe = "Yes"
	gen model = "Poisson"
	append using coeffs_test
	save coeffs_test, replace
}



tab group_country, gen(county_)
poi2hdfe fc_2yr nih post nih_post yr_* `covariates', cluster(group_ui4) id1(group_ui) id2(group_country)   
      



local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "author_count author_corp"
local pubtype "pt_ja pt_nophs pt_phs pt_arra pt_nous pt_rev pt_engabs pt_cr pt_comp pt_meta pt_eval pt_guide pt_multi pt_obs pt_rct pt_tech pt_twin pt_valid pt_ct pt_irreg"
local language "lang_other lang_eng lang_ger lang_fre lang_rus lang_jpn lang_spa lang_ita lang_chi"
local othergrant "grant_countnonnih"
local type "type_com type_edu type_eduhos type_gov type_hos type_mil type_org type_unk"
local country "i.group_country"
local covariates `" `backcites' `ment' `mesh' `author' `pubtype' `language' `othergrant' `type' "'

use test, clear
keep if ps_lin_prca_1to1_2011_ddd == 1
keep pmid fc_2yr fc_com_2yr fc_dev_2yr ta nih post yr_* nih_post ta_post nih_ta nih_ta_post nih_yr_* ta_yr_* ta_nih_yr_* `covariates' group_* year
save test3, replace

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "author_count author_corp"
local pubtype "pt_ja pt_nophs pt_phs pt_arra pt_nous pt_rev pt_engabs pt_cr pt_comp pt_meta pt_eval pt_guide pt_multi pt_obs pt_rct pt_tech pt_twin pt_valid pt_ct pt_irreg"
local language "lang_other lang_eng lang_ger lang_fre lang_rus lang_jpn lang_spa lang_ita lang_chi"
local othergrant "grant_countnonnih"
local type "type_com type_edu type_eduhos type_gov type_hos type_mil type_org type_unk"
local country "i.group_country"
local covariates `" `backcites' `ment' `mesh' `author' `pubtype' `language' `othergrant' `type' "'

set more off
tab group_country, gen(county_)
poi2hdfe fc_2yr nih post ta nih_post ta_post nih_ta nih_ta_post yr_* county_* `covariates', cluster(group_ui4) id1(group_ui) id2(group_country)   
      

      



keep if ps_lin_prca_1to1_2011_ddd == 1

*sample 1
*tab group_country, gen(county_)

poi2hdfe fc_2yr nih post ta nih_post ta_post nih_ta nih_ta_post yr_* county_* `covariates', cluster(group_ui4) id1(group_ui) id2(group_nlmid)



reg fc_2yr i.nih##i.post##i.ta i.year
reg fc_2yr 

reghdfe fc_2yr i.nih##i.post##i.ta i.year `covariates', cluster(group_ui4) absorb(group_ui nlmid) keepsingletons


poi2hdfe fc_2yr i.nih##i.post##i.ta i.year `covariates', cluster(group_ui4) id1(group_ui) id2(group_nlmid)





reghdfe ta i.nih##i.post i.year `covariates', cluster(group_ui4) absorb(group_ui) keepsingletons
poisson ta i.nih##i.post i.year `covariates', cluster(group_ui4) iter(25)
reg ta i.nih##i.post i.year `covariates', cluster(group_ui4)



poisson ta i.nih##i.post i.year `covariates', cluster(group_ui4) iter(25)

reg ta i.nih##i.post i.year `covariates', cluster(group_ui4)
reghdfe ta i.nih##i.post i.year `covariates' i.group_country, cluster(group_ui4) absorb(group_ui) keepsingletons




reghdfe `depvar' `treatvars' `covariates', absorb(group_ui group_country) cluster(`clustvar') keepsingletons

keep if ps_lin_prca_1to1_2013_dd_t

save test, replace

drop prob_*

use `dataset' if ps_`pspec'_`sample'_`endyear'_`framework'`trimmed'==1, clear;
cd $inpath; estimation "temp" "`depvar'" "group_ui4" "`sample'" "quad" "2013" "dd" "" "`treatment'" "No"; cd $outpath; append using `filename'; save `filename', replace;

use temp, clear
keep if sample_

