use HTTP::Lite;
$http = new HTTP::Lite;
$req = $http->request("http://www.cpan.org/")
# $req = $http->request("http://www.vim.org/scripts/download_script.php?src_id=12553")
    or die "Unable to get document: $!";
# print $http->body();
@headers = $http->headers_array();
use Data::Dumper; warn Dumper( \@headers     );

my $info = {};
for my $line ( @headers ) {
    # warn $line;
    if( $line =~ m/^content-type:\s*(.*)/ims ) {
        my @q = split /\s*;\s*/,$1;
        use Data::Dumper; warn Dumper( \@q );

        $info->{content_type} = \@q;
    }
    elsif( $line =~ m/^content-disposition:\s*(.*)/ims ) {
        my @q = split /\s*;\s*/,$1;
        $info->{content_disposition} = \@q;
    }
}

use Data::Dumper; warn Dumper( $info );
