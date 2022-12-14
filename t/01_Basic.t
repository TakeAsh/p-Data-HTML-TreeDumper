use strict;
use Test::More;
use Test::More::UTF8;
use YAML::Syck qw(Load LoadFile Dump DumpFile);
use FindBin::libs;
use Data::HTML::TreeDumper;
use open ':std' => ( $^O eq 'MSWin32' ? ':locale' : ':utf8' );

my $td = Data::HTML::TreeDumper->new();

subtest 'Scalar' => sub {
    is( $td->dump(undef), '<span class="trdValue">[undef]</span>', 'undef' );
    is( $td->dump(0),     '<span class="trdValue">0</span>',       'num:0' );
    is( $td->dump(1),     '<span class="trdValue">1</span>',       'num:1' );
    is( $td->dump(10),    '<span class="trdValue">10</span>',      'num:10' );
    is( $td->dump(''),    '<span class="trdValue"></span>',        'str:blank' );
    is( $td->dump('A'),   '<span class="trdValue">A</span>',       'str:A' );
    is( $td->dump('ABC'), '<span class="trdValue">ABC</span>',     'str:ABC' );
};

subtest 'ScalarRef' => sub {
    is( $td->dump( \0 ),     '<span class="trdValue">0</span>',   'num:0' );
    is( $td->dump( \1 ),     '<span class="trdValue">1</span>',   'num:1' );
    is( $td->dump( \10 ),    '<span class="trdValue">10</span>',  'num:10' );
    is( $td->dump( \'' ),    '<span class="trdValue"></span>',    'str:blank' );
    is( $td->dump( \'A' ),   '<span class="trdValue">A</span>',   'str:A' );
    is( $td->dump( \'ABC' ), '<span class="trdValue">ABC</span>', 'str:ABC' );
};

subtest 'ArrayRef' => sub {
    map { is( $td->dump( $_->{input}, $_->{name} ), $_->{expected}, $_->{name} ); } (
        {   input    => [],
            expected => '<details>'
                . '<summary class="trdKey">blank</summary>'
                . '<ol class="trdOL" start="0"></ol>'
                . '</details>',
            name => 'blank'
        },
        {   input    => [ 0, 1, 2 ],
            expected => '<details>'
                . '<summary class="trdKey">[0,1,2]</summary>'
                . '<ol class="trdOL" start="0">'
                . '<li><span class="trdValue">0</span></li>'
                . '<li><span class="trdValue">1</span></li>'
                . '<li><span class="trdValue">2</span></li>'
                . '</ol></details>',
            name => '[0,1,2]'
        },
        {   input    => [ 'A', 'B', 'C' ],
            expected => '<details>'
                . '<summary class="trdKey">[A,B,C]</summary>'
                . '<ol class="trdOL" start="0">'
                . '<li><span class="trdValue">A</span></li>'
                . '<li><span class="trdValue">B</span></li>'
                . '<li><span class="trdValue">C</span></li>'
                . '</ol></details>',
            name => '[A,B,C]'
        },
    );
};

subtest 'HashRef' => sub {
    map { is( $td->dump( $_->{input}, $_->{name} ), $_->{expected}, $_->{name} ); } (
        {   input    => {},
            expected => '<details>'
                . '<summary class="trdKey">blank</summary>'
                . '<ul class="trdUL"></ul>'
                . '</details>',
            name => 'blank'
        },
        {   input    => { A => 0, B => 1, C => 2 },
            expected => '<details>'
                . '<summary class="trdKey">[A=&gt;0,B=&gt;1,C=&gt;2]</summary>'
                . '<ul class="trdUL">'
                . '<li><span class="trdKey">A</span>: <span class="trdValue">0</span></li>'
                . '<li><span class="trdKey">B</span>: <span class="trdValue">1</span></li>'
                . '<li><span class="trdKey">C</span>: <span class="trdValue">2</span></li>'
                . '</ul>'
                . '</details>',
            name => '[A=>0,B=>1,C=>2]'
        },
    );
};

subtest 'ArrayOfArray' => sub {
    map { is( $td->dump( $_->{input}, $_->{name} ), $_->{expected}, $_->{name} ); } (
        {   input    => [ [], [], [] ],
            expected => '<details>'
                . '<summary class="trdKey">blank array</summary>'
                . '<ol class="trdOL" start="0">'
                . '<li><details>'
                . '<summary class="trdKey">ARRAY</summary>'
                . '<ol class="trdOL" start="0"></ol>'
                . '</details></li>'
                . '<li><details><summary class="trdKey">ARRAY</summary><ol class="trdOL" start="0"></ol></details></li><li><details><summary class="trdKey">ARRAY</summary><ol class="trdOL" start="0"></ol></details></li></ol></details>',
            name => 'blank array'
        },
        {   input    => [ [undef], [ 0, 1 ], [ 2, 3, 4 ] ],
            expected => '<details>'
                . '<summary class="trdKey">jagged array</summary>'
                . '<ol class="trdOL" start="0">'
                . '<li><details>'
                . '<summary class="trdKey">ARRAY</summary>'
                . '<ol class="trdOL" start="0">'
                . '<li><span class="trdValue">[undef]</span></li>'
                . '</ol></details></li>'
                . '<li><details>'
                . '<summary class="trdKey">ARRAY</summary>'
                . '<ol class="trdOL" start="0">'
                . '<li><span class="trdValue">0</span></li>'
                . '<li><span class="trdValue">1</span></li>'
                . '</ol></details></li>'
                . '<li><details>'
                . '<summary class="trdKey">ARRAY</summary>'
                . '<ol class="trdOL" start="0">'
                . '<li><span class="trdValue">2</span></li>'
                . '<li><span class="trdValue">3</span></li>'
                . '<li><span class="trdValue">4</span></li>'
                . '</ol></details>'
                . '</li></ol></details>',
            name => 'jagged array'
        },
    );
};

done_testing;
