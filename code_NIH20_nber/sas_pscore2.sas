
ods graphics off;
ods exclude all;

libname nih '/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/';
data work.estimation_sample; 
  set nih.pscore_covariates;
  rename treated_dd=dd;
  rename treated_ddd=ddd;
run;

data work.estimation_sample; 
  set work.estimation_sample; 
  rename treated_dd=dd;
  rename treated_ddd=ddd;
run;

* Create a file to hold the covariates for the linear and fully saturated models;
data work.estsample_lin; set work.estimation_sample; keep pmid year dd ddd sample_medline sample_journal sample_prca_full sample_prca_1to1 lin_1-lin_46; run;
data work.estsample_quad; set work.estimation_sample; keep pmid year dd ddd sample_medline sample_journal sample_prca_full sample_prca_1to1 lin_1-lin_46 quad_1-quad_982; run;
proc sort data=work.estsample_lin; by pmid; run;
proc sort data=work.estsample_quad; by pmid; run;

* Create a file to hold the final estimated propensity scores;
data work.pscores; set work.estimation_sample; keep pmid; run;
proc sort data=work.pscores; by pmid; run;

* Create a file to hold the final estimated logit coefficients;
data coeffs_logit; length Variable $ 9 DF 8 Estimate 8 StdErr 8 WaldChiSq 8 ProbChiSq 8_ESTTYPE_ $ 4 sample $ 9 spec $ 9 year $ 9 trim $ 9 depvar $ 9; run;

%macro pscore(sample, year, spec, depvar, covs);
  
  * Subset data by comparison group and year;
  data work.pscore_temp; 
    set work.estsample_&spec; 
    if sample_&sample=1;
    if year>=2003 & year<=&year;
  run;

  * Estimate logistic regression model;
  proc logistic data=work.pscore_temp;
    model &depvar (event='1') = &covs;
    output out = work.pscore_temp p = prob_&spec._&sample._&year._&depvar xbeta = logit_&spec._&sample._&year._&depvar;
    ods output ParameterEstimates = work.coeffs_temp;
  run;

  * Trim extreme estimated propensity scores and rerun logit on trimmed sample;
  data work.pscore_temp_trim; 
    set work.pscore_temp; 
    if (prob_&spec._&sample._&year._&depvar < 0.1 | prob_&spec._&sample._&year._&depvar > 0.9) then delete; 
    drop prob_&spec._&sample._&year._&depvar logit_&spec._&sample._&year._&depvar _LEVEL_; 
  run;

  * Estimate logistic regression model on trimmed sample;
  proc logistic data=work.pscore_temp_trim;
    model &depvar (event='1') = &covs;
    output out = work.pscore_temp_trim p = prob_&spec._&sample._&year._&depvar._t xbeta = logit_&spec._&sample._&year._&depvar._t;
    ods output ParameterEstimates = work.coeffs_temp_trim;
  run;

  * Subset data, keeping only ID info, log odds, and predicted values;
  * We do not want to export the huge number of variables used to estimate the model;
  data work.pscore_temp; 
    set work.pscore_temp; 
    keep pmid prob_&spec._&sample._&year._&depvar logit_&spec._&sample._&year._&depvar; 
  run;
  data work.pscore_temp_trim; 
    set work.pscore_temp_trim; 
    keep pmid prob_&spec._&sample._&year._&depvar._t logit_&spec._&sample._&year._&depvar._t; 
  run;

  * Merge data into a single file;
  proc sort data=work.pscore_temp; by pmid; run;
  proc sort data=work.pscore_temp_trim; by pmid; run;
  data work.pscores;
    merge work.pscores (IN=A) work.pscore_temp (IN=B);
    by pmid;
    if A=1 & B=1 then ps_&spec._&sample._&year._&depvar=1;
    if A=1 & B=0 then ps_&spec._&sample._&year._&depvar=0;
  run;
  data work.pscores;
    merge work.pscores (IN=A) work.pscore_temp_trim (IN=B);
    by pmid;
    if A=1 & B=1 then ps_&spec._&sample._&year._&depvar._t=1;
    if A=1 & B=0 then ps_&spec._&sample._&year._&depvar._t=0;
  run;

  * Organize coefficient output for appending and then append;
  data work.coeffs_temp; set work.coeffs_temp; sample="&sample"; spec="&spec"; year="&year"; trim="No"; depvar="&depvar"; run;
  data work.coeffs_temp_trim; set work.coeffs_temp_trim; sample="&sample"; spec="&spec"; year="&year"; trim="Yes"; depvar="&depvar"; run;  
  proc append base=coeffs_logit data=coeffs_temp; run;
  proc append base=coeffs_logit data=coeffs_temp_trim; run;

