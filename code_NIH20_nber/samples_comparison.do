
global outpath = "/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/"

* Create 2003-2013 Analysis Sample
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Processed/
use medline16_dates_clean, clear
keep if version==1
keep pmid year
keep if year>=2003 & year<=2013
label var pmid "PubMed ID"
label var year "Publication Year"
compress
cd $outpath
save samples_comparison, replace

* NIH Grants (and other info) from the Grant List
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Parsed/
import delimited "medline16_grants.txt", clear delimiter(tab) varnames(1)
keep if version==1
gen flag_grantlistcomplete=(complete=="Y")
* Identify as NIH if "NIH" is listed in the funding agency variable.
gen grant_countnih=(regexm(agency, "NIH"))
gen grant_countnonnih=(grantid!="null" & grant_countnih!=1)
collapse (max) flag_grantlistcomplete (sum) grant_countnih grant_countnonnih, by(pmid) fast
label var grant_countnih "NIH Grant Count"
label var grant_countnonnih "Non-NIH Grant Count"
label var flag_grantlistcomplete "Grant List Complete Flag"
cd $outpath
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
compress
cd $outpath
save samples_comparison, replace


* NIH Grants (and other info) from the Publication Type
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Parsed/
import delimited "medline16_pubtypes.txt", clear delimiter(tab) varnames(1)
keep if version==1
* https://www.nlm.nih.gov/mesh/pubtypes.html
gen pt_ja=0
replace pt_ja=1 if pubtype=="Journal Article"
gen pt_nih=0
replace pt_nih=1 if pubtype=="Research Support, N.I.H., Extramural"
replace pt_nih=1 if pubtype=="Research Support, N.I.H., Intramural"
gen pt_nophs=0
replace pt_nophs=1 if pubtype=="Research Support, U.S. Gov't, Non-P.H.S."
gen pt_phs=0
replace pt_phs=1 if pubtype=="Research Support, U.S. Gov't, P.H.S."
gen pt_arra=0
replace pt_arra=1 if pubtype=="Research Support, American Recovery and Reinvestment Act"
gen pt_nous=0
replace pt_nous=1 if pubtype=="Research Support, Non-U.S. Gov't"
gen pt_rev=0
replace pt_rev=1 if pubtype=="Review"
gen pt_engabs=0
replace pt_engabs=1 if pubtype=="English Abstract"
gen pt_cr=0
replace pt_cr=1 if pubtype=="Case Reports"
gen pt_comp=0
replace pt_comp=1 if pubtype=="Comparative Study"
gen pt_meta=0
replace pt_meta=1 if pubtype=="Meta-Analysis"
gen pt_eval=0
replace pt_eval=1 if pubtype=="Evaluation Studies"
gen pt_guide=0
replace pt_guide=1 if pubtype=="Guideline"
replace pt_guide=1 if pubtyp=="Practice Guideline"
gen pt_multi=0
replace pt_multi=1 if pubtype=="Multicenter Study"
gen pt_obs=0
replace pt_obs=1 if pubtype=="Observational Study"
gen pt_rct=0
replace pt_rct=1 if pubtype=="Randomized Controlled Trial"
gen pt_tech=0
replace pt_tech=1 if pubtype=="Technical Report"
gen pt_twin=0
replace pt_twin=1 if pubtype=="Twin Study"
gen pt_valid=0
replace pt_valid=1 if pubtype=="Validation Studies"
gen pt_ct=0
replace pt_ct=1 if pubtype=="Clinical Trial"
replace pt_ct=1 if pubtype=="Clinical Trial, Phase II"
replace pt_ct=1 if pubtype=="Clinical Trial, Phase I"
replace pt_ct=1 if pubtype=="Clinical Trial, Phase III"
replace pt_ct=1 if pubtype=="Clinical Trial, Phase IV"
replace pt_ct=1 if pubtype=="Pragmatic Clinical Trial"
replace pt_ct=1 if pubtype=="Controlled Clinical Trial"
gen pt_irreg=0
replace pt_irreg=1 if pubtype=="Letter"
replace pt_irreg=1 if pubtype=="Comment"
replace pt_irreg=1 if pubtype=="Editorial"
replace pt_irreg=1 if pubtype=="News"
replace pt_irreg=1 if pubtype=="Biography"
replace pt_irreg=1 if pubtype=="Portraits"
replace pt_irreg=1 if pubtype=="Introductory Journal Article"
replace pt_irreg=1 if pubtype=="Overall"
replace pt_irreg=1 if pubtype=="Interview"
replace pt_irreg=1 if pubtype=="Newspaper Article"
replace pt_irreg=1 if pubtype=="Bibliography"
replace pt_irreg=1 if pubtype=="Legal Cases"
replace pt_irreg=1 if pubtype=="Consensus Development Conference"
replace pt_irreg=1 if pubtype=="Published Erratum"
replace pt_irreg=1 if pubtype=="Directory"
replace pt_irreg=1 if pubtype=="Lectures"
replace pt_irreg=1 if pubtype=="Classical Article"
replace pt_irreg=1 if pubtype=="Addresses"
replace pt_irreg=1 if pubtype=="Patient Education Handout"
replace pt_irreg=1 if pubtype=="Retracted Publication"
replace pt_irreg=1 if pubtype=="Retraction of Publication"
replace pt_irreg=1 if pubtype=="Autobiography"
replace pt_irreg=1 if pubtype=="Personal Narratives"
replace pt_irreg=1 if pubtype=="Legislation"
replace pt_irreg=1 if pubtype=="Festschrift"
replace pt_irreg=1 if pubtype=="Corrected and Republished Article"
replace pt_irreg=1 if pubtype=="Consensus Development Conference, NIH"
replace pt_irreg=1 if pubtype=="Dictionary"
replace pt_irreg=1 if pubtype=="Webcasts"
replace pt_irreg=1 if pubtype=="Periodical Index"
replace pt_irreg=1 if pubtype=="Interactive Tutorial"
replace pt_irreg=1 if pubtype=="Scientific Integrity Review"
replace pt_irreg=1 if pubtype=="Government Publications"
replace pt_irreg=1 if pubtype=="Dataset"
replace pt_irreg=1 if pubtype=="Historical Article"
replace pt_irreg=1 if pubtype=="Clinical Conference"
replace pt_irreg=1 if pubtype=="Congresses"
replace pt_irreg=1 if pubtype=="Duplicate Publication"
replace pt_irreg=1 if pubtype=="Video-Audio Media"
collapse (max) pt_*, by(pmid) fast
label var pt_ja "Journal Article"
label var pt_nih "NIH Research Support (PubType)"
label var pt_nophs "Research Support, U.S. Gov't, Non-P.H.S."
label var pt_phs "Research Support, U.S. Gov't, P.H.S."
label var pt_arra "Research Support, American Recovery and Reinvestment Act"
label var pt_nous "Research Support, American Recovery and Reinvestment Act"
label var pt_nous "Research Support, Non-U.S. Gov't"
label var pt_rev "Review"
label var pt_engabs "English Abstract"
label var pt_cr "Case Reports"
label var pt_comp "Comparative Study"
label var pt_meta "Meta-Analysis"
label var pt_eval "Evaluation Studies"
label var pt_guide "Guideline"
label var pt_multi "Multicenter Study"
label var pt_obs "Observational Study"
label var pt_rct "Randomized Controlled Trial"
label var pt_tech "Technical Report"
label var pt_twin "Twin Study"
label var pt_valid "Validation Studies"
label var pt_ct "Clinical Trial"
label var pt_irreg "Irregular Article"
cd $outpath
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
compress
save samples_comparison, replace


