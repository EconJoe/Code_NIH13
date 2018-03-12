

#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;

# Set path names
$inpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";
$outpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\PubTypes";

open (OUTFILE_ALL, ">:utf8", "$outpath\\medline16_pubtypes.txt") or die "Can't open subjects file: medline16_pubtypes.txt";
print OUTFILE_ALL "filenum	pmid	version	pubtype	ui\n";

# Declare which MEDLINE files to parse
$startfile=1; $endfile=812;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    open (OUTFILE, ">:utf8", "$outpath\\medline16\_$fileindex\_pubtypes.txt") or die "Can't open subjects file: medline16\_$fileindex\_pubtypes.txt";
    print OUTFILE "filenum	pmid	version	pubtype	ui\n";

    print "Reading in file: medline16n0$fileindex.xml\n";
    &importfile;

    print "Parsing file: medline16n0$fileindex.xml\n";
    &pubtype;

    # this "dumps" the XML file out of memory
    $data=0;
}

sub importfile {

     if ($fileindex<10) { $data = XMLin("$inpath\\medline16n000$fileindex.xml", ForceArray => 1);}
     if($fileindex>=10 && $fileindex<=99) { $data = XMLin("$inpath\\medline16n00$fileindex.xml", ForceArray => 1); }
     if($fileindex>=100 && $fileindex<=812) { $data = XMLin("$inpath\\medline16n0$fileindex.xml", ForceArray => 1); }
}


sub pubtype {

    foreach $i (@{$data->{MedlineCitation}}) {

            @pmid = @{$i->{PMID}};
            @medlinejournalinfo = @{$i->{MedlineJournalInfo}};
            @article = @{$i->{Article}};

            foreach $j (@pmid) {
                    $pmid = "$j->{content}";
                    $version = "$j->{Version}";
            }

            foreach $j (@article) {
                    @publicationtypelist = @{$j->{PublicationTypeList}};
                    $publicationtypelistsize=@publicationtypelist;

                    if ($publicationtypelistsize==0) {
                       print OUTFILE "$fileindex	$pmid	$version	null\n";
                       print OUTFILE_ALL "$fileindex	$pmid	$version	null\n";
                    }

                    else {
                         foreach $k (@publicationtypelist) {
                                 @publicationtype = @{$k->{PublicationType}};
                                 
                                    foreach $l (@publicationtype) {
                                            $publicationtype="$l->{content}";
                                            $ui="$l->{UI}";

                                            print OUTFILE "$fileindex	$pmid	$version	$publicationtype	$ui\n";
                                            print OUTFILE_ALL "$fileindex	$pmid	$version	$publicationtype	$ui\n";
                                 }
                         }
                 }
            }
    }
}