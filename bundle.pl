#!/usr/bin/env perl
use warnings;
use strict;

use App::BundleDeps;
App::BundleDeps->new()->bundle_from_meta( 'META.yml' );
