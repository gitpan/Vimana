    



use HTTP::Lite;
my $savetofile = sub {
    my ( $self, $dataref, $cbargs ) = @_;
    print $cbargs $$dataref;
    return undef;
};

# Download File
print "Downloading plugin from $url\n" if $verbose;

my $http = new HTTP::Lite;
my $url = 'http://www.vim.org/scripts/download_script.php?src_id=12532';
open DL, ">" , '/tmp/test' or die $!;
my $res = $http->request($url, $savetofile, DL );
close DL;
print "\n";

