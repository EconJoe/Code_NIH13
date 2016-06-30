
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\MeSH\Clean
use medline16_mesh_all, clear
drop if type=="Qualifier"
keep pmid version ui

cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Dates\Clean
merge m:1 pmid version using medline16_all_dates
drop _merge
keep if year>=2003 & year<=2013
keep pmid version ui year

cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals\Clean
merge m:1 pmid version using medline16_journals
drop if _merge==2
drop _merge

cd D:\Research\NIH\NIH13\Data\UPF
merge m:1 pmid version using upf_articlepubtypes
drop if _merge==2
drop _merge

cd D:\Research\NIH\NIH13\Data\UPF
merge m:1 pmid using upf_backwardcites_journals
drop if _merge==2
drop _merge
replace bc=0 if bc==.
replace bc_oa=0 if bc_oa==.

cd D:\Research\NIH\NIH13\Data\UPF
merge m:1 pmid using upf_forwardcites_journals
drop if _merge==2
drop _merge
replace fc_2yr=0 if fc_2yr==.
replace fc_3yr=0 if fc_3yr==.
replace fc_5yr=0 if fc_5yr==.

cd D:\Research\NIH\NIH13\Data\UPF
merge m:1 nlmid using upf_oajournals
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

