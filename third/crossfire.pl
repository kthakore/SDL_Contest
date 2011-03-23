use strict;
use warnings;
use SDL;
use SDLx::App;

package Crossfire;
use SDL::Video;

sub new {

    my $app = SDLx::App->new(
        w     => 600,
        h     => 600,
        eoq   => 1,
        title => "Crossfire",
        flags => SDL_HWSURFACE | SDL_DOUBLEBUF
    );
    my $self = bless { app => $app }, shift;

    $self->init_grid();

    $app->update();
    return $self;

}

sub init_grid {
    my $app = $_[0]->{app};

    my $grid = SDLx::Surface->new( w => 600, h => 600 );

    $grid->draw_rect( [ 0, 0, 600, 600 ], [ 200, 200, 200, 200 ] );

    foreach ( 0 .. 7 ) {
        $grid->draw_rect( [ $_ * 80, 0,       40,  600 ], 0 );
        $grid->draw_rect( [ 0,       $_ * 80, 600, 40 ],  0 );

    }

    $grid->update();

    $grid->blit( $app, [ 0, 0, 600, 600 ], [ 0, 0, 600, 600 ] );

    $app->stash( grid => $grid );

}

package main;

Crossfire->new()->{app}->run();

