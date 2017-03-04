
cd D:\Research\Projects\NIHMandate\NIH14\Data
import delimited "m2.csv", clear delimiter(comma) varnames(1)
keep pmid logit prob
compress
save m2_small, replace
