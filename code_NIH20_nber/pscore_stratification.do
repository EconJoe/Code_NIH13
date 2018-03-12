
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/

* This program stratifies based on the propensity score
*  1) Feed in file with identifier (PMID), pscore, log-lin pscore, group variable
*  2) Feed in tuning paramters

capture program drop stratifypscore
program define stratifypscore

	* Stopping rules
	local F_thresh="`1'"
	local Ngroup_thresh="`2'"
	local Ntot_tresh="`3'"

	* Initial values
	local strata=1
	local exit="No"
	local iter=1

	gen stratum_cur=`strata'
	save notstratified, replace
	
	clear
	gen pmid=.
	save stratified, replace

	set more off
	while ("`exit'"=="No") {

		display in red "Iteration `iter'"

		use notstratified, clear
		gen F=.
		qui su stratum_cur
		local strata_max=`r(max)'
		forvalues i=1/`strata_max' {
			qui oneway logit group if stratum_cur==`i'
			replace F=`r(F)' if stratum_cur==`i'
		}
		gen split_homog=(F>`F_thresh')
		tab stratum_cur split_homog
		
		****** Prob cannot handle probabilities extremely close to zero.****
		****** Alternatively, could define each 0 smallest non-zero and each 1 largest non-1.
		local metric="logit"
		*local metric="prob"
		by stratum_cur, sort: egen med = median(`metric')
		gen stratum_pot=.
		replace stratum_pot=1 if `metric'<=med
		replace stratum_pot=2 if `metric'>med
		* This handles edge cases when the choice of EQUALITY matters. Can happen when the median (split value) equals the min or max.
		* Without this, all observations can be assigned to the same stratum in an infinite loop.
		qui su stratum_pot
		local min=`r(min)'
		local max=`r(max)'
		if (`min'==1 & `max'==1) {
			drop stratum_pot
			gen stratum_pot=.
			replace stratum_pot=1 if `metric'<med
			replace stratum_pot=2 if `metric'>=med
		}
		
		* Construct POTENTIAL new strata.
		egen stratum_new = group(stratum_cur stratum_pot)

		* Check to make sure there are a sufficient number of observations in the POTENTIAL new srata
		gen split_obs_=1
		gen obs_tot_=1
		by stratum_new, sort: egen obs_tot=total(obs_tot_)
		drop obs_tot_
		replace split_obs_=0 if obs_tot<`Ntot_tresh'
		levelsof group, local(group) 
		foreach i of local group {
			gen obs_g`i'_ = (group==`i')
			by stratum_new, sort: egen obs_g`i'=total(obs_g`i'_)
			drop obs_g`i'_
			replace split_obs_=0 if obs_g`i'<`Ngroup_thresh'
		}
		by stratum_cur, sort: egen split_obs=min(split_obs_)
		drop split_obs_
		tab stratum_cur split_obs

		tempfile hold
		save `hold', replace

		use `hold' if split_homog==0 | split_obs==0, clear
		gen iter=`iter'
		append using stratified
		save stratified, replace

		use `hold' if split_homog==1 & split_obs==1, clear
		if (_N==0) {
			local exit="Yes"
		}
		else {
			drop F split_* med stratum_pot stratum_cur obs_*
			egen stratum_cur = group(stratum_new)
			drop stratum_new
			save notstratified, replace
		}
		local iter=`iter'+1
	}
	erase notstratified.dta
	use stratified, clear
	erase stratified.dta
end


use samples_comparison, clear
gen nih=(grant_countnih>0 | pt_nih==1)
gen post=(year>2008)
gen ta=1-oa
gen group_dd=.
replace group_dd=1 if nih==1 & post==1
replace group_dd=2 if nih==1 & post==0
replace group_dd=3 if nih==0 & post==1
replace group_dd=4 if nih==0 & post==0
gen group_ddd=.
replace group_ddd=1 if nih==1 & post==1 & ta==1
replace group_ddd=2 if nih==1 & post==1 & ta==0
replace group_ddd=3 if nih==1 & post==0 & ta==1
replace group_ddd=4 if nih==1 & post==0 & ta==0
replace group_ddd=5 if nih==0 & post==1 & ta==1
replace group_ddd=6 if nih==0 & post==1 & ta==0
replace group_ddd=7 if nih==0 & post==0 & ta==1
replace group_ddd=8 if nih==0 & post==0 & ta==0
keep pmid sample_* group_* year logit_* prob_* ps_*
compress
save temp, replace

* Save the file in which the stratfication information will be stored.
keep pmid sample_* group_*
save samples_stratified, replace

set more off
local samples = `" "prca_1to1" "prca_full" "journal" "medline" "'
foreach sample in `samples' {

	local frameworks `" "_dd" "_ddd" "'
	foreach framework in `frameworks' {
		if ("`framework'"=="_dd") {
			local years `" "_2011" "_2013" "'
		}
		if ("`framework'"=="_ddd") {
			local years `" "_2011" "'
		}
		
		foreach year in `years' {
			
			local pspecs `" "lin" "quad" "'
			foreach pspec in `pspecs' {
			
				local trimmed `" "" "_t" "'
				foreach trim in `trimmed' {

					* Initial values
					local strata=1
					local exit="No"
					local iter=1
					
					use temp, clear
					keep if ps_`pspec'_`sample'`year'`framework'`trim'==1
					keep pmid group`framework' logit_`pspec'_`sample'`year'`framework'`trim' prob_`pspec'_`sample'`year'`framework'`trim'
					rename logit_`pspec'_`sample'`year'`framework'`trim' logit
					rename prob_`pspec'_`sample'`year'`framework'`trim' prob
					rename group`framework' group
					
					* Stopping rules
					local F_thresh=2
					local Ngroup_thresh=100
					local Ntot_tresh=1000
					stratifypscore "`F_thresh'" "`Ngroup_thresh'" "`Ntot_tresh'"
					
					tempfile hold
					save `hold', replace
					collapse (mean) prob, by(stratum_cur iter) fast
					sort prob
					gen stratum=_n
					merge 1:m iter stratum_cur using `hold'
					drop _merge
					
					drop obs_*
					gen obs_tot_=1
					by stratum, sort: egen obs_tot=total(obs_tot_)
					drop obs_tot_
					levelsof group, local(group) 
					foreach i of local group {
						gen obs_g`i'_ = (group==`i')
						by stratum, sort: egen obs_g`i'=total(obs_g`i'_)
						drop obs_g`i'_
					}

					keep pmid iter prob stratum logit F obs_*
					* Shorten names for Stata name requirements
					rename stratum strat
					if ("`pspec'"=="lin") {
						local p="l"
					}
					if ("`pspec'"=="quad") {
						local p="q"
					}
					
					foreach var of varlist _all {
						rename `var' `var'_`p'_`sample'`year'`framework'`trim'
					}
					rename pmid_ pmid

					order pmid strat prob logit iter F obs_*
					compress
					merge 1:1 pmid using samples_stratified
					drop _merge
					save samples_stratified, replace
				}
			}
		}
	}
}
erase temp.dta
