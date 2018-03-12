

#!/usr/bin/perl

# use XML::Simple module
use XML::Simple;

# Set path names
$inpath = "B:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";
$outpath = "B:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\Authors";

open (OUTFILE_BASIC, ">:utf8", "$outpath\\medline16_authors_basic.txt") or die "Can't open subjects file: medline16_authors_basic.txt";
print OUTFILE_BASIC "filenum	pmid	version	authororder	authortotal\n";

open (OUTFILE_NAME, ">:utf8", "$outpath\\medline16_authors_name.txt") or die "Can't open subjects file: medline16_authors_name.txt";
print OUTFILE_NAME "filenum	pmid	version	authororder	authortotal	lastname	forename	inititals	collectivename\n";

open (OUTFILE_AFFIL, ">:utf8", "$outpath\\medline16_authors_affil.txt") or die "Can't open subjects file: medline16_authors_affil.txt";
print OUTFILE_AFFIL "filenum	pmid	version	authororder	authortotal	affiliation\n";

open (OUTFILE_OTHER, ">:utf8", "$outpath\\medline16_authors_other.txt") or die "Can't open subjects file: medline16_authors_other.txt";
print OUTFILE_OTHER "filenum	pmid	version	authororder	authortotal	authorlistcomplete	authorvalid	identifier	source\n";

# Declare which MEDLINE files to parse
$startfile=1; $endfile=812;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    # Read in XML file
    print "Reading in file: medline16n0$fileindex.xml\n";
    &importfile;

    # Parse MEDLINE XML file
    print "Parsing file: medline16n0$fileindex.xml\n";
    &author;

    # "Dump" the XML file out of memory
    $data=0;
}

sub importfile {

    # Read in MELDINE XML files based on the number of leading zeros in the file name
    if ($fileindex<10) { $data = XMLin("$inpath\\medline16n000$fileindex.xml", ForceArray => 1);}
    if($fileindex>=10 && $fileindex<=99) { $data = XMLin("$inpath\\medline16n00$fileindex.xml", ForceArray => 1); }
    if($fileindex>=100 && $fileindex<=812) { $data = XMLin("$inpath\\medline16n0$fileindex.xml", ForceArray => 1); }
}

sub author {
    
    # <MedlineCitation> is the top level element in MedlineCitationSet and contains one entire record
    # Access <MedlineCitation> array
    foreach $i (@{$data->{MedlineCitation}}) {

            @pmid = @{$i->{PMID}};
            @article = @{$i->{Article}};

            foreach $j (@pmid) {
                    $pmid = "$j->{content}";
                    $version = "$j->{Version}";
            }

            foreach $j (@article) {
              @authorlist = @{$j->{AuthorList}};
              $authorlistsize=@authorlist;
  
              if ($authorlistsize==0) {

                 print OUTFILE_BASIC "$fileindex	$pmid	$version	null	null\n";
                 print OUTFILE_NAME "$fileindex	$pmid	$version	null	null	null	null	null	null\n";
                 print OUTFILE_OTHER "$fileindex	$pmid	$version	null	null	null	null	null	null\n";

              }
              
              else {
                foreach $k (@authorlist) {
                        $complete = "$k->{CompleteYN}";
                        @author = @{$k->{Author}};
                        
                        $authortotal=@author;
                        $authororder=0;

                        foreach $l (@author) {
                                $valid = "$l->{ValidYN}";
                                @lastname = @{$l->{LastName}};
                                @forename = @{$l->{ForeName}};
                                @initials = @{$l->{Initials}};
                                @identifier = @{$l->{Identifier}};
                                @collectivename = @{$l->{CollectiveName}};
                                @affiliationinfo = @{$l->{AffiliationInfo}};
                                $affiliationinfosize=@affiliationinfo;
                                $authororder++;

                                $identifier="null";
                                $source="null";
                                foreach $m (@identifier) {
                                    $identifier="$m->{content}";
                                    $source="$m->{Source}";
                                }

                                if ($affiliationinfosize==0) {
                                  
                                        print OUTFILE_BASIC "$fileindex	$pmid	$version	$authororder	$authortotal\n";
                                        print OUTFILE_NAME "$fileindex	$pmid	$version	$authororder	$authortotal	$lastname[0]	$forename[0]	$initials[0]	$collectivename[0]\n";
                                        print OUTFILE_OTHER "$fileindex	$pmid	$version	$authororder	$authortotal	$complete	$valid	$identifier	$source\n";
                                }

                                else {
                                  foreach $m (@affiliationinfo) {
                                          @affiliation = @{$m->{Affiliation}};

                                          foreach $n (@affiliation) {

                                            print OUTFILE_BASIC "$fileindex	$pmid	$version	$authororder	$authortotal\n";
                                            print OUTFILE_NAME "$fileindex	$pmid	$version	$authororder	$authortotal	$lastname[0]	$forename[0]	$initials[0]	$collectivename[0]\n";
                                            print OUTFILE_OTHER "$fileindex	$pmid	$version	$authororder	$authortotal	$complete	$valid	$identifier	$source\n";
                                            print OUTFILE_AFFIL "$fileindex	$pmid	$version	$authororder	$authortotal	$n\n";
                                          }
                                  }
                                }
                        }
                }
              }
            }
    }
}