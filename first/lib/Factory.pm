package Factory;
use strict;
use warnings;
use Math::Trig;

sub calculate_regular_polygon {
	my $verts = shift || 3;
	return if $verts < 3;
	my $rot_ang = shift || 45;
	my $radius = shift || 50;
	my $cx = shift;
	my $cy = shift;	
	my $angle = deg2rad($rot_ang); 
	my $angle_inc = 2 * pi / $verts;



	my @x; my @y;

	push @x, $radius * cos($angle) + $cx;
	push @y, $radius * sin($angle) + $cy;

	foreach( 1..$verts)
	{
		$angle += $angle_inc;
		push @x, $radius * cos($angle) + $cx;
		push @y, $radius * sin($angle) + $cy;
	}	
	return [ \@x, \@y ];
}


sub polygon {
	my %options = @_;

	my $surf = $options{surf};

	$surf = SDLx::Surface->new( @_ ) unless $surf;

	my $center = $options{center};

	my $poly_points = calculate_regular_polygon( $options{verts}, $options{rot}, $options{radius}, $center->[0], $center->[1]);

	$surf->draw_rect( [0,0,$surf->w, $surf->h], $options{bgcolor} ) if $options{bgcolor};
	SDL::GFX::Primitives::filled_polygon_color( $options{surf}, $poly_points->[0], $poly_points->[1], $options{verts} + 1, $options{color} );
	SDL::GFX::Primitives::aapolygon_color( $options{surf}, $poly_points->[0], $poly_points->[1], $options{verts} + 1, $options{color} );

	return $surf;

}


sub poly_insert
{
	my %options = @_;

	my $app = $options{app};
	my $polygon = $options{poly};
	   $polygon = polygon( @_ ) unless $polygon;

	#Make a show handler and attach it to the app

	my $animate_handler = sub {

		# For each $dt cycle trough squence of radii 

		# Once done drop the cycle between throb ?
	};

	$app->add_show_handler( $animate_handler );


	#Make an event handler to check for clicks on the polygon
	
	my $check_click = sub {
	
	 # convert the click to relative coords on polygon

	 # we can do a check between min and max points relative to the polygon.
	 
	

	};

	$app->add_show_handler( $check_click );
		
	

}
1;
