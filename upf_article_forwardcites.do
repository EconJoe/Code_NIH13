
* Obtain information on the NLMID and publication date of each MEDLINE article
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals\Clean
use medline16_journals, clear

cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Dates\Clean
merge 1:1 pmid version using medline16_all_dates
keep if version==1
keep pmid nlmid year
tempfile hold
save `hold', replace

* Obtain information on citing-cited relationships for PMIDs in WOS
cd B:\Research\RAWDATA\WOS
use pmidcites, clear

* Attach the NLMID and publication year to each *citing* PMID
rename pmid_citing pmid
merge m:1 pmid using `hold'
drop if _merge==2
drop _merge
rename pmid pmid_citing
rename year year_citing
rename nlmid nlmid_citing

rename pmid_cited pmid
merge m:1 pmid using `hold'
drop if _merge==2
drop _merge
rename pmid pmid_cited
rename year year_cited
rename nlmid nlmid_cited

rename nlmid_citing nlmid
cd D:\Research\NIH\NIH13\Data\UPF
merge m:1 nlmid using upf_oajournals
drop if _merge==2
drop _merge

* If a PMID does not have an NLMID, just assume the article is toll access. We are talking
*  a tiny fraction.
replace oa=0 if oa==.

* Reassign all citations that occured before an article was published to
*  the publication year. It may be possible for an article to receive
*  citations prior to publiation (e.g. working papers), but it is not
*  clear how to handle this. What is clear is that these SHOULD be counted
*  in the foroward citation measues, which they are.
replace year_citing=year_cited if year_citing<year_cited & year_cited!=.

set more off
local vals 2 3 5
foreach i in `vals' {
	gen _`i'yr=0
	replace _`i'yr=1 if year_citing<=year_cited+`i' & year_cited!=.
	by pmid_cited, sort: egen fc_`i'yr=total(_`i'yr)
	drop _`i'yr
	
	gen _`i'yr=0
	replace _`i'yr=1 if year_citing<=year_cited+`i' & year_cited!=. & oa==1
	by pmid_cited, sort: egen fc_oa_`i'yr=total(_`i'yr)
	drop _`i'yr
}

keep pmid_cited year_cited fc_*
duplicates drop

rename pmid_cited pmid
rename year_cited year
order pmid year
sort  pmid

compress
cd D:\Research\NIH\NIH13\Data\UPF
save upf_article_forwardcites, replace
