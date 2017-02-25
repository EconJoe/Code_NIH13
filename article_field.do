

clear
set more off


**************************************************
cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\MeSH
import delimited "medline16_mesh_ui.txt", clear delimiter(tab) varnames(1)

* Identify major topics
gen major=0
replace major=1 if majortopic=="Y"
*drop majortopic
by pmid version meshgroup, sort: egen groupmajor=total(major)
keep if groupmajor==1 & type=="Descriptor"
*keep filenum pmid version ui year type major
gen count=1
by pmid version, sort: egen total=total(count)
keep filenum pmid version ui meshgroup
by pmid version, sort: egen min=min(meshgroup)
keep if meshgroup==min
keep filenum pmid version ui
compress 
cd D:\Research\Projects\NIHMandate\NIH14\Data
save article_meshfieldraw, replace

**************************************************
cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\MeSH
import delimited "medline16_mesh_ui.txt", clear delimiter(tab) varnames(1)
* Keep only articles that are actually tagged with a raw MeSH term
drop if ui=="null"
* Keep only "Descriptor" MeSH terms. Eliminate "Qualifiers"
drop if type=="Qualifier"
keep filenum pmid version ui
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save meshfield_temp, replace

**************************************************
cd B:\Research\RAWDATA\MeSH\2016\Parsed
import delimited using "desc2016_meshtreenumbers.txt", clear delimiter(tab) varnames(1)
* The only MeSH terms without a tree number are "Male" and "Female". Thus, we just assign the MeSH terms as the tree number. 
replace treenumber="Male" if mesh=="Male"
replace treenumber="Female" if mesh=="Female"
keep meshid treenumber
rename meshid ui
tempfile mesh
save `mesh', replace
**************************************************

**************************************************
* Create a temporary file to hold the aggregated MeSH terms. This will be deleted in the end.
clear
gen filenum=.
cd D:\Research\Projects\NIHMandate\NIH14\Data
save meshfield_agg_temp, replace
**************************************************

local startfile=1
local endfile=812
local increment=100

set more off
forvalues i=`startfile'(`increment')`endfile' {
	
	local file1=`i'
	local file2=`i'+`increment'-1
	
	display in red "------- Aggregating MeSH terms from MEDLINE files `file1'-`file2' -----"
	
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	use meshfield_temp if filenum>=`file1' & filenum<=`file2', clear
	
	*keep pmid version mesh
	* Observations in the master file are uniquely identified by a pmid, version and MeSH term
	* Observations in the using file are uniquely identified by a MeSH term and tree number
	* We want to generate all treenumbers with which each article is associated
	joinby ui using `mesh', unmatched(master)
	drop _merge
	
	* When _merge==1, the MEDLINE article has no MeSH terms to match on. That is, the MeSH column has a value of "null" for this article.
	* Most of these articles have status "PubMed-not-Medline" articles and so haven't been indexed. 
	* However, some have statuss "MEDLINE", but still have "null" values. These are typically retractions.	
	
	* Transform all tree numbers into their 4-digit equivalents
	gen _4digit=regexs(1) if regexm(treenumber, "([A-Z][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9])")
	drop if _4digit==""
	
	gen count=1
	by pmid ui, sort: egen total=total(count)
	gen withinmesh_weight=count/total
	
	drop treenumber
	rename _4digit treenumber
	rename ui ui_raw
	* Attach the MeSH names/ID of the 4-digit tree branches
	merge m:1 treenumber using `mesh'
	drop if _merge==2
	drop _merge
	
	by pmid, sort: egen acrossmesh_weight=total(withinmesh_weight)
	gen weight_=withinmesh_weight/acrossmesh_weight
	by pmid ui, sort: egen weight=total(weight_)
	keep filenum pmid version ui weight
	duplicates drop
	
	sort filenum pmid version ui
	order filenum pmid version weight
	
	rename ui ui4
	rename weight mesh4_weight
	
	cd D:\Research\Projects\NIHMandate\NIH14\Data
	append using meshfield_agg_temp
	save meshfield_agg_temp, replace
}

sort filenum pmid version ui4
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data
save meshfield_4digit, replace
erase medline14_mesh_clean_temp.dta
********************************************************************************************************************
