

* WITHIN YEAR PS ESTIMATION

cd D:\Research\Projects\NIHMandate\NIH15\Data
use estsample_large, clear
keep if year>=2000 & year<=2013
gen nih=(nih_pubtype==1 | nih_grantlist==1)
save temp, replace

clear
gen pmid=.
cd D:\Research\Projects\NIHMandate\NIH15\Data
save ps_large_hold, replace

set more off
forvalues i=2000/2013 {

	display in red "---- Year `i'-------"

	use temp if year==`i', clear

	local backcites "bc_count bc_oa_count"
	local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
	local mesh "count_desc count_qual"
	local author "authortotal"
	local pubtype "pt_*"
	local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"
	local spec `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'

	logit nih `spec'
	predict pr
	rename pr pr_logit
	
	*probit nih `spec'
	*predict pr
	*rename pr pr_probit
	
	append using ps_large_hold
	save ps_large_hold, replace
}




* Coarsened exact matching
cd D:\Research\Projects\NIHMandate\NIH15\Data
use estsample_large, clear
keep if year>=2000 & year<=2013
gen nih=(nih_pubtype==1 | nih_grantlist==1)
save temp, replace

clear
gen pmid=.
cd D:\Research\Projects\NIHMandate\NIH15\Data
save cem_large_hold, replace

set seed 1234

set more off
forvalues i=2000/2013 {

	display in red "---------- Year `i' --------"

	use temp if year==`i', clear
	local backcites "bc_count bc_oa_count"
	local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
	local mesh "count_desc count_qual"
	local author "authortotal"
	local pubtype "pt_ja pt_rsnnonus pt_rev pt_engabs pt_cr pt_comp pt_ct pt_irreg"
	local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"
	local spec `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'
	cem `spec', treatment(nih) show

	append using cem_large_hold
	save cem_large_hold, replace
}



cd D:\Research\Projects\NIHMandate\NIH15\Data
use estsample_large, clear
keep if year>=2000 & year<=2013
gen nih=(nih_pubtype==1 | nih_grantlist==1)
save temp, replace

set seed 1234
keep if year==2000
psmatch2 nih bc_count














* Coarsened exact matching
cd D:\Research\Projects\NIHMandate\NIH15\Data
use estsample_large, clear
keep if year>=2000 & year<=2013
gen nih=(nih_pubtype==1 | nih_grantlist==1)
save temp, replace

clear
gen pmid=.
cd D:\Research\Projects\NIHMandate\NIH15\Data
save cem_large_hold, replace

set seed 1234

set more off
forvalues i=2000/2013 {

	display in red "---------- Year `i' --------"

	use temp if year==`i', clear
	local backcites "bc_count bc_oa_count"
	local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
	local mesh "count_desc count_qual"
	local author "authortotal"
	local pubtype "pt_ja pt_rsnnonus pt_rev pt_engabs pt_cr pt_comp pt_ct pt_irreg"
	local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"
	local spec `"`backcites' `ment' `mesh' `author' `pubtype' `meshaug1'"'
	cem `spec', treatment(nih) show

	append using cem_large_hold
	save cem_large_hold, replace
}



