
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Authors\Clean
use authorpmidlist, clear
merge m:1 lastname firstinital using authorid_crosswalk
keep authorid pmid version authororder authortotal
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Dates\Clean
merge m:1 pmid version using medline16_all_dates
keep authorid pmid version authororder authortotal year

* Compute the career age of each author for each year in which the author publishes an article
by authorid, sort: egen startyear=min(year)
gen age=year-startyear+1

* Compute metrics that characterize the distribution of the ages of all authors on an article
by pmid version, sort: egen age_all_mean=mean(age)
by pmid version, sort: egen age_all_med=median(age)
by pmid version, sort: egen age_all_min=min(age)
by pmid version, sort: egen age_all_max=max(age)
by pmid version, sort: egen age_all_sd=sd(age)

* Compute the age of the first author of each article
gen age_1st_=age if authororder=="1"
by pmid version, sort: egen age_1st=max(age_1st_)
drop age_1st_

* Compute the age of the last author of each article
gen age_last_=age if authororder==authortotal
by pmid version, sort: egen age_last=max(age_last_)
drop age_last_

* Compute metrics that characterize the distribution of the ages of the middle authors on an article
gen age_middle=age if (authororder!="1" & authororder!=authortotal) | authortotal=="1"
by pmid version, sort: egen age_mid_mean=mean(age_middle)
by pmid version, sort: egen age_mid_med=median(age_middle)
by pmid version, sort: egen age_mid_min=min(age_middle)
by pmid version, sort: egen age_mid_max=max(age_middle)
by pmid version, sort: egen age_mid_sd=sd(age_middle)
drop age_middle

keep pmid version age_*
duplicates drop

sort pmid
compress
cd D:\Research\NIH\NIH13\Data\UPF
save upf_article_authorages, replace

