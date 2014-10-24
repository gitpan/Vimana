package Vimana::Util;
use warnings;
use strict;
use base qw(Exporter::Lite);
our @EXPORT = qw(canonical_script_name runtime_path find_vim);

sub canonical_script_name {
    my $name = shift;
    $name = lc $name;
    $name =~ s/\s+/-/g;
    $name =~ s/-?\(.*\)$//;
    $name =~ tr/_<>[],{/-/;
    $name =~ s/-+/-/g;
    $name;
}

sub get_mine_type {
    my $type = File::Type->new->checktype_filename( $_[ 0 ] );
    die "can not found file type from @{[ $_[0] ]}" unless $type;
    return $type;
}

use File::Which;
sub find_vim {
    return $ENV{VIMPATH} || File::Which::which( 'vim' );
}


=head2 runtime_path

You can export enviroment variable VIMANA_RUNTIME_PATH to override default
runtime path.

=cut

sub runtime_path {
    # return File::Spec->join( $ENV{HOME} , 'vim-test' );
    return $ENV{VIMANA_RUNTIME_PATH} || File::Spec->join( $ENV{HOME} , '.vim' );
}

=head2 init_vim_runtime 

=cut

use File::Spec;
use File::Path qw'mkpath rmtree';
sub init_vim_runtime {
    my $paths = [ ];
    for my $subdir ( qw(plugin doc syntax colors after ftplugin indent autoload) ) {
        push @$paths ,
            File::Spec->join( runtime_path , $subdir );
    }
    mkpath $paths;
}


1;
