#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;

# Set path names
$inpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";
$outpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\Dates";

####################################################################################
open (OUTFILE_ALL, ">:utf8", "$outpath\\medline16_dates.txt") or die "Can't open subjects file: medline16_dates.txt";
print OUTFILE_ALL "filenum	pmid	version	";
print OUTFILE_ALL "pubyear	articyear	pubmonth	articmonth	pubday	articday	medlinedate\n";
####################################################################################

$startfile=1; $endfile=812;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    open (OUTFILE, ">:utf8", "$outpath\\medline16\_$fileindex\_dates.txt") or die "Can't open subjects file: medline16\_$fileindex\_dates.txt";
    print OUTFILE "filenum	pmid	version	";
    print OUTFILE "pubyear	articyear	pubmonth	articmonth	pubday	articday	medlinedate\n";

    print "Reading in file: medline16n0$fileindex.xml\n";
    &importfile;

    print "Parsing file: medline16n0$fileindex.xml\n";
    &date;

    # this "dumps" the XML file out of memory
    $data=0;
}

sub importfile {

     if ($fileindex<10) { $data = XMLin("$inpath\\medline16n000$fileindex.xml");}
     if($fileindex>=10 && $fileindex<=99) { $data = XMLin("$inpath\\medline16n00$fileindex.xml"); }
     if($fileindex>=100 && $fileindex<=812) { $data = XMLin("$inpath\\medline16n0$fileindex.xml"); }
}

sub date {

    # access <MedlineCitation> array
    foreach $e (@{$data->{MedlineCitation}}) {

            $pmid = $e->{PMID}->{content};
            $version = $e->{PMID}->{Version};

            $pubyear = $e->{Article}->{Journal}->{JournalIssue}->{PubDate}->{Year};
            $pubmonth = $e->{Article}->{Journal}->{JournalIssue}->{PubDate}->{Month};
            $pubday = $e->{Article}->{Journal}->{JournalIssue}->{PubDate}->{Day};

            $articyear = $e->{Article}->{ArticleDate}->{Year};
            $articmonth = $e->{Article}->{ArticleDate}->{Month};
            $articday = $e->{Article}->{ArticleDate}->{Day};
            
            $medlinedate = $e->{Article}->{Journal}->{JournalIssue}->{PubDate}->{MedlineDate};

            if ($pmid eq "") { $pmid="null"; }
            if ($version eq "") { $version="null"; }

            if ($pubyear eq "") { $pubyear="null"; }
            if ($pubmonth eq "") { $pubmonth="null"; }
            if ($pubday eq "") { $pubday="null"; }
            
            if ( $articyear eq "") { $articyear="null"; }
            if ( $articmonth eq "") { $articmonth="null"; }
            if ( $articday eq "") { $articday="null"; }

            if ($medlinedate eq "") { $medlinedate="null"; }

            print OUTFILE "$fileindex	$pmid	$version	";
            print OUTFILE "$pubyear	$articyear	$pubmonth	$articmonth	$pubday	$articday	$medlinedate\n";
            
            print OUTFILE_ALL "$fileindex	$pmid	$version	";
            print OUTFILE_ALL "$pubyear	$articyear	$pubmonth	$articmonth	$pubday	$articday	$medlinedate\n";
    }
}
