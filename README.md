# NAME

Paws::Kinesis::MemoryCaller - A Paws Caller with in-memory Kinesis.

[![Build Status](https://travis-ci.org/keithbro/Paws-Kinesis-MemoryCaller.svg?branch=master)](https://travis-ci.org/keithbro/Paws-Kinesis-MemoryCaller)

# SYNOPSIS

    use Paws;
    use Paws::Kinesis::MemoryCaller;

    my $kinesis = Paws->service('Kinesis',
        region      => 'N/A',
        caller      => Paws::Kinesis::MemoryCaller->new(),
        credentials => Paws::Credential::None->new(),
    );

    $kinesis->CreateStream(...)

# DESCRIPTION

Paws::Kinesis::MemoryCaller implements Paws::Net::CallerRole which simulates its
own streams, shards and records.

# LICENSE

Copyright (C) Keith Broughton.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Keith Broughton <keithbro256@gmail.com>
