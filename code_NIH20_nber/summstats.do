
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/
use samples_comparison, clear
gen nih=(grant_countnih>0 | pt_nih==1)
gen ta=1-oa
gen science=(nlmid=="0404511")
gen nature=(nlmid=="0410462")
gen scinat=(science==1 | nature==1)
gen post=(year>2008)
tempfile hold
save `hold', replace

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Output/
set more off
local samples `" "medline" "journal" "prca_full" "prca_1to1" "'
*local samples `" "prca_1to1" "'
foreach sample in `samples' {

	use `hold', clear
	keep if sample_`sample'==1

	local backcites "bc_count bc_oa_count"
	local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
	local mesh "count_desc count_qual"
	local author "author_count author_corp"
	local pubtype "pt_ja pt_nophs pt_phs pt_arra pt_nous pt_rev pt_engabs pt_cr pt_comp pt_meta pt_eval pt_guide pt_multi pt_obs pt_rct pt_tech pt_twin pt_valid pt_ct pt_irreg"
	local language "lang_other lang_eng lang_ger lang_fre lang_rus lang_jpn lang_spa lang_ita lang_chi"
	local othergrant "grant_countnonnih"
	local type "type_com type_edu type_eduhos type_gov type_hos type_mil type_org type_unk"
	local covariates `" `backcites' `ment' `mesh' `author' `pubtype' `language' `othergrant' `type' "'

	local outcomes "ta scinat fc_2yr fc_com_2yr fc_dev_2yr"

	keep pmid nih post year `outcomes' `covariates'

	label var fc_2yr "2-Yr For. Cites (Total)"
	label var fc_com_2yr "2-Yr Forward Cites (Com. Enterprise)"
	label var fc_dev_2yr "2-Yr Forward Cites (Dev. Country)"
	label var ta "TA Journal"
	label var scinat "Science/Nature"
	
	label var bc_count "Backward Cites"
	label var bc_oa_count "OA Backward Cites"
	label var ment_0_both_001 "Age 0 Top Concepts"
	label var ment_5_both_001 "\$Age\leq5$ Top Concepts"
	label var wordcount_both "Total Concepts"
	label var count_desc "Total MeSH Descriptors"
	label var count_qual "Total MeSH Qualifiers"
	label var author_count "Author Count"
	label var author_corp "Corporate Author"
	label var pt_ja "Journal Article"
	label var pt_rev "Review Article"
	label var pt_engabs "English Abstract"
	label var pt_cr "Case Report"
	label var pt_comp "Comparative Study"
	label var pt_ct "Clinical Trial"
	label var pt_irreg "Irregular Article"
	label var lang_other "Other Language"
	label var lang_eng "English"
	label var lang_ger "German"
	label var lang_fre "French"
	label var lang_rus "Russian"
	label var lang_jpn "Japanese"
	label var lang_spa "Spanish"
	label var lang_ita "Italian"
	label var lang_chi "Chinese"
	label var grant_countnonnih "Other Grant Count"
	label var pt_arra "Research Support, ARRA"

	quietly: file open test using ss_`sample'.tex, write replace

	quietly: file write test "\begin{table}" _newline
	quietly: file write test "\begin{flushleft}Table AX: Summary Statistics for the .... Sample.\end{flushleft} \\" _newline
	quietly: file write test "\resizebox{18cm}{!} {" _newline
	quietly: file write test "\begin{tabular}{lccccccccccccccc}" _newline
	quietly: file write test "\hline\hline" _newline
	quietly: file write test "&  & \multicolumn{2}{c}{\textbf{NIH Pre}} & & \multicolumn{2}{c}{\textbf{Comp. Pre}} & & \multicolumn{2}{c}{\textbf{NIH Post}} & & \multicolumn{2}{c}{\textbf{Comp. Post}}  & & \multicolumn{2}{c}{\textbf{All}} \\" _newline
	quietly: file write test "&  & Mean & SD & & Mean & SD & & Mean & SD & & Mean & SD & & Mean & SD \\" _newline
	quietly: file write test "\hline" _newline

	quietly: file write test "\\" _newline
	quietly: file write test "\textbf{Outcome Variables} \\" _newline

	local covs `" "ta" "scinat" "fc_2yr" "fc_com_2yr" "fc_dev_2yr" "'
	foreach cov in `covs' {

		local label: variable label `cov'
		quietly: file write test "\hspace{0.25em}`label' & "

		forvalues post=0/1 {

			forvalues nih=1(-1)0 {

				su `cov' if nih==`nih' & post==`post'
				local mean=round(`r(mean)', 0.01)
				if regex("`mean'", "^\.") {
					local mean = "0`mean'"
				}
				else if regex("`mean'", "^-\.") {
					local mean = "-0`mean'"
				}
				else {
					local mean = `mean'
				}
				local sd=round(`r(sd)', 0.01)
				if regex("`sd'", "^\.") {
					local sd = "0`sd'"
				}
				else if regex("`sd'", "^-\.") {
					local sd = "-0`sd'"
				}
				else {
					local sd = `sd'
				}
				display in red "& `mean' & `sd'"
				quietly: file write test "& `mean' & `sd' & "
			}
			
		}
		su `cov'
		local mean=round(`r(mean)', 0.01)
		if regex("`mean'", "^\.") {
			local mean = "0`mean'"
		}
		else if regex("`mean'", "^-\.") {
			local mean = "-0`mean'"
		}
		else {
			local mean = `mean'
		}
		local sd=round(`r(sd)', 0.01)
		if regex("`sd'", "^\.") {
			local sd = "0`sd'"
		}
		else if regex("`sd'", "^-\.") {
			local sd = "-0`sd'"
		}
		else {
			local sd = `sd'
		}
		display in red "& `mean' & `sd'"
		quietly: file write test "& `mean' & `sd' \\" _newline
	}

	quietly: file write test "\\" _newline
	quietly: file write test "\textbf{Covariates} \\" _newline


	local backcites "bc_count bc_oa_count"
	local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
	local mesh "count_desc count_qual"
	local author "author_count author_corp"
	local pubtype "pt_ja pt_nophs pt_phs pt_arra pt_nous pt_rev pt_engabs pt_cr pt_comp pt_meta pt_eval pt_guide pt_multi pt_obs pt_rct pt_tech pt_twin pt_valid pt_ct pt_irreg"
	local language "lang_other lang_eng lang_ger lang_fre lang_rus lang_jpn lang_spa lang_ita lang_chi"
	local othergrant "grant_countnonnih"
	local type "type_com type_edu type_eduhos type_gov type_hos type_mil type_org type_unk"
	local covariates `" `backcites' `ment' `mesh' `author' `pubtype' `language' `othergrant' `type' "'

	foreach cov in `covariates' {

		local label: variable label `cov'
		quietly: file write test "\hspace{0.25em}`label' & "

		forvalues post=0/1 {

			forvalues nih=1(-1)0 {

				su `cov' if nih==`nih' & post==`post'
				local mean=round(`r(mean)', 0.01)
				if regex("`mean'", "^\.") {
					local mean = "0`mean'"
				}
				else if regex("`mean'", "^-\.") {
					local mean = "-0`mean'"
				}
				else {
					local mean = `mean'
				}
				local sd=round(`r(sd)', 0.01)
				if regex("`sd'", "^\.") {
					local sd = "0`sd'"
				}
				else if regex("`sd'", "^-\.") {
					local sd = "-0`sd'"
				}
				else {
					local sd = `sd'
				}
				display in red "& `mean' & `sd'"
				quietly: file write test "& `mean' & `sd' & "
			}
			
		}
		su `cov'
		local mean=round(`r(mean)', 0.01)
		if regex("`mean'", "^\.") {
			local mean = "0`mean'"
		}
		else if regex("`mean'", "^-\.") {
			local mean = "-0`mean'"
		}
		else {
			local mean = `mean'
		}
		local sd=round(`r(sd)', 0.01)
		if regex("`sd'", "^\.") {
			local sd = "0`sd'"
		}
		else if regex("`sd'", "^-\.") {
			local sd = "-0`sd'"
		}
		else {
			local sd = `sd'
		}
		display in red "& `mean' & `sd'"
		quietly: file write test "& `mean' & `sd' \\" _newline
	}
	su ta if nih==1 & post==0
	local nihpre=`r(N)'
	su ta if nih==0 & post==0
	local comppre=`r(N)'
	su ta if nih==1 & post==1
	local nihpost=`r(N)'
	su ta if nih==0 & post==1
	local comppost=`r(N)'
	su ta
	local all=`r(N)'

	quietly: file write test "\\" _newline
	quietly: file write test "Observations &  & \multicolumn{2}{c}{`nihpre'} & & \multicolumn{2}{c}{`comppre'} & & \multicolumn{2}{c}{`nihpost'} & & \multicolumn{2}{c}{`comppost'}  & & \multicolumn{2}{c}{`all'} \\" _newline
	quietly: file write test "\hline" _newline
	quietly: file write test "\end{tabular}" _newline
	quietly: file write test "}" _newline
	quietly: file write test "\end{table}" _newline
	quietly: file close test
}
