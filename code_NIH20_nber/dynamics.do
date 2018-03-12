

capture program drop dynamics
program define dynamics
	
	args dataset depvar sample pspec framework trimmed covariates journfe endyear
	
	cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output/
	use `dataset', clear
	keep if treatment=="Fully Flexible"
	keep if depvar=="`depvar'"
	keep if sample=="`sample'"
	keep if pspec=="`pspec'"
	keep if framework=="`framework'"
	keep if trim=="`trimmed'"
	keep if covariates=="`covariates'"
	keep if journfe=="`journfe'"
	
	#delimit ;
	if ("`sample'" == "prca_1to1") {; local samplename="1-to-1 PRCA"; };
	if ("`sample'" == "prca_full") {; local samplename="Full PRCA"; };
	if ("`sample'" == "journal") {; local samplename="Journal"; };
	if ("`sample'" == "medline") {; local samplename="MEDLINE"; };
	
	if ("`framework'" == "dd") {; keep if regexm(parm, "nih_yr_"); };
	if ("`framework'" == "ddd") {; keep if regexm(parm, "ta_nih_yr_"); };
	#delimit cr
	
	gen year = regexs(0) if regexm(parm, "[0-9][0-9][0-9][0-9]")
	destring year, replace
	keep estimate min95 max95 stderr year

	twoway (line max95 year, lwidth(none) lcolor(navy) lpattern(dash)) ///
		   (connected estimate year, lcolor(navy) mcolor(navy)msymbol(square_hollow) lpattern(dash)) ///
		   (line min95 year, lwidth(none) lcolor(navy) lpattern(dash)), ///
		   xlabel(2003(1)`endyear', angle(forty_five)) ///
		   xline(2008) ///
		   legend(off) ///
		   xtitle("Year") ///
		   title("`samplename'") ///
		   graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))
	graph export "/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output/Graphs/dynamics_`depvar'_`sample'_`pspec'_`framework'.pdf", as(pdf) replace

end

dynamics "coeffs_pubpatterns_reg_ta" "ta" "prca_1to1" "lin" "dd" "No" "No" "No" "2013"
dynamics "coeffs_pubpatterns_reg_ta" "ta" "prca_full" "lin" "dd" "No" "No" "No" "2013"
dynamics "coeffs_pubpatterns_reg_ta" "ta" "journal" "lin" "dd" "No" "No" "No" "2013"
dynamics "coeffs_pubpatterns_reg_ta" "ta" "medline" "lin" "dd" "No" "No" "No" "2013"

dynamics "coeffs_pubpatterns_reg_scinat" "scinat" "prca_1to1" "lin" "dd" "No" "No" "No" "2013"
dynamics "coeffs_pubpatterns_reg_scinat" "scinat" "prca_full" "lin" "dd" "No" "No" "No" "2013"
dynamics "coeffs_pubpatterns_reg_scinat" "scinat" "journal" "lin" "dd" "No" "No" "No" "2013"
dynamics "coeffs_pubpatterns_reg_scinat" "scinat" "medline" "lin" "dd" "No" "No" "No" "2013"

dynamics "coeffs_forwardcites_reg_fc_2yr" "fc_2yr" "prca_1to1" "lin" "ddd" "No" "No" "No" "2011"
dynamics "coeffs_forwardcites_reg_fc_2yr" "fc_2yr" "prca_full" "lin" "ddd" "No" "No" "No" "2011"
dynamics "coeffs_forwardcites_reg_fc_2yr" "fc_2yr" "journal" "lin" "ddd" "No" "No" "No" "2011"
dynamics "coeffs_forwardcites_reg_fc_2yr" "fc_2yr" "medline" "lin" "ddd" "No" "No" "No" "2011"


