
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Dates\Clean
use medline16_all_dates, clear
keep if year>=2003 & year<=2013
keep pmid version year

cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals\Clean
merge 1:1 pmid version using medline16_journals
drop if _merge==2
drop _merge

cd D:\Research\NIH\NIH13\Data\UPF
merge m:1 pmid using upf_article_backwardcites
drop if _merge==2
drop _merge
*replace bc=0 if bc==.
*replace bc_oa=0 if bc_oa==.

cd D:\Research\NIH\NIH13\Data\UPF
merge m:1 pmid using upf_article_forwardcites
drop if _merge==2
drop _merge
replace fc_2yr=0 if fc_2yr==.
replace fc_oa_2yr=0 if fc_oa_2yr==.
replace fc_3yr=0 if fc_3yr==.
replace fc_oa_3yr=0 if fc_oa_3yr==.
replace fc_5yr=0 if fc_5yr==.
replace fc_oa_5yr=0 if fc_oa_5yr==.

cd D:\Research\NIH\NIH13\Data\UPF
merge 1:1 pmid version using upf_article_authorages
drop if _merge==2
drop _merge
 
cd D:\Research\NIH\NIH13\Data\UPF
merge 1:1 pmid version using upf_article_authorcohorts
drop if _merge==2
drop _merge
 
cd D:\Research\NIH\NIH13\Data\UPF
merge 1:1 pmid version using upf_article_pubtypes
drop if _merge==2
drop _merge

cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Authors\Clean
merge 1:1 pmid version using authorcount
drop if _merge==2
drop _merge

cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\MeSH\Clean
merge m:1 pmid using meshcount_all
drop if _merge==2
drop _merge
replace meshcount=0 if meshcount==.

cd D:\Research\NIH\NIH13\Data\UPF
merge m:1 nlmid using upf_journal_oa
drop if _merge==2
drop _merge

compress
cd D:\Research\NIH\NIH13\Data\Estimation
save estsample_medline, replace


cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Grants\Clean
use nihgrants_grants, clear
keep pmid version
duplicates drop
gen treated1=1
tempfile hold
save `hold', replace
use nihgrants_pubtype, clear
keep pmid version
duplicates drop
gen treated2=1
merge 1:1 pmid version using `hold'
replace treated1=0 if _merge==1
replace treated2=0 if _merge==2
drop _merge

cd D:\Research\NIH\NIH13\Data\Estimation
merge 1:m pmid version using estsample_medline
drop if _merge==1
replace treated1=0 if _merge==2
replace treated2=0 if _merge==2
drop _merge

compress
cd D:\Research\NIH\NIH13\Data\Estimation
save estsample_medline, replace

