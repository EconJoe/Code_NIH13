
*********************************************************************************************************************
*********************************************************************************************************************
* This section of the code uses info from the grant list to identify NIH-supporteda articles
clear
set more off

cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\Grants
import delimited "medline16_grants.txt", clear delimiter(tab) varnames(1)
keep if regexm(agency, "NIH")
keep filenum pmid version complete grantid acronym agency
sort filenum pmid version grantid
duplicates drop
compress
cd D:\Research\RAWDATA\MEDLINE\2016\Processed
save mdeline2016_grants_nihgrants, replace

* This section of the code uses info from the publication type list to identify NIH-supporteda articles
cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\PubTypes
import delimited "medline16_pubtypes.txt", clear delimiter(tab) varnames(1)
keep if ui=="D052061" | ui=="D052060"
keep filenum pmid version pubtype ui
sort filenum pmid version pubtype
compress
cd D:\Research\RAWDATA\MEDLINE\2016\Processed
save mdeline2016_pubtypes_nihgrants, replace
