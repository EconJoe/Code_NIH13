

set more off

global inpath "/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data"
global outpath "/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output"

cd $inpath


clear
gen estimate = .
save coeffs_poisson_covs_fc_com_2yr, replace


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

use temp, clear
keep if sample_prca_1to1 == 1
keep if ps_lin_prca_1to1_2011_ddd == 1
keep pmid fc_com_2yr ta nih post yr_* nih_post ta_post nih_ta nih_ta_post `covariates' group_* year
tab group_country, gen(county_)
poi2hdfe fc_com_2yr nih post ta nih_post ta_post nih_ta nih_ta_post yr_* county_* `covariates', cluster(group_ui4) id1(group_ui) id2(group_country)
local obs = e(N)
parmest, norestore
gen obs = `obs'
gen trimmed = "No"
gen sample = "PRCA 1-to-1"
append using coeffs_poisson_covs_fc_com_2yr
save coeffs_poisson_covs_fc_com_2yr, replace


use temp, clear
keep if sample_prca_1to1 == 1
keep if ps_lin_prca_1to1_2011_ddd_t == 1
keep pmid fc_com_2yr ta nih post yr_* nih_post ta_post nih_ta nih_ta_post `covariates' group_* year
tab group_country, gen(county_)
poi2hdfe fc_com_2yr nih post ta nih_post ta_post nih_ta nih_ta_post yr_* county_* `covariates', cluster(group_ui4) id1(group_ui) id2(group_country)
local obs = e(N)
parmest, norestore
gen obs = `obs'
gen trimmed = "No"
gen sample = "PRCA 1-to-1"
append using coeffs_poisson_covs_fc_com_2yr
save coeffs_poisson_covs_fc_com_2yr, replace

      
