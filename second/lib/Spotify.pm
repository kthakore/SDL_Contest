package Spotify;
use strict;
use warnings;
use SDLx::Surface;
use Data::Dumper;


sub avg_color_in_circle
{
	my( $screen, $center, $radius, $max) = @_;

	my $color_sum = [0,0,0,0];

	my $start = [ $center->[0], $center->[1] - $radius ];
	$start = [0,0] if $start->[1] < 0 ;
	my $current = $start;

#	my @points;
	my $points;
	if ( _point_in_circle( $current, $center, $radius) )
	{

		 _sum_color( $color_sum, $screen->[$current->[0]][$current->[1]]);

				$points++;
#		push @points, $current;

	}
	while( $current->[0] != $center->[0] || $current->[1] != $center->[1]+$radius )
	{

		my $next = [ $current->[0]++, $current->[1] ];

		while( $next->[0] <= $center->[0]+$radius && $next->[0] < $max->[0])
		{

			if ( _point_in_circle( $next, $center, $radius) )
			{
					 _sum_color( $color_sum, $screen->[$current->[0]][$current->[1]]);
				#warn "Current ".$current->[0]." ".$current->[1];
				#warn "Color : $color_sum";
				#push @points, $next;
				$points++;
			}
		 	$next->[0] =  $next->[0] + 1;

		}

		$current = [0, $next->[1] + 1 ];
		unless ($current->[1] <= $center->[1]+$radius && $current->[1] < $max->[1])
		{
			return int($color_sum/$points);
		}

	}
	
			return int($color_sum/$points)

}

sub _point_in_circle
{
	my ( $point, $center, $radius ) = @_;
	
	# Get the distance from point to center
	
	my $dist = ($point->[0] - $center->[0])**2 + ($point->[1] - $center->[1])**2;

#	warn 'Dist '.sqrt($dist);
	return ($dist <= $radius**2);

}

sub _sum_color 
{
	my $sum = shift;
	my $value = shift;

	my ($r,$g,$b,$a); 

	$r = $value >> 24;
	$g = $value >> 16;
	$b = $value >> 8;
	$a = $value;

	$sum = [$sum->[0] + $r, $sum->[1] + $g, $sum->[2] + $b, $sum->[3] + $a]; 

}

1;

