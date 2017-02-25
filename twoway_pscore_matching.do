
cd D:\Research\Projects\NIHMandate\NIH15\Data
use estsample_large, clear
keep if year>=2000 & year<=2013
gen nih=(nih_pubtype==1 | nih_grantlist==1)
gen post=(year>2008)



set seed 1235
sample 5
save temp, replace

use temp, clear

local backcites "bc_count bc_oa_count"
local ment "ment_0_both_001 ment_5_both_001 wordcount_both"
local mesh "count_desc count_qual"
local author "authortotal"
local pubtype "pt_*"
local meshaug1 "mean_arttot_meshvintage mean_arttot_mc_d_all mean_arttot_cum_mc_d_all"
local spec `" `ment' `author' "'

gen bc_count_=.
replace bc_count_=0 if bc_count==0
replace bc_count_=1 if bc_count>=1 & bc_count<=13
replace bc_count_=2 if bc_count>=14 & bc_count<=30
replace bc_count_=3 if bc_count>=31 & bc_count<=47
replace bc_count_=4 if bc_count>=48 & bc_count<=61
replace bc_count_=5 if bc_count>=62 & bc_count<=117
replace bc_count_=6 if bc_count>=118


logit nih `spec'
predict pr, pr
rename pr pr_nih
predict xb, xb
rename xb xb_nih

logit post `spec'
predict pr, pr
rename pr pr_post
predict xb, xb
rename xb xb_post


twoway (kdensity xb_nih if nih==1 & post==1) ///
       (kdensity xb_nih if nih==1 & post==0) ///
	   (kdensity xb_nih if nih==0 & post==1) ///
	   (kdensity xb_nih if nih==0 & post==0), ///
	   legend(order(1 "Treated After" 2 "Treated Before" 3 "Control After" 4 "Control Before"))

	   
twoway (kdensity pr_nih if nih==1 & post==1) ///
       (kdensity pr_nih if nih==1 & post==0) ///
	   (kdensity pr_nih if nih==0 & post==1) ///
	   (kdensity pr_nih if nih==0 & post==0), ///
	   legend(order(1 "Treated After" 2 "Treated Before" 3 "Control After" 4 "Control Before"))
	   
	   
twoway (kdensity xb_post if nih==1 & post==1) ///
       (kdensity xb_post if nih==1 & post==0) ///
	   (kdensity xb_post if nih==0 & post==1) ///
	   (kdensity xb_post if nih==0 & post==0), ///
	   legend(order(1 "Treated After" 2 "Treated Before" 3 "Control After" 4 "Control Before"))
	   

twoway (kdensity xb_nih if nih==1 & post==1 & xb_nih>=-4 & xb_nih<=1) ///
       (kdensity xb_nih if nih==1 & post==0 & xb_nih>=-4 & xb_nih<=1), ///
	   legend(order(1 "Treated After" 2 "Treated Before"))
	   
	   
	   
	   
	   
	   
	   
	   
	   
	   
	   
	   
	   
	   
	   
