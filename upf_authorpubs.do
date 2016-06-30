
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Authors\Clean
use authorpmidlist, clear
keep authorid pmid version year authororder authortotal

cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Journals\Clean
merge m:1 pmid version using medline16_journals
drop if _merge==2
drop _merge

cd D:\Research\NIH\NIH13\Data\UPF
merge m:1 nlmid using upf_oajournals
drop if _merge==2
drop _merge

gen pubcount=1
gen pubcount_1st=0
replace pubcount_1st=1 if authororder=="1"
gen pubcount_last=0
replace pubcount_last=1 if authororder==authortotal
gen pubcount_oa=0
replace pubcount_oa=1 if oa==1
gen pubcount_1st_oa=0
replace pubcount_1st_oa=1 if authororder=="1" & oa==1
gen pubcount_last_oa=0
replace pubcount_last_oa=1 if authororder==authortotal & oa==1

collapse (sum) pubcount*, by(authorid year)

sort authorid year
by authorid: gen pubcount_cum=sum(pubcount)
by authorid: gen pubcount_1st_cum=sum(pubcount_1st)
by authorid: gen pubcount_last_cum=sum(pubcount_last)
by authorid: gen pubcount_oa_cum=sum(pubcount_oa)
by authorid: gen pubcount_1st_oa_cum=sum(pubcount_1st_oa)
by authorid: gen pubcount_last_oa_cum=sum(pubcount_last_oa)

compress
cd D:\Research\NIH\NIH13\Data\UPF
save upf_authorpubs, replace

