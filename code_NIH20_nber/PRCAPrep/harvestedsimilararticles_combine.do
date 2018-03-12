

clear
gen nihpmid=.
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/PRCA/HarvestedSimilarArticles/
save harvestedsimilararticles, replace

set more off
forvalues i=1/100 {

	display in red "------ File `i' ------"

	cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/PRCA/HarvestedSimilarArticles/
	import delimited "harvestedsimilararticles_`i'.txt", clear delimiter(tab) varnames(1)
	keep if linkname=="pubmed_pubmed"
	keep nihpmid similarpmid similarityscore
	compress
	cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/PRCA/HarvestedSimilarArticles/
	append using harvestedsimilararticles
	save harvestedsimilararticles, replace
}


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
save `hold', replace
* Attach dates
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Processed/
use medline16_dates_clean, clear
keep if version==1
keep pmid year
merge 1:1 pmid using `hold'
gen nih=(_merge==3)
drop _merge
compress 
save `hold', replace

* Attach information to NIH and harvested ("Potential Comparison") articles
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/PRCA/HarvestedSimilarArticles/
use harvestedsimilararticles, clear
rename nihpmid pmid
merge m:1 pmid using `hold'
drop if _merge==2
drop _merge
rename year nihyear
rename pmid nihpmid
rename similarpmid pmid
drop nih
merge m:1 pmid using `hold'
drop if _merge==2
gen flag_similarnotmedline = (_merge==1)
drop _merge
rename year similaryear
rename pmid similarpmid
gen flag_similarisnih = (nih==1)
drop nih
gen flag_yearmismatch = (nihyear!=similaryear)

* A "valid" similar article is one that is:
*  1) In MEDLINE (flag_similarnotmedline==0)
*  2) The same year as the treated (flag_yearmismatch==0)
*  3) The similar article is NOT NIH (flag_similarisnih==0)
gen validsimilar = (flag_similarnotmedline==0 & flag_yearmismatch==0 & flag_similarisnih==0)
* Compute the total number of "valid" potential comparison articles
by nihpmid, sort: egen validsimilar_total=total(validsimilar)

compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/PRCA/HarvestedSimilarArticles/
save harvestedsimilararticles, replace



