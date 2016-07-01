
* NOTE: Early versions of this file computed the age of backward citations. However, many CITING PMIDs did not
*       actually cite anything, and so the backward citation ages are undefined for many articles. Thus, we 
*       decided not to compute these metrics.


* Obtain information on the NLMID and publication date of each MEDLINE article
* medline16_journals.dta is a list of all NLMIDs associated with each PMID.
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals\Clean
use medline16_journals, clear
keep if version==1
keep pmid nlmid
rename pmid pmid_cited

cd B:\Research\RAWDATA\WOS
merge 1:1 pmid_cited using pmid_cited
* _merge==1 means that the CITED PMID is in MEDLINE but not in WOS. This means that the PMID is never actually
*  cited by another PMID in WOS. Definitely drop these because they are never part of backward citations for any
*  PMID.
* _merge==2 means that the CITED PMID is in WOS but not in MEDLINE. This may be due to PMIDs
*  in PubMed only, but not in MEDLINE. This causes a problem because we cannot link any information
*  from MEDLINE (such as NLMID) to these CITED PMIDs.
drop if _merge==1
drop _merge

cd D:\Research\Projects\NIHMandate\NIH13\Data\UPF
merge m:1 nlmid using upf_journal_oa
* _merge==2 means that the journal is indexed in DOAJ, but not in our data. This may be due to the fact that
*  DOAJ indexes journals outside of the life sciences. We drop these.
drop if _merge==2
drop _merge

* Denote missing values of the OA indicator with a -1. These arise for CITED PMIDs that are in WOS but not MEDLINE
*  (see above).
replace oa=-1 if oa==.

rename nlmid nlmid_cited
rename oa oa_cited

tempfile hold
save `hold', replace

* Obtain information on the publication date of each MEDLINE article.
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Dates\Clean
use medline16_all_dates, clear
keep if version==1
* Restrict the data to the years of analysis. This just avoids clutter and saves RAM. Also, since WOS data
*  starts in 1950, it avoids the problem of knnowing whether a miss is due to lack of indexing or being outside
*  of date range.
keep if year>=2000 & year<=2014
keep pmid

rename pmid pmid_citing
* Obtain information on citing-cited relationships for PMIDs in WOS.
cd B:\Research\RAWDATA\WOS
merge 1:m pmid_citing using pmidcites
* _merge==1 means that the CITING PMID is in MEDLINE but is not in WOS. We interpret this as meaning the CITING
*  PMID did not actually cite any other PMID. We drop these for now (to save RAM), but will add them back in
*  at the end.
* _merge==2 means that the CITING PMID is in WOS but not MEDLINE. This is partyly due to restrictions on years for
*  MEDLINE PMIDs that we imposed above. Definitely drop these.
drop if _merge==1
drop if _merge==2
drop _merge

cd D:\Research\Projects\NIHMandate\NIH13
merge m:1 pmid_cited using `hold'
* _merge==2 is mostly due to year restrictions. Drop these.
drop if _merge==2
drop _merge

gen bc_all=1
gen bc_oa_max1=oa_cited
replace bc_oa_max1=1 if oa_cited==-1
gen bc_oa_max0=oa_cited
replace bc_oa_max0=0 if oa_cited==-1

collapse (sum) bc_all bc_oa*, by(pmid_citing) 
save `hold', replace

* Obtain information on the NLMID and publication date of each MEDLINE article
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Dates\Clean
use medline16_all_dates, clear
keep if version==1
keep if year>=2000 & year<=2014
keep pmid year
rename pmid pmid_citing
rename year year_citing

cd D:\Research\Projects\NIHMandate\NIH13
merge 1:1 pmid_citing using `hold'
drop _merge
replace bc_all=0 if bc_all==. 
replace bc_oa_max1=0 if bc_oa_max1==. 
replace bc_oa_max0=0 if bc_oa_max0==. 

rename pmid_citing pmid
rename year_citing year
sort pmid
compress

cd D:\Research\Projects\NIHMandate\NIH13\Data\UPF
save upf_article_backwardcites, replace

 
 
