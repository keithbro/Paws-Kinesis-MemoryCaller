use Test::Most;

use Data::Dumper;
use Paws;
use Paws::Credential::None;
use Paws::Kinesis::MemoryCaller;

my $kinesis = Paws->service('Kinesis',
    region      => 'N/A',
    credentials => Paws::Credential::None->new(),
    caller      => Paws::Kinesis::MemoryCaller->new(),
);

$kinesis->CreateStream(StreamName => "my_stream", ShardCount => 2);

eq_or_diff($kinesis->caller->store, {
    my_stream => {
        'shardId-000000000000' => [],
        'shardId-000000000001' => [],
    },
}, "One stream exists, with two empty shards");

eq_or_diff(
    $kinesis->caller->shard_iterator__address, {},
    "no shard_iterators exist yet",
);

my $put_record_output = $kinesis->PutRecord(
    Data => "1st message",
    StreamName => "my_stream",
    PartitionKey => "my_partition_key",
);
is(
    ref($put_record_output), "Paws::Kinesis::PutRecordOutput",
    "got a Paws::Kinesis::PutRecordOutput",
);
is($put_record_output->SequenceNumber, 1, "Returned a SequenceNumber");

my $get_shard_iterator_output = $kinesis->GetShardIterator(
    ShardId => "shardId-000000000000",
    StreamName => "my_stream",
    ShardIteratorType => "LATEST",
);
is(
    ref($get_shard_iterator_output), "Paws::Kinesis::GetShardIteratorOutput",
    "got a Paws::Kinesis::GetShardIteratorOutput",
);

my $shard_iterator = $get_shard_iterator_output->ShardIterator;

eq_or_diff(
    $kinesis->caller->shard_iterator__address, {
        $shard_iterator => {
            shard_id => "shardId-000000000000",
            index => 1,
            stream_name => "my_stream",
        },
    },
    "a shard_iterator has been created ($shard_iterator)",
);

my $get_records_output = $kinesis->GetRecords(ShardIterator => $shard_iterator);
eq_or_diff(
    $get_records_output->Records,
    [],
    "no records found on shard_iterator",
);
ok $get_records_output->NextShardIterator, "got NextShardIterator";

$kinesis->PutRecord(
    Data => "2nd message",
    StreamName => "my_stream",
    PartitionKey => "my_partition_key",
);

$kinesis->PutRecord(
    Data => "3rd message",
    StreamName => "my_stream",
    PartitionKey => "my_partition_key",
);

$get_records_output = $kinesis->GetRecords(
    ShardIterator => $get_records_output->NextShardIterator,
);
is(scalar @{$get_records_output->Records}, 2, "got two records");
eq_or_diff(
    [ map { $_->Data } @{$get_records_output->Records} ],
    [ "2nd message", "3rd message" ],
    "found the new messages on the shard_iterator",
);

$get_shard_iterator_output = $kinesis->GetShardIterator(
    ShardIteratorType => "TRIM_HORIZON",
    ShardId => "shardId-000000000000",
    StreamName => "my_stream",
);

ok(
    $get_shard_iterator_output->ShardIterator,
    "got a shard_iterator using TRIM_HORIZON",
);

$get_records_output = $kinesis->GetRecords(
    ShardIterator => $get_shard_iterator_output->ShardIterator,
);

is scalar @{$get_records_output->Records}, 3, "got 3 records using TRIM_HORIZON";

$get_shard_iterator_output = $kinesis->GetShardIterator(
    ShardIteratorType => "AT_SEQUENCE_NUMBER",
    StartingSequenceNumber => 3,
    ShardId => "shardId-000000000000",
    StreamName => "my_stream",
);

ok(
    $get_shard_iterator_output->ShardIterator,
    "got a shard_iterator using AT_SEQUENCE_NUMBER",
);

$get_records_output = $kinesis->GetRecords(
    ShardIterator => $get_shard_iterator_output->ShardIterator,
);

is(
    scalar @{$get_records_output->Records}, 1,
    "got 1 records using AT_SEQUENCE_NUMBER",
);

is(
    $get_records_output->Records->[0]->SequenceNumber, 3,
    "record has SequenceNumber 3",
);

is(
    $get_records_output->Records->[0]->Data, "3rd message",
    "record has correct data",
);

#diag Dumper $kinesis->caller->store;
#diag Dumper $kinesis->caller->shard_iterator__address;

done_testing;
