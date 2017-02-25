
cd D:\Research\Projects\NIHMandate\NIH14\Data
use estsample, clear
keep if year>=2000 & year<=2014

gen lsim=ln(similarityscore)
gen post=(year>2008)
gen validcontrol=validsimilar_total
replace validcontrol=40 if validcontrol>=40

drop *_meshage

collapse (mean) oa, by(nih year)
twoway (connected res year if nih==1, sort) ///
       (connected res year if nih==0, sort), ///
	   xline(2008) xlabel(2000(1)2014)

local match "validcontrol lsim"
local mesh "count_desc count_qual"
local meshaug1 "mean_art_tot_*"
local meshaug2 "median_art_tot_* max_art_tot_* min_art_tot_*"
local author "authortotal"
local backcites "bc_count bc_oa_count"
local backcitesaug1 "bc_age_mean"
local backcitesaug2 "bc_age_median bc_age_min bc_age_max"
local ment "ment_* wordcount_* pct_* rank_*"


areg oa i.nih##i.post i.year `match' `mesh', cluster(ui) absorb(ui)

predict res, r
predict yhat
collapse (mean) res yhat, by(nih year)

areg oa i.nih##i.post i.year `match' `mesh' `meshaug1' `meshaug2' `author' `backcites' `backcitesaug1' `backcitesaug2' `ment', cluster(ui) absorb(ui4)

areg oa i.nih##i.post i.year `match' `mesh' `meshaug1' `meshaug2' `author' `backcites' `backcitesaug1' `backcitesaug2',  r absorb(ui4)
areg oa i.nih##i.post i.year `match' `mesh' `meshaug1' `meshaug2' `author' `backcites' `backcitesaug1' `backcitesaug2', cluster(ui4) absorb(ui4)



reg oa i.nih##i.post i.year `match' `mesh' `meshaug1' `meshaug2' `author' `backcites' `backcitesaug1' `backcitesaug2', r

reg oa i.nih##i.post i.year, r
outreg2 using mainreg.doc, replace keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

reg oa i.nih##i.post i.year `match', r
outreg2 using mainreg.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

reg oa i.nih##i.post i.year `match' `mesh', r
outreg2 using mainreg.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

reg oa i.nih##i.post i.year `match' `mesh' `author', r
outreg2 using mainreg.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

reg oa i.nih##i.post i.year `match' `mesh' `author' `backcites', r
outreg2 using mainreg.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

reg oa i.nih##i.post i.year `match' `mesh' `author' `backcites' `backcitesaug1', r
outreg2 using mainreg.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

reg oa i.nih##i.post i.year `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2', r
outreg2 using mainreg.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

reg oa i.nih##i.post i.year `match' `mesh' `meshaug1' `author' `backcites' `backcitesaug1' `backcitesaug2', r
outreg2 using mainreg.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons


local match "validcontrol lsim"
local mesh "count_desc count_qual"
local author "authortotal"
local backcites "bc_count bc_oa_count"
local backcitesaug1 "bc_age_mean"
local backcitesaug2 "bc_age_median bc_age_min bc_age_max"

set more off

logit oa i.nih##i.post i.year, r
outreg2 using mainreg_logit.doc, replace keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

logit oa i.nih##i.post i.year `match', r
outreg2 using mainreg_logit.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

logit oa i.nih##i.post i.year `match' `mesh', r
outreg2 using mainreg_logit.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

logit oa i.nih##i.post i.year `match' `mesh' `author', r
outreg2 using mainreg_logit.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

logit oa i.nih##i.post i.year `match' `mesh' `author' `backcites', r
outreg2 using mainreg_logit.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

logit oa i.nih##i.post i.year `match' `mesh' `author' `backcites' `backcitesaug1', r
outreg2 using mainreg_logit.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

logit oa i.nih##i.post i.year `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2', r
outreg2 using mainreg_logit.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons


local match "validcontrol lsim"
local mesh "count_desc count_qual"
local author "authortotal"
local backcites "bc_count bc_oa_count"
local backcitesaug1 "bc_age_mean"
local backcitesaug2 "bc_age_median bc_age_min bc_age_max"

set more off

probit oa i.nih##i.post i.year, r
outreg2 using mainreg_probit.doc, replace keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

probit oa i.nih##i.post i.year `match', r
outreg2 using mainreg_probit.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

probit oa i.nih##i.post i.year `match' `mesh', r
outreg2 using mainreg_probit.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

probit oa i.nih##i.post i.year `match' `mesh' `author', r
outreg2 using mainreg_probit.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

probit oa i.nih##i.post i.year `match' `mesh' `author' `backcites', r
outreg2 using mainreg_probit.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

probit oa i.nih##i.post i.year `match' `mesh' `author' `backcites' `backcitesaug1', r
outreg2 using mainreg_probit.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons

probit oa i.nih##i.post i.year `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2', r
outreg2 using mainreg_probit.doc, keep(i.nih##i.post `match' `mesh' `author' `backcites' `backcitesaug1' `backcitesaug2') label dec(4) nocons


logit oa i.nih##i.post i.year, r
probit oa i.nih##i.post i.year, r

parmby "reg oa i.year i.year#i.nih similarityscore validsimilar_total pt_*, r", norestore
keep if regexm(parm, "1\.nih")
gen year=regexs(1) if regexm(parm, "^([0-9][0-9][0-9][0-9])")
destring year, replace
twoway (connected estimate year, sort) ///
       (line min95 year, sort) ///
       (line max95 year, sort), ///
	   xline(2008) xlabel(2003(1)2013)
