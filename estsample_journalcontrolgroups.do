
set more off
local groups volumeissuegroup yearissuegroup volumegroup yeargroup
foreach group in `groups' {

	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use journalcontrols_`group', replace
	
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

	****************************************************************************************************************
	************************* ATTACH MEDLINE INFO ******************************************************************
	****************************************************************************************************************

	* Attach NLMID to each PMID
	cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals
	import delimited "medline16_nlmid.txt", clear delimiter(tab) varnames(1)
	keep if version==1
	keep pmid nlmid
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge 1:1 pmid using estsample_`group'
	drop if _merge==1
	drop _merge
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

	* Attach Date Information
	cd D:\Research\RAWDATA\MEDLINE\2016\Processed
	use medline16_dates_clean, clear
	keep if version==1
	keep pmid year
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge 1:1 pmid using estsample_`group'
	drop if _merge==1
	drop _merge
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

	* Add publication type dummies
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use article_pubtypedummies, clear
	keep if version==1
	keep pmid pt_*
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge 1:1 pmid using estsample_`group'
	drop if _merge==1
	drop _merge
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

	* Add author counts
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use article_authortotal, clear
	keep if version==1
	keep pmid authortotal
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge 1:1 pmid using estsample_`group'
	drop if _merge==1
	drop _merge
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

	* Add counts of MeSH terms
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use meshcount, clear
	keep if version==1
	keep pmid count_*
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge 1:1 pmid using estsample_`group'
	drop if _merge==1
	drop _merge
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use article_mesh_mean, clear
	keep if version==1
	drop mean_artmaj_*
	keep pmid mean_*
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge 1:1 pmid using estsample_`group'
	drop if _merge==1
	drop _merge
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use article_mesh_median, clear
	keep if version==1
	drop median_artmaj_*
	keep pmid median_*
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge 1:1 pmid using estsample_`group'
	drop if _merge==1
	drop _merge
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use article_mesh_max, clear
	keep if version==1
	drop max_artmaj_*
	keep pmid max_*
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge 1:1 pmid using estsample_`group'
	drop if _merge==1
	drop _merge
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use article_mesh_min, clear
	keep if version==1
	drop min_artmaj_*
	keep pmid min_*
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge 1:1 pmid using estsample_`group'
	drop if _merge==1
	drop _merge
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

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
	merge 1:1 pmid using estsample_`group'
	drop if _merge==1
	replace ui4="null" if _merge==2
	replace flag_ui4count=0 if _merge==2
	drop _merge
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use article_meshfieldraw, clear
	keep if version==1
	keep pmid ui
	merge 1:1 pmid using estsample_`group'
	drop if _merge==1
	replace ui="null" if _merge==2
	drop _merge
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace


	cd D:\Research\RAWDATA\MEDLINE\2016\Processed\TextMetrics
	use medline16_textmetrics_articlelevel_mentions, clear
	keep if version==1
	keep pmid ment_0_both_001 ment_3_both_001 ment_5_both_001 ment_10_both_001 ment_all_both_001 ment_0_both_0001 ment_3_both_0001 ment_5_both_0001 ment_10_both_0001 ment_all_both_0001 rank_both_mean pct_both_mean wordcount_both
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge 1:1 pmid using estsample_`group'
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
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace


	* Attach Open Access Info
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge m:1 nlmid using journal_oa
	drop if _merge==2
	drop _merge
	gen flag_oaimputed=(oa==.)
	replace oa=0 if oa==.
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use article_backwardcites, clear
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge 1:1 pmid using estsample_`group'
	drop if _merge==1
	drop _merge
	replace bc_count=0 if bc_count==.
	replace bc_oa_count=0 if bc_oa_count==.
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace

	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use article_forwardcites, clear
	keep pmid fc_*
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	merge 1:1 pmid using estsample_`group'
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
	gsort `group' -nih
	order `group' pmid nlmid year nih
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save estsample_`group', replace
}
