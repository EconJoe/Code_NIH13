#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;

# Set path names
$outpath="B:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\Journals";
$inpath="B:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";

open (OUTFILE_NLMID, ">:utf8", "$outpath\\medline16_nlmid.txt") or die "Can't open subjects file: medline16_nlmid.txt";
print OUTFILE_NLMID "filenum	pmid	version	nlmid\n";

open (OUTFILE_ISSN, ">:utf8", "$outpath\\medline16_issn.txt") or die "Can't open subjects file: medline16_issn.txt";
print OUTFILE_ISSN "filenum	pmid	version	issn	issnl	issntype\n";

open (OUTFILE_VINT, ">:utf8", "$outpath\\medline16_vint.txt") or die "Can't open subjects file: medline16_vint.txt";
print OUTFILE_VINT "filenum	pmid	version	volume	issue\n";

open (OUTFILE_TITLE, ">:utf8", "$outpath\\medline16_title.txt") or die "Can't open subjects file: medline16_title.txt";
print OUTFILE_TITLE "filenum	pmid	version	journtitle	medlineta	isoabbrev\n";

open (OUTFILE_OTHER, ">:utf8", "$outpath\\medline16_other.txt") or die "Can't open subjects file: medline16_other.txt";
print OUTFILE_OTHER "filenum	pmid	version	pubmodel	artictype	citedmed	country	language\n";

# Declare which MEDLINE files to parse
$startfile=1; $endfile=812;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    print "Reading in file: medline16n0$fileindex.xml\n";
    &importfile;

    print "Parsing file: medline16n0$fileindex.xml\n";
    &journal;

    # this "dumps" the XML file out of memory
    $data=0;
}

sub importfile {
  
  # Read in MELDINE XML files based on the number of leading zeros in the file name
  if ($fileindex<10) { $data = XMLin("$inpath\\medline16n000$fileindex.xml");}
  if($fileindex>=10 && $fileindex<=99) { $data = XMLin("$inpath\\medline16n00$fileindex.xml"); }
     if($fileindex>=100 && $fileindex<=812) { $data = XMLin("$inpath\\medline16n0$fileindex.xml"); }
}

sub journal {

    # access <MedlineCitation> array
    foreach $e (@{$data->{MedlineCitation}}) {

            $pmid = $e->{PMID}->{content}; if ( $pmid eq "") { $pmid="null"; }
            $version = $e->{PMID}->{Version}; if ( $version eq "") { $version="null"; }
            
            $nlmuniqueid = $e->{MedlineJournalInfo}->{NlmUniqueID}; if ( $nlmuniqueid eq "") { $nlmuniqueid="null"; }
            print OUTFILE_NLMID "$fileindex	$pmid	$version	$nlmuniqueid\n";


            $issn = $e->{Article}->{Journal}->{ISSN}->{content}; if ( $issn eq "") { $issn="null"; }
            $issnl = $e->{MedlineJournalInfo}->{ISSNLinking}; if ( $issnl eq "") { $issnl="null"; }
            $issntype = $e->{Article}->{Journal}->{ISSN}->{IssnType}; if ( $issntype eq "") { $issntype="null"; }
            print OUTFILE_ISSN "$fileindex	$pmid	$version	$issn	$issnl	$issntype\n";


            $volume = $e->{Article}->{Journal}->{JournalIssue}->{Volume}; if ( $volume eq "") { $volume="null"; }
            $issue = $e->{Article}->{Journal}->{JournalIssue}->{Issue}; if ( $issue eq "") { $issue="null"; }
            print OUTFILE_VINT "$fileindex	$pmid	$version	$volume	$issue\n";
            

            $journtitle = $e->{Article}->{Journal}->{Title}; if ( $journtitle eq "") { $journtitle="null"; } $journtitle =~ tr/"//d;
            $medlineta = $e->{MedlineJournalInfo}->{MedlineTA}; if ( $medlineta eq "") { $medlineta="null"; }
            $isoabbrev= $e->{Article}->{Journal}->{ISOAbbreviation}; if ( $isoabbrev eq "") { $isoabbrev="null"; }
            print OUTFILE_TITLE "$fileindex	$pmid	$version	$journtitle	$medlineta	$isoabbrev\n";


            $pubmodel = $e->{Article}->{PubModel}; if ( $pubmodel eq "") { $pubmodel="null"; }
            $artictype = $e->{Article}->{ArticleDate}->{DateType}; if ( $artictype eq "") { $artictype="null"; }
            $citedmed = $e->{Article}->{Journal}->{JournalIssue}->{CitedMedium}; if ( $citedmed eq "") { $citedmed="null"; }
            $country = $e->{MedlineJournalInfo}->{Country}; if ( $country eq "") { $country="null"; }
            $language = $e->{Article}->{Language}; if ( $language eq "") { $language="null"; }
            print OUTFILE_OTHER "$fileindex	$pmid	$version	$pubmodel	$artictype	$citedmed	$country	$language\n";
    }
}