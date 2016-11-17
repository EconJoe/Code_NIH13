
#!/usr/bin/perl -w

use LWP::Simple;
use XML::Simple;

$inpath = "D:\\Research\\NIH\\NIH11\\Data\\Medline\\NIHGrants";
$outpath = "D:\\Research\\NIH\\NIH11\\Data\\Medline\\NIHGrants\\Similarity";

open (INFILE, "<$inpath\\similar_grants.txt") or die "Can't open subjects file: similar_grants.txt";
while (<INFILE>) {
      if (/(.*)\n/) {

         $pmid=$1;
         #print "$pmid\n";

         $url = "http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=pubmed&id=$pmid&db=pubmed&cmd=neighbor_score";
         $content = get $url;
         die "Couldn't get $url" unless defined $content;

         #print $content;

         open (OUTFILE, ">$outpath\\pmidsimilarity.xml") or die "Can't open subjects file: pmidsimilarity.xml";
         print OUTFILE $content;
         close OUTFILE;

         $data = XMLin("$outpath\\pmidsimilarity.xml");

         print $data;

         foreach $i (@{$data->{eLinkResult}}) {

           #$id = $i->{LinkSet}->{DbFrom}->{IdList}->{Id}->{content};

           #print "$id\n";
           #open (OUTFILE2, ">>$outpath\\test.txt") or die "Can't open subjects file: test.txt";
           #print "$id\n";
           #close OUTFILE2;
         #}

      }
}
