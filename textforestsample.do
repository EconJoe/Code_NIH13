

cd D:\Research\Projects\NIHMandate\NIH14\Data
use testmatched.dta, clear
* Generate an internal ID for the pair
gen pairid=_n
order pairid
tempfile hold
save `hold', replace

use `hold', clear
drop similarpmid
rename nihpmid pmid
gen nih=1
tempfile hold2
save `hold2', replace

use `hold', clear
drop nihpmid
rename similarpmid pmid
gen nih=0
append using `hold2'
gsort pairid -nih
order pairid nih
keep pairid nih pmid
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data\SampleText
save text_estsample_temp, replace

clear 
gen pairid=.
save text_estsample, replace

set more off
forvalues i=1/812 {

	display in red "----------- File `i' ---------------"
	
	cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\NGrams\dtafiles
	use medline16_`i'_ngrams, clear
	keep filenum recordnum pmid version ngram dim source ngramnum wordcount
	
	cd D:\Research\Projects\NIHMandate\NIH14\Data\SampleText
	merge m:1 pmid using text_estsample_temp
	keep if _merge==3
	drop _merge

	order pairid pmid nih
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data\SampleText
	save text_estsample_`i', replace
}

local filenum=0
local obs=0
set more off
forvalues i=1/812 {

	display in red "------ File `i' -------"

	if(`i'==1 | `obs'>25000000) {
	
		local filenum=`filenum'+1
		clear
		gen pairid=.
		cd D:\Research\Projects\NIHMandate\NIH14\Data\SampleText
		save test_estsample_agg_`filenum', replace
	}

	cd D:\Research\Projects\NIHMandate\NIH14\Data\SampleText
	use text_estsample_`i', clear
	append using test_estsample_agg_`filenum'
	save test_estsample_agg_`filenum', replace
	local obs=_N
}

set more off
forvalues i=1/29 {

	display in red "----- File `i' -------"
	
	cd D:\Research\Projects\NIHMandate\NIH14\Data\SampleText
	use test_estsample_agg_`i', clear
	
	cd D:\Research\RAWDATA\MEDLINE\2016\Processed
	merge m:1 ngram using medline16_ngrams_id
	drop if _merge==2
	drop _merge
	
	cd D:\Research\RAWDATA\MEDLINE\2016\Processed
	merge m:1 ngramid using medline16_ngrams_mentions
	drop if _merge==2
	drop _merge
	
	cd D:\Research\RAWDATA\MEDLINE\2016\Processed
	merge m:1 ngramid using medline16_ngrams_vintage
	drop if _merge==2
	drop _merge
	
	cd D:\Research\RAWDATA\MEDLINE\2016\Processed
	merge m:1 ngramid using medline16_ngrams_rank
	drop if _merge==2
	drop _merge
	
	compress
	cd D:\Research\Projects\NIHMandate\NIH14\Data\SampleText
	save test_estsample_agg_`i', replace
}



cd D:\Research\RAWDATA\MEDLINE\2016\Processed
use medline16_dates_clean, clear
keep pmid version year
cd D:\Research\Projects\NIHMandate\NIH14\Data\SampleText
merge 1:m pmid version using test_estsample_agg_28
drop if _merge==1
drop _merge
keep pmid year pairid nih ngram ngramid vintage top_*
duplicates drop
sort pmid ngram
gen age = year-vintage
gen oldngram = (age>50)
keep if age<=50
compress
sort pmid ngram
cd D:\Research\Projects\NIHMandate\NIH14\Data\SampleText
save test1, replace


cd D:\Research\RAWDATA\MEDLINE\2016\Processed
use medline16_dates_clean, clear
keep pmid version year
cd D:\Research\RAWDATA\MEDLINE\2016\Parsed\NGrams\dtafiles
merge 1:m pmid version using medline16_700_ngrams
drop if _merge==1
drop _merge
rename pmid pmid_using
rename year year_using
keep pmid_using year_using ngram
duplicates drop
cd D:\Research\Projects\NIHMandate\NIH14\Data\SampleText
joinby ngram using test1, unmatched(both)
drop if _merge==1
rename _merge _merge1
compress
cd D:\Research\Projects\NIHMandate\NIH14\Data\SampleText
save test2, replace


use test2, clear
gen diff = year_using - year
keep if diff>=-6 & diff<=5
gen pre=(diff<0)
keep pmid year pmid_using diff pairid nih
duplicates drop
gen count=1
* Compute how many articles used a concept in each paper during the pre and post peiords
collapse (sum) count, by(pmid pairid nih year diff) fast
gen code =diff+6
drop diff
reshape wide count, i(pmid year pairid nih) j(code)
forvalues i=0/7 {
	replace count`i'=0 if count`i'==.
}


keep filenum recordnum pmid version ngram dim source ngramnum wordcount
