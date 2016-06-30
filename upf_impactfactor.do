
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Dates\Clean
use medline16_all_dates, clear
keep if version==1
keep pmid year
tempfile hold
save `hold', replace

cd B:\Research\RAWDATA\WOS
use pmidcites, clear
rename pmid_citing pmid
merge m:1 pmid using `hold'
drop if _merge==2
drop _merge
rename pmid pmid_citing
rename year year_citing
rename pmid_cited pmid
merge m:1 pmid using `hold'
drop if _merge==2
drop _merge
rename pmid pmid_cited
rename year year_cited

* Reassign all citations that occured before an article was published to
*  the publication year. It may be possible for an article to receive
*  citations prior to publiation (e.g. working papers), but it is not
*  clear how to handle this. What is clear is that these SHOULD be counted
*  in the foroward citation measues, which they are.
replace year_citing=year_cited if year_citing<year_cited & year_cited!=.

gen cites=1
collapse (sum) cites, by(pmid_cited year_cited year_citing)
sort pmid_cited year_citing
order pmid_cited year_cited
keep if year_cited+2>=year_citing
rename pmid_cited pmid

compress
cd D:\Research\NIH\NIH13\Data\UPF
save upf_impactfactor, replace





cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals\Clean
use medline16_journals, clear
keep if version==1
keep pmid nlmid
tempfile hold
save `hold', replace

cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Dates\Clean
use medline16_all_dates, clear
keep if version==1
keep pmid year
merge 1:1 pmid using `hold'
drop _merge

by nlmid, sort: egen jstartyear=min(year)
by nlmid, sort: egen jendyear=max(year)
keep nlmid jstartyear jendyear
duplicates drop

tempfile hold
save `hold', replace

clear
set obs 208
gen year=_n+1808

cross using `hold'
drop if year<jstartyear
drop if year>jendyear
order nlmid year
sort nlmid year


drop if _merge==2
drop _merge
