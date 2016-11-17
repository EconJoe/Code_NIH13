
set more off

cd D:\Research\RAWDATA\MEDLINE\2016\Processed
use mdeline2016_grants_nihgrants, clear
keep pmid
duplicates drop
tempfile hold
save `hold', replace

cd D:\Research\RAWDATA\MEDLINE\2016\Processed
use mdeline2016_pubtypes_nihgrants, clear
keep pmid
duplicates drop
append using `hold'
duplicates drop

set seed 1234
generate rannum = uniform()
egen group = cut(rannum), group(100)
replace group=group+1
tempfile temp
save `temp', replace

forvalues i=1/100 {
	
	display in red "----- `i' ------"
	use `temp' if group==`i', clear
	keep pmid
	
	duplicates drop
	cd D:\Research\Projects\NIHMandate\NIH14\Data\Groups
	export delimited using "nihpmids_group`i'.txt", delimiter(tab) novarnames replace
}
