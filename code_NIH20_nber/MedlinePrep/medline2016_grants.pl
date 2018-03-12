

#!/usr/bin/perl

# NOTE: I mannually corrected the grant ID R"R-01243 to RR-01243  for PMID 11053342 in file 449.

# use XML::Simple module
use XML::Simple;

# Set path names
$inpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";
$outpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\Grants";

####################################################################################
open (OUTFILE_ALL, ">:utf8", "$outpath\\medline16_grants.txt") or die "Can't open subjects file: medline16_grants.txt";
print OUTFILE_ALL "filenum	pmid	version	";
print OUTFILE_ALL "complete	grantid	acronym	agency	country	";
print OUTFILE_ALL "grantidsize	acronymsize	agencysize	countrysize\n";
####################################################################################


# Declare which MEDLINE files to parse
$startfile=700; $endfile=700;
for ($fileindex=$startfile; $fileindex<=$endfile; $fileindex++) {

    # Create the output file, and print the variable names
    open (OUTFILE, ">:utf8", "$outpath\\medline16\_$fileindex\_grants.txt") or die "Can't open subjects file: medline16\_$fileindex\_grants.txt";
    print OUTFILE "filenum	pmid	version	";
    print OUTFILE "complete	grantid	acronym	agency	country	";
    print OUTFILE "grantidsize	acronymsize	agencysize	countrysize\n";

    # Read in XML file
    print "Reading in file: medline16n0$fileindex.xml\n";
    &importfile;

    # Parse MEDLINE XML file
    print "Parsing file: medline16n0$fileindex.xml\n";
    &grant;

    # "Dump" the XML file out of memory
    $data=0;
}

sub importfile {

    # Read in MELDINE XML files based on the number of leading zeros in the file name
    if ($fileindex<10) { $data = XMLin("$inpath\\medline16n000$fileindex.xml", ForceArray => 1);}
    if($fileindex>=10 && $fileindex<=99) { $data = XMLin("$inpath\\medline16n00$fileindex.xml", ForceArray => 1); }
    if($fileindex>=100 && $fileindex<=812) { $data = XMLin("$inpath\\medline16n0$fileindex.xml", ForceArray => 1); }
}

sub grant {
  
    # <MedlineCitation> is the top level element in MedlineCitationSet and contains one entire record
    # Access <MedlineCitation> array
    foreach $i (@{$data->{MedlineCitation}}) {

            @pmid = @{$i->{PMID}};
            @medlinejournalinfo = @{$i->{MedlineJournalInfo}};
            @article = @{$i->{Article}};

            foreach $j (@pmid) {
                    $pmid = "$j->{content}";
                    $version = "$j->{Version}";
            }

            foreach $j (@article) {
                    @grantlist = @{$j->{GrantList}};

                    $grantlistsize=@grantlist;

                    if ($grantlistsize==0) {
                       print OUTFILE "$fileindex	$pmid	$version	null	";
                       print OUTFILE "null	null	null	null\n";

                       print OUTFILE_ALL "$fileindex	$pmid	$version	null	";
                       print OUTFILE_ALL "null	null	null	null\n";
                    }

                    foreach $k (@grantlist) {
                            $complete = "$k->{CompleteYN}";
                            @grant = @{$k->{Grant}};

                            foreach $l (@grant) {
                                    @grantid = @{$l->{GrantID}};
                                    @acronym = @{$l->{Acronym}};
                                    @agency = @{$l->{Agency}};
                                    @country = @{$l->{Country}};

                                    $grantidsize=@grantid;
                                    $acronymsize=@acronym;
                                    $agencysize = @agency;
                                    $countrysize = @country;

                                    for ($m=0; $m<=$agencysize-1; $m++) {
                                        print OUTFILE "$fileindex	$pmid	$version	$complete	";
                                        print OUTFILE "$grantid[$m]	$acronym[$m]	$agency[$m]	$country[$m]	";
                                        print OUTFILE "$grantidsize	$acronymsize	$agencysize	$countrysize\n";
                                        
                                        print OUTFILE_ALL "$fileindex	$pmid	$version	$complete	";
                                        print OUTFILE_ALL "$grantid[$m]	$acronym[$m]	$agency[$m]	$country[$m]	";
                                        print OUTFILE_ALL "$grantidsize	$acronymsize	$agencysize	$countrysize\n";
                                    }
                            }
                    }
            }
    }
}