

clear
gen nihpmid=.
cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
save similar_grants_all, replace

set more off
forvalues i=1/100 {

	display in red "------ File `i' ------"

	cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
	import delimited "similar_grants_`i'.txt", clear delimiter(tab) varnames(1)
	keep if linkname=="pubmed_pubmed"
	keep nihpmid similarpmid similarityscore
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
	append using similar_grants_all
	save similar_grants_all, replace
}

cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
use similar_grants_all, clear
rename similarpmid pmid
* Eliminate NIH funded articles from the set of potential contorls.
cd D:\Research\Projects\NIHMandate\NIH14\Data
merge m:1 pmid using nihgrants
drop if _merge==2
drop if _merge==3
drop _merge
rename pmid similarpmid
tempfile hold
save `hold', replace

cd D:\Research\Projects\NIHMandate\NIH14\Data\Similar
use similar_grants_all, clear
keep nihpmid similarpmid
merge 1:1 nihpmid similarpmid using `hold'
gen validmatch=(_merge==3)
drop _merge
by nihpmid, sort: egen validmatch_total=total(validmatch)
keep if validmatch==1 | validmatch_total==0
replace similarpmid=. if validmatch_total==0
gsort nihpmid -similarityscore
egen group=group(validmatch_total)
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save main, replace




cd D:\Research\Projects\NIHMandate\NIH14\Data
use main, clear
su group
local groupmax=`r(max)'
display in red "`groupmax'"

clear
gen nihpmid=.
save testmatched, replace

clear
gen similarpmid=.
save elimcontrols, replace

clear
gen nihpmid=.
save unmatched, replace

set more off
forvalues h=2/`groupmax' {

	display in red "---- Group `h' out of `groupmax' -------"
	
	* Identify the size of group `h'
	use main if group==`h', clear
	keep nihpmid
	duplicates drop
	local groupsize=_N
	
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
			keep nihpmid similarpmid similarityscore validmatch_total group
			*gen groupsize=`groupsize'
			append using testmatched
			save testmatched, replace
			su
			
			* List eliminated controls
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

use main if group>=2 & group<=1790, clear
keep nih
duplicates drop
merge 1:1 nih using testmatched

use testmatched, clear
duplicates tag nihpmid, gen(dup)
duplicates tag similarp, gen(dup2)
su dup*
gsort -dup2 similarp nih

use unmatched, clear
keep nih
duplicates drop
