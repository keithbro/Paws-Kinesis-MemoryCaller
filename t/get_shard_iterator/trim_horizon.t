use Test::Most;

use Paws;
use Paws::Credential::None;
use Paws::Kinesis::MemoryCaller;
use Paws::Kinesis::PutRecordsRequestEntry;

my $kinesis = Paws->service('Kinesis',
    region      => 'N/A',
    credentials => Paws::Credential::None->new(),
    caller      => Paws::Kinesis::MemoryCaller->new(),
);

$kinesis->CreateStream(StreamName => "my_stream", ShardCount => 1);

my $describe_stream_output = $kinesis->DescribeStream(
    StreamName => "my_stream",
);

my $shard_id = $describe_stream_output->StreamDescription->Shards->[0]->ShardId;

my $get_shard_iterator_output = $kinesis->GetShardIterator(
    ShardId           => $shard_id,
    ShardIteratorType => "TRIM_HORIZON",
    StreamName        => "my_stream",
);

my $shard_iterator = $get_shard_iterator_output->ShardIterator;
ok ($shard_iterator, "got a new shard_iterator ($shard_iterator)");

$kinesis->PutRecords(
    Records => [
        Paws::Kinesis::PutRecordsRequestEntry->new(
            Data => "1st Message",
            PartitionKey => "olympics",
        ),
        Paws::Kinesis::PutRecordsRequestEntry->new(
            Data => "2nd Message",
            PartitionKey => "olympics",
        ),
    ],
    StreamName => "my_stream",
);

my $get_records_output = $kinesis->GetRecords(
    ShardIterator => $shard_iterator,
);

is scalar @{$get_records_output->Records}, 2, 'got two records';
is $get_records_output->Records->[0]->Data, "1st Message", "got correct data";
is $get_records_output->Records->[1]->Data, "2nd Message", "got correct data";

done_testing;
