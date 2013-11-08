package BackWrite::Controller::Page;
use Mojo::Base 'BackWrite::Controller::Base';

use BackWrite::Model;

sub index {
    my $self = shift;

    # load page
    my $model = BackWrite::Model->load('Entry');
    $model = $model->find(
        where => [ slug => $self->param('slug') || undef ], single => 1
    ) || undef;

    # not found
    unless ($model) {
        return $self->render(
            layout => 'default',
            text   => 'page not found',
        );
    }

    # error
    if ( $model && $model->error ) {
        return $self->render(
            layout => 'default',
            text   => $model->error || 'generic error',
        );
    }

    # show page
    return $self->render(
        layout => 'default',
        text   => $model->column('content') || 'none',
    );
}

1;
