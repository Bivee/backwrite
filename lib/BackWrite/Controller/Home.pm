package BackWrite::Controller::Home;
use Mojo::Base 'BackWrite::Controller::Base';

use BackWrite::Model;

sub index {
    my $self = shift;

    my $model = BackWrite::Model->load('Entry');

    return $self->render(
        list => $model->find || undef
    );
}

sub profile {
    my $self = shift;
}

1;
