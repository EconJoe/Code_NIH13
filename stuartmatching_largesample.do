
* This file computes estimates using open access indicator as the outcome variable.

cd D:\Research\Projects\NIHMandate\NIH15\Data
use estsample_large, clear
keep if year>=2000 & year<=2013
gen ta=1-oa
gen post=(year>2008)
gen nih=(nih_pubtype==1 | nih_grantlist==1)

reg ta i.nih##i.post i.year, cluster(ui4)

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"


local spec `"`match' `backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

gen tgroup=.
replace tgroup=1 if nih==1 & post==0
replace tgroup=2 if nih==1 & post==1
replace tgroup=3 if nih==0 & post==0
replace tgroup=4 if nih==0 & post==1

*keep tgroup `spec'
mlogit tgroup `spec'
forvalues i=1/4 {
	predict pr`i', outcome(#`i')
}
gen weight=.
forvalues i=1/4 {
	replace weight=pr1/pr`i' if tgroup==`i'
}


reg ta i.nih##i.post i.year, cluster(ui4)
reg ta i.nih##i.post i.year if weight<=2, cluster(ui4)

reg ta i.nih##i.post i.year [aweight=weight], cluster(ui4)
reg ta i.nih##i.post i.year [aweight=weight] if weight<=2, cluster(ui4)


gen tgroup2=.
replace tgroup2=1 if nih==1 & year==2000
replace tgroup2=2 if nih==1 & year==2001
replace tgroup2=3 if nih==1 & year==2002
replace tgroup2=4 if nih==1 & year==2003
replace tgroup2=5 if nih==1 & year==2004
replace tgroup2=6 if nih==1 & year==2005
replace tgroup2=7 if nih==1 & year==2006
replace tgroup2=8 if nih==1 & year==2007
replace tgroup2=9 if nih==1 & year==2008
replace tgroup2=10 if nih==1 & year==2009
replace tgroup2=11 if nih==1 & year==2010
replace tgroup2=12 if nih==1 & year==2011
replace tgroup2=13 if nih==1 & year==2012
replace tgroup2=14 if nih==1 & year==2013
replace tgroup2=15 if nih==0 & year==2000
replace tgroup2=16 if nih==0 & year==2001
replace tgroup2=17 if nih==0 & year==2002
replace tgroup2=18 if nih==0 & year==2003
replace tgroup2=19 if nih==0 & year==2004
replace tgroup2=20 if nih==0 & year==2005
replace tgroup2=21 if nih==0 & year==2006
replace tgroup2=22 if nih==0 & year==2007
replace tgroup2=23 if nih==0 & year==2008
replace tgroup2=24 if nih==0 & year==2009
replace tgroup2=25 if nih==0 & year==2010
replace tgroup2=26 if nih==0 & year==2011
replace tgroup2=27 if nih==0 & year==2012
replace tgroup2=28 if nih==0 & year==2013

local spec `"`match' `backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

*keep tgroup `spec'
mlogit tgroup2 `spec'
forvalues i=1/28 {
	predict pr`i', outcome(#`i')
}
gen weight=.
forvalues i=1/28 {
	replace weight=pr1/pr`i' if tgroup2==`i'
}
save temp2, replace


reg ta i.nih##i.post i.year [aweight=weight], cluster(ui4)

use temp2, clear
parmby "reg ta i.nih#i.year i.year [aweight=weight], cluster(ui4)", norestore
keep if regexm(parm, "1.nih#")
gen year = regexs(0) if regexm(parm, "[0-9][0-9][0-9][0-9]")
destring year, replace
twoway (connected estimate year)

predict pr1, outcome(#1)
predict pr2, outcome(#2)
predict pr3, outcome(#3)
predict pr4, outcome(#4)

gen weight=.
replace weight=pr1/pr1 if tgroup==1
replace weight=pr1/pr2 if tgroup==2
replace weight=pr1/pr3 if tgroup==3
replace weight=pr1/pr4 if tgroup==4

twoway (kdensity pr2 if nih==1 & post==1) ///
       (kdensity pr2 if nih==1 & post==0) ///
	   (kdensity pr2 if nih==0 & post==1) ///
	   (kdensity pr2 if nih==0 & post==0), ///
	   legend(order(1 "Treated After" 2 "Treated Before" 3 "Control After" 4 "Control Before"))

gen treated = (tgroup==2)
gsort -treated
keep if tgroup==1 | tgroup==2

keep pmid nih post pr2 tgroup
	   
	   
