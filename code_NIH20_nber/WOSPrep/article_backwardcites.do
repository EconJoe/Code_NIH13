* This file

* Obtain information on the NLMID and publication date of each MEDLINE article
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Parsed/
import delimited "medline16_journals_nlmid.txt", clear delimiter(tab) varnames(1)

cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Processed/
merge 1:1 filenum pmid version using medline16_dates_clean
keep if version==1
keep pmid nlmid year
tempfile hold
save `hold', replace

cd /disk/bulkw/staudt/RAWDATA/WOS
use pmidcites, clear

* Attach the NLMID and publication year to each *citing* PMID
rename pmid_citing pmid
merge m:1 pmid using `hold'
drop if _merge==2
* _merge==1 means the PMID is in WOS but not MEDLINE. These may be PMIDs in Pubmed but not MEDLINE. Tiny fraction.
* _merge==2 means the PMID is in MEDLINE but not WOS. This is not really a problem, since WOS only runs through 2014.
drop _merge
rename pmid pmid_citing
rename year year_citing
rename nlmid nlmid_citing

* Attach the NLMID and publication year to each *cited* PMID
rename pmid_cited pmid
merge m:1 pmid using `hold'
* _merge==1 means the PMID is in WOS but not MEDLINE. These may be PMIDs in Pubmed but not MEDLINE. Tiny fraction.
* _merge==2 means the PMID is in MEDLINE but not WOS. This is not really a problem, since WOS only runs through 2014.
drop if _merge==2
drop _merge
rename pmid pmid_cited
rename year year_cited

* Attach the OA indicator to the CITED NLMID
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data
merge m:1 nlmid using journal_oa
drop if _merge==2
drop _merge

*order id pmid_citing nlmid_citing year_citing pmid_cited year_cited nlmid
*sort pmid_citing pmid_cited

set more off
* Compute the total number of backward citations 
gen bc_count_=1
by pmid_citing, sort: egen bc_count=total(bc_count_)
drop bc_count_

* Compute the total number of backward citations that are open access
by pmid_citing, sort: egen bc_oa_count=total(oa)

* Compute metrics characterizing the distribution of the age of the backward citation
gen age=year_citing-year_cited
replace age=0 if age<0
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
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data
save article_backwardcites, replace

