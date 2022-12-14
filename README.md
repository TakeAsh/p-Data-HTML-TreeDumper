[![Actions Status](https://github.com/TakeAsh/p-Data-HTML-TreeDumper/actions/workflows/test.yml/badge.svg)](https://github.com/TakeAsh/p-Data-HTML-TreeDumper/actions)
# NAME

Data::HTML::TreeDumper - dumps perl data as HTML5 open/close tree

# SYNOPSIS

    use Data::HTML::TreeDumper;
    my $td = Data::HTML::TreeDumper->new(
        ClassKey    => 'trdKey',
        ClassValue  => 'trdValue',
    );
    my $obj = someFunction();
    print $td->dump($obj);

# DESCRIPTION

Data::HTML::TreeDumper dumps perl data as HTML5 open/close tree.

# LICENSE

Copyright (C) TakeAsh.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

[TakeAsh](https://github.com/TakeAsh/)
