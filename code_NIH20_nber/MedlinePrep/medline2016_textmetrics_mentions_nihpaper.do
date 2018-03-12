
* Set paths for files used in the dofile metrics_articlelevel_importclean.do
* Since we are passing a variable to another dofile, we need to declare these paths as global variables
global processed="/disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Processed"
global ngramfilepath "/disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Parsed/NGrams"
global outpath "/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/"

*global medlinemesh "B:\Research\RAWDATA\MEDLINE\2014\Parsed\MeSH"
*global meshtree "B:\Research\RAWDATA\MeSH\2014\Parsed"

*************************************************************************************
*************************************************************************************
* Construct a set of files that contain each PMID along with a list of all n-grams
*  used in the title or abstract. These files will be used multiple times to construct
*  various article-level metrics. However, they are merely intermediate files, and
*  do not need to be retained after all metrics are computed. They are created
*  because they take a while to construct and it would be inefficient to recreate them
*  each time we wanted to compute a new metric.

* Create a file that contains information for every n-gram in the MEDLINE corpus.
*  Mainly we want to create a set of files with the ngram replaced with an n-gram ID
*  in order to save space.
cd $processed
use medline16_ngrams_id, clear
merge 1:1 ngramid using medline16_ngrams_mentions
keep ngram ngramid mentions_bt
merge 1:1 ngramid using medline16_ngrams_vintage
drop _merge
*keep ngram ngramid mentions_bt vintage
merge 1:1 ngramid using medline16_ngrams_rank
drop _merge
sort ngram
compress
cd $outpath
save ngram_temp, replace

* Create the imported and cleaned files in increments of 50 underlying MEDLINE files.
* This will allow us to compute each metric looping over 15 large files instead of 812
*   smaller files. This saves a great deal of time.
local initialfiles 1 51 101 151 201 251 301 351 401 451 501 551 601 651 701 801
local terminalfile=812
local fileinc=49

clear
set more off
foreach h in `initialfiles' {

	* These lines just set the file numbers that we use at each iteration.
	local startfile=`h'
	local endfile=`startfile'+`fileinc'
	if (`endfile'>`terminalfile') {
		local endfile=`terminalfile'
	}
	
	clear
	set more off
	gen ngram=""
	cd $outpath
	save importandclean_`startfile'_`endfile', replace

	set more off
	forvalues i=`startfile'/`endfile' {
	
		display in red "--------- File `i' ----------"

		cd $ngramfilepath
		use medline16_`i'_ngrams, clear
		drop if dim=="null"

		keep pmid version ngram source wordcount
		* Eliminate duplicate ngrams in the same title or abstract
		duplicates drop pmid version source ngram, force
	
		compress
		cd $outpath
		append using importandclean_`startfile'_`endfile'
		save importandclean_`startfile'_`endfile', replace
	}
	
	* Attach date information
	cd $processed
	use medline16_dates_clean if filenum>=`startfile' & filenum<=`endfile', clear
	cd $outpath
	merge 1:m pmid version using importandclean_`startfile'_`endfile'
	drop if _merge==1
	drop _merge
	keep filenum pmid version ngram source wordcount year
	
	* Attach n-gram level information
	cd $outpath
	merge m:1 ngram using ngram_temp
	drop if _merge==2
	drop _merge
	
	* Replace "abstract" and "title" to "a" and "t" to save space
	replace source="a" if source=="abstract"
	replace source="t" if source=="title"
	
	order filenum pmid version ngramid year source wordcount top_* mentions_* vintage
	drop ngram
	*keep filenum pmid version ngramid year source wordcount top_* mentions_bt vintage
	sort pmid source vintage ngramid
	compress
	cd $outpath
	save importandclean_`startfile'_`endfile', replace
}
* erase ngram_temp.dta
*********************************************************************************


*************************************************************************************
*************************************************************************************
* Compute article-level mentions metrics. Specifically, compute the number of top concepts
*  each article uses.

capture program drop mentions
program define mentions

	local sources `" "title" "abstract" "both" "'
	foreach source in `sources' {

		if ("`source'"=="title") { 
			local elim="abstract" 		
		}
		if ("`source'"=="abstract") { 
			local elim="title" 
		}
		if ("`source'"=="both") {
			keep filenum pmid ngram year version vintage ment_* wordcount_* top_* rank pct rank_* pct_*
			duplicates drop
			* These assignments ensure that the source and elim variables nevery match which means that the 
			*  hold variables (see below) will not be marked 0.
			gen source="1"
			local elim="0"
		}
		
		local percentiles `" "001" "0001" "'
		foreach percentile in `percentiles' {
				
			* Compute mentions within *`i'* years of the vintage
			local vals 0 3 5 10
			foreach j in `vals' {
				gen hold=top_`percentile'
				* Mark the hold variable as missing if the article is beyond `j' years past vintage OR it is in the wrong source.
				replace hold=0 if year>vintage+`j' | source=="`elim'"
				by pmid version, sort: egen ment_`j'_`source'_`percentile'=total(hold)
				drop hold
			}
			*************
			* Compute mentions from *all* vintages
			gen hold=top_`percentile'
			replace hold=0 if source=="`elim'"
			by pmid version, sort: egen ment_all_`source'_`percentile'=total(hold)
			drop hold
			*************
		}
		
		* Compute average ranks and percentiles
		gen hold=rank
		replace hold=. if source=="`elim'"
		by pmid version, sort: egen rank_`source'_mean=mean(hold)
		drop hold
		
		gen hold=pct
		replace hold=. if source=="`elim'"
		by pmid version, sort: egen pct_`source'_mean=mean(hold)
		drop hold
		
		* Compute word counts.
		* Note that the tempfiles have been constructed so that each observation is uniquely identified by a PMID, NGRAMID, and source.
		gen hold=1
		* Mark the hold variable as missing if the article is in the wrong source.
		replace hold=0 if source=="`elim'"
		by pmid version, sort: egen wordcount_`source'=total(hold)
		drop hold
	}

	keep filenum pmid year version ment_* wordcount_* rank_* pct_*
	duplicates drop
end



clear
gen filenum=.
cd $outpath
save medline16_textmetrics_articlelevel_mentions_2, replace

local initialfiles 1 51 101 151 201 251 301 351 401 451 501 551 601 651 701 801
local terminalfile=812
local fileinc=49

clear
set more off
foreach h in `initialfiles' {
	
	* These lines just set the file numbers that we use at each iteration.
	local startfile=`h'
	local endfile=`startfile'+`fileinc'
	if (`endfile'>`terminalfile') {
		local endfile=`terminalfile'
	}
	
	cd $outpath
	use importandclean_`startfile'_`endfile', clear
	drop rank_
	* Compute the mentions metrics.
	mentions
	
	compress
	cd $outpath
	append using medline16_textmetrics_articlelevel_mentions_2
	sort filenum pmid version
	compress
	save medline16_textmetrics_articlelevel_mentions_2, replace
}
*************************************************************************************
