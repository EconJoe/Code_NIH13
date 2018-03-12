
set more off

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/
use samples_comparison, clear
gen nih=(grant_countnih>0 | pt_nih==1)
gen ta=1-oa
keep pmid sample_* year nih ta fc_2yr

tempfile hold
save `hold', replace

clear
gen year=.
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output/Graphs
save commontrends, replace

set more off
local samples `" "medline" "journal" "prca_full" "prca_1to1" "'
*local samples `" "prca_1to1" "'
foreach sample in `samples' {

	use `hold' if sample_`sample'==1, clear
	gen fc_2yr_oa = fc_2yr if ta==0
	gen fc_2yr_ta = fc_2yr if ta==1
	collapse (mean) ta fc_2yr_*, by(year nih) fast
	tempfile samplehold
	save `samplehold', replace
	gen sample="`sample'"
	append using commontrends
	save commontrends, replace
}

use commontrends, clear
gen order=.
replace order=1 if sample=="medline"
replace order=2 if sample=="journal"
replace order=3 if sample=="prca_full"
replace order=4 if sample=="prca_1to1"
label define samplenames 1 "MEDLINE" 2 "Journal" 3 "PRCA Full" 4 "PRCA 1-to-1"
label values order samplenames   
drop sample
rename order sample


twoway (connected ta year if nih==1 & year<=2007, msymbol(circle_hollow)) ///
       (connected ta year if nih==0 & year<=2007, msymbol(triangle_hollow)), ///
	   xlabel(2003(1)2007, angle(forty_five)) ///
	   xtitle("") ytitle("") ///
	   legend(order(1 "NIH" 2 "Comparison")) ///
	   by(sample, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) subtitle(, nobox)
graph export "commontrends_preyears_ta.pdf", as(pdf) replace

twoway (connected fc_2yr_oa year if nih==1 & year<=2007, msymbol(circle_hollow)) ///
       (connected fc_2yr_oa year if nih==0 & year<=2007, msymbol(triangle_hollow)) ///
	   (connected fc_2yr_ta year if nih==1 & year<=2007, msymbol(circle)) ///
       (connected fc_2yr_ta year if nih==0 & year<=2007, msymbol(triangle)), ///
	   xlabel(2003(1)2007, angle(forty_five)) ///
	   xtitle("") ytitle("") ///
	   legend(order(1 "NIH OA" 2 "Comparison OA" 3 "NIH TA" 4 "Comparison TA")) ///
	   by(sample, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) subtitle(, nobox)
graph export "commontrends_preyears_fc_2yr.pdf", as(pdf) replace
