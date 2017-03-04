

cd D:\Research\Projects\NIHMandate\NIH14\Data
use estsample, clear
keep if year>=2000 & year<=2013

gen ta=1-oa
gen lsim=ln(similarityscore)
gen lval=ln(validsimilar_total)
gen post=(year>2008)

local match "lsim lval"
local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"
local spec `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

reg ta i.nih##i.post i.year, cluster(ui4)
reg ta i.nih##i.post i.year `spec', cluster(ui4)
areg ta i.nih##i.post i.year `spec', absorb(ui) cluster(ui4)



* This file computes estimates using open access indicator as the outcome variable.

cd D:\Research\Projects\NIHMandate\NIH15\Data
use estsample_large, clear
keep if year>=2000 & year<=2013
gen ta=1-oa
gen post=(year>2008)
gen nih=(nih_pubtype==1 | nih_grantlist==1)

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"

local spec `" `backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

reg ta i.nih##i.post i.year, cluster(ui4)
reg ta i.nih##i.post i.year `spec', cluster(ui4)
areg ta i.nih##i.post i.year `spec', absorb(ui) cluster(ui4)




cd D:\Research\Projects\NIHMandate\NIH14\Data
use matched_all, clear
keep if year>=2000 & year<=2013
gen post=(year>2008)
gen ta=1-oa

local match "lsim lval"
local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"
local spec `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

reg ta i.nih##i.post i.year [aweight=similar_weight], cluster(ui4)
reg ta i.nih##i.post i.year `spec' [aweight=similar_weight], cluster(ui4)
areg ta i.nih##i.post i.year `spec' [aweight=similar_weight], absorb(ui) cluster(ui4)








