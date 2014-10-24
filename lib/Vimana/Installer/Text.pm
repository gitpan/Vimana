package Vimana::Installer::Text;
use warnings;
use strict;
use base qw(Vimana::Installer);
use Vimana::Logger;
use Vimana::Record;
use Vimana::VimballInstall;

sub run {
    my ( $self, $pkgfile ) = @_;

    if( $pkgfile->is_vimball ) {
        $logger->info("Found Vimball File");
        my $install = Vimana::VimballInstall->new({ package => $pkgfile });
        $install->run();
        return 1;
    }

    my $target;
    my $type = $pkgfile->script_type();
    if( $type ) {
        $target = $pkgfile->copy_to_rtp( File::Spec->join( $self->runtime_path , $type ));
    }
    else {
        # Can't found script ype,
        # inspect text filetype here.  (colorscheme, ftplugin ...etc)
        $logger->info( "Inspecting file content for script type." );

        my $arg = $self->inspect_text_content2( $self->package->content );
        $type = $arg->{type};

        if ($type) {
            $logger->info("Script type found: $type.");
            $logger->info("Installing..");
            $target = $pkgfile->copy_to_rtp( File::Spec->join( $self->runtime_path, $type ));
        }
        else {
            $logger->info("Can't guess script type.");
        }
    }

    if( $type and $target ) {
        # make record:
        my @e = Vimana::Record->mk_file_digests( $target );
        Vimana::Record->add( {
                version => 0.2,    # record spec version
                generated_by => 'Vimana-' . $Vimana::VERSION,
                install_type => 'text',    # auto , make , rake ... etc
                package => $pkgfile->cname,
                files => \@e } );
    }
    return $target;
}


=head2 inspect_text_content

you can add something like this to your vim script file:

    " script type: plugin

then the file will be installed into ~/.vim/plugin/

=cut

sub inspect_text_content {
    my ($self,$content) = @_;
    if( $content =~ m{^"\s*script\s*type:\s*(\w+)}im  ){
        my $type = $1;
        return $type;
    }

    warn 'inspect_text_content deprecated.';

    return 'colors'   if $content =~ m/^let\s+(g:)?colors_name\s*=/;
    return 'syntax'   if $content =~ m/^syn[tax]* (?:match|region|keyword)/;
    return 'compiler' if $content =~ m/^let\s+current_compiler\s*=/;
    return 'indent'   if $content =~ m/^let\s+b:did_indent/;

    # XXX: inspect more types.
    return 0;
}


sub inspect_text_content2 {
    my ($self,$content) = @_;
    my $arg =  {};
    if( $content =~ m{^"\s*script\s*type:\s*(\w+)}im  ){
        my $type = $1;
        $arg->{type} = $type;
    }
    else {
        $arg->{type} = 'colors'   if $content =~ m/^let\s+(g:)?colors_name\s*=/;
        $arg->{type} = 'syntax'   if $content =~ m/^syn[tax]* (?:match|region|keyword)/;
        $arg->{type} = 'compiler' if $content =~ m/^let\s+current_compiler\s*=/;
        $arg->{type} = 'indent'   if $content =~ m/^let\s+b:did_indent/;
        # XXX: inspect more types.
    }

    if( $content =~ m{^"\s*(?:script\s*)?(?:deps|dependency|dependencies):\s*(.*)}im ) {
        my $deps_str = $1;
        my @deps = split /\s*,\s*/,$deps_str;
        $arg->{deps} = \@deps;
    }

    if( $content =~ m{^"\s*(?:script\s*)?version:\s*([.0-9]+)}im ) {
        $arg->{version} = $1;
    }

    return $arg;
}

1;
