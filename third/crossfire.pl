use strict;
use warnings;
use SDL;
use SDLx::App;
use SDLx::Surface;

package Ship;
use SDL::Event;

sub new {
	my ( $class, $app ) = @_;
	my $self = bless { app => $app }, $class;
	$self->init_surface();

	$self->{x}     = 40 * 7;
	$self->{y}     = 40 * 6;
	$self->{vel}   = 10;
	$self->{y_vel} = 0;
	$self->{x_vel} = 0;

	$app->add_event_handler( sub { $self->event_handler(@_) } );
	$app->add_show_handler( sub  { $self->show_handler(@_) } );
	$app->add_move_handler( sub  { $self->move_handler(@_) } );

	return $self;
}

sub event_handler {
	my $self  = shift;
	my $event = shift;
	if ( $event->type == SDL_KEYDOWN ) {
		my $key = $event->key_sym;

		if (   $key == SDLK_UP
				|| $key == SDLK_DOWN
				|| $key == SDLK_LEFT
				|| $key == SDLK_RIGHT )
		{

			$self->{shoot_dir} = $key;

			unless ( $self->{moving} ) {
				$self->{move_dir} = $key;
				$self->{moving} = 1;
			}

		}
		$self->{shoot} = 1 if $key == SDLK_SPACE;

	}
	elsif ( $event->type == SDL_KEYUP ) {
		my $key = $event->key_sym;
		$self->{moving} = 0 if(    $key == SDLK_UP
				|| $key == SDLK_DOWN
				|| $key == SDLK_LEFT
				|| $key == SDLK_RIGHT );


	}

}

sub move_handler {
	my $self = shift;
	my $dt   = shift;

	if( $self->{moving} )
	{
	my $key = $self->{move_dir};
	$self->{y} -= $self->{vel} * $dt if $key == SDLK_UP;
	$self->{y} += $self->{vel} * $dt if $key == SDLK_DOWN;
	$self->{x} -= $self->{vel} * $dt if $key == SDLK_LEFT;
	$self->{x} += $self->{vel} * $dt if $key == SDLK_RIGHT;
	}

}

sub show_handler {
	my $self = shift;
	my $dt   = shift;
	my $app  = shift;
	$self->{surf}
	->blit( $app, [ 0, 0, 40, 40 ], [ $self->{x}, $self->{y}, 40, 40 ] );

}

sub init_surface {
	my $app = $_[0]->{app};
	my $surf = SDLx::Surface->new( width => 40, height => 40 );

	$surf->draw_rect( [ 10, 10, 20, 20 ], [ 255, 0,   0,   255 ] );
	$surf->draw_rect( [ 12, 12, 16, 16 ], [ 255, 255, 255, 255 ] );

	$surf->update();

	$_[0]->{surf} = $surf;

}

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

	$app->add_show_handler(
			sub {

			$self->{grid_surf}
			->blit( $app, [ 0, 0, 600, 600 ], [ 0, 0, 600, 600 ] );

			}
			);

	my $ship = Ship->new($app);
	$self->{ship} = $ship;

	$app->add_show_handler(
			sub {
			$app->update();
			}
			);

	return $self;

}

sub init_grid {

	my $app = $_[0]->{app};

	my $grid = SDLx::Surface->new( w => 600, h => 600 );

	$grid->draw_rect( [ 0, 0, 600, 600 ], [ 200, 200, 200, 255 ] );

	foreach ( 0 .. 7 ) {
		$grid->draw_rect( [ $_ * 80, 0,       40,  600 ], [ 0, 0, 0, 255 ] );
		$grid->draw_rect( [ 0,       $_ * 80, 600, 40 ],  [ 0, 0, 0, 255 ] );

	}

	$grid->update();

	$grid->blit( $app, [ 0, 0, 600, 600 ], [ 0, 0, 600, 600 ] );

	$_[0]->{grid_surf} = $grid;

}

package main;

Crossfire->new()->{app}->run();

