
* Obtain raw DOAJ data and keep information on journal ISSN and the date on which the
*  journal was added to DOAJ.
cd D:\Research\NIH\NIH13\Data\Raw\DOAJ
import delimited "doaj_20160117_1200_utf8.csv", clear delimiter(comma) varnames(1)
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

* Identify instances in which a MEDLINE ISSN is included in the DOAJ
* If _merge==1, the journal is in DOAJ but not MEDLINE. This may be because it is a journal
*  from a different field.
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals\CrossWalks
joinby issn using medline16_journals_crosswalk_nlmid_issn, unmatched(both)
drop if _merge==1

* Identify which NLMIDs are open access (i.e. they have a corresponding ISSN included in DOAJ).
gen oa_=0
replace oa_=1 if _merge==3
by nlmid, sort: egen oa=max(oa_)

keep nlmid oa
duplicates drop

sort nlmid
compress
cd D:\Research\NIH\NIH13\Data\UPF
save upf_journal_oa, replace




