
*********************************************************************
* Compute journal-level metrics
cd D:\Research\NIH\NIH13\Code_NIH13\Stata\Construction\UPF
do upf_journal_oa.do
*********************************************************************

*********************************************************************
* Compute article-level metrics
cd D:\Research\NIH\NIH13\Code_NIH13\Stata\Construction\UPF
do upf_article_backwardcites.do
do upf_article_forwardcites.do
do upf_article_authorages.do
do upf_article_authorcohorts.do
do upf_article_pubtypes.do
*********************************************************************

*********************************************************************
* Compute author-level metrics
cd D:\Research\NIH\NIH13\Code_NIH13\Stata\Construction\UPF
do upf_authorpubs.do
