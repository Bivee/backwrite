package BackWrite::Controller::Entry;
use Mojo::Base 'BackWrite::Controller::Base';

use Time::Piece;
use BackWrite::Model;

# public actions
sub index {
    shift->redirect_to('/entry/list');
}

sub create {
    my $self = shift;

    my $d = localtime();
    # TODO check if user is admin

    # getting form data
    my $data = $self->_get_form();
    $data->{created} = join( 'T', ( $d->ymd('-'), $d->hms ) ) || undef;

    my $model = BackWrite::Model->load('Entry');

    if ( $self->is_post ) {

        # check slug exists
        my $count = $model->count( where => [ slug => $data->{slug} ] );

        if ($count) {
            return $self->render(
                template => 'entry/form',
                model    => $model || {},
                message  => {
                    class   => 'alert alert-danger',
                    text    => 'there are an entry with same slug',
                },
            );
        }

        # store entry
        $model->column( $_, $data->{$_} ) for keys %$data;
        $model->create;

        # error
        if ( $model && $model->error ) {
            return $self->render(
                template => 'entry/form',
                model    => $model || {},
                message  => {
                    class   => 'alert alert-danger',
                    text    => 'database error saving entry' . $model->error,
                },
            );
        }
    }

    return $self->render(
        template => 'entry/form',
        model    => $model || {},
        message  => {
            class   => ( $model && $model->column('id') )
                ?'alert alert-success': '',
            text    => ( $model && $model->column('id') )
                ? 'entry has been saved' : '',
        }
    );
}

sub edit {
    my $self = shift;

    # TODO check if user is admin

    # getting form data
    my $id   = $self->param('id') || 0;
    my $data = $self->_get_form();

    my $model = BackWrite::Model->load('Entry');
    $model = $model->find( where => [ id => $id ], single => 1 ) || undef;

    if ( $self->is_post ) {

        # check slug exists
        if($model && $model->column('slug') ne $data->{slug}){
            my $count = $model->count( where => [ slug => $data->{slug} ] );

            if ($count) {
                return $self->render(
                    template => 'entry/form',
                    model    => $model || {},
                    message  => {
                        class   => 'alert alert-danger',
                        text    => 'there are an entry with same slug',
                    },
                );
            }
        }

        # store entry
        $model->column( $_, $data->{$_} ) for keys %$data;
        $model->update;

        # error
        if ( $model && $model->error ) {
            return $self->render(
                template => 'entry/form',
                model    => $model || {},
                message  => {
                    class   => 'alert alert-danger',
                    text    => 'database error saving entry' . $model->error,
                },
            );
        }
        else {
            return $self->render(
                template => 'entry/form',
                model    => $model || {},
                message  => {
                    class   => ( $model && $model->column('id') )
                        ?'alert alert-success': '',
                    text    => ( $model && $model->column('id') )
                        ? 'entry has been saved' : '',
                }
            );
        }
    }

    return $self->render(
        template => 'entry/form',
        model    => $model || {},
        message  => {}
    );
}

sub list {
    my $self = shift;

    # TODO check if user is admin

    my $model = BackWrite::Model->load('Entry');

    return $self->render( list => $model->find || undef, );
}

sub remove {
    my $self = shift;

    # form data
    my $id = $self->param('id') || 0;

    # TODO check if user is admin

    # load entry
    my $model = BackWrite::Model->load('Entry');
    $model = $model->find( where => [ id => $id ], single => 1 ) || undef;

    if ($model) {
        $model->delete;
    }

    return $self->redirect_to('/entry/list');
}

# private methods
sub _get_form {
    my $self = shift;

    my $user = $self->current_user;

    return {
        title       => $self->param('title')       || undef,
        subtitle    => $self->param('subtitle')    || undef,
        description => $self->param('description') || undef,
        slug        => $self->param('slug')        || undef,
        content     => $self->param('content')     || undef,
        author      => ($user && $user->column('id'))? $user->column('id'): 0,
      }
      || undef;
}

1;
