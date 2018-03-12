*************************************************************
* PARSING AND PROCESSING MEDLINE 2016 XML FILES
* The XML files are parsed using a series of Perl scripts.
global process "/disk/bulkw/staudt/RAWDATA/MEDLINE/2016/Processors/"
global medlineprep "/disk/bulkw/staudt/Projects/NIHMandate/NIH20/code_NIH20_nber/MedlinePrep/"
global wosprep "/disk/bulkw/staudt/Projects/NIHMandate/NIH20/code_NIH20_nber/WOSPrep/"
global prcaprep "/disk/bulkw/staudt/Projects/NIHMandate/NIH20/code_NIH20_nber/PRCAPrep/"

*  	medline2016_dates.pl
*  	medline2016_grants.pl
*  	medline2016_pubtypes.pl
*  	medline2016_journals.pl
*  	medline2016_lanugage.pl
*  	medline2016_authors.pl
*  	medline2016_mesh.pl
cd $process
do medline2016_dates_clean.do

****************************************************************************************************************
****************************************************************************************************************
* PROCESS TEXT
* This process takes a very long time.


* If you have access to multiple machines, break this step up across them. 
* It takes a long time to load some of the larger text files.
cd $process/textmetrics
do medline2016_ngrams_txttodta.do
* The following 5 scripts should be run in order. 
* The only exception is that the mentions and vintage scripts can be run simultaneously on different machines.
cd $process/textmetrics
do medline2016_ngrams_id.do
cd $process/textmetrics
do medline2016_ngrams_mentions.do
cd $process/textmetrics
do medline2016_ngrams_vintage.do
cd $process/textmetrics
do medline2016_ngrams_rank.do
* Note that there is a more complete version of this dofile in $process/textmetrics called medline2016_textmetrics_master.do. 
*   It computes age and diversity of concepts, not just mentions. I don't use those for this paper though.
cd $medlineprep
do medline2016_textmetrics_master_nihpaper.do 
****************************************************************************************************************
****************************************************************************************************************


* Determine the field to which each article belongs -- both the raw field and the 4-digit aggregated field
cd $medlineprep
do article_field.do
cd $medlineprep
do medline2016_nlmid_issn_xwalk.do
cd $medlineprep
do journal_oa.do

cd $wosprep
do article_fowardcites.do
cd $wosprep
do article_backwardcites.do

* PRCA Harvester and Matching
cd $prcaprep
do nihgroups_prcainputs.do
* The Perl script below needs to connect to the web. It harvests articles using NIH's Entrez.
* perl harvester.pl
cd $prcaprep
do harvestedsimilararticles_combine.do
cd $prcaprep
do matchingalgorithm.do

* Build main estimation samples. This builds on all of the preliminaries above.
*  Calls on pscore_covariates, StatTransfer, sas_pscores2.sas, and pscore_stratification.do
*  Note that if you cannot invoke SAS from Stata, you have to run sas_pscore2.sas separately.
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/code_NIH20_nber/
do samples_comparison_2.do

* This will take a very long time (maybe months, depending on machine). 
* This is especially true of the within propensity score estimates.
* If you can, break it up by outcome variable or sample, distribute across several machines, and recombine later.
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/code_NIH20_nber/
do estimates_pubpatterns.do

* Construct Graphs from Estimates
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/code_NIH20_nber/
do commontrends.do
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/code_NIH20_nber/
do dotwhisker.do
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/code_NIH20_nber/
do dynamics.do
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/code_NIH20_nber/
do magnitudes.do
cd /disk/bulkw/staudt/Projects/NIHMandate/NIH20/code_NIH20_nber/
do summstats.do
