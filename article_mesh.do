

cd D:\Research\Projects\NIHMandate\NIH14\Data
use meshfreq, clear
by ui, sort: egen meshvintage=min(year)
order ui meshvintage
keep ui meshvintage year meshcount_desc_all meshcount_desc_maj

* Compute the running cumulative sum.
local vars meshcount_desc_all meshcount_desc_maj
foreach var in `vars' {
	sort ui year
	bysort ui: gen cum_`var' = sum(`var')
}
label var meshcount_desc_all "Articles using Descriptor in given year"
label var meshcount_desc_maj "Articles using Descriptor as major topic in given year"
label var cum_meshcount_desc_all "Articles EVER using Descriptor"
label var cum_meshcount_desc_maj "Articles EVER using Descriptor as major topic"
cd D:\Research\Projects\NIHMandate\NIH14\Data
save meshfreq_temp, replace

cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\MeSH
import delimited "medline16_mesh_ui.txt", clear varnames(1) delimiter(tab)
cd D:\Research\RAWDATA\MEDLINE\2016\Processed
merge m:1 filenum pmid version using medline16_dates_clean
keep filenum pmid version meshorder ui majortopic type meshgroup year
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge m:1 ui year using meshfreq_temp
drop _merge

* Identify article-level major topics.
gen major=0
replace major=1 if majortopic=="Y"
drop majortopic
by pmid version meshgroup, sort: egen groupmajor=total(major)
order major

* Rename to conform with Stata name requirements
rename meshcount_desc_all mc_d_all
rename meshcount_desc_maj mc_d_maj
rename cum_meshcount_desc_all cum_mc_d_all
rename cum_meshcount_desc_maj cum_mc_d_maj

keep if type=="Descriptor" | type=="null"
compress
keep pmid version year groupmajor ui type meshvintage mc_d_all mc_d_maj cum_mc_d_all cum_mc_d_maj
cd D:\Research\Projects\NIHMandate\NIH14\Data
save articlemesh_temp, replace

set more off
local metrics mean median max min
foreach metric in `metrics' {

	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use articlemesh_temp, clear
	
	rename mc_d_all `metric'_arttot_mc_d_all
	rename mc_d_maj `metric'_arttot_mc_d_maj
	rename cum_mc_d_all `metric'_arttot_cum_mc_d_all
	rename cum_mc_d_maj `metric'_arttot_cum_mc_d_maj
	
	gen `metric'_artmaj_mc_d_all=`metric'_arttot_mc_d_all if groupmajor==1
	gen `metric'_artmaj_mc_d_maj=`metric'_arttot_mc_d_maj if groupmajor==1
	gen `metric'_artmaj_cum_mc_d_all=`metric'_arttot_cum_mc_d_all if groupmajor==1
	gen `metric'_artmaj_cum_mc_d_maj=`metric'_arttot_cum_mc_d_maj if groupmajor==1

	rename meshvintage `metric'_arttot_meshvintage
	gen `metric'_artmaj_meshvintage=`metric'_arttot_meshvintage if groupmajor==1

	collapse (`metric') `metric'_*, by(pmid version) fast
	compress
	sort pmid version
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	save article_mesh_`metric', replace
}