* Attach NLMID to each PMID
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Parsed/
import delimited "medline16_journals_nlmid.txt", clear delimiter(tab) varnames(1)
keep if version==1
keep pmid nlmid
cd $outpath
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
label var nlmid "NLM ID"
compress
save samples_comparison, replace

* Attach Language Information
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Parsed/
import delimited "medline16_language.txt", clear delimiter(tab) varnames(1)
keep if version==1
gen lang_other=1
local languages "eng ger fre rus jpn und spa ita chi"
foreach language in `languages' {
	gen lang_`language'=(language=="`language'")
	replace lang_other=0 if lang_`language'==1
}
collapse (max) lang_*, by(pmid) fast
label var lang_other "Other Language"
label var lang_und "Undetermined Language"
label var lang_eng "English"
label var lang_ger "German"
label var lang_fre "French"
label var lang_rus "Russian"
label var lang_jpn "Japanese"
label var lang_spa "Spanish"
label var lang_ita "Italian"
label var lang_chi "Chinese"
cd $outpath
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
compress
save samples_comparison, replace


* Add author counts
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Parsed/
import delimited "medline16_authors_basic.txt", clear delimiter(tab) varnames(1)
keep if version==1
gen author_count=(authororder!="null")
gen author_corp=(authororder=="null")
collapse (sum) author_count (max) author_corp, by(pmid) fast
label var author_count "Author Count"
label var author_corp "Corporate Author"
cd $outpath
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
compress
save samples_comparison, replace


* Add counts of raw MeSH "Descriptors" and "Qualifiers"
* This is a very rough measure of how multidisplinary an article is.
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Parsed/
import delimited "medline16_mesh_ui.txt", clear varnames(1) delimiter(tab)
keep if version==1
gen count_desc=(type=="Descriptor")
gen count_qual=(type=="Qualifier")
collapse (sum) count_*, by(pmid) fast
label var count_desc "MeSH Descriptor Count"
label var count_qual "MeSH Qualifier Count"
cd $outpath
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
compress
save samples_comparison, replace

cd $outpath
use meshfield_4digit, clear	
keep if version==1
keep pmid mesh4_weight ui4
* Identify the 4 digit term with the most weight--some will be ties
by pmid, sort: egen double max=max(mesh4_weight)
compress
keep if mesh4_weight==max
* Break ties randomly
set seed 1234
gen rand1=runiform()
gen rand2=runiform()
sort pmid rand1 rand2
by pmid, sort: gen id=_n
duplicates tag pmid, gen(flag_ui4count)
replace flag_ui4count=flag_ui4count+1
keep if id==1
keep pmid mesh4_weight ui4 flag_ui4count
label var mesh4_weight "Weight of Top 4-Digit MeSH"
label var ui4 "4-Digit MeSH UI"
label var flag_ui4count "Flag for Count of Potential Top 4-Digit MeSH"
cd $outpath
merge 1:1 pmid using samples_comparison
drop if _merge==1
replace ui4="null" if _merge==2
replace flag_ui4count=0 if _merge==2
drop _merge
compress
save samples_comparison, replace


cd $outpath
use article_meshfieldraw, clear
keep if version==1
keep pmid ui ui_total
cd $outpath
merge 1:1 pmid using samples_comparison
drop if _merge==1
replace ui="null" if _merge==2
replace ui_total=0 if _merge==2
rename ui_total flag_uicount
label var flag_uicount "Flag for Count of Potential Raw MeSH"
drop _merge
compress
save samples_comparison, replace


cd /disk/bulkw/staudt/RAWDATA/Medline2016/Processed/TextMetrics/
use medline16_textmetrics_articlelevel_mentions, clear
keep if version==1
keep pmid ment_0_both_001 ment_3_both_001 ment_5_both_001 ment_10_both_001 ment_all_both_001 ment_0_both_0001 ment_3_both_0001 ment_5_both_0001 ment_10_both_0001 ment_all_both_0001 rank_both_mean pct_both_mean wordcount_both
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
replace ment_0_both_001=0 if _merge==2
replace ment_3_both_001=0 if _merge==2
replace ment_5_both_001=0 if _merge==2
replace ment_10_both_001=0 if _merge==2
replace ment_all_both_001=0 if _merge==2
replace ment_0_both_0001=0 if _merge==2
replace ment_3_both_0001=0 if _merge==2
replace ment_5_both_0001=0 if _merge==2
replace ment_10_both_0001=0 if _merge==2
replace ment_all_both_0001=0 if _merge==2
replace wordcount_both=0 if _merge==2
drop _merge
label var ment_0_both_001 "Age 0 Top 0.1% Concepts"
label var ment_3_both_001 "Age 3 Top 0.1% Concepts"
label var ment_5_both_001 "Age 5 Top 0.1% Concepts"
label var ment_10_both_001 "Age 10 Top 0.1% Concepts"
label var ment_all_both_001 "All Age Top 0.1% Concepts"
label var ment_0_both_0001 "Age 0 Top 0.01% Concepts"
label var ment_3_both_0001 "Age 3 Top 0.01% Concepts"
label var ment_5_both_0001 "Age 5 Top 0.01% Concepts"
label var ment_10_both_0001 "Age 10 Top 0.01% Concepts"
label var ment_all_both_0001 "All Age Top 0.01% Concepts"
label var wordcount_both "Total Concepts"
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace


* Attach 2016 MapAffil Info
cd /disk/bulkw/staudt/RAWDATA/TorvikGroup
import delimited "mapaffil2016.tsv", clear varnames(1) delimiter(tab)
keep pmid au_order year type country
keep if au_order==1
replace type="null" if type==""
replace country="null" if country==""
replace country="null" if country=="-"
replace country="multiple" if regexm(country, "\|")
gen count=1
by country, sort: egen tot_count=total(count)
* Countries must have at least 10000 publications EVER to get their own fixed effect
replace country="other" if tot_count<10000
keep pmid type country
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
replace type="null" if _merge==2
replace country="null" if _merge==2
drop _merge
gen type_com=0
replace type_com=1 if type=="COM"
gen type_edu=0
replace type_edu=1 if type=="EDU"
gen type_eduhos=0
replace type_eduhos=1 if type=="EDU-HOS"
gen type_gov=0
replace type_gov=1 if type=="GOV"
gen type_hos=0
replace type_hos=1 if type=="HOS"
gen type_mil=0
replace type_mil=1 if type=="MIL"
gen type_org=0
replace type_org=1 if type=="ORG"
gen type_unk=0
replace type_unk=1 if type=="UNK" | type=="null"
drop type
label var country "Affiliation Country"
label var type_com "Commercial Affiliation"
label var type_edu "Educational Affiliation"
label var type_eduhos "Eductional/Hospital Affiliation"
label var type_gov "Government Affiliation"
label var type_hos "Hospital Affiliation"
label var type_mil "Military Affiliation"
label var type_org "Organization Affiliation"
label var type_unk "Unkown Affiliation"
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace


* Attach Open Access Info
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge m:1 nlmid using journal_oa
drop if _merge==2
drop _merge
replace oa=0 if missing(oa)
label var oa "Open Access Journal"
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use article_backwardcites, clear
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
replace bc_count=0 if missing(bc_count)
replace bc_oa_count=0 if missing(bc_oa_count)
label var bc_count "Backward Citation Count"
label var bc_oa_count "Open Access Backward Citation Count"
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use article_forwardcites, clear
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop _merge
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use journal_IF, clear
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:m nlmid year using samples_comparison
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace

****************************************************************************************************************
************************* CREATE FULL PRCA SAMPLE **************************************************************
****************************************************************************************************************
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use harvestedsimilararticles, clear

* Keep pairs with valid similar article (or articles with no potential controls)
* DO WE REALLY NEED TO ELIMINATE CONTROLS WITH DIFFERENT YEARS??
keep if validsimilar==1
keep nihpmid similarpmid
tempfile hold
save `hold', replace

