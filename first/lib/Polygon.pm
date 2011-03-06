package Polygon;
use strict;
use warnings;
use Math::Trig;
use Data::Dumper;

use SDL;
use SDLx::Rect;
use SDL::Event;
use SDL::Events;
use SDLx::Sprite;
use SDL::GFX::Primitives;

use SDLx::Surface;

sub new {
    my ( $class, %options ) = @_;

    my $self = {%options};
    $self = bless $self, $class;

    $self->_construct();
    return $self;
}

# ATTRIBUTES

sub x {
    $_[0]->{sprite}->x(@_);
}

sub y {
    $_[0]->{sprite}->y(@_);
}

sub min {
    $_[0]->{min};
}

sub max {
    $_[0]->{max};
}

sub poly_points {
    $_[0]->{poly_points};
}

sub surf {
    $_[0]->{surf};
}

# METHODS

sub attach {
    my $self    = shift;
    my %options = @_;

    die "Require app to be passed in!" unless $options{app};

	my $app = $options{app};
    if ( rand() > 0.5 ) {
        $self->{v} = [ 0, rand() * 60 + 5];
        $self->{sprite}->x( $app->w() * rand() );
        $self->{sprite}->y(0);
    }
    else {
        $self->{v} = [ rand() * 60 + 5, 0 ];
        $self->{sprite}->y( $app->h() * rand() );
        $self->{sprite}->x(0);

    }

    $self->{app} = $options{app};

    # Construct a Event Handler
    $self->{event_handler_id} =
      $self->{app}->add_event_handler( sub { $self->_event_handler(@_) } );

    # Construct a Show Handler
    $self->{show_handler_id} =
      $self->{app}->add_show_handler( sub { $self->_show_handler(@_) } );

    # Construct a Move Handler
    $self->{move_hander_id} =
      $self->{app}->add_move_handler( sub { $self->_move_handler(@_) } );

}

sub detach {
    my $self = shift;
}

# PRIVATE FUNCTIONS

sub _construct {
    my $self = shift;

	$self->{bgcolor} = $self->{bgcolor} || 0x00000010;
    my $surf = $self->{surf};

    $surf = SDLx::Surface->new(%$self) unless $surf;

    $self->{sprite} = SDLx::Sprite->new( surface => $surf );
    my $center = $self->{center};

    $self->{surf} = $surf;

    my $poly_points = $self->_calculate_regular_polygon();
	
    $surf->draw_rect( [ 0, 0, $surf->w, $surf->h ], $self->{bgcolor});
    SDL::GFX::Primitives::filled_polygon_color(
        $self->{surf},      $poly_points->[0], $poly_points->[1],
        $self->{verts} , $self->{color}
    );


    SDL::GFX::Primitives::aapolygon_color(
        $self->{surf},      $poly_points->[0], $poly_points->[1],
        $self->{verts} , 0x000000ff
    );

    $surf->update();
    $self->{poly_points} = $poly_points;

}

sub _calculate_regular_polygon {
    my $self = shift;
    my $verts = int($self->{verts}) || 4;
    $verts = 4 if $verts < 4;
    my $rot_ang = $self->{rot}         || 0;
    my $radius  = $self->{radius}      || 50;
    my $cx      = $self->{center}->[0] || $self->{surf}->w / 2;
    my $cy      = $self->{center}->[1] || $self->{surf}->h / 2;
    my $angle   = deg2rad($rot_ang);
    my $angle_inc = 2 * pi / ($verts-1);

    my @x;
    my @y;

    push @x, $radius * cos($angle) + $cx;
    push @y, $radius * sin($angle) + $cy;

    $self->{min} = [ $x[0], $y[0] ];
    $self->{max} = [ $x[0], $y[0] ];
    foreach ( 0 .. $verts ) {
        $angle += $angle_inc;
        my $x = $radius * cos($angle) + $cx;
        my $y = $radius * sin($angle) + $cy;

        $self->{min}->[0] = $x if ( $x <= $self->{min}->[0] );
        $self->{max}->[0] = $x if ( $x >= $self->{max}->[0] );

        $self->{min}->[1] = $y if ( $y <= $self->{min}->[1] );
        $self->{may}->[1] = $y if ( $y >= $self->{max}->[1] );

        push @x, $x;
        push @y, $y;

    }
	$self->{center} = [ $cx, $cy ];
    return [ \@x, \@y ];
}

sub _show_handler {
    my $self = shift;
    my ( $dt, $app ) = @_;

    $self->{sprite}->draw( $self->{app} );

}

sub _event_handler {
    my $self = shift;
    my ( $event, $app ) = @_;

    if ( $event->type == SDL_MOUSEBUTTONDOWN ) {
        my $click = [ $event->button_x, $event->button_y ];

		my $x = $self->{sprite}->x();
		my $y = $self->{sprite}->y();	
		my @r = ($x + $self->{min}->[0], $y + $self->{min}->[1], $self->{max}->[0] - $self->{min}->[0],  $self->{max}->[1] - $self->{min}->[1] );
		$app->stash->{score} += int($self->{verts}) if SDLx::Rect->new(@r)->collidepoint( $event->button_x, $event->button_y );
    }

}

sub _move_handler {
    my $self = shift;
    my ( $dt, $app, $time ) = @_;
    my $x = $self->{sprite}->x() + ( $self->{v}->[0] * $dt );
    my $y = $self->{sprite}->y() + ( $self->{v}->[1] * $dt );

    $self->{sprite}->x($x);
    $self->{sprite}->y($y);

	if ( $self->{center}->[0] + $x > $app->w ) {
	$self->{sprite}->x( 0 - $self->{center}->[0] )
	}
	if ( $self->{center}->[1] + $y > $app->h ) {
	$self->{sprite}->y( 0 - $self->{center}->[1])
	}
}

1;
