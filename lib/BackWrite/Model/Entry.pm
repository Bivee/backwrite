package BackWrite::Model::Entry;
use Mojo::Base 'BackWrite::Model::Base';

__PACKAGE__->schema(
    table          => 'entry',
    columns        => [qw/id title subtitle description slug content author created/],
    primary_keys   => ['id'],
    auto_increment => 'id',
);

1;




