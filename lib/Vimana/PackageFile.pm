package Vimana::PackageFile;
use warnings;
use strict;
use Vimana::Logger;
use LWP::Simple qw();
use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors( qw(
    cname
    file 
    url 
    filetype 
    info 
    page_fino 
    archive
) );


=head1 FUNCTIONS

=head2 is_archive

=head2 is_text

=head2 is_vimball

=head2 script_type

=head2 script_is

=head2 download

=head2 preprocess

=head2 postprocess

=cut

sub is_archive { $_[ 0 ]->filetype =~ m{(x-bzip2|x-gzip|x-gtar|zip|rar|tar)} ? 1 : 0; }

sub is_text { $_[ 0 ]->filetype =~ m{octet-stream} ? 1 : 0 }

sub is_vimball {  $_[0]->file =~ m/\.vba$/  }

sub script_type { $_[ 0 ]->info->{type}   }

sub script_is { $_[ 0 ]->script_type eq $_[1] }

sub download {
    my $self = shift;

    my $file_content = LWP::Simple::get( $self->url );
    unless( $file_content ) {
        $logger->error('Can not download file');
        return 0;
    }

    open FH , ">" , $self->file or die $@;
    print FH $file_content;
    close FH;

    return 1;
}


sub preprocess {
    my $self = shift;
    if( $self->is_archive ) {
        $self->archive( Archive::Any->new( $self->file ) );
        die "Can not read archive file: @{[ $self->file ]}" unless $self->archive;
    }
}

# XXX: DESTROY
sub postprocess {


}

sub detect_filetype { 
    my $self = shift;
    $self->filetype( 
        Vimana::Util::get_mine_type( $self->file )
    );

}

sub archive_files {
    my $self = shift;
    my @files = $self->archive->files;
    return \@files;
}

sub content {
    my $self = shift;
    local $/;
    open my $fh , "<" , $self->file;
    my $content = <$fh>;
    close $fh;
    return $content;
}

sub has_makefile {
    my $self = shift;
    my @files = $self->archive->files();
    @files = grep /makefile/i , @files;
    return @files if scalar @files;
    return undef;
}

sub has_vimball {
    my $self = shift;
    my @files = $self->archive->files();
    @files = grep /\.vba$/i , @files;
    return @files if scalar @files;
    return undef;
}

sub set_record {
    my ( $self , $package , $pkgfiles ) =  @_;
    # Vimana::Record->set_record(  cname => $package , files => [ $pkgfiles ]  );
}

sub auto_install {
    my $self = shift;
    my %args = @_;

    require Vimana::AutoInstall;
    my $auto = Vimana::AutoInstall->new( { package => $self , options => \%args } );
    return $auto->run();  # dry_run , verbose

}


sub makefile_install {

}

1;
