
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Grants\Clean
use nihgrants_grants, clear
keep pmid
duplicates drop
tempfile hold
save `hold', replace

use nihgrants_grants, clear
keep pmid
duplicates drop
append using `hold'
duplicates drop

cd D:\Research\RAWDATA\MEDLINE\2016\Processed
merge 1:m pmid using medline16_dates_clean
gen nih=(_merge==3)
drop _merge
keep if version==1
keep pmid year nih
keep if year>=2000 & year<=2013

cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace

* Attach NLMID to each PMID
cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals
import delimited "medline16_nlmid.txt", clear delimiter(tab) varnames(1)
keep if version==1
keep pmid nlmid
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge 1:1 pmid using estsample_cem
drop if _merge==1
drop _merge
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace

* Add publication type dummies
cd D:\Research\Projects\NIHMandate\NIH14\Data
use article_pubtypedummies, clear
keep if version==1
keep pmid pt_*
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge 1:1 pmid using estsample_cem
drop if _merge==1
drop _merge
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace


* Add author counts
cd D:\Research\Projects\NIHMandate\NIH14\Data
use article_authortotal, clear
keep if version==1
keep pmid authortotal
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge 1:1 pmid using estsample_cem
drop if _merge==1
drop _merge
order pmid nlmid year nih
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace


* Add counts of MeSH terms
cd D:\Research\Projects\NIHMandate\NIH14\Data
use meshcount, clear
keep if version==1
keep pmid count_*
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge 1:1 pmid using estsample_cem
drop if _merge==1
drop _merge
order pmid nlmid year nih
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace

cd D:\Research\Projects\NIHMandate\NIH14\Data
use article_mesh_mean, clear
keep if version==1
drop mean_artmaj_*
keep pmid mean_*
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge 1:1 pmid using estsample_cem
drop if _merge==1
drop _merge
order pmid nlmid year nih
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace


cd D:\Research\Projects\NIHMandate\NIH14\Data
use article_mesh_median, clear
keep if version==1
drop median_artmaj_*
keep pmid median_*
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge 1:1 pmid using estsample_cem
drop if _merge==1
drop _merge
order pmid nlmid year nih
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace


cd D:\Research\Projects\NIHMandate\NIH14\Data
use article_mesh_max, clear
keep if version==1
drop max_artmaj_*
keep pmid max_*
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge 1:1 pmid using estsample_cem
drop if _merge==1
drop _merge
order pmid nlmid year nih
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace


cd D:\Research\Projects\NIHMandate\NIH14\Data
use article_mesh_min, clear
keep if version==1
drop min_artmaj_*
keep pmid min_*
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge 1:1 pmid using estsample_cem
drop if _merge==1
drop _merge
order pmid nlmid year nih
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace



cd D:\Research\Projects\NIHMandate\NIH14\Data
use meshfield_4digit, clear
keep if version==1
keep pmid mesh4_weight ui4
* Identify the 4 digit term with the most weight--some will be ties
by pmid, sort: egen max=max(mesh4_weight)
keep if mesh4_weight==max
* Break ties randomly
set seed 1234
gen rand1=runiform()
gen rand2=runiform()
sort pmid rand1 rand2
by pmid, sort: gen id=_n
duplicates tag pmid, gen(flag_ui4count)
replace flag_ui4count=flag_ui4count+1
keep if id==1
keep pmid mesh4_weight ui4 flag_ui4count
merge 1:1 pmid using estsample_cem
drop if _merge==1
replace ui4="null" if _merge==2
replace flag_ui4count=0 if _merge==2
drop _merge
order pmid nlmid year nih
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace

cd D:\Research\Projects\NIHMandate\NIH14\Data
use article_meshfieldraw, clear
keep if version==1
keep pmid ui
merge 1:1 pmid using estsample_cem
drop if _merge==1
replace ui="null" if _merge==2
drop _merge
order pmid nlmid year nih
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace


cd D:\Research\RAWDATA\MEDLINE\2016\Processed\TextMetrics
use medline16_textmetrics_articlelevel_mentions, clear
keep if version==1
keep pmid ment_0_both_001 ment_3_both_001 ment_5_both_001 ment_10_both_001 ment_all_both_001 ment_0_both_0001 ment_3_both_0001 ment_5_both_0001 ment_10_both_0001 ment_all_both_0001 rank_both_mean pct_both_mean wordcount_both
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge 1:1 pmid using estsample_cem
drop if _merge==1
replace ment_0_both_001=0 if _merge==2
replace ment_3_both_001=0 if _merge==2
replace ment_5_both_001=0 if _merge==2
replace ment_10_both_001=0 if _merge==2
replace ment_all_both_001=0 if _merge==2
replace ment_0_both_0001=0 if _merge==2
replace ment_3_both_0001=0 if _merge==2
replace ment_5_both_0001=0 if _merge==2
replace ment_10_both_0001=0 if _merge==2
replace ment_all_both_0001=0 if _merge==2
replace wordcount_both=0 if _merge==2
drop _merge
order pmid nlmid year nih
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace


* Attach Open Access Info
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge m:1 nlmid using journal_oa
drop if _merge==2
drop _merge
order pmid nlmid year nih oa
gen flag_oaimputed=(oa==.)
replace oa=0 if oa==.
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace


