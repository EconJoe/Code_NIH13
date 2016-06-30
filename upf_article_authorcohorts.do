cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Authors\Clean
use authorpmidlist, clear
merge m:1 lastname firstinital using authorid_crosswalk
keep authorid pmid version authororder authortotal
cd B:\Research\RAWDATA\MEDLINE\2016\Parsed\Dates\Clean
merge m:1 pmid version using medline16_all_dates
keep authorid pmid version authororder authortotal year

* Compute the start year (cohort) of each author
by authorid, sort: egen startyear=min(year)

* Compute metrics that characterize the distribution of the cohorts of all authors on an article
by pmid version, sort: egen startyear_all_mean=mean(startyear)
by pmid version, sort: egen startyear_all_med=median(startyear)
by pmid version, sort: egen startyear_all_min=min(startyear)
by pmid version, sort: egen startyear_all_max=max(startyear)
by pmid version, sort: egen startyear_all_sd=sd(startyear)

* Compute the cohort of the first author of each article
gen startyear_1st_=startyear if authororder=="1"
by pmid version, sort: egen startyear_1st=max(startyear_1st_)
drop startyear_1st_

* Compute the cohort of the last author of each article
gen startyear_last_=startyear if authororder==authortotal
by pmid version, sort: egen startyear_last=max(startyear_last_)
drop startyear_last_

* Compute metrics that characterize the distribution of the cohorts of the middle authors on an article
gen startyear_middle=startyear if (authororder!="1" & authororder!=authortotal) | authortotal=="1"
by pmid version, sort: egen startyear_mid_mean=mean(startyear_middle)
by pmid version, sort: egen startyear_mid_med=median(startyear_middle)
by pmid version, sort: egen startyear_mid_min=min(startyear_middle)
by pmid version, sort: egen startyear_mid_max=max(startyear_middle)
by pmid version, sort: egen startyear_mid_sd=sd(startyear_middle)
drop startyear_middle

keep pmid version startyear_*
duplicates drop

sort pmid
compress
cd D:\Research\NIH\NIH13\Data\UPF
save upf_article_authorcohorts, replace









