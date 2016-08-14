[![Build Status](https://travis-ci.org/keithbro/Paws-Kinesis-MemoryCaller.svg?branch=master)](https://travis-ci.org/keithbro/Paws-Kinesis-MemoryCaller)
# NAME

Paws::Kinesis::MemoryCaller - A Paws Caller with in-memory Kinesis.

# SYNOPSIS

    use Paws;
    use Paws::Kinesis::MemoryCaller;

    my $kinesis = Paws->service('Kinesis',
        region      => 'N/A',
        caller      => Paws::Kinesis::MemoryCaller->new(),
        credentials => Paws::Credential::None->new(),
    );

    # Create a Kinesis stream...
    $kinesis->CreateStream(%args);

    # Get a shard iterator...
    $kinesis->GetShardIterator(%args);

    # Put a record on a stream...
    $kinesis->PutRecord(%args);

    # Get records from a stream...
    $kinesis->GetRecords(%args);

# DESCRIPTION

Paws::Kinesis::MemoryCaller implements Paws::Net::CallerRole which simulates its
own streams, shards and records in memory.

The following methods have been implemented:

\* CreateStream
\* DescribeStream
\* GetRecords
\* GetShardIterator
\* PutRecord

# LICENSE

Copyright (C) Keith Broughton.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# DEVELOPMENT

## Author

Keith Broughton `<keithbro [AT] cpan.org>`

## Bug reports

Please report any bugs or feature requests on GitHub:

[https://github.com/keithbro/Paws-Kinesis-MemoryCaller/issues](https://github.com/keithbro/Paws-Kinesis-MemoryCaller/issues).
