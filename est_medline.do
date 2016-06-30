
cd D:\Research\NIH\NIH13\Data\Estimation
use estsample_medline, clear

gen post=0
replace post=1 if year>2008

set more off
reg oa treated1##post i.year bc_* fc_* age_* startyear_* pt_* authortotal meshcount, cluster(nlmid)

set more off
reg oa treated1##post i.year bc_* age_* startyear_* pt_* authortotal meshcount, cluster(nlmid)


local vars pubcount_3 pubcount_oa_3 art_bc art_bc_oa authortotal meshcount age_all_mean age_1st age_last
foreach i in `vars' {
	forvalues j=1/5 {
		gen `i'_`j'=`i'^`j'
	}
}

set more off
reg oa treated1##post i.year, cluster(ui)
areg oa treated1##post i.year, absorb(ui) cluster(ui)

set more off
reg oa treated1##post pt_* i.year, cluster(ui)
areg oa treated1##post pt_* i.year, absorb(ui) cluster(ui)

set more off
reg oa treated1##post bc bc_oa pt_* i.year, cluster(ui)
areg oa treated1##post bc bc_oa pt_* i.year, absorb(ui) cluster(ui)

reg oa treated post treated_post fc_5yr_tot_3_* pubcount_3_* pubcount_oa_3_* art_bc_* art_bc_oa_* authortotal_* meshcount_* i.year, cluster(nlmid)
logit oa treated post treated_post i.year, cluster(nlmid)
margins, dydx(treated_post) post
logit oa treated post treated_post fc_5yr_tot_3_* pubcount_3_* pubcount_oa_3_* art_bc_* art_bc_oa_* authortotal_* meshcount_* i.year, cluster(nlmid)
margins, dydx(treated_post) post



reg oa treated1#year i.year bc_* fc_* age_* startyear_* pt_* authortotal meshcount, cluster(nlmid)


parmby "reg oa treated1#year i.year bc_* fc_* age_* startyear_* pt_* authortotal meshcount", norestore
keep if regexm(parm, "1\.treated1#")
gen year=regexs(1) if regexm(parm, "1\.treated1#([0-9][0-9][0-9][0-9])")
destring year, replace
sort year



twoway (scatter estimate year, color(black)), ///
		xtitle(Year) ///
		xlabel(2003(1)2013, angle(forty_five)) ///
		xline(2008) ///
		legend(off)

		

parmby "reg oa treated1#year i.year", norestore
keep if regexm(parm, "1\.treated1#")
gen year=regexs(1) if regexm(parm, "1\.treated1#([0-9][0-9][0-9][0-9])")
destring year, replace
sort year
		
		