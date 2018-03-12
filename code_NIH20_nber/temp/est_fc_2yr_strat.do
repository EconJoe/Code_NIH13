
* This dofile computes regression and stratified regerssion estimates. It takes the following arguments:
*  1) Data set used to compute
*  2) Dependent variable of the models (ta, scinat, fc_2yr, fc_com_2yr, fc_dev_2yr)
*  3) Variable on which to cluster standard errors (group_ui4 for ta and scinat; group_nlmid for fc_2yr, fc_com_2yr, and fc_deve_2yr)
*  4) Sample of the entire data on which to compute estimates (medline, journal, prca_full, prca_1to1)
*  5) Propensity score specification (lin, quad)
*  6) End year of the analysis (2013 for ta and scinat; 2011 for fc_2yr, fc_com_2yr, fc_dev_2yr)
*  7) Frame for identification -- differences-in-differences (DID) or triple differences (DDD) (dd, ddd)
*  8) Whether the sample should be trimmmed or not ("", "_t")
*  9) Treatment variables -- standard DID/DDD, linear trend DID/DDD, or fully flexible DID/DDD ("Standard", "Linear" "Fully Flexible")
*  10) Whether or not to stratify the sample prior to estimation ("No", "Yes")

capture program drop estimation
program define estimation
	
	args dataset depvar clustvar sample pspec endyear framework trimmed treatment stratified
	
	#delimit ;

	use `dataset' if ps_`pspec'_`sample'_`endyear'_`framework'`trimmed'==1, clear;
				
	local backcites "bc_count bc_oa_count";
	local ment "ment_0_both_001 ment_5_both_001 wordcount_both";
	local mesh "count_desc count_qual";
	local author "author_count author_corp";
	local pubtype "pt_ja pt_nophs pt_phs pt_arra pt_nous pt_rev pt_engabs pt_cr pt_comp pt_meta pt_eval pt_guide pt_multi pt_obs pt_rct pt_tech pt_twin pt_valid pt_ct pt_irreg";
	local language "lang_other lang_eng lang_ger lang_fre lang_rus lang_jpn lang_spa lang_ita lang_chi";
	local othergrant "grant_countnonnih";
	local type "type_com type_edu type_eduhos type_gov type_hos type_mil type_org type_unk";
	local covariates `" `backcites' `ment' `mesh' `author' `pubtype' `language' `othergrant' `type' "';
			
	if ("`pspec'"=="lin") {; local p = "l"; };	
	if ("`pspec'"=="quad") {; local p = "q"; };

	keep pmid year `depvar' ta nih post sample_* `covariates' group_* 
	     yr_2003-yr_`endyear' nih_yr_2003-nih_yr_`endyear' ta_yr_2003-ta_yr_`endyear' ta_nih_yr_2003-ta_nih_yr_`endyear'
	     ps_`pspec'_`sample'_`endyear'_`framework'`trimmed' prob_`pspec'_`sample'_`endyear'_`framework'`trimmed' strat_`p'_`sample'_`endyear'_`framework'`trimmed';
	   
	compress; tempfile hold; save `hold', replace;
	
	clear; gen parm=""; tempfile coeffs; save `coeffs', replace;
	
	if ("`trimmed'"=="") {; local trimmed="No"; };
	if ("`trimmed'"=="_t") {; local trimmed="Yes"; };
	
	* Differences-in-Differences;
	if ("`framework'" == "dd") {;
		if ("`treatment'"=="Standard") {; local treatvars = "i.nih##i.post i.year"; };
		if ("`treatment'"=="Linear") {; local treatvars = "i.nih##i.post i.nih#c.year i.year"; };
		if ("`treatment'"=="Fully Flexible") {; local treatvars = "nih_yr_* yr_*"; };
	};
	* Triple Differences;
	if ("`framework'" == "ddd") {;
		if ("`treatment'"=="Standard") {; local treatvars = "i.nih##i.post##ta i.year"; };
		if ("`treatment'"=="Linear") {; local treatvars = "i.nih##i.post##ta i.ta##i.nih##c.year i.year"; };
		if ("`treatment'"=="Fully Flexible") {; local treatvars = "ta_nih_yr_* ta_yr_* nih_yr_* yr_*"; };
	};
	
	if ("`stratified'" == "No") {; 
	
		* No covariates, No journal FEs;
		use `hold', clear;
		local obs=_N;
		parmby "reg `depvar' `treatvars', cluster(`clustvar')", norestore;
		gen depvar="`depvar'"; gen clustvar="`clustvar'"; gen sample="`sample'"; gen endyear="`endyear'"; gen covariates="No"; gen journfe="No"; gen treatment="`treatment'"; gen trimmed="`trimmed'"; gen pspec="`pspec'"; gen framework="`framework'"; gen obs="`obs'";
		append using `coeffs'; save `coeffs', replace;
		
		* Covariates. No journal FEs;
		use `hold', clear;
		local obs=_N;
		parmby "reghdfe `depvar' `treatvars' `covariates', absorb(group_ui group_country) cluster(`clustvar') keepsingletons", norestore;
		gen depvar="`depvar'"; gen clustvar="`clustvar'"; gen sample="`sample'"; gen endyear="`endyear'"; gen covariates="Yes"; gen journfe="No"; gen treatment="`treatment'"; gen trimmed="`trimmed'"; gen pspec="`pspec'"; gen framework="`framework'"; gen obs="`obs'";
		append using `coeffs'; save `coeffs', replace;
		
		* Variables that vary WITHIN journal. Always cluster standard errors at journal level.;
		if ("`depvar'" == "fc_2yr" | "`depvar'" == "fc_com_2yr" | "`depvar'" == "fc_dev_2yr") {;
		
			* No Covariates. Journal FEs.;
			use `hold', clear;
			local obs=_N;
			parmby "reghdfe `depvar' `treatvars', absorb(group_nlmid) cluster(group_nlmid) keepsingletons", norestore;
			gen depvar="`depvar'"; gen clustvar="`clustvar'"; gen sample="`sample'"; gen endyear="`endyear'"; gen covariates="No"; gen journfe="Yes"; gen treatment="`treatment'"; gen trimmed="`trimmed'"; gen pspec="`pspec'"; gen framework="`framework'"; gen obs="`obs'";
			append using `coeffs'; save `coeffs', replace;
			
			* No Covariates. Journal FEs.;
			use `hold', clear;
			local obs=_N;
			parmby "reghdfe `depvar' `treatvars' `covariates', absorb(group_ui group_nlmid group_country) cluster(group_nlmid) keepsingletons", norestore;
			gen depvar="`depvar'"; gen clustvar="`clustvar'"; gen sample="`sample'"; gen endyear="`endyear'"; gen covariates="Yes"; gen journfe="Yes"; gen treatment="`treatment'"; gen trimmed="`trimmed'"; gen pspec="`pspec'"; gen framework="`framework'"; gen obs="`obs'";
			append using `coeffs'; save `coeffs', replace;
		};
		
	};
	
	if ("`stratified'" == "Yes") {;
	
		use `hold', clear; qui su strat; local strat_max = `r(max)';
		forvalues i=1/`strat_max' {;
		
			display in red "--- Stratum `i' of `strat_max' ---";
	
			* No covariates, No journal FEs;
			use `hold' if strat==`i', clear;
			local obs=_N;
			qui parmby "reg `depvar' `treatvars', cluster(`clustvar')", norestore;
			gen depvar="`depvar'"; gen clustvar="`clustvar'"; gen sample="`sample'"; gen endyear="`endyear'"; gen covariates="No"; gen journfe="No"; gen treatment="`treatment'"; gen trimmed="`trimmed'"; gen pspec="`pspec'"; gen framework="`framework'"; gen obs="`obs'"; gen stratum="`i'";
			append using `coeffs'; save `coeffs', replace;
			
			* Covariates. No journal FEs;
			use `hold' if strat==`i', clear;
			local obs=_N;
			qui parmby "reghdfe `depvar' `treatvars' `covariates', absorb(group_ui group_country) cluster(`clustvar') keepsingletons", norestore;
			gen depvar="`depvar'"; gen clustvar="`clustvar'"; gen sample="`sample'"; gen endyear="`endyear'"; gen covariates="Yes"; gen journfe="No"; gen treatment="`treatment'"; gen trimmed="`trimmed'"; gen pspec="`pspec'"; gen framework="`framework'"; gen obs="`obs'"; gen stratum="`i'";
			append using `coeffs'; save `coeffs', replace;
			
			* Variables that vary WITHIN journal. Always cluster standard errors at journal level.;
			if ("`depvar'" == "fc_2yr" | "`depvar'" == "fc_com_2yr" | "`depvar'" == "fc_dev_2yr") {;
			
				* No Covariates. Journal FEs.;
				use `hold' if strat==`i', clear;
				local obs=_N;
				qui parmby "reghdfe `depvar' `treatvars', absorb(group_nlmid) cluster(group_nlmid) keepsingletons", norestore;
				gen depvar="`depvar'"; gen clustvar="`clustvar'"; gen sample="`sample'"; gen endyear="`endyear'"; gen covariates="No"; gen journfe="Yes"; gen treatment="`treatment'"; gen trimmed="`trimmed'"; gen pspec="`pspec'"; gen framework="`framework'"; gen obs="`obs'"; gen stratum="`i'";
				append using `coeffs'; save `coeffs', replace;
				
				* Covariates. Journal FEs.;
				use `hold' if strat==`i', clear;
				local obs=_N;
				qui parmby "reghdfe `depvar' `treatvars' `covariates', absorb(group_ui group_nlmid group_country) cluster(group_nlmid) keepsingletons", norestore;
				gen depvar="`depvar'"; gen clustvar="`clustvar'"; gen sample="`sample'"; gen endyear="`endyear'"; gen covariates="Yes"; gen journfe="Yes"; gen treatment="`treatment'"; gen trimmed="`trimmed'"; gen pspec="`pspec'"; gen framework="`framework'"; gen obs="`obs'"; gen stratum="`i'";
				append using `coeffs'; save `coeffs', replace;
			};
		};
	};
	
	#delimit cr