use `hold', clear
rename nihpmid pmid
keep pmid
duplicates drop
gen nih=1
tempfile temp
save `temp', replace
use `hold', clear
rename similarpmid pmid
keep pmid
duplicates drop
gen nih=0
append using `temp'

* Attach to main dataset
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
gen sample_prca_full=(_merge==3)
drop nih
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace
****************************************************************************************************************



****************************************************************************************************************
************************* CREATE 1-to-1 PRCA SAMPLE ************************************************************
****************************************************************************************************************

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use matchedarticles, clear
keep if matched==1
keep nihpmid similarpmid
tempfile hold
save `hold', replace

use `hold', clear
drop similarpmid
rename nihpmid pmid
tempfile hold2
save `hold2', replace

use `hold', clear
drop nihpmid
rename similarpmid pmid
append using `hold2'
compress

* Attach control variables
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
gen sample_prca_1to1=(_merge==3)
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace
****************************************************************************************************************


****************************************************************************************************************
***************************** CREATE JOURNAL SAMPLE ************************************************************
****************************************************************************************************************
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use samples_comparison, clear
gen nih=(grant_countnih>0 | pt_nih==1)

* Identify journals that publish a NIH article in a given year
by nlmid year, sort: egen sample_journal=max(nih)
drop nih

order pmid sample_*
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace
****************************************************************************************************************


****************************************************************************************************************
***************************** CREATE MEDLINE SAMPLE ************************************************************
****************************************************************************************************************
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use samples_comparison, clear
gen sample_medline=1
order pmid sample_*
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace
****************************************************************************************************************



**********************************************************************
* Generage the covariates used to estimate the propensity scores
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Code_NIH19_nber/
do pscore_covariates.do

* Use Stat/Transfer to covert to SAS dataset
set more off
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
stcmd pscore_covariates.dta pscore_covariates.sas7bdat

* Attach propensity score info
* Note that these first need to be estimated using SAS
* Use file pscore.sas

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
import delimited "pscores.csv", clear varnames(1) delimiter(comma)
tempfile pscores
save `pscores', replace
use samples_comparison, clear
merge 1:1 pmid using `pscores'
drop _merge
compress
save samples_comparison, replace


* Stratify based onthe propensity score
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Code_NIH19_nber/
do pscore_stratification.do
keep pmid strat_*
tempfile strata
save `strata', replace
use samples_comparison, clear
merge 1:1 pmid using `strata'
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace










****************************************************************************************************************
************************* CREATE MEDLINE SAMPLE ****************************************************************
****************************************************************************************************************

* Create 2003-2013 Analysis Sample
cd /disk/bulkw/staudt/RAWDATA/Medline2016/Processed/
use medline16_dates_clean, clear
keep if version==1
keep pmid year
keep if year>=2003 & year<=2013
label var pmid "PubMed ID"
label var year "Publication Year"
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace

* NIH Grants (and other info) from the Grant List
cd /disk/bulkw/staudt/RAWDATA/Medline2016/Parsed/Grants/
import delimited "medline16_grants.txt", clear delimiter(tab) varnames(1)
keep if version==1
gen flag_grantlistcomplete=(complete=="Y")
* Identify as NIH if "NIH" is listed in the funding agency variable.
gen grant_countnih=(regexm(agency, "NIH"))
gen grant_countnonnih=(grantid!="null" & grant_countnih!=1)
collapse (max) flag_grantlistcomplete (sum) grant_countnih grant_countnonnih, by(pmid) fast
label var grant_countnih "NIH Grant Count"
label var grant_countnonnih "Non-NIH Grant Count"
label var flag_grantlistcomplete "Grant List Complete Flag"
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace


* NIH Grants (and other info) from the Publication Type
cd /disk/bulkw/staudt/RAWDATA/Medline2016/Parsed/PubTypes/
import delimited "medline16_pubtypes.txt", clear delimiter(tab) varnames(1)
keep if version==1
* https://www.nlm.nih.gov/mesh/pubtypes.html
gen pt_ja=0
replace pt_ja=1 if pubtype=="Journal Article"
gen pt_nih=0
replace pt_nih=1 if pubtype=="Research Support, N.I.H., Extramural"
replace pt_nih=1 if pubtype=="Research Support, N.I.H., Intramural"
gen pt_nophs=0
replace pt_nophs=1 if pubtype=="Research Support, U.S. Gov't, Non-P.H.S."
gen pt_phs=0
replace pt_phs=1 if pubtype=="Research Support, U.S. Gov't, P.H.S."
gen pt_arra=0
replace pt_arra=1 if pubtype=="Research Support, American Recovery and Reinvestment Act"
gen pt_nous=0
replace pt_nous=1 if pubtype=="Research Support, Non-U.S. Gov't"
gen pt_rev=0
replace pt_rev=1 if pubtype=="Review"
gen pt_engabs=0
replace pt_engabs=1 if pubtype=="English Abstract"
gen pt_cr=0
replace pt_cr=1 if pubtype=="Case Reports"
gen pt_comp=0
replace pt_comp=1 if pubtype=="Comparative Study"
gen pt_meta=0
replace pt_meta=1 if pubtype=="Meta-Analysis"
gen pt_eval=0
replace pt_eval=1 if pubtype=="Evaluation Studies"
gen pt_guide=0
replace pt_guide=1 if pubtype=="Guideline"
replace pt_guide=1 if pubtyp=="Practice Guideline"
gen pt_multi=0
replace pt_multi=1 if pubtype=="Multicenter Study"
gen pt_obs=0
replace pt_obs=1 if pubtype=="Observational Study"
gen pt_rct=0
replace pt_rct=1 if pubtype=="Randomized Controlled Trial"
gen pt_tech=0
replace pt_tech=1 if pubtype=="Technical Report"
gen pt_twin=0
replace pt_twin=1 if pubtype=="Twin Study"
gen pt_valid=0
replace pt_valid=1 if pubtype=="Validation Studies"
gen pt_ct=0
replace pt_ct=1 if pubtype=="Clinical Trial"
replace pt_ct=1 if pubtype=="Clinical Trial, Phase II"
replace pt_ct=1 if pubtype=="Clinical Trial, Phase I"
replace pt_ct=1 if pubtype=="Clinical Trial, Phase III"
replace pt_ct=1 if pubtype=="Clinical Trial, Phase IV"
replace pt_ct=1 if pubtype=="Pragmatic Clinical Trial"
replace pt_ct=1 if pubtype=="Controlled Clinical Trial"
gen pt_irreg=0
replace pt_irreg=1 if pubtype=="Letter"
replace pt_irreg=1 if pubtype=="Comment"
replace pt_irreg=1 if pubtype=="Editorial"
replace pt_irreg=1 if pubtype=="News"
replace pt_irreg=1 if pubtype=="Biography"
replace pt_irreg=1 if pubtype=="Portraits"
replace pt_irreg=1 if pubtype=="Introductory Journal Article"
replace pt_irreg=1 if pubtype=="Overall"
replace pt_irreg=1 if pubtype=="Interview"
replace pt_irreg=1 if pubtype=="Newspaper Article"
replace pt_irreg=1 if pubtype=="Bibliography"
replace pt_irreg=1 if pubtype=="Legal Cases"
replace pt_irreg=1 if pubtype=="Consensus Development Conference"
replace pt_irreg=1 if pubtype=="Published Erratum"
replace pt_irreg=1 if pubtype=="Directory"
replace pt_irreg=1 if pubtype=="Lectures"
replace pt_irreg=1 if pubtype=="Classical Article"
replace pt_irreg=1 if pubtype=="Addresses"
replace pt_irreg=1 if pubtype=="Patient Education Handout"
replace pt_irreg=1 if pubtype=="Retracted Publication"
replace pt_irreg=1 if pubtype=="Retraction of Publication"
replace pt_irreg=1 if pubtype=="Autobiography"
replace pt_irreg=1 if pubtype=="Personal Narratives"
replace pt_irreg=1 if pubtype=="Legislation"
replace pt_irreg=1 if pubtype=="Festschrift"
replace pt_irreg=1 if pubtype=="Corrected and Republished Article"
replace pt_irreg=1 if pubtype=="Consensus Development Conference, NIH"
replace pt_irreg=1 if pubtype=="Dictionary"
replace pt_irreg=1 if pubtype=="Webcasts"
replace pt_irreg=1 if pubtype=="Periodical Index"
replace pt_irreg=1 if pubtype=="Interactive Tutorial"
replace pt_irreg=1 if pubtype=="Scientific Integrity Review"
replace pt_irreg=1 if pubtype=="Government Publications"
replace pt_irreg=1 if pubtype=="Dataset"
replace pt_irreg=1 if pubtype=="Historical Article"
replace pt_irreg=1 if pubtype=="Clinical Conference"
replace pt_irreg=1 if pubtype=="Congresses"
replace pt_irreg=1 if pubtype=="Duplicate Publication"
replace pt_irreg=1 if pubtype=="Video-Audio Media"
collapse (max) pt_*, by(pmid) fast
label var pt_ja "Journal Article"
label var pt_nih "NIH Research Support (PubType)"
label var pt_nophs "Research Support, U.S. Gov't, Non-P.H.S."
label var pt_phs "Research Support, U.S. Gov't, P.H.S."
label var pt_arra "Research Support, American Recovery and Reinvestment Act"
label var pt_nous "Research Support, American Recovery and Reinvestment Act"
label var pt_nous "Research Support, Non-U.S. Gov't"
label var pt_rev "Review"
label var pt_engabs "English Abstract"
label var pt_cr "Case Reports"
label var pt_comp "Comparative Study"
label var pt_meta "Meta-Analysis"
label var pt_eval "Evaluation Studies"
label var pt_guide "Guideline"
label var pt_multi "Multicenter Study"
label var pt_obs "Observational Study"
label var pt_rct "Randomized Controlled Trial"
label var pt_tech "Technical Report"
label var pt_twin "Twin Study"
label var pt_valid "Validation Studies"
label var pt_ct "Clinical Trial"
label var pt_irreg "Irregular Article"
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace


* Attach NLMID to each PMID
cd /disk/bulkw/staudt/RAWDATA/Medline2016/Parsed/Journals/
import delimited "medline16_nlmid.txt", clear delimiter(tab) varnames(1)
keep if version==1
keep pmid nlmid
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
label var nlmid "NLM ID"
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace

set more off

* Attach Language Information
cd /disk/bulkw/staudt/RAWDATA/Medline2016/Parsed/Language/
import delimited "medline16_language.txt", clear delimiter(tab) varnames(1)
keep if version==1
gen lang_other=1
local languages "eng ger fre rus jpn und spa ita chi"
foreach language in `languages' {
	gen lang_`language'=(language=="`language'")
	replace lang_other=0 if lang_`language'==1
}
collapse (max) lang_*, by(pmid) fast
label var lang_other "Other Language"
label var lang_und "Undetermined Language"
label var lang_eng "English"
label var lang_ger "German"
label var lang_fre "French"
label var lang_rus "Russian"
label var lang_jpn "Japanese"
label var lang_spa "Spanish"
label var lang_ita "Italian"
label var lang_chi "Chinese"
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace


* Add author counts
cd /disk/bulkw/staudt/RAWDATA/Medline2016/Parsed/Authors/
import delimited "medline16_authors_basic.txt", clear delimiter(tab) varnames(1)
keep if version==1
gen author_count=(authororder!="null")
gen author_corp=(authororder=="null")
collapse (sum) author_count (max) author_corp, by(pmid) fast
label var author_count "Author Count"
label var author_corp "Corporate Author"
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace


* Add counts of raw MeSH "Descriptors" and "Qualifiers"
* This is a very rough measure of how multidisplinary an article is.
cd /disk/bulkw/staudt/RAWDATA/Medline2016/Parsed/MeSH/
import delimited "medline16_mesh_ui.txt", clear varnames(1) delimiter(tab)
keep if version==1
gen count_desc=(type=="Descriptor")
gen count_qual=(type=="Qualifier")
collapse (sum) count_*, by(pmid) fast
label var count_desc "MeSH Descriptor Count"
label var count_qual "MeSH Qualifier Count"
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use meshfield_4digit, clear	
keep if version==1
keep pmid mesh4_weight ui4
* Identify the 4 digit term with the most weight--some will be ties
by pmid, sort: egen double max=max(mesh4_weight)
compress
keep if mesh4_weight==max
* Break ties randomly
set seed 1234
gen rand1=runiform()
gen rand2=runiform()
sort pmid rand1 rand2
by pmid, sort: gen id=_n
duplicates tag pmid, gen(flag_ui4count)
replace flag_ui4count=flag_ui4count+1
keep if id==1
keep pmid mesh4_weight ui4 flag_ui4count
label var mesh4_weight "Weight of Top 4-Digit MeSH"
label var ui4 "4-Digit MeSH UI"
label var flag_ui4count "Flag for Count of Potential Top 4-Digit MeSH"
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
replace ui4="null" if _merge==2
replace flag_ui4count=0 if _merge==2
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace


cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use article_meshfieldraw, clear
keep if version==1
keep pmid ui ui_total
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
replace ui="null" if _merge==2
replace ui_total=0 if _merge==2
rename ui_total flag_uicount
label var flag_uicount "Flag for Count of Potential Raw MeSH"
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace


cd /disk/bulkw/staudt/RAWDATA/Medline2016/Processed/TextMetrics/
use medline16_textmetrics_articlelevel_mentions, clear
keep if version==1
keep pmid ment_0_both_001 ment_3_both_001 ment_5_both_001 ment_10_both_001 ment_all_both_001 ment_0_both_0001 ment_3_both_0001 ment_5_both_0001 ment_10_both_0001 ment_all_both_0001 rank_both_mean pct_both_mean wordcount_both
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
replace ment_0_both_001=0 if _merge==2
replace ment_3_both_001=0 if _merge==2
replace ment_5_both_001=0 if _merge==2
replace ment_10_both_001=0 if _merge==2
replace ment_all_both_001=0 if _merge==2
replace ment_0_both_0001=0 if _merge==2
replace ment_3_both_0001=0 if _merge==2
replace ment_5_both_0001=0 if _merge==2
replace ment_10_both_0001=0 if _merge==2
replace ment_all_both_0001=0 if _merge==2
replace wordcount_both=0 if _merge==2
drop _merge
label var ment_0_both_001 "Age 0 Top 0.1% Concepts"
label var ment_3_both_001 "Age 3 Top 0.1% Concepts"
label var ment_5_both_001 "Age 5 Top 0.1% Concepts"
label var ment_10_both_001 "Age 10 Top 0.1% Concepts"
label var ment_all_both_001 "All Age Top 0.1% Concepts"
label var ment_0_both_0001 "Age 0 Top 0.01% Concepts"
label var ment_3_both_0001 "Age 3 Top 0.01% Concepts"
label var ment_5_both_0001 "Age 5 Top 0.01% Concepts"
label var ment_10_both_0001 "Age 10 Top 0.01% Concepts"
label var ment_all_both_0001 "All Age Top 0.01% Concepts"
label var wordcount_both "Total Concepts"
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace


* Attach 2016 MapAffil Info
cd /disk/bulkw/staudt/RAWDATA/TorvikGroup
import delimited "mapaffil2016.tsv", clear varnames(1) delimiter(tab)
keep pmid au_order year type country
keep if au_order==1
replace type="null" if type==""
replace country="null" if country==""
replace country="null" if country=="-"
replace country="multiple" if regexm(country, "\|")
gen count=1
by country, sort: egen tot_count=total(count)
* Countries must have at least 10000 publications EVER to get their own fixed effect
replace country="other" if tot_count<10000
keep pmid type country
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
replace type="null" if _merge==2
replace country="null" if _merge==2
drop _merge
gen type_com=0
replace type_com=1 if type=="COM"
gen type_edu=0
replace type_edu=1 if type=="EDU"
gen type_eduhos=0
replace type_eduhos=1 if type=="EDU-HOS"
gen type_gov=0
replace type_gov=1 if type=="GOV"
gen type_hos=0
replace type_hos=1 if type=="HOS"
gen type_mil=0
replace type_mil=1 if type=="MIL"
gen type_org=0
replace type_org=1 if type=="ORG"
gen type_unk=0
replace type_unk=1 if type=="UNK" | type=="null"
drop type
label var country "Affiliation Country"
label var type_com "Commercial Affiliation"
label var type_edu "Educational Affiliation"
label var type_eduhos "Eductional/Hospital Affiliation"
label var type_gov "Government Affiliation"
label var type_hos "Hospital Affiliation"
label var type_mil "Military Affiliation"
label var type_org "Organization Affiliation"
label var type_unk "Unkown Affiliation"
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace


* Attach Open Access Info
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge m:1 nlmid using journal_oa
drop if _merge==2
drop _merge
replace oa=0 if missing(oa)
label var oa "Open Access Journal"
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use article_backwardcites, clear
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
drop _merge
replace bc_count=0 if missing(bc_count)
replace bc_oa_count=0 if missing(bc_oa_count)
label var bc_count "Backward Citation Count"
label var bc_oa_count "Open Access Backward Citation Count"
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use article_forwardcites, clear
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop _merge
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use journal_IF, clear
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:m nlmid year using samples_comparison
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace

****************************************************************************************************************
************************* CREATE FULL PRCA SAMPLE **************************************************************
****************************************************************************************************************
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use harvestedsimilararticles, clear

* Keep pairs with valid similar article (or articles with no potential controls)
* DO WE REALLY NEED TO ELIMINATE CONTROLS WITH DIFFERENT YEARS??
keep if validsimilar==1
keep nihpmid similarpmid
tempfile hold
save `hold', replace

