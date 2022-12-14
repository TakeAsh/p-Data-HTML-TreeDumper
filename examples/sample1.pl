#!/usr/bin/perl

use strict;
use warnings;
use utf8;
use feature qw(say);
use Encode;
use YAML::Syck qw(Load LoadFile Dump);
use Template;
use File::Slurp;
use FindBin::libs;
use Data::HTML::TreeDumper;
use Term::Encoding qw(term_encoding);
use open ':std' => ( $^O eq 'MSWin32' ? ':locale' : ':utf8' );

$|                           = 1;
$YAML::Syck::ImplicitUnicode = 1;

my $td_Default = Data::HTML::TreeDumper->new();
my $td_NoClass = Data::HTML::TreeDumper->new(
    ClassKey           => '',
    ClassValue         => '',
    ClassOrderedList   => '',
    ClassUnorderedList => '',
);

my $testCases = [
    map {
        {   name       => $_->{name},
            yaml       => Dump( $_->{input} ),
            td_Default => $td_Default->dump( $_->{input} ),
            td_NoClass => $td_NoClass->dump( $_->{input} ),
        }
    } ( { input => undef,                                             name => 'undef' },
        { input => 0,                                                 name => '0' },
        { input => 1,                                                 name => '1' },
        { input => 123,                                               name => '123' },
        { input => '',                                                name => 'blank' },
        { input => 'A',                                               name => 'A' },
        { input => 'ABC',                                             name => 'ABC' },
        { input => [],                                                name => 'Array1' },
        { input => [ [], [], [] ],                                    name => 'Array2' },
        { input => [ [undef], [ 1, 2 ], [ 3, 4, 5 ] ],                name => 'Array3' },
        { input => {},                                                name => 'Hash1' },
        { input => { a => undef, b => 0, c => '', d => [], e => {} }, name => 'Hash2' },
        {   input => {
                a => [ undef, 0, 1, 10 ],
                b => {
                    c => { f => undef, g => 0, h => '' },
                    d => { i => 1,     j => 10 },
                    e => { k => 'A',   l => 'ABC' }
                }
            },
            name => 'Hash3'
        },
        {   input => [
                { a => 'A', b => [ 1, 2, 3 ], c => { d => undef, e => 0, f => '' } },
                { a => 'B', b => [ 4, 5, 6 ], c => { d => [ 0, 1, 2 ], e => 1,   f => 'A' } },
                { a => 'C', b => [ 7, 8, 9 ], c => { d => [ 3, 4, 5 ], e => 123, f => 'ABC' } },
            ],
            name => 'ArrayOfHash'
        },
    )
];

my $tt = Template->new(
    {   INCLUDE_PATH => "${FindBin::RealBin}/templates",
        ENCODING     => 'utf-8',
    }
) or die( Template->error() );
my $out = '';
$tt->process( "sample1.html", { testCases => $testCases, }, \$out )
    or die( $tt->error );
write_file( "${FindBin::RealBin}/output/sample1.html", $out );