cd D:\Research\Projects\NIHMandate\NIH14\Data
use article_backwardcites, clear
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge 1:1 pmid using estsample_cem
drop if _merge==1
drop _merge
replace bc_count=0 if bc_count==.
replace bc_oa_count=0 if bc_oa_count==.
order pmid nlmid year nih oa
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace


cd D:\Research\Projects\NIHMandate\NIH14\Data
use article_forwardcites, clear
keep pmid fc_*
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge 1:1 pmid using estsample_cem
drop if _merge==1
replace fc_2yr=0 if _merge==2
replace fc_oa_2yr=0 if _merge==2
replace fc_3yr=0 if _merge==2
replace fc_oa_3yr=0 if _merge==2
replace fc_oa_5yr=0 if _merge==2
replace fc_10yr=0 if _merge==2
replace fc_oa_10yr=0 if _merge==2
replace fc_allyr=0 if _merge==2
replace fc_oa_allyr=0 if _merge==2
drop _merge
order pmid nlmid year nih oa
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save estsample_cem, replace




set seed 1234
clear
gen pmid=.
cd D:\Research\Projects\NIHMandate\NIH14\Data
save cem_post_sample5, replace

set more off
forvalues h=2000/2013 {

	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use estsample_cem if year==`h',  clear
	sample 5
	gen ta=1-oa

	local backcites "bc_count bc_oa_count"
	local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
	local mesh "count_desc count_qual"
	local author "authortotal"
	local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"

	local spec1 `" `backcites'"'
	local spec2 `" `backcites' `ment'"'
	local spec3 `" `backcites' `ment' `mesh'"'
	local spec4 `" `backcites' `ment' `mesh' `author'"'
	local spec5 `" `backcites' `ment' `mesh' `author' `meshaug1'"'

	set mor off
	forvalues i=1/5 {
	
		display in red "----  Specification `i' in year `h' ----"

		imb `spec`i'', treatment(nih)
		gen base_L1_`i' = `r(L1)'
		cem `spec`i'', treatment(nih) showbreaks
		rename cem_strata cem_strata_`i'
		rename cem_matched cem_matched_`i'
		rename cem_weights cem_weights_`i'
		gen cem_L1_`i' = `r(L1)'
	}
	
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	append using cem_post_sample5
	save cem_post_sample5, replace
}



local n_strata = r(n_strata)
local n_groups = r(n_groups)
local n_mstrata = r(n_mstrata)
local n_matched = r(n_matched)
local L1 = r(L1)

local varlist = r(varlist)
local treatment = r(treatment)
local cem_call = r(cem_call)
local L1_breaks = r(L1_breaks)

display in red "`n_strata'"
display in red "`n_groups'"
display in red "`n_mstrata'"
display in red "`n_matched'"
display in red "`L1'"

display in red "`varlist'"
display in red "`treatment'"
display in red "`cem_call'"
display in red "`L1_breaks'"








gen post=(year>2008)
gen nih_post = nih*post

teffects psmatch (ta) (nih bc_count bc_oa_count ment_0_both_001), osample(newvar)
drop if newvar==1
drop newvar
teffects psmatch (ta) (nih bc_count bc_oa_count ment_0_both_001), osample(newvar)

teffects psmatch (ta) (nih_post nih post bc_count bc_oa_count ment_0_both_001), osample(newvar)


cd D:\Research\Projects\NIHMandate\NIH14\Data
use estsample_cem if year==2005,  clear
imb bc_count bc_oa_count ment_0_both_001 ment_3_both_001 ment_5_both_001 ment_10_both_001 ment_all_both_001 pt_* authortotal count_desc count_qual, treatment(nih)




. imb bc_count bc_oa_count ment_0_both_001 ment_3_both_001 ment_5_both_001 ment_10_both_00
> 1 ment_all_both_001 pt_* authortotal count_desc count_qual, treatment(nih)

Multivariate L1 distance: .99267064

Univariate imbalance:

                        L1     mean      min      25%      50%      75%      max
         bc_count   .40875   18.759        0       19       22       21     -609
      bc_oa_count   .09984   .20844        0        0        0        0     -203
  ment_0_both_001   .00717   .00882        0        0        0        0       -3
  ment_3_both_001   .03839    .0692        0        0        0        0      -22
  ment_5_both_001   .06594   .13779        0        0        0        0      -54
 ment_10_both_001     .164   .58327        0        0        0        1      -71
ment_all_both_001   .33001   9.8945        0        9       11       12      -66
            pt_ja   .08194   .08194        0        0        0        0        0
      pt_rsnnonus   .13938   .13938        0        0        0        0        0
           pt_rev    .0186   -.0186        0        0        0        0        0
        pt_engabs   .07303  -.07303        0        0        0        0        0
            pt_cr   .07256  -.07256        0        0        0        0        0
          pt_comp   .04004   .04004        0        0        0        0        0
            pt_ct   .00246   .00246        0        0        0        0        0
         pt_irreg   .09237  -.09237        0        0        0        0        0
      authortotal   .14326    .9759        0        1        1        1     -369
       count_desc   .22921   3.2906        0        3        3        3       -4
       count_qual   .20137    2.642        0        2        2        3       -6






cd D:\Research\Projects\NIHMandate\NIH14\Data
save test, replace


cem authortotal year (#14), treatment(nih) autocuts(fd)

logit nih authortotal

 teffects psmatch (bweight) (mbsmoke mmarried c.mage##c.mage fbaby medu)