use `hold', clear
rename nihpmid pmid
keep pmid
duplicates drop
gen nih=1
tempfile temp
save `temp', replace
use `hold', clear
rename similarpmid pmid
keep pmid
duplicates drop
gen nih=0
append using `temp'

* Attach to main dataset
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
gen sample_prca_full=(_merge==3)
drop nih
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace
****************************************************************************************************************



****************************************************************************************************************
************************* CREATE 1-to-1 PRCA SAMPLE ************************************************************
****************************************************************************************************************

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use matchedarticles, clear
keep if matched==1
keep nihpmid similarpmid
tempfile hold
save `hold', replace

use `hold', clear
drop similarpmid
rename nihpmid pmid
tempfile hold2
save `hold2', replace

use `hold', clear
drop nihpmid
rename similarpmid pmid
append using `hold2'
compress

* Attach control variables
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
merge 1:1 pmid using samples_comparison
drop if _merge==1
gen sample_prca_1to1=(_merge==3)
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace
****************************************************************************************************************


****************************************************************************************************************
***************************** CREATE JOURNAL SAMPLE ************************************************************
****************************************************************************************************************
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use samples_comparison, clear
gen nih=(grant_countnih>0 | pt_nih==1)

* Identify journals that publish a NIH article in a given year
by nlmid year, sort: egen sample_journal=max(nih)
drop nih

order pmid sample_*
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace
****************************************************************************************************************


****************************************************************************************************************
***************************** CREATE MEDLINE SAMPLE ************************************************************
****************************************************************************************************************
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
use samples_comparison, clear
gen sample_medline=1
order pmid sample_*
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace
****************************************************************************************************************



**********************************************************************
* Generage the covariates used to estimate the propensity scores
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Code_NIH19_nber/
do pscore_covariates.do

* Use Stat/Transfer to covert to SAS dataset
set more off
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
stcmd pscore_covariates.dta pscore_covariates.sas7bdat

* Attach propensity score info
* Note that these first need to be estimated using SAS
* Use file pscore.sas

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
import delimited "pscores.csv", clear varnames(1) delimiter(comma)
tempfile pscores
save `pscores', replace
use samples_comparison, clear
merge 1:1 pmid using `pscores'
drop _merge
compress
save samples_comparison, replace


* Stratify based onthe propensity score
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Code_NIH19_nber/
do pscore_stratification.do
keep pmid strat_*
tempfile strata
save `strata', replace
use samples_comparison, clear
merge 1:1 pmid using `strata'
drop _merge
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH19/Data/
save samples_comparison, replace









