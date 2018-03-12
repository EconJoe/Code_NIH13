

cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/
use samples_comparison, clear
gen nih=(grant_countnih>0 | pt_nih==1)
gen ta=1-oa
gen post=(year>2008)

rename oa oa_tot
rename ta ta_tot
gen all_tot=1
gen oa_mean=oa_tot
gen ta_mean=ta_tot

collapse (sum) all_tot oa_tot ta_tot (mean) oa_mean ta_mean, by(year nih) fast

gen effect1=0.01
gen effect2=0.02
gen effect3=0.03

gen shift1=ta_mean-effect1 if year>2008 & nih==1
gen shift2=ta_mean-effect2 if year>2008 & nih==1
gen shift3=ta_mean-effect3 if year>2008 & nih==1

gen countertot1=all_tot*shift1 if year>2008 & nih==1
gen countertot2=all_tot*shift2 if year>2008 & nih==1
gen countertot3=all_tot*shift3 if year>2008 & nih==1

gen counterdiff1=ta_tot-countertot1 if year>2008 & nih==1
gen counterdiff2=ta_tot-countertot2 if year>2008 & nih==1
gen counterdiff3=ta_tot-countertot3 if year>2008 & nih==1

keep if year>2008 & nih==1

egen all_gtot=total(all_tot)
egen ta_gtot=total(ta_tot)
egen oa_gtot=total(oa_tot)
