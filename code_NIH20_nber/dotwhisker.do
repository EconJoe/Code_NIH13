
capture program drop dotwhiskerR
program define dotwhiskerR
	
	args dataset outcomevar					
	
	* Write R code for dotwhisker plot
	quietly: file open rcode using dotwhisker.R, write replace
	quietly: file write rcode ///
		`"library(dotwhisker)"' _newline ///
		`"library(broom)"' _newline ///
		`"library(dplyr)"' _newline ///
		`"library(readstata13)"' _newline ///
		`"dat <- read.dta13("/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output/`dataset'.dta")"' _newline ///
		`"colnames(dat) <- c("estimate", "std.error", "model", "term")"' _newline ///
		`"pdf("/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output/Graphs/coefplot_`outcomevar'.pdf")"' _newline ///
		`"dwplot(dat, alpha=0.05, size = 0.25, dodge_size = 0.50, dot_args = list(aes(colour = model, shape = model))) +"' _newline ///
		  `"geom_vline(xintercept = 0, colour = "grey60", linetype = 2) +"' _newline ///
		  `"scale_shape_manual(values = c(0, 1, 2, 5, 15, 16, 17, 18)) +"' _newline ///
		  `"theme_bw() +"' _newline ///
		  `"xlab("Coefficient Estimate") +"' _newline ///
		  `"theme(legend.title = element_blank())"' _newline ///
		`"dev.off()"'
	quietly: file close rcode
	* Invoke R and run file
	rsource using dotwhisker.R, rpath("/usr/lib64/R/bin/R") roptions("--save")
end


capture program drop dotwhisker_pubpatterns
program define dotwhisker_pubpatterns
	
	args outcomevar treatment pspec
	
	use coeffs_pubpatterns_reg_`outcomevar', clear
	if ("`treatment'"=="Standard" | "`treatment'"=="Linear") {
		keep if treatment=="`treatment'"
	}
	if ("`treatment'"=="Standard/Linear") {
		keep if treatment=="Standard" | treatment=="Linear"
	}
	keep if pspec=="`pspec'"
	keep if parm=="1.nih#1.post"
	keep sample covariates treatment trim pspec estimate stderr
	gen type="reg"
	tempfile hold
	save `hold', replace

	use coeffs_pubpatterns_strat_`outcomevar', clear
	if ("`treatment'"=="Standard" | "`treatment'"=="Linear") {
		keep if treatment=="`treatment'"
	}
	if ("`treatment'"=="Standard/Linear") {
		keep if treatment=="Standard" | treatment=="Linear"
	}
	keep if pspec=="`pspec'"
	keep if parm=="1.nih#1.post"
	destring obs stratum, replace
	by sample covariates treatment trim pspec, sort: egen tot_obs=total(obs)
	gen estimate_w = estimate*(obs/tot_obs)
	gen var_w = (stderr^2)*(obs/tot_obs)^2
	by sample covariates treatment trim pspec, sort: egen att=total(estimate_w)
	by sample covariates treatment trim pspec, sort: egen var=total(var_w)
	keep sample covariates treatment trim pspec att var
	duplicates drop
	gen sd=sqrt(var)
	gen t=att/sd
	rename att estimate
	rename sd stderr
	keep sample covariates treatment trim pspec estimate stderr
	gen type="strat"
	append using `hold'
	
	* The number prefixes are just added for sorting and will be eliminated.
	gen model=""
	replace model="1_DID" if covariates=="No" & trim=="No" & type=="reg"
	replace model="2_DID w/Cov" if covariates=="Yes" & trim=="No" & type=="reg"
	replace model="3_DID (Trimmed)" if covariates=="No" & trim=="Yes" & type=="reg"
	replace model="4_DID w/Cov (Trimmed)" if covariates=="Yes" & trim=="Yes" & type=="reg"
	replace model="5_Stratified DID" if covariates=="No" & trim=="No" & type=="strat"
	replace model="6_Stratified DID w/Cov" if covariates=="Yes" & trim=="No" & type=="strat"
	replace model="7_Stratified DID (Trimmed)" if covariates=="No" & trim=="Yes" & type=="strat"
	replace model="8_Stratified DID w/Cov (Trimmed)" if covariates=="Yes" & trim=="Yes" & type=="strat"

	if ("`treatment'"=="Standard" | "`treatment'"=="Linear") {

		gen term=""
		replace term = "1_MEDLINE" if sample=="medline"
		replace term = "2_Journal" if sample=="journal"
		replace term = "3_Full PRCA" if sample=="prca_full"
		replace term = "4_1-to-1 PRCA" if sample=="prca_1to1"
	}
		
	if ("`treatment'"=="Standard/Linear") {
		
		gen term=""
		replace term = "1_MEDLINE Standard" if sample=="medline" & treatment=="Standard"
		replace term = "2_Journal Standard" if sample=="journal" & treatment=="Standard"
		replace term = "3_Full PRCA Standard" if sample=="prca_full" & treatment=="Standard"
		replace term = "4_1-to-1 PRCA Standard" if sample=="prca_1to1" & treatment=="Standard"
		replace term = "5_MEDLINE Linear" if sample=="medline" & treatment=="Linear"
		replace term = "6_Journal Linear" if sample=="journal" & treatment=="Linear"
		replace term = "7_Full PRCA Linear" if sample=="prca_full" & treatment=="Linear"
		replace term = "8_1-to-1 PRCA Linear" if sample=="prca_1to1" & treatment=="Linear"
	}
		
	sort term model
	keep estimate stderr model term
	
	replace model = regexs(1) if regexm(model, "^[0-9]_(.*)")
	replace term = regexs(1) if regexm(term, "^[0-9]_(.*)")
	
	save temp_, replace	
