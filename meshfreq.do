
cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\MeSH
import delimited "medline16_mesh_ui.txt", clear delimiter(tab) varnames(1)
keep filenum pmid version ui majortopic type meshgroup

cd D:\Research\RAWDATA\MEDLINE\2016\Processed
merge m:1 filenum pmid version using medline16_dates_clean

gen major=0
replace major=1 if majortopic=="Y"
drop majortopic
by pmid version meshgroup, sort: egen groupmajor=total(major)
keep pmid version ui year type major

set more off

gen meshcount_total_all=1
gen meshcount_desc_all = (type=="Descriptor")
gen meshcount_qual_all = (type=="Qualifier")

gen meshcount_total_maj = (major==1)
gen meshcount_desc_maj = (type=="Descriptor" & major==1)
gen meshcount_qual_maj = (type=="Qualifier" & major==1)

gen meshcount_total_min = (major==0)
gen meshcount_desc_min = (type=="Descriptor" & major==0)
gen meshcount_qual_min = (type=="Qualifier" & major==0)

collapse (sum) meshcount_*, by(ui year) fast

sort ui year
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save meshfreq, replace
