

***************************************************************************************************
* There are 2,050,044 NIH articles.
* We are able to harvest similar articlces for 2,049,888.
* This is reduced to 1,964,118 after requiring at least 1 "valid" similar article.
* More info on the PRCA: https://ii.nlm.nih.gov/MTI/Details/related.shtml

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/PRCA/HarvestedSimilarArticles/
use harvestedsimilararticles, clear
* Keep pairs with valid similar article.
keep if validsimilar==1
gsort nihpmid -similarityscore similarpmid

* Group NIH articles by the number of POTENTIAL comparisons that they have.
* We want to first match NIH articles with the FEWEST POTENTIAL comparisons.
* This will increase the number of NIH articles that are matched to an ACTUAL comprison article.
egen group=group(validsimilar_total)
keep nihpmid similarpmid similarityscore group
qui su group
local groupmax=`r(max)'
display in red "There are `groupmax' groups"
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/PRCA
save potentialcomparisons, replace
***************************************************************************************************




***************************************************************************************************
* Create a file to hold the NIH articles and their matches
clear
gen nihpmid=.
save matchedarticles, replace
***************************************************************************************************



***************************************************************************************************
capture program drop matcher
program define matcher
	
	* Eliminate all artilces that have already been matched as potential comparison articles.
	use `1' `2', clear
	keep nihpmid similarpmid similarityscore group matched_nih
	
	if (_N>0) {
	
		local iter=0
	
		local exit=""
		while ("`exit'"=="") {
		
			local iter=`iter'+1
	
			*********
			* STEP 1: This step IDs unambiguous matches. That is matches in which a POTENTIAL comparison article is 
			*         top ranked (i.e., most similar) to a single NIH article.
			use temp if matched_nih==0, clear
			* Check if there are any observations left for group `h'. 
			* If there are, continue. If not, exit the while loop.
			qui su nihpmid
			if (`r(N)'==0) {
				local exit="Yes"
			}
			if (`r(N)'>0) {
				keep nihpmid similarpmid similarityscore group
				* For each NIH article, identify the most similar POTENTIAL comparison article.
				* Sort by similarpmid to break ties.
				gsort nihpmid -similarityscore similarpmid
				by nihpmid, sort: gen rank=_n
				* Identify any POTENTIAL comparison article that is top ranked for multiple NIH articles -- we have to decide how to assign.
				duplicates tag similarpmid rank, gen(dupmatches)
				* A POTENTIAL comparison article that is top ranked for an NIH article and is not a top ranked POTENTIAL comparison
				*   article for any other NIH articles is assigned as the ACTUAL comparison article. Assignment is unambiguous in this case.
				gen matched_pair=(dupmatches==0 & rank==1)
				* ID the NIH and comparison articles that have been matched. We need to remove these as we go.
				by similarpmid, sort: egen matched_comp = max(matched_pair)
				by nihpmid, sort: egen matched_nih=max(matched_pair)
				save temp, replace
				
				* Store the matched NIH and ACTUAL comparison articles.
				use temp if matched_nih==1, clear
				keep if matched_pair==1
				keep nihpmid similarpmid similarityscore group
				gen step=1
				gen iter = `iter'
				append using matchedarticles
				save matchedarticles, replace
				
				* Drop the matched ACTUAL comparison articles from the sample. 
				* These can no longer be considered as POTENTIAL comparisons for other NIH articles.
				* Note that if an NIH article only has POTENTIAL comparison articles that have already been assigned as ACTUAL
				*   comparison articles, the NIH article will be dropped at this step. It cannot be matched to comparison.
				use temp, clear
				drop if matched_comp==1
				save temp, replace
			}
			*********
			
			*********
			* STEP 2: This step IDs ambiguous matches. That is, it assigns POTENTIAL comparison articles to particualr 
			*         NIH articles when the POTENTIAL comparison articl is top ranked for multiple NIH articles.
			*         Note that once an ambiguous POTENTIAL comparison article is assigned to an NIH article, other POTENTIAL comparison
			*         articles may become unambiguous for some NIH articles -- this brings us back to step 1.
			use temp if matched_nih==0, clear
			qui su nihpmid
			* Check if there are any observations left for group `h'. 
			* If there are, continue. If not, exit the while loop.
			if (`r(N)'==0) {
				local exit="Yes"
			}
			if (`r(N)'>0) {
				keep nihpmid similarpmid similarityscore group
				gsort nihpmid -similarityscore similarpmid
				* Identify the top ranked POTENTIAL comparison article for each NIH article.
				* In this step, some POTENTIAL comparison articles are top ranked for multiple NIH articles. 
				* We need to decide to which NIH article such POTENTIAL comparison articles get matched.
				* We assign the POTENTIAL comparison article to NIH article for which the similarity score is highest.
				* When a POTENTIAL article is top ranked AND has the same similarity score for multiple NIH articles, this
				*   tie is randomly broken.
				by nihpmid, sort: gen rank1=_n
				* Break ties randomly
				gen rand1 = rnormal()
				gen rand2 = rnormal()
				gsort similarpmid -similarityscore rand1 rand2
				by similarpmid, sort: gen rank2=_n
				gen matched_pair=(rank1==1 & rank2==1)
				* ID the NIH and comparison articles that have been matched. We need to remove these as we go.
				by similarpmid, sort: egen matched_comp = max(matched_pair)
				by nihpmid, sort: egen matched_nih=max(matched_pair)
				save temp, replace
				
				* Store the matched NIH and ACTUAL comparison articles.
				use temp if matched_nih==1, clear
				keep if matched_pair==1
				keep nihpmid similarpmid similarityscore group
				gen step=2
				gen iter = `iter'
				append using matchedarticles
				save matchedarticles, replace
				
				* Drop the matched ACTUAL comparison articles from the sample. 
				use temp, clear
				drop if matched_comp==1
				save temp, replace
			}
			*********
		}
	}
		
end		
***************************************************************************************************

set seed 12345
set more off
forvalues h=1/`groupmax' {

	display in red "---- Group `h' out of `groupmax' -------"
	
	* Identify the matched and unmatched articles for this group.
	use potentialcomparisons if group==`h', clear
	gen matched_nih=0
	save temp, replace
	matcher "temp" "if matched==0"
	
	* Purge ACTUAL comparison articles from the list of POTENTIAL comparison articles.
	use matchedarticles, clear
	keep similarpmid
	merge 1:m similarpmid using potentialcomparisons
	keep if _merge==2
	drop _merge
	* Elmiinate groups already matched. This just saves time.
	drop if group==`h'
	save potentialcomparisons, replace
}

erase temp.dta
erase potentialcomparisons.dta


clear
set more off
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Parsed/
import delimited "medline16_grants.txt", clear delimiter(tab) varnames(1)
* Keep if the the NIH is listed as one of the funding agencies
keep if regexm(agency, "NIH")
keep pmid
duplicates drop
* It turns out that some grants reaaly are repeated on some articles.
* For instance, see file 375 PMID 8526461
tempfile hold
save `hold', replace
* This section of the code uses info from the publication type list to identify NIH-supporteda articles
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Parsed/
import delimited "medline16_pubtypes.txt", clear delimiter(tab) varnames(1)
keep if ui=="D052061" | ui=="D052060"
keep pmid
duplicates drop
append using `hold'
duplicates drop

rename pmid nihpmid
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/PRCA
merge 1:1 nihpmid using matchedarticles
gen matched=(_merge==3)
drop _merge
save matchedarticles, replace








