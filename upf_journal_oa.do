
* Obtain raw DOAJ data and keep information on journal ISSN and the date on which the
*  journal was added to DOAJ.
cd D:\Research\Projects\NIHMandate\NIH13\Data\Raw\DOAJ
import delimited "doaj_20160117_1200_utf8.csv", clear delimiter(comma) varnames(1)
* We want to keep the ISSNs because this is how we will connect this data to the NLMIDs in MEDLINE.
* We want to keep the added on date as a control variable.
keep journalissnprintversion journaleissnonlineversion addedondate
gen yearadded=regexs(1) if regexm(addedondate, "^([0-9][0-9][0-9][0-9])")
destring yearadded, replace
drop addedondate
tempfile hold
save `hold', replace

* Rearrage data so that each observation is characterized by a unique ISSN
use `hold', clear
rename journalissnprintversion issn
drop journaleissnonlineversion
tempfile hold2
save `hold2', replace

use `hold', clear
rename journaleissnonlineversion issn
drop journalissnprintversion
append using `hold2'
drop if issn==""

duplicates drop issn, force
* Now we have a list of observations uniquely defined by an ISSN. All of these ISSNs are  associated
*   with a journal that is open access.

* Identify instances in which a MEDLINE ISSN is included in the DOAJ
* The file medline16_journals_crosswalk_nlmid_issn.dta is a file that lists the Electronic,
*  Print, and Linking ISSN associated with each NLMID in the MEDLINE 2016 Baseline files.
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals\CrossWalks
joinby issn using medline16_journals_crosswalk_nlmid_issn, unmatched(both)
drop if _merge==1

* If _merge==1, the journal is in DOAJ but not MEDLINE. This may be because it is a journal
*  from a different field. Drop these.
* If _merge==2, the journal is in MEDLINE but not in DOAJ. We interpret this as meaning the
*  journal is NOT open access. An alternative is that the journal is open access, but has not 
*  been listed in DOAJ for some reason.
* If _merge==3, the journal is in BOTH MEDLINE AND DOAJ. We interpret this as meaning the journal
*  IS open access. An alternative is that the journal is NOT open access, and there is a mistake in
*  DOAJ.

* Identify which NLMIDs are open access (i.e. they have a corresponding ISSN included in DOAJ).
gen oa_=0
replace oa_=1 if _merge==3
by nlmid, sort: egen oa=max(oa_)

keep nlmid oa
duplicates drop
* We now have a list of observations uniquely identified by an NLMID. Each NLMID is tagged with whether
*  it is or is not an open access journal.

sort nlmid
compress
cd D:\Research\Projects\NIHMandate\NIH13\Data\UPF
save upf_journal_oa, replace