end


capture program drop dotwhisker_forwardcites
program define dotwhisker_forwardcites
	
	args outcomevar treatment pspec framework
	
	use coeffs_forwardcites_reg_`outcomevar', clear
	keep if pspec=="`pspec'"

	if ("`treatment'"=="Standard" | "`treatment'"=="Linear") {
		keep if treatment=="`treatment'"
	}
	if ("`treatment'"=="Standard/Linear") {
		keep if treatment=="Standard" | treatment=="Linear"
	}

	keep if framework=="`framework'"
	if ("`framework'" == "dd") {
		keep if parm=="1.nih#1.post"
	}
	if ("`framework'" == "ddd") {
		keep if parm=="1.nih#1.post#1.ta"
	}

	keep sample covariates treatment trim pspec journfe estimate stderr
	gen type="reg"
	tempfile hold
	save `hold', replace

	use coeffs_forwardcites_strat_`outcomevar', clear
	keep if pspec=="`pspec'"

	if ("`treatment'"=="Standard" | "`treatment'"=="Linear") {
		keep if treatment=="`treatment'"
	}
	if ("`treatment'"=="Standard/Linear") {
		keep if treatment=="Standard" | treatment=="Linear"
	}

	keep if framework=="`framework'"
	if ("`framework'" == "dd") {
		keep if parm=="1.nih#1.post"
	}
	if ("`framework'" == "ddd") {
		keep if parm=="1.nih#1.post#1.ta"
	}

	keep sample covariates treatment trim pspec journfe estimate stderr obs stratum
	destring obs stratum, replace
	by sample covariates treatment trim pspec journfe, sort: egen tot_obs=total(obs)
	gen estimate_w = estimate*(obs/tot_obs)
	gen var_w = (stderr^2)*(obs/tot_obs)^2
	by sample covariates treatment trim pspec journfe, sort: egen att=total(estimate_w)
	by sample covariates treatment trim pspec journfe, sort: egen var=total(var_w)
	keep sample covariates treatment trim pspec journfe att var
	duplicates drop
	gen sd=sqrt(var)
	gen t=att/sd
	rename att estimate
	rename sd stderr
	keep sample covariates treatment trim pspec journfe estimate stderr
	gen type="strat"
	append using `hold'
	keep if (covariates=="No" & journfe=="No") | (covariates=="Yes" & journfe=="Yes")

	if ("`framework'" == "dd") {
		local framework = "DD"
	}
	if ("`framework'" == "ddd") {
		local framework = "DDD"
	}

	gen model=""
	replace model="1_`framework'" if covariates=="No" & trim=="No" & type=="reg" & journfe=="No"
	replace model="2_`framework' w/Cov" if covariates=="Yes" & trim=="No" & type=="reg" & journfe=="Yes"
	replace model="3_`framework' (Trimmed)" if covariates=="No" & trim=="Yes" & type=="reg" & journfe=="No"
	replace model="4_`framework' w/Cov (Trimmed)" if covariates=="Yes" & trim=="Yes" & type=="reg" & journfe=="Yes"
	replace model="5_Stratified `framework'" if covariates=="No" & trim=="No" & type=="strat" & journfe=="No"
	replace model="6_Stratified `framework' w/Cov" if covariates=="Yes" & trim=="No" & type=="strat" & journfe=="Yes"
	replace model="7_Stratified `framework' (Trimmed)" if covariates=="No" & trim=="Yes" & type=="strat" & journfe=="No"				
	replace model="8_Stratified `framework' w/Cov (Trimmed)" if covariates=="Yes" & trim=="Yes" & type=="strat" & journfe=="Yes"

	gen term=""
	replace term = "1_MEDLINE" if sample=="medline"
	replace term = "2_Journal" if sample=="journal"
	replace term = "3_Full PRCA" if sample=="prca_full"
	replace term = "4_1-to-1 PRCA" if sample=="prca_1to1"

	sort term model
	keep estimate stderr model term
	
	replace model = regexs(1) if regexm(model, "^[0-9]_(.*)")
	replace term = regexs(1) if regexm(term, "^[0-9]_(.*)")
	
	save temp_, replace
end




* The arguments for the program dotwhisker_pubpatterns are:
*   outcomevar: ta, scinat
*   treatment: Standard, Linear, Standard/Linear
*   pspec: lin, quad
set more off
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output/
dotwhisker_pubpatterns "ta" "Standard" "lin"
dotwhiskerR "temp_" "ta"
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output/
dotwhisker_pubpatterns "scinat" "Standard/Linear" "lin"
dotwhiskerR "temp_" "scinat"


* The arguments for the program dotwhisker_pubpatterns are:
*   outcomevar: fc_2yr, fc_com_2yr, fc_dev_2yr
*   treatment: Standard, Linear, Standard/Linear
*   pspec: lin, quad
*   framework: dd, ddd
set more off
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output/
dotwhisker_forwardcites "fc_2yr" "Standard" "lin" "ddd"
dotwhiskerR "temp_" "fc_2yr"

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output/
dotwhisker_forwardcites "fc_com_2yr" "Standard" "lin" "ddd"
dotwhiskerR "temp_" "fc_com_2yr"

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output/
dotwhisker_forwardcites "fc_dev_2yr" "Standard" "lin" "ddd"
dotwhiskerR "temp_" "fc_dev_2yr"
