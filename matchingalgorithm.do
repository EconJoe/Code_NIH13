

clear
gen nihpmid=.
cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
save similar_grants_all, replace

set more off
forvalues i=1/100 {

	display in red "------ File `i' ------"

	cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
	import delimited "similar_grants_1.txt", clear delimiter(tab) varnames(1)
	keep if linkname=="pubmed_pubmed"
	keep nihpmid similarpmid similarityscore
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
	append using similar_grants_all
	save similar_grants_all, replace
}

* Attach dates to NIH articles and potential controls
cd D:\Research\RAWDATA\MEDLINE\2016\Processed
use medline16_dates_clean, clear
keep if version==1
keep pmid year
tempfile hold
save `hold', replace

cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
use similar_grants_all, clear
rename nihpmid pmid
merge m:1 pmid using `hold'
drop if _merge==2
drop _merge
rename year nihyear
rename pmid nihpmid
rename similarpmid pmid
merge m:1 pmid using `hold'
drop if _merge==2
gen flag_similarnotmedline = (_merge==1)
drop _merge
rename year similaryear
rename pmid similarpmid
gen flag_yearmismatch = (nihyear!=similaryear)

rename similarpmid pmid
* Eliminate NIH funded articles from the set of potential contorls.
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge m:1 pmid using nihgrants
drop if _merge==2
gen flag_similarisnih = (_merge==3)
drop _merge
rename pmid similarpmid

* A "valid" similar article is one that is:
*  1) In MEDLINE (flag_similarnotmedline==0)
*  2) The same year as the treated (flag_yearmismatch==0)
*  3) The similar article is NOT NIH (flag_similarisnih==0)
gen validsimilar = (flag_similarnotmedline==0 & flag_yearmismatch==0 & flag_similarisnih==0)
by nihpmid, sort: egen validsimilar_total=total(validsimilar)

compress
cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
save similar_grants_all, replace




cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
use similar_grants_all, clear
* Keep pairs with valid similar article
keep if validsimilar==1 | validsimilar_total==0
drop if validsimilar_total==0
gsort nihpmid -similarityscore
* Group NIH articles by the number of potential controls that they have.
* We want to assign NIH articles with the FEWEST potential controls to a control first
*   so as to maximize the number of NIH articles that get a control.
egen group=group(validsimilar_total)
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save main, replace

cd D:\Research\Projects\NIHMandate\NIH14\Data
use main, clear
su group
local groupmax=`r(max)'
display in red "`groupmax'"

* Create a file to hold the NIH articles and their matches
clear
gen nihpmid=.
save testmatched, replace

* Create a file to hold controls that have already been used.
clear
gen similarpmid=.
save elimcontrols, replace

* Create a file to hold the NIH articles that were not able to be matched.
clear
gen nihpmid=.
save unmatched, replace

set more off
forvalues h=1/`groupmax' {

	display in red "---- Group `h' out of `groupmax' -------"
	
	* Identify the size of group `h'. That is the number of NIH articles that have `h' potential controls.
	use main if group==`h', clear
	keep nihpmid
	duplicates drop
	local groupsize=_N
	
	* Eliminate, as potential controls, articles that are already serving as a control. For `h'==`, there
	*  are no potential controls yet eliminated.
	use main if group==`h', clear
	merge m:1 similarpmid using elimcontrols
	keep if _merge==1
	drop _merge
	
	* Identify whether the candidate control article is a candidate for more than 1 treated article.
	* That is, is the same article a "similar" article for multiple NIH articles?
	duplicates tag similarpmid, gen(dupmatches)
	* Within the NIH article identify the top ranked potential control in terms of similarity score.
	by nihpmid, sort: gen rank=_n
	* If the POTENTIAL control is top ranked AND is not a dupilcate, make it the ACTUAL control for the NIH article.
	gen matched_=(dupmatches==0 & rank==1)
	by nihpmid, sort: egen matched=max(matched)
	* We have identified the matched and unmatched NIH articles for this group.
	save temp, replace

	local exit=""
	while ("`exit'"=="") {

		* Import the matched NIH articles and their potential controls. Then append to master match file.
		use temp if matched==1, clear
		if (_N>0) {
			* Keep only the ACTUAL matched controls.
			keep if matched_==1
			keep nihpmid similarpmid similarityscore validsimilar_total group
			*gen groupsize=`groupsize'
			append using testmatched
			save testmatched, replace
			su
			
			* List eliminated controls from the master file.
			keep similarpmid
			duplicates drop
			save elimcontrols, replace
		}

		* Import the non-matched NIH articles
		use temp if matched==0, clear
		merge m:1 similarpmid using elimcontrols
		keep if _merge==1
		drop _merge
		if (_N>0) {
			* Drop the articles no longer on the table
			drop rank matched_ matched dupmatches
			duplicates tag similarpmid, gen(dupmatches)
			by nihpmid, sort: gen rank=_n
			gen matched_=(dupmatches==0 & rank==1)
			by nihpmid, sort: egen matched=max(matched)
			save temp, replace
			qui su
			local mean=`r(mean)'
			if (`mean'==0) {
				append using unmatched
				save unmatched, replace
				local exit="Yes"
			}
			**************************************
		}
		if (_N==0) {
			local exit="Yes"
		}
	}
}

* Checks on data
cd D:\Research\Projects\NIHMandate\NIH14\Data
use main, clear
keep nihpmid
duplicates drop
merge 1:1 nihpmid using testmatched
gen matchsuccess=(_merge==3)
drop _merge
tab matchsuccess

use testmatched, clear
duplicates tag nihpmid, gen(dup)
duplicates tag similarp, gen(dup2)
su dup*
gsort -dup2 similarp nih

