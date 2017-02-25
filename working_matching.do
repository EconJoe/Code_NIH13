

cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
use similar_grants_all, clear

* Keep pairs with valid similar article (or articles with no potential controls)
keep if validsimilar==1 | validsimilar_total==0
drop if validsimilar_total==0
rename nihyear year
drop similaryear
gsort nihpmid -similarityscore
duplicates tag similarpmid, gen(similar_count)
replace similar_count=similar_count+1
gen similar_weight=1/(similar_count)
drop flag_* validsimilar

egen groupid = group(nihpmid)
order groupid

cd D:\Research\Projects\NIHMandate\NIH14\Data
save matched_all, replace

use matched_all, clear
rename nihpmid pmid
keep groupid pmid year validsimilar_total
duplicates drop
gen nih=1
gen similar_weight=1
gen similar_count=1
tempfile hold
save `hold', replace

use matched_all, clear
rename similarpmid pmid
keep groupid pmid year validsimilar_total similar_weight similar_count
gen nih=0
append using `hold'

gsort groupid -nih
cd D:\Research\Projects\NIHMandate\NIH14\Data
save matched_all, replace

* Attach NLMID to each PMID
cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals
import delimited "medline16_nlmid.txt", clear delimiter(tab) varnames(1)
keep if version==1
keep pmid nlmid
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge 1:m pmid using matched_all
drop if _merge==1
drop _merge
cd D:\Research\Projects\NIHMandate\NIH14\Data
save matched_all, replace

* Attach Open Access Info
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge m:1 nlmid using journal_oa
drop if _merge==2
drop _merge
gen flag_oaimputed=(oa==.)
replace oa=0 if oa==.
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save matched_all, replace

cd D:\Research\Projects\NIHMandate\NIH14\Data
use matched_all, clear
cd D:\Research\Projects\NIHMandate\NIH15\Data
merge m:1 pmid using estsample_large
drop if _merge==2
drop _merge
cd D:\Research\Projects\NIHMandate\NIH14\Data
save matched_all, replace


cd D:\Research\Projects\NIHMandate\NIH14\Data
use matched_all, clear
keep if year>=2000 & year<=2013
gen post=(year>2008)
gen ta=1-oa

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"

local spec `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

logit nih `spec' i.year [fweight=similar_weight]
predict pr
order pr
gen control_pr=pr if nih==0
gen treated_pr=pr if nih==1
by groupid, sort: egen max_treated_pr=max(treated_pr)
drop treated_pr
gen dist = abs(max_treated_pr-control_pr)
by groupid, sort: egen min_dist_pr=min(dist)
keep if (nih==1) | (nih==0 & dist==min_dist_pr)

histogram pr, by(nih)

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"

local spec `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

reg ta i.nih##i.post i.year
reg ta i.nih##i.post i.year `spec'


parmby "reg ta i.nih#i.year i.year `spec', cluster(ui4)", norestore
keep if regexm(parm, "1.nih#")
gen year = regexs(0) if regexm(parm, "[0-9][0-9][0-9][0-9]")
destring year, replace
twoway(connected estimate year), ///
		xlabel(2000(1)2013, angle(forty_five)) ///
		xline(2008) ///
		xtitle("Year")

forvalues i=1/5 {
	
	twoway (rarea max min year if spec1==`i' & spec2=="OLS" & weighted=="No", fcolor(ltblue) fintensity(10) lwidth(none) lcolor(ltblue)) ///
		   (connected estimate year if spec1==`i' & spec2=="OLS" & weighted=="No", lcolor(navy) mcolor(navy) msymbol(circle_hollow)) ///
		   (connected estimate year if spec1==`i' & spec2=="Raw MeSH FE" & weighted=="No", lcolor(navy) mcolor(navy) msymbol(triangle_hollow)) ///
		   (connected estimate year if spec1==`i' & spec2=="Agg MeSH FE" & weighted=="No", lcolor(navy) mcolor(navy) msymbol(square_hollow)), ///
			xlabel(2000(1)2013, angle(forty_five)) ///
			xline(2008) ///
			xtitle("Year") ///
			ytitle("") ///
			legend(off) ///
			graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph export "D:\Research\Projects\NIHMandate\NIH14\Output\tacoeff_`i'.pdf", as(pdf) replace





reg ta i.nih##i.post i.year [aweight=similar_weight]
reg ta i.nih##i.post i.year `spec' [aweight=similar_weight]






cd D:\Research\Projects\NIHMandate\NIH14\Data
use matched_all, clear
keep if year>=2000 & year<=2013
gen post=(year>2008)
gen ta=1-oa
save temp, replace

clear
gen pmid=.
save ps_hold, replace

set more off
forvalues i=2000/2013 {

	display in red "---- Year `i'-------"

	use temp if year==`i', clear

	local backcites "bc_count bc_oa_count"
	local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
	local mesh "count_desc count_qual"
	local author "authortotal"
	local pubtype "pt_*"
	local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"

	local spec `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

	logit nih `spec' [fweight=similar_count]
	predict pr
	rename pr pr_weighted
	
	*logit nih `spec'
	*predict pr
	*rename pr pr_notweighted
	
	append using ps_hold
	save ps_hold, replace
}

use ps_hold, clear
gen control_pr=pr if nih==0
gen treated_pr=pr if nih==1
by groupid, sort: egen max_treated_pr=max(treated_pr)
drop treated_pr
gen dist_pr = abs(max_treated_pr-control_pr)
by groupid, sort: egen min_dist_pr=min(dist_pr)
keep if (nih==1) | (nih==0 & dist==min_dist_pr)


local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"

local spec `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

reg ta i.nih##i.post i.year, cluster(ui4)
reg ta i.nih##i.post i.year `spec', cluster(ui4)

histogram pr, by(nih)

use temp if year==2000, clear
psmatch2 nih bc_count, out(ta) logit




