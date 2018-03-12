
cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Processed/
use medline16_dates_clean, clear
keep if version==1
keep pmid year
tempfile hold
save `hold', replace
* Obtain information on citing-cited relationships for PMIDs in WOS
cd /disk/bulkw/staudt/RAWDATA/WOS
use pmidcites, clear
* Attach publication year to each cited and citing PMIDs
rename pmid_cited pmid
merge m:1 pmid using `hold'
drop if _merge==1
drop _merge
rename pmid pmid_cited
rename year year_cited
keep if year_cited>=2003 & year_cited<=2013
rename pmid_citing pmid
merge m:1 pmid using `hold'
drop if _merge==2
drop _merge
rename pmid pmid_citing
rename year year_citing
compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data
save article_forwardcites, replace



cd /disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Processed/
use medline16_dates_clean, clear
keep if version==1
keep pmid year
tempfile hold
save `hold', replace
* Attach 2016 MapAffil Info
cd /disk/bulkw/staudt/RAWDATA/TorvikGroup/
import delimited "mapaffil2016.tsv", clear varnames(1) delimiter(tab)
keep pmid au_order year type country
keep if au_order==1
replace type="null" if type==""
replace country="null" if country==""
replace country="null" if country=="-"
replace country="multiple" if regexm(country, "\|")
keep pmid type country
merge 1:1 pmid using `hold'
drop if _merge==1
drop _merge
replace country="null" if missing(country)
replace type="null" if missing(type)
replace country=lower(country)
compress
save `hold', replace



*************************************************************************
* Attach GDP quintile information
clear
set obs 13
gen year=_n+2002
tempfile year
save `year', replace

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/
import delimited "UNdata_Export_20170327_155919109.csv", clear varnames(1) delimiter(comma)
keep if year>=2003 & year<=2015
rename countryorarea country
rename value gdp
keep country year gdp
sort country year
replace country=lower(country)

replace country="bolivia" if country=="bolivia (plurinational state of)"
replace country="brunei" if country=="brunei darussalam"
replace country="cape verde" if country=="cabo verde"
replace country="hong kong" if country=="china, hong kong sar"
replace country="china" if country=="china, people's republic of"
replace country="macao" if country=="china, macao special administrative region"
replace country="cote d'ivoire" if country=="cÃ´te d'ivoire"
replace country="democratic republic of congo" if country=="democratic republic of the congo"
replace country="iran" if country=="iran, islamic republic of"
replace country="laos" if country=="lao people's democratic republic"
replace country="micronesia" if country=="micronesia (federated states of)"
replace country="korea" if country=="republic of korea"
replace country="moldova" if country=="republic of moldova"
replace country="russia" if country=="russian federation"
replace country="saint martin" if country=="sint maarten (dutch part)"
replace country="palestine" if country=="state of palestine"
replace country="syria" if country=="syrian arab republic"
replace country="uk" if country=="united kingdom of great britain and northern ireland"
replace country="usa" if country=="united states"
replace country="venezuela" if country=="venezuela (bolivarian republic of)"
replace country="netherlands antilles" if country=="former netherlands antilles"
replace country="north korea" if country=="democratic people's republic of korea"
replace country="east timor" if country=="timor-leste"
replace country="republic of georgia" if country=="georgia"
replace country="macedonia" if country=="the former yugoslav republic of macedonia"
replace country="tanzania" if country=="united republic of tanzania: mainland"
replace country="sultanate of oman" if country=="oman"
* Split between "fomer sudan", "south sudan", and "sudan" occurrs in 2008
replace country="sudan" if country=="former sudan"
replace country="sudan" if country=="south sudan"
* Netherlands antilles becomes curasao in 2010
replace country="netherlands antilles" if country=="curaÃ§ao"

* This collapse only deals with Sudan, and Netherlands Antilles
collapse (mean) gdp, by(country year)

tempfile countrypanel
save `countrypanel', replace

keep country
duplicates drop
cross using `year'
merge 1:1 country year using `countrypanel'
drop _merge

* The only country that does not have a complete panel is Saint Martin, which is missing data from 2003-2004.
* Just linearly interpolate back.
by country: ipolate gdp year, gen(gdp_imp) epolate
replace gdp=gdp_imp if missing(gdp)
drop gdp_imp

* Assign each country to a GDP quntile for a given year
gen quintile=.
forvalues i=2003/2015 {
	xtile quintile_=gdp if year==`i', n(5)
	replace quintile=quintile_ if year==`i'
	drop quintile_
}

keep country year quintile
merge 1:m country year using `hold'
drop if _merge==1
drop _merge
keep pmid type quintile
rename pmid pmid_citing
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/
merge 1:m pmid_citing using article_forwardcites
drop if _merge==1
drop _merge

order pmid_cited year_cited pmid_citing year_citing type quintile
*sort pmid_cited year_citing pmid_citing

* Reassign all citations that occured before an article was published to
*  the publication year. It may be possible for an article to receive
*  citations prior to publiation (e.g. working papers), but it is not
*  clear how to handle this. What is clear is that these SHOULD be counted
*  in the foroward citation measues, which they are.
replace year_citing=year_cited if year_citing<year_cited & year_cited!=.

set more off
local vals 2
foreach i in `vals' {
	gen hold=0
	replace hold=1 if year_citing<=year_cited+`i' & year_cited!=.
	by pmid_cited, sort: egen fc_`i'yr=total(hold)
	drop hold
	
	gen hold=0
	replace hold=1 if year_citing<=year_cited+`i' & year_cited!=. & type=="COM"
	by pmid_cited, sort: egen fc_com_`i'yr=total(hold)
	drop hold
	
	gen hold=0
	replace hold=1 if year_citing<=year_cited+`i' & year_cited!=. & (quintile==1 | quintile==2)
	by pmid_cited, sort: egen fc_dev_`i'yr=total(hold)
	drop hold
}

keep pmid_cited fc_*
duplicates drop

rename pmid_cited pmid
order pmid
sort  pmid

compress
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/
save article_forwardcites, replace
