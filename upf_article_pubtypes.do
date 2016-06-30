
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\PubTypes
use medline16_pubtypes_crosswalk, clear

* https://www.nlm.nih.gov/mesh/pubtypes.html
gen pt_ja=0
replace pt_ja=1 if pubtype=="Journal Article"

gen pt_rsnnonususus=0
replace pt_rsnnonususus=1 if pubtype=="Research Support, Non-U.S. Gov't"

gen pt_rev=0
replace pt_rev=1 if pubtype=="Review"

gen pt_engabs=0
replace pt_engabs=1 if pubtype=="English Abstract"

gen pt_cr=0
replace pt_cr=1 if pubtype=="Case Reports"

gen pt_comp=0
replace pt_comp=1 if pubtype=="Comparative Study"

gen pt_ct=0
replace pt_ct=1 if pubtype=="Clinical Trial"
replace pt_ct=1 if pubtype=="Clinical Trial, Phase II"
replace pt_ct=1 if pubtype=="Clinical Trial, Phase I"
replace pt_ct=1 if pubtype=="Clinical Trial, Phase III"
replace pt_ct=1 if pubtype=="Clinical Trial, Phase IV"
replace pt_ct=1 if pubtype=="Pragmatic Clinical Trial"

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

*keep if pt_irreg==1
keep ui pt_*

cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\PubTypes
merge 1:m ui using medline16_pubtypes
drop _merge

collapse (max) pt_*, by(filenum pmid version)

sort pmid version
compress
cd D:\Research\NIH\NIH13\Data\UPF
save upf_article_pubtypes, replace
