package Vimana::AutoInstall;
use warnings;
use strict;

# use re 'debug';
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use File::Spec;
use File::Path qw'mkpath rmtree';
use Archive::Any;
use File::Find::Rule;
use File::Type;
use File::Temp qw(tempdir);

$| = 1;


sub can_autoinstall {
    my ( $class, $file, $info , $page ) = @_;

    if( is_archive_file( $file ) ) {
        my $archive = Archive::Any->new($file);
        my @files = $archive->files;
        my $nodes = $class->find_runtime_node( \@files );
        return i_know_what_to_do( $nodes );
    }
    elsif( is_text_file( $file ) ) {
        # XXX: detect file type , colorscheme ? plugin ? 
        # inspect file content

    }
}

sub install {
    my ( $class, $file, $info , $page , $opt ) = @_;

    if( is_archive_file( $file ) ) {
        $class->install_from_archive(  $file , $info , $page , $opt  );
    }
    elsif( is_text_file( $file ) ) {
        if( $info->{type} eq 'color scheme' ) {
            $class->install_to( $file , 'colors' );
        }
    }
}

sub install_to_colors {

}


sub install_from_archive {
    my ( $class , $file , $info , $opt ) = @_;

    # XXX: make sure is archive file
    my $archive = Archive::Any->new( $file );
    my @files = $archive->files;

    if( $opt->{verbose} ) {
        for (@files ) {
            print "FILE: $_ \n";
        }
    }

    print "Creating temporary directory.\n" if $opt->{verbose};

    my $out = tempdir( CLEANUP => 1 );
    rmtree [ $out ] if -e $out;
    mkpath [ $out ];

    print "Extracting...\n" if $opt->{verbose};
    $archive->extract( $out );  

    my @subdirs = File::Find::Rule->file->in(  $out );

    # XXX: check vim runtime path subdirs
    print "Initializing vim runtime path...\n" if $opt->{verbose};
    $class->init_vim_runtime();

    my $nodes = $class->find_runtime_node( \@subdirs );
    
    print "Runtime path in extracted directory\n" if $opt->{verbose};
    print join("\n" , keys %$nodes ) . "\n" if $opt->{verbose};

    print "Installing...\n" if $opt->{verbose};
    $class->install_from_nodes( $nodes );

    print "Done\n";
}

sub runtime_path {
    # return File::Spec->join( $ENV{HOME} , 'vim-test' );
    return $ENV{VIMANA_RUNTIME_PATH} || File::Spec->join( $ENV{HOME} , '.vim' );
}

sub is_archive_file {
    my $file = shift;
    my $ft = File::Type->new();
    my $type = $ft->checktype_filename($file);

    die "can not found file type: $type" unless $type;

    return 1 if $type =~ m{(x-bzip2|x-gzip|x-gtar|zip|rar|tar)};
    return 0;
}

sub is_text_file {
    my $file = shift;
    my $ft = File::Type->new();
    my $type = $ft->checktype_filename($file);
    return 1 if $type =~ m{octet-stream};
    return 0;
}


sub init_vim_runtime {
    my $class = shift;
    my $paths = [ ];
    for my $subdir ( qw(plugin doc syntax colors after ftplugin indent autoload) ) {
        push @$paths ,File::Spec->join( runtime_path , $subdir );
    }
    mkpath $paths;
}

sub install_from_nodes {
    my ($class , $nodes) = @_;
    for my $node  ( grep { $nodes->{ $_ } > 1 } keys %$nodes ) {
        my (@ret) = dircopy($node, runtime_path );
    }
}

sub i_know_what_to_do {
    my $nodes = shift;
    for my $v ( values %$nodes ) {
        return 1 if $v > 1;
    }
    return 0;  # i am not sure
}

sub find_runtime_node {
    my ( $class, $paths ) = @_;
    my $nodes = {};
    for my $p ( @$paths ) {
        if ( $p =~ m{^(.*?/)?(plugin|doc|syntax|indent|colors|autoload|after|ftplugin)/.*?\.(vim|txt)$} ) {
            $nodes->{ $1 || '' } += 2;
        }
    }
    return $nodes;
}


1;
