
* This file

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

* Attach the NLMID and publication year to each *cited* PMID
rename pmid_cited pmid
merge m:1 pmid using `hold'
drop if _merge==2
drop _merge
rename pmid pmid_cited
rename year year_cited

cd D:\Research\NIH\NIH13\Data\UPF
merge m:1 nlmid using upf_oajournals
drop if _merge==2
drop _merge

* Reassign all citations that occured before an article was published to
*  the publication year. It may be possible for an article to receive
*  citations prior to publiation (e.g. working papers), but it is not
*  clear how to handle this. What is clear is that these SHOULD be counted
*  in the foroward citation measues, which they are.
replace year_citing=year_cited if year_citing<year_cited & year_cited!=.

* Compute the total number of backward citations 
gen bc_count_=1
by pmid_citing, sort: egen bc_count=total(bc_count_)
drop bc_count_

* Compute the total number of backward citations that are open access
by pmid_citing, sort: egen bc_oa_count=total(oa)

* Compute metrics characterizing the distribution of the age of the backward citation
gen age=year_citing-year_cited
by pmid_citing, sort: egen bc_age_mean=mean(age)
by pmid_citing, sort: egen bc_age_median=median(age)
by pmid_citing, sort: egen bc_age_sd=sd(age)
by pmid_citing, sort: egen bc_age_min=min(age)
by pmid_citing, sort: egen bc_age_max=max(age)

* Compute metrics characterizing the distribution of publication year of the backward citations
by pmid_citing, sort: egen bc_year_mean=mean(year_cited)
by pmid_citing, sort: egen bc_year_median=median(year_cited)
by pmid_citing, sort: egen bc_year_sd=sd(year_cited)
by pmid_citing, sort: egen bc_year_min=min(year_cited)
by pmid_citing, sort: egen bc_year_max=max(year_cited)

keep pmid_citing bc_*
duplicates drop

rename pmid_citing pmid
sort pmid
compress
cd D:\Research\NIH\NIH13\Data\UPF
save upf_article_backwardcites, replace


