
* Obtain grants from grant elements
cd D:\Research\RAWDATA\MEDLINE\2016\Processed
use mdeline2016_grants_nihgrants, clear
keep pmid version
duplicates drop
tempfile hold
save `hold', replace

* Obtain NIH grants from pubtype elements
cd D:\Research\RAWDATA\MEDLINE\2016\Processed
use mdeline2016_pubtypes_nihgrants, clear
keep pmid version
duplicates drop

append using `hold'
duplicates drop
save `hold', replace

* Merge with journal data
cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals
import delimited "medline16_nlmid.txt", clear delimiter(tab) varnames(1)
merge 1:1 pmid version using `hold'
gen nih=(_merge==3)
drop _merge
tempfile hold
save `hold', replace

* Merge with journal vintage data (e.g. volume, issue)
cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals
import delimited "medline16_vint.txt", clear delimiter(tab) varnames(1)
merge 1:1 pmid version using `hold'
drop _merge
save `hold', replace

* Merge with date data
cd D:\Research\RAWDATA\MEDLINE\2016\Processed
use medline16_dates_clean, clear
keep pmid version year
merge 1:1 pmid version using `hold'
drop _merge

* Identify journals that publish a NIH article in a given year
by nlmid year, sort: egen maxnih=max(nih)
keep if maxnih==1
drop maxnih
compress
* Identify different groups that may possible serve as control groups
egen yeargroup=group(nlmid year)
egen volumegroup=group(nlmid volume)
egen yearissuegroup=group(nlmid year issue)
egen volumeissuegroup=group(nlmid volume issue)

compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save journalcontrols, replace


use journalcontrols, clear
keep if version==1
keep pmid nih nlmid year yeargroup
* Identify and keep only group that has at least 1 treated observation
by yeargroup, sort: egen maxnih=max(nih)
keep if maxnih==1
drop maxnih
order yeargroup nlmid year pmid nih
sort yeargroup pmid
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save journalcontrols_yeargroup, replace

use journalcontrols, clear
keep if version==1
keep pmid nih nlmid year volume volumegroup
* Identify and keep only group that has at least 1 treated observation
by volumegroup, sort: egen maxnih=max(nih)
keep if maxnih==1
drop maxnih
order volumegroup nlmid volume year pmid nih
sort volumegroup pmid
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save journalcontrols_volumegroup, replace

use journalcontrols, clear
keep if version==1
keep pmid nih nlmid year issue yearissuegroup
* Identify and keep only group that has at least 1 treated observation
by yearissuegroup, sort: egen maxnih=max(nih)
keep if maxnih==1
drop maxnih
order yearissuegroup nlmid year issue pmid nih
sort yearissuegroup pmid
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save journalcontrols_yearissuegroup, replace

use journalcontrols, clear
keep if version==1
keep pmid nih nlmid year volume issue volumeissuegroup
* Identify and keep only group that has at least 1 treated observation
by volumeissuegroup, sort: egen maxnih=max(nih)
keep if maxnih==1
drop maxnih
order volumeissuegroup nlmid year volume issue pmid nih
sort volumeissuegroup pmid
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save journalcontrols_volumeissuegroup, replace





























use test, clear
keep pmid version nih volumeissuegroup
gsort volume -nih pmid version
by volumeissuegroup, sort: egen maxnih=max(nih)
keep if maxnih==1
drop maxnih
save test2, replace

use test2 if nih==1, clear
gen nihcount=1
collapse (sum) nihcount, by(volume)
tempfile hold
save `hold', replace

use test2 if nih==0, clear
merge m:1 volumeissuegroup using `hold'
drop if _merge==2
drop _merge
set seed 1234
gen rand1=runiform()
gen rand2=runiform()
sort volumeissuegroup rand1 rand2
by volumeissuegroup, sort: gen rank=_n
keep if rank<=nihcount
keep pmid version nih volume


gen count=1
by volumeissuegroup, sort: egen total=total(count)

gen test=total
replace test=10 if test>=10


