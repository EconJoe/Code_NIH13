
*********************************************************************************************************************
*********************************************************************************************************************
* This section of the code uses info from the grant list to identify NIH-supporteda articles
* The purpose is to create a set of 100 input files to harvest similar articles for each NIH file using the PRCA
* We break them into 100 files so we can process small groups at a time so as not to overwhelm the NIH server.
*   Also, if something goes wrong, we don't have to start from scratch.

clear
set more off

cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Parsed/
import delimited "medline16_grants.txt", clear delimiter(tab) varnames(1)
* Keep if the the NIH is listed as one of the funding agencies
keep if regexm(agency, "NIH")
keep pmid
duplicates drop
* It turns out that some grants reaaly are repeated on some articles.
* For instance, see file 375 PMID 8526461
tempfile hold
save `hold', replace
* This section of the code uses info from the publication type list to identify NIH-supporteda articles
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Parsed/
import delimited "medline16_pubtypes.txt", clear delimiter(tab) varnames(1)
keep if ui=="D052061" | ui=="D052060"
keep pmid
duplicates drop
append using `hold'
duplicates drop

* This randomizatino is not crucial. Our plan is to harvest similar articles for all 2,050,044 NIH articles.
*   However, to get preliminary results, we just want random samples.
set seed 1234
generate rannum = uniform()
egen group = cut(rannum), group(100)
replace group=group+1
tempfile temp
save `temp', replace

set more off
forvalues i=1/100 {
	
	display in red "----- `i' ------"
	use `temp' if group==`i', clear
	keep pmid
	
	duplicates drop
	cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/PRCA/NIHGroups/
	export delimited using "nihpmids_group`i'.txt", delimiter(tab) novarnames replace
}

