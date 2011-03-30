use strict;
use warnings;
use SDL;
use SDLx::App;
use SDLx::Surface;

package Enemy;

sub new {
    my ( $class) = shift;
    my $self = bless { @_ }, $class;
	my $app = $self->{app};
	$self->init_surface();

	$self->{vel} = 10;
	$self->{status} = 'm'; #or changing direction
	$self->get_next_dir();
	$app->add_show_handler( sub { $self->show_handler(@_) } );
    $app->add_move_handler( sub { $self->move_handler(@_) } );

	

    return $self;
}

sub init_surface {
	my $self = shift;

	my $surf = SDLx::Surface->new( width => 40, height => 40 );
	
	$surf->draw_rect( [ 10, 10, 20, 20 ], [ 255, 255,   255,   255 ] );
    $surf->draw_rect( [ 12, 12, 16, 16 ], [ 255, 0, 0, 255 ] );

    $surf->update();


	$self->{surf} = $surf; 	
}

sub show_handler {
	my $self = shift;
    my $dt   = shift;
    my $app  = shift;
    $self->{surf}
      ->blit( $app, [ 0, 0, 40, 40 ], [ $self->{x}, $self->{y}, 40, 40 ] );
}

sub move_handler {
    my $self = shift;
	my $dt = shift;
	if ( $self->{status} =~ 'm' )
	{
        my $key = $self->{move_dir};

        $self->{y} -= $self->{vel} * $dt if $key == 0;
        $self->{y} += $self->{vel} * $dt if $key == 1;
        $self->{x} -= $self->{vel} * $dt if $key == 2;
        $self->{x} += $self->{vel} * $dt if $key == 3;

		#collision check
		if($self->{y} > 600 - 39) 
		{
			$self->{y} = 600 - 40;
			$self->get_next_dir();
		}
		elsif( $self->{y} < 1 )
		{
			$self->{y} = 0;
			$self->get_next_dir();
		}
		elsif($self->{x} > 600 - 39) 
		{
			$self->{x} = 600 - 40;
			$self->get_next_dir();
		}
		elsif( $self->{x} < 1 )
		{
			$self->{x} = 0;
			$self->get_next_dir();
		}

		#random enabled check for crossroads
	}	
	else
	{
		$self->get_next_dir();
	}
	
}

sub get_next_dir {
	my $self = shift;


	$self->{move_dir} = int(rand()*4); #move randomly in one of the four direction 

	

}

package Ship;
use SDL::Event;

sub new {
    my ( $class, $app ) = @_;
    my $self = bless { app => $app }, $class;
    $self->init_surface();

    $self->{x}        = 40 * 7;
    $self->{y}        = 40 * 6;
    $self->{vel}      = 10;
    $self->{y_vel}    = 0;
    $self->{x_vel}    = 0;
    $self->{move_dir} = SDLK_RIGHT;
	$self->{next_move} = 0;

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

            # Trying to move vertical?
            if ( $key == SDLK_DOWN || $key == SDLK_UP || $self->{next_move} == 1 ) {

                # Were going horizontal
                if (   $self->{move_dir} == SDLK_LEFT
                    || $self->{move_dir} == SDLK_RIGHT )
                {
                    my $x_D = _cor_move_off( $self->{move_dir}, $self->{x} );
                    if ( $x_D % 2 ) {
                        return;
                    }
                    else {
                        $self->{x} = $x_D * 40;
                    }

                }
            }
            else

              # Trying to move horizontal?
            {

                if (   $self->{move_dir} == SDLK_UP
                    || $self->{move_dir} == SDLK_DOWN )
                {
                    my $y_D = _cor_move_off( $self->{move_dir}, $self->{y} );
                    if ( $y_D % 2 ) {
			#			warn "Failed going vertical, at $y_D and ".$self->{x}.", ".$self->{y}.". ".($self->{x}/40).", ". ($self->{y}/40 ).".";
                        return;
                    }
                    else {
                        $self->{y} = $y_D * 40;
                    }
                }

            }

            $self->{move_dir} = $key;

            unless ( $self->{moving} ) {
                $self->{moving} = 1;
            }

        }
        $self->{shoot} = 1 if $key == SDLK_SPACE;

    }
    elsif ( $event->type == SDL_KEYUP ) {
        my $key = $event->key_sym;

    }

}

# Calculates the right offset for the sprite
# And when to turn
sub _cor_move_off
{
	my ( $md, $val ) = @_;

	my $ret ;

	$ret = int( ($val -20 )/40 ) if( $md == SDLK_DOWN || $md == SDLK_LEFT);
	$ret = int( ($val + 20 )/40 ) if( $md == SDLK_UP || $md == SDLK_RIGHT);

	return $ret;

}

sub move_handler {
    my $self = shift;
    my $dt   = shift;

    my $i_y = int( $self->{y} / 40 );
    my $i_x = int( $self->{x} / 40 );

    if ( $i_x == 0 ) {
        $self->{x}      = ( 1 * 40 );
        $self->{moving} = 0;
    }
    if ( $self->{x} / 40 > 13 ) {
        $self->{x}      = ( 13 * 40 );
        $self->{moving} = 0;
    }
    if ( $i_y == 0 ) {
        $self->{y}      = ( 1 * 40 );
        $self->{moving} = 0;
    }
    if ( $self->{y} / 40 > 13 ) {
        $self->{y}      = ( 13 * 40 );
        $self->{moving} = 0;
    }

    if ( $self->{moving} ) {
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


	$self->init_enemies();


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

sub init_enemies
{
	my $self = shift;

	my @enemies = ();
	foreach(2..8)
	{
		my $enemy = Enemy->new(app => $self->{app}, x=> $_*40, y => 0);
		push @enemies, $enemy;
	}

	foreach(1..2)
	{
		my $enemy = Enemy->new(app => $self->{app}, x=> 0, y => $_*120);
		push @enemies, $enemy;
	}
	foreach(3..5)
	{
		my $enemy = Enemy->new(app => $self->{app}, x=> 14*40, y => $_*40);
		push @enemies, $enemy;
	}



	$self->{enemies} = \@enemies;

}

package main;

Crossfire->new()->{app}->run();

