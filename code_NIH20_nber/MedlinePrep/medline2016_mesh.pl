

#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;

# Set path names
$inpath = "B:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";
$outpath = "B:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\MeSH";

####################################################################################
open (OUTFILE_TERMS, ">:utf8", "$outpath\\medline16_mesh_terms.txt") or die "Can't open subjects file: medline16_mesh_terms.txt";
print OUTFILE_TERMS "filenum	pmid	version	meshorder	mesh	majortopic	type	meshgroup\n";

open (OUTFILE_UI, ">:utf8", "$outpath\\medline16_mesh_ui.txt") or die "Can't open subjects file: medline16_mesh_ui.txt";
print OUTFILE_UI "filenum	pmid	version	meshorder	ui	majortopic	type	meshgroup\n";
####################################################################################

# Declare which MEDLINE files to parse
$startfile=1; $endfile=812;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    # Read in XML file
    print "Reading in file: medline16n0$fileindex.xml\n";
    &importfile;

    # Parse MEDLINE XML file
    print "Parsing file: medline16n0$fileindex.xml\n";
    &mesh;

    # "Dump" the XML file out of memory
    $data=0;
}

sub importfile {

    # Read in MELDINE XML files based on the number of leading zeros in the file name
    if ($fileindex<10) { $data = XMLin("$inpath\\medline16n000$fileindex.xml", ForceArray => 1);}
    if($fileindex>=10 && $fileindex<=99) { $data = XMLin("$inpath\\medline16n00$fileindex.xml", ForceArray => 1); }
    if($fileindex>=100 && $fileindex<=812) { $data = XMLin("$inpath\\medline16n0$fileindex.xml", ForceArray => 1); }
}

sub mesh {
    
    # <MedlineCitation> is the top level element in MedlineCitationSet and contains one entire record
    # Access <MedlineCitation> array
    foreach $i (@{$data->{MedlineCitation}}) {

            @pmid = @{$i->{PMID}};
            @medlinejournalinfo = @{$i->{MedlineJournalInfo}};
            @meshheadinglist = @{$i->{MeshHeadingList}};

            foreach $j (@pmid) {
                    $pmid = "$j->{content}";
                    $version = "$j->{Version}";
            }

            $meshheadinglistsize=@meshheadinglist;

            if ($meshheadinglistsize==0) {
               print OUTFILE_TERMS "$fileindex	$pmid	$version	null	null	null	null	\n";
               print OUTFILE_UI "$fileindex	$pmid	$version	null	null	null	null	\n";
            }

            foreach $j (@meshheadinglist) {
                    @meshheading = @{$j->{MeshHeading}};

                    $meshgroup=0;
                    $meshorder=0;
                    foreach $k (@meshheading) {
                            @descriptorname=@{$k->{DescriptorName}};
                            @qualifiername=@{$k->{QualifierName}};

                            $meshgroup++;

                            foreach $l (@descriptorname) {
                                    $mesh="$l->{content}";
                                    $majortopic="$l->{MajorTopicYN}";
                                    $ui="$l->{UI}";
                                    $type="Descriptor";
                                    $meshorder++;

                                    print OUTFILE_TERMS "$fileindex	$pmid	$version	$meshorder	$mesh	$majortopic	$type	$meshgroup\n";
                                    print OUTFILE_UI "$fileindex	$pmid	$version	$meshorder	$ui	$majortopic	$type	$meshgroup\n";
                            }
                            
                            foreach $l (@qualifiername) {
                                    $mesh="$l->{content}";
                                    $majortopic="$l->{MajorTopicYN}";
                                    $ui="$l->{UI}";
                                    $type="Qualifier";
                                    $meshorder++;
                                    
                                    print OUTFILE_TERMS "$fileindex	$pmid	$version	$meshorder	$mesh	$majortopic	$type	$meshgroup\n";
                                    print OUTFILE_UI "$fileindex	$pmid	$version	$meshorder	$ui	$majortopic	$type	$meshgroup\n";
                            }
                    }
            }
    }
}