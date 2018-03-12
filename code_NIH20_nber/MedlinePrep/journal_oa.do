
* Obtain raw DOAJ data and keep information on journal ISSN and the date on which the
*  journal was added to DOAJ.
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/
import delimited "doaj_20161104_2100_utf8.csv", clear delimiter(comma) varnames(1)
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
duplicates drop

* Identify instances in which a MEDLINE ISSN is included in the DOAJ
* If _merge==1, the journal is in DOAJ but not MEDLINE. This may be because it is a journal
*  from a different field.
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Processed/
merge 1:m issn using medline16_nlmid_issn_xwalk
drop if _merge==1
* _merge==1 means the ISSN is in DOAJ but not in MEDLINE. This is fine since DOAJ covers many
*  fields and MEDLINE is only life sciences.

* Identify which NLMIDs are open access (i.e. they have a corresponding ISSN included in DOAJ).
gen oa = (_merge==3)
collapse (max) oa, by(nlmid) fast

sort nlmid
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/
save journal_oa, replace




