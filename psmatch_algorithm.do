

cd D:\Research\Projects\NIHMandate\NIH14\Data
use ps_hold, clear
keep pmid groupid year validsimilar_total nih pr_weighted
tempfile hold
save `hold', replace

use `hold', clear
keep if nih==1
keep pmid groupid pr_weighted
rename pmid nihpmid
rename pr_weighted nih_pr_weighted
save psmatched, replace

use `hold', clear
keep if nih==0
keep pmid groupid pr_weighted validsimilar year
rename pmid similarpmid
rename pr_weighted similar_pr_weighted
merge m:1 groupid using psmatched
drop _merge
order groupid nihpmid similarpmid
sort groupid similarpmid
gen dist=abs(nih_pr_weighted-similar_pr_weighted)
save main_ps, replace

cd D:\Research\Projects\NIHMandate\NIH14\Data
use main_ps, clear
gsort nihpmid dist
egen group = group(validsimilar_total)
su group
local groupmax=`r(max)'
display in red "`groupmax'"
save main_ps_hold, replace

* Create a file to hold the NIH articles and their matches
clear
gen nihpmid=.
save testmatched_ps, replace

* Create a file to hold controls that have already been used.
clear
gen similarpmid=.
save elimcontrols_ps, replace

* Create a file to hold the NIH articles that were not able to be matched.
clear
gen nihpmid=.
save unmatched_ps, replace

set more off
forvalues h=1/`groupmax' {

	display in red "---- Group `h' out of `groupmax' -------"
	
	* Identify the size of group `h'. That is the number of NIH articles that have `h' potential controls.
	use main_ps_hold if group==`h', clear
	keep nihpmid
	duplicates drop
	local groupsize=_N
	
	* Eliminate, as potential controls, articles that are already serving as a control. For `h'==`, there
	*  are no potential controls yet eliminated.
	use main_ps_hold if group==`h', clear
	merge m:1 similarpmid using elimcontrols_ps
	keep if _merge==1
	drop _merge
	
	* Identify whether the candidate control article is a candidate for more than 1 treated article.
	* That is, is the same article a "similar" article for multiple NIH articles?
	duplicates tag similarpmid, gen(dupmatches)
	* Within the NIH article identify the closest potential control in terms of the pscore.
	by nihpmid, sort: gen rank=_n
	* If the POTENTIAL control is top ranked AND is not a dupilcate, make it the ACTUAL control for the NIH article.
	gen matched_=(dupmatches==0 & rank==1)
	by nihpmid, sort: egen matched=max(matched)
	* We have identified the matched and unmatched NIH articles for this group.
	save temp_ps, replace

	local exit=""
	while ("`exit'"=="") {

		* Import the matched NIH articles and their potential controls. Then append to master match file.
		use temp_ps if matched==1, clear
		if (_N>0) {
			* Keep only the ACTUAL matched controls.
			keep if matched_==1
			keep nihpmid similarpmid dist validsimilar_total group
			*gen groupsize=`groupsize'
			append using testmatched_ps
			save testmatched_ps, replace
			su
			
			* List eliminated controls from the master file.
			keep similarpmid
			duplicates drop
			save elimcontrols_ps, replace
		}

		* Import the non-matched NIH articles
		use temp_ps if matched==0, clear
		merge m:1 similarpmid using elimcontrols_ps
		keep if _merge==1
		drop _merge
		if (_N>0) {
			* Drop the articles no longer on the table
			drop rank matched_ matched dupmatches
			duplicates tag similarpmid, gen(dupmatches)
			by nihpmid, sort: gen rank=_n
			gen matched_=(dupmatches==0 & rank==1)
			by nihpmid, sort: egen matched=max(matched)
			save temp_ps, replace
			qui su
			local mean=`r(mean)'
			if (`mean'==0) {
				append using unmatched_ps
				save unmatched_ps, replace
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








gen control_pr=pr if nih==0
gen treated_pr=pr if nih==1
