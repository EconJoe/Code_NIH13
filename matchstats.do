

cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
use similar_grants_all, clear
keep if nihyear==

* Keep pairs with valid similar article
keep if validsimilar==1 | validsimilar_total==0
drop if validsimilar_total==0

keep nihpmid pmid
tempfile hold
save `hold', replace
use `hold', clear
keep nihpmid
rename nihpmid pmid
gen nih=1
tempfile hold2
save `hold2', replace
use `hold', clear
keep pmid
gen nih=0
append using `hold2'
duplicates drop

save test, replace

cd D:\Research\Projects\NIHMandate\NIH14\Data
use testmatched.dta, clear

cd D:\Research\Projects\NIHMandate\NIH14\Data
use testmatched.dta, clear
* Generate an internal ID for the pair
keep nihpmid similarpmid
tempfile hold
save `hold', replace

use `hold', clear
drop similarpmid
rename nihpmid pmid
gen nih=1
tempfile hold2
save `hold2', replace

use `hold', clear
drop nihpmid
rename similarpmid pmid
gen nih=0
append using `hold2'
compress


cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
merge 1:1 pmid using test
gen matched=(_merge==3)
drop _merge

cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
save matchstats, replace

tab nih matched



* Attach Date Information
cd D:\Research\RAWDATA\MEDLINE\2016\Processed
use medline16_dates_clean, clear
keep if version==1
keep pmid year
cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
merge 1:1 pmid using matchstats
drop if _merge==1
drop _merge

cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
save matchstats, replace