%mend;


%pscore(prca_1to1, 2013, lin, dd, lin_1-lin_46);
%pscore(prca_full, 2013, lin, dd, lin_1-lin_46);
%pscore(journal, 2013, lin, dd, lin_1-lin_46);
%pscore(medline, 2013, lin, dd, lin_1-lin_46);

%pscore(prca_1to1, 2011, lin, dd, lin_1-lin_46); 
%pscore(prca_full, 2011, lin, dd, lin_1-lin_46);
%pscore(journal, 2011, lin, dd, lin_1-lin_46); 
%pscore(medline, 2011, lin, dd, lin_1-lin_46); 

%pscore(prca_1to1, 2011, lin, ddd, lin_1-lin_46); 
%pscore(prca_full, 2011, lin, ddd, lin_1-lin_46);
%pscore(journal, 2011, lin, ddd, lin_1-lin_46); 
%pscore(medline, 2011, lin, ddd, lin_1-lin_46);

%pscore(prca_1to1, 2013, lin, ddd, lin_1-lin_46); 
%pscore(prca_full, 2013, lin, ddd, lin_1-lin_46);
%pscore(journal, 2013, lin, ddd, lin_1-lin_46); 
%pscore(medline, 2013, lin, ddd, lin_1-lin_46); 

* Export coefficients file;
data work.coeffs_logit; set work.coeffs_logit; if missing(Variable) then delete; run;
proc export data=work.coeffs_logit outfile="/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/coeffs_lin_logit.csv" dbms=csv replace; run;

* Export estimated propensity score file;
proc export data=work.pscores outfile="/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/pscores_lin.csv" dbms=csv replace; run;
	

%pscore(prca_1to1, 2013, quad, dd, lin_1-lin_46 quad_1-quad_982);
%pscore(prca_full, 2013, quad, dd, lin_1-lin_46 quad_1-quad_982);
%pscore(journal, 2013, quad, dd, lin_1-lin_46 quad_1-quad_982);
%pscore(medline, 2013, quad, dd, lin_1-lin_46 quad_1-quad_982);

%pscore(prca_1to1, 2011, quad, dd, lin_1-lin_46 quad_1-quad_982);
%pscore(prca_full, 2011, quad, dd, lin_1-lin_46 quad_1-quad_982);
%pscore(journal, 2011, quad, dd, lin_1-lin_46 quad_1-quad_982);
%pscore(medline, 2011, quad, dd, lin_1-lin_46 quad_1-quad_982);

%pscore(prca_1to1, 2011, quad, ddd, lin_1-lin_46 quad_1-quad_982);
%pscore(prca_full, 2011, quad, ddd, lin_1-lin_46 quad_1-quad_982);
%pscore(journal, 2011, quad, ddd, lin_1-lin_46 quad_1-quad_982);
%pscore(medline, 2011, quad, ddd, lin_1-lin_46 quad_1-quad_982);

%pscore(prca_1to1, 2013, quad, ddd, lin_1-lin_46 quad_1-quad_982);
%pscore(prca_full, 2013, quad, ddd, lin_1-lin_46 quad_1-quad_982);
%pscore(journal, 2013, quad, ddd, lin_1-lin_46 quad_1-quad_982);
%pscore(medline, 2013, quad, ddd, lin_1-lin_46 quad_1-quad_982);


* Export coefficients file;
data work.coeffs_logit; set work.coeffs_logit; if missing(Variable) then delete; run;
proc export data=work.coeffs_logit outfile="/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/coeffs_logit.csv" dbms=csv replace; run;

* Export estimated propensity score file;
proc export data=work.pscores outfile="/disk/bulkw/staudt/Projects/NIHMandate/NIH20/Data/pscores.csv" dbms=csv replace; run;
	


