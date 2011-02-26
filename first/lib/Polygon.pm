package Polygon;
use strict;
use warnings;
use Math::Trig;
use Data::Dumper;
use SDLx::Surface;
use SDL::GFX::Primitives;

sub new {
    my ( $class, %options ) = @_;

    my $self = {%options};
    $self = bless $self, $class;

    $self->_construct();
    return $self;
}

# ATTRIBUTES

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

sub born {
    my $self = shift;

}

sub die {

}

# PRIVATE FUNCTIONS

sub _construct {
    my $self = shift;

    my $surf = $self->{surf};

    $surf = SDLx::Surface->new(%$self) unless $surf;

    my $center = $self->{center};

    my $poly_points = $self->_calculate_regular_polygon();

    $surf->draw_rect( [ 0, 0, $surf->w, $surf->h ], $self->{bgcolor} )
      if $self->{bgcolor};
    SDL::GFX::Primitives::filled_polygon_color(
        $self->{surf},      $poly_points->[0], $poly_points->[1],
        $self->{verts} + 1, $self->{color}
    );
    SDL::GFX::Primitives::aapolygon_color(
        $self->{surf},      $poly_points->[0], $poly_points->[1],
        $self->{verts} + 1, $self->{color}
    );

    $surf->update();
    $self->{surf}        = $surf;
    $self->{poly_points} = $poly_points;

}

sub _calculate_regular_polygon {
    my $self = shift;
    my $verts = $self->{verts} || 3;
    return if $verts < 3;
    my $rot_ang = $self->{rot}         || 45;
    my $radius  = $self->{radius}      || 50;
    my $cx      = $self->{center}->[0] || $self->{surf}->w / 2;
    my $cy      = $self->{center}->[1] || $self->{surf}->h / 2;
    my $angle   = deg2rad($rot_ang);
    my $angle_inc = 2 * pi / $verts;

    my @x;
    my @y;

    push @x, $radius * cos($angle) + $cx;
    push @y, $radius * sin($angle) + $cy;

    $self->{min} = [ $x[0], $y[0] ];
    $self->{max} = [ $x[0], $y[0] ];
    foreach ( 1 .. $verts ) {
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
    return [ \@x, \@y ];
}

1;