end


global inpath "/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data"
global outpath "/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output"


set more off
local depvars `" "fc_2yr" "fc_2yr_com" "fc_2yr_dev" "'
foreach depvar in `depvars' {

	local filename "coeffs_forwardcites_strat_`depvar'"
	clear
	gen parm=""
	cd $outpath
	save `filename', replace

	local samples `" "prca_1to1" "prca_full" "journal" "medline" "'
	foreach sample in `samples' {

		local treatments `" "Standard" "Linear" "Fully Flexible" "'
		foreach treatment in `treatments' {

			#delimit ;
			* Triple Differences;
			cd $inpath; estimation "temp" "`depvar'" "group_nlmid" "`sample'" "quad" "2011" "ddd" "" "`treatment'" "Yes"; cd $outpath; append using `filename'; save `filename', replace;
			cd $inpath; estimation "temp" "`depvar'" "group_nlmid" "`sample'" "quad" "2011" "ddd" "_t" "`treatment'" "Yes"; cd $outpath; append using `filename'; save `filename', replace;
			cd $inpath; estimation "temp" "`depvar'" "group_nlmid" "`sample'" "lin" "2011" "ddd" "" "`treatment'" "Yes"; cd $outpath; append using `filename'; save `filename', replace;
			cd $inpath; estimation "temp" "`depvar'" "group_nlmid" "`sample'" "lin" "2011" "ddd" "_t" "`treatment'" "Yes"; cd $outpath; append using `filename'; save `filename', replace;
			
			* DID;
			cd $inpath; estimation "temp" "`depvar'" "group_nlmid" "`sample'" "quad" "2011" "dd" "" "`treatment'" "Yes"; cd $outpath; append using `filename'; save `filename', replace;
			cd $inpath; estimation "temp" "`depvar'" "group_nlmid" "`sample'" "quad" "2011" "dd" "_t" "`treatment'" "Yes"; cd $outpath; append using `filename'; save `filename', replace;
			cd $inpath; estimation "temp" "`depvar'" "group_nlmid" "`sample'" "lin" "2011" "dd" "" "`treatment'" "Yes"; cd $outpath; append using `filename'; save `filename', replace;
			cd $inpath; estimation "temp" "`depvar'" "group_nlmid" "`sample'" "lin" "2011" "dd" "_t" "`treatment'" "Yes"; cd $outpath; append using `filename'; save `filename', replace;
			#delimit cr
		}
	}
}

#delimit cr

