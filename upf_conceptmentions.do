
local startfile=650
local endfile=650

clear
gen filenum=.
cd D:\Research\NIH\NIH13\Data\UPF
save upf_conceptmentions_`startfile'_`endfile', replace

clear
set more off
forvalues i=`startfile'/`endfile' {

	display in red "------------- File `i' -----------------"

	cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\NGrams
	import delimited "medline16_`i'_ngrams.txt", clear delimiter(tab) varnames(1) bindquotes(nobind)
	cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Dates\Clean
	merge m:1 pmid version using medline16_`i'_dates
	drop _merge
	keep if version==1

	cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\NGrams\Clean
	merge m:1 ngram using ngram_top
	drop if _merge==2
	drop _merge
	replace top_01=0 if top_01==.
	replace top_001=0 if top_001==.
	replace top_0001=0 if top_0001==.
	sort pmid ngram
	keep filenum pmid ngram source year vintage top_*
	duplicates drop
	
	* Compute mentions within *`i'* years of the vintage in titles
	local vals 0 3 5 10
	foreach j in `vals' {
		gen hold_01=top_01
		replace hold_01=0 if year>vintage+`j' | source=="abstract"
		gen hold_001=top_001
		replace hold_001=0 if year>vintage+`j' | source=="abstract"
		gen hold_0001=top_0001
		replace hold_0001=0 if year>vintage+`j' | source=="abstract"

		by pmid, sort: egen ment_`j'_title_01=total(hold_01)
		by pmid, sort: egen ment_`j'_title_001=total(hold_001)
		by pmid, sort: egen ment_`j'_title_0001=total(hold_0001)
		drop hold_*
	}

	* Compute mentions within *`i'* years of the vintage in abstracts
	local vals 0 3 5 10
	foreach j in `vals' {
		gen hold_01=top_001
		replace hold_01=0 if year>vintage+`j' | source=="title"
		gen hold_001=top_001
		replace hold_001=0 if year>vintage+`j' | source=="title"
		gen hold_0001=top_0001
		replace hold_0001=0 if year>vintage+`j' | source=="title"

		by pmid, sort: egen ment_`j'_abstract_01=total(hold_01)
		by pmid, sort: egen ment_`j'_abstract_001=total(hold_001)
		by pmid, sort: egen ment_`j'_abstract_0001=total(hold_0001)
		drop hold_*
	}
	
	gen wordcount_abstract_=1
	replace wordcount_abstract_=0 if source=="title"
	by pmid, sort: egen wordcount_abstract=total(wordcount_abstract_)
	drop wordcount_abstract_

	gen wordcount_title_=1
	replace wordcount_title_=0 if source=="abstract"
	by pmid, sort: egen wordcount_title=total(wordcount_title_)
	drop wordcount_title_
	
	* Compute totals by eliminating duplicates across titles and abstracts
	keep filenum pmid ngram year vintage ment_* wordcount_* top_*
	duplicates drop

	* Compute mentions within *`i'* years of the vintage in *both* abstracts and titles
	local vals 0 3 5 10
	foreach j in `vals' {
		gen hold_01=top_01
		replace hold_01=0 if year>vintage+`j'
		gen hold_001=top_001
		replace hold_001=0 if year>vintage+`j'
		gen hold_0001=top_0001
		replace hold_0001=0 if year>vintage+`j'

		by pmid, sort: egen ment_`j'_both_01=total(hold_01)
		by pmid, sort: egen ment_`j'_both_001=total(hold_001)
		by pmid, sort: egen ment_`j'_both_0001=total(hold_0001)
		drop hold_*
	}
	
	gen wordcount_both_=1
	by pmid, sort: egen wordcount_both=total(wordcount_both_)
	drop wordcount_both_
	replace wordcount_both=wordcount_both-1 if wordcount_title==0
	replace wordcount_both=wordcount_both-1 if wordcount_abstract==0
	replace wordcount_both=0 if wordcount_both<0

	keep filenum pmid ment_* wordcount_*
	duplicates drop

	order filenum pmid  wordcount_*
	sort pmid
	compress
	cd D:\Research\NIH\NIH13\Data\UPF
	append using upf_conceptmentions_`startfile'_`endfile'
	save upf_conceptmentions_`startfile'_`endfile', replace
}

use upf_conceptmentions_1_100, clear
append using upf_conceptmentions_101_200
append using upf_conceptmentions_201_300
append using upf_conceptmentions_301_400
append using upf_conceptmentions_401_500
append using upf_conceptmentions_501_600
append using upf_conceptmentions_601_700
append using upf_conceptmentions_701_812

compress
sort filenum pmid
cd D:\Research\NIH\NIH13\Data\UPF
save upf_conceptmentions, replace
