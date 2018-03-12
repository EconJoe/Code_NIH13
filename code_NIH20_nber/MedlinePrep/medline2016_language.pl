
#!/usr/bin/perl

# Set path names
$inpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\XML\\zip";
$outpath = "D:\\Research\\RAWDATA\\MEDLINE\\2016\\Parsed\\Language";

open (OUTFILE, ">:utf8", "$outpath\\medline16_language.txt") or die "Can't open subjects file: medline16_language.txt";
print OUTFILE "filenum	pmid	version	language\n";


$startfile=1; $endfile=812;
for ($filenum=$startfile; $filenum<=$endfile; $filenum++) {
    
    print "Reading in file: medline16n0$filenum.xml\n";
    &importfile;

    print "Parsing file: medline16n0$filenum.xml\n";
    &lang;
    
    close INFILE;
}

sub importfile {

    # Read in MELDINE XML files based on the number of leading zeros in the file name
    if ($filenum<10) { open (INFILE, "<$inpath\\medline16n000$filenum.xml") or die "Can't open subjects file: medline16n000$filenum.xml"; }
    if($filenum>=10 && $filenum<=99) { open (INFILE, "<$inpath\\medline16n00$filenum.xml") or die "Can't open subjects file: medline16n000$filenum.xml"; }
    if($filenum>=100 && $filenum<=812) { open (INFILE, "<$inpath\\medline16n0$filenum.xml") or die "Can't open subjects file: medline16n000$filenum.xml"; }
}

sub lang {
  while(<INFILE>) {
     # Identify new records
     if (/<MedlineCitation Owner="(.*?)" Status="(.*?)">/) { $new="Yes"; if ($new eq "Yes") { $pmid="null"; $version="null"; $$language="null"; } }
     if ($pmid eq "null" & $version eq "null") {
        if (/<PMID Version="(.*?)">(.*?)<\/PMID>/) {
           $version=$1; $pmid=$2;
        }
     }
     if (/<Language>([a-z][a-z][a-z])<\/Language>/) {
           $language=$1;
           print OUTFILE "$filenum	$pmid	$version	$language\n";
     }
  }
}


