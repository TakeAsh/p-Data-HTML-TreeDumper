package Data::HTML::TreeDumper;
use 5.010;
use strict;
use warnings;
use utf8;
use Encode;
use Carp       qw(croak);
use YAML::Syck qw(Load LoadFile Dump DumpFile);
use Ref::Util  qw(is_ref is_scalarref is_arrayref is_hashref);
use Const::Fast;
use HTML::Entities;

use version 0.77; our $VERSION = version->declare("v0.0.1");

$YAML::Syck::ImplicitUnicode = 1;
$YAML::Syck::ImplicitTyping  = 1;
$YAML::Syck::Headless        = 1;

const my %default => (
    ClassKey           => 'trdKey',
    ClassValue         => 'trdValue',
    ClassOrderedList   => 'trdOL',
    ClassUnorderedList => 'trdUL',
    StartOrderedList   => 0,
);

sub new {
    my $class = shift;
    my $args  = { %default, ( is_hashref( $_[0] ) ? %{ $_[0] } : @_ ) };
    my $self  = {};
    bless $self, $class;
    $self->ClassKey( $args->{ClassKey} );
    $self->ClassValue( $args->{ClassValue} );
    $self->ClassOrderedList( $args->{ClassOrderedList} );
    $self->ClassUnorderedList( $args->{ClassUnorderedList} );
    $self->StartOrderedList( $args->{StartOrderedList} );
    return $self;
}

sub ClassKey {
    my $self = shift;
    if (@_) {
        $self->{ClassKey} = shift;
    }
    return $self->{ClassKey};
}

sub ClassValue {
    my $self = shift;
    if (@_) {
        $self->{ClassValue} = shift;
    }
    return $self->{ClassValue};
}

sub ClassOrderedList {
    my $self = shift;
    if (@_) {
        $self->{ClassOrderedList} = shift;
    }
    return $self->{ClassOrderedList};
}

sub ClassUnorderedList {
    my $self = shift;
    if (@_) {
        $self->{ClassUnorderedList} = shift;
    }
    return $self->{ClassUnorderedList};
}

sub StartOrderedList {
    my $self = shift;
    if (@_) {
        $self->{StartOrderedList} = shift;
    }
    return $self->{StartOrderedList};
}

sub dump {
    my $self  = shift;
    my $x     = shift // return $self->_dumpRaw('[undef]');
    my $name  = $self->_normalizeName( $x, shift );
    my $depth = shift || 0;
    my $result
        = !is_ref($x)      ? $self->_dumpRaw( $x, $name )
        : is_scalarref($x) ? $self->dump( ${$x}, $name, $depth + 1 )
        : is_arrayref($x)  ? $self->_dumpArray( $x, $name, $depth + 1 )
        : is_hashref($x)   ? $self->_dumpHash( $x, $name, $depth + 1 )
        :                    $self->_dumpRaw('[error]');
    return $result;
}

sub _normalizeName {
    my $self = shift;
    my $x    = shift;
    my $name = shift;
    return $name || ref($x) || 'unnamed';
}

sub _dumpRaw {
    my $self  = shift;
    my $x     = shift // '';
    my $name  = $self->_normalizeName( $x, shift );
    my $depth = shift || 0;
    return sprintf( '<span class="%s">%s</span>', $self->ClassValue(), encode_entities($x) );
}

sub _dumpArray {
    my $self  = shift;
    my $x     = shift // '';
    my $name  = $self->_normalizeName( $x, shift );
    my $depth = shift || 0;
    my $inner
        = join( "", map { sprintf( '<li>%s</li>', $self->dump( $_, undef, $depth + 1 ) ); } @{$x} );
    return sprintf(
        '<details><summary class="%s">%s</summary><ol class="%s" start="%d">%s</ol></details>',
        $self->ClassKey(), encode_entities($name),
        $self->ClassOrderedList(),
        $self->StartOrderedList(), $inner
    );
}

sub _dumpHash {
    my $self  = shift;
    my $x     = shift // '';
    my $name  = $self->_normalizeName( $x, shift );
    my $depth = shift || 0;
    my $inner = join(
        "",
        map {
            is_arrayref( $x->{$_} )
                ? sprintf( "<li>%s</li>", $self->_dumpArray( $x->{$_}, $_, $depth + 1 ) )
                : is_hashref( $x->{$_} )
                ? sprintf( "<li>%s</li>", $self->_dumpHash( $x->{$_}, $_, $depth + 1 ) )
                : sprintf( '<li><span class="%s">%s</span>: %s</li>',
                $self->ClassKey(), encode_entities($_), $self->dump( $x->{$_}, $_, $depth + 1 ) )
        } sort( keys( %{$x} ) )
    );
    return sprintf( '<details><summary class="%s">%s</summary><ul class="%s">%s</ul></details>',
        $self->ClassKey(), encode_entities($name), $self->ClassUnorderedList(), $inner );
}

1;
__END__

=encoding utf-8

=head1 NAME

Data::HTML::TreeDumper - dumps perl data as HTML5 open/close tree

=head1 SYNOPSIS

    use Data::HTML::TreeDumper;
    my $td = Data::HTML::TreeDumper->new(
        ClassKey    => 'trdKey',
        ClassValue  => 'trdValue',
    );
    my $obj = someFunction();
    print $td->dump($obj);

=head1 DESCRIPTION

Data::HTML::TreeDumper dumps perl data as HTML5 open/close tree.

=head1 LICENSE

Copyright (C) TakeAsh.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

L<TakeAsh|https://github.com/TakeAsh/>

=cut

