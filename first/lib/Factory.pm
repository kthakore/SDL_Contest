package Factory;
use strict;
use warnings;
use Math::Trig;

sub polygon {
	my $verts = shift || 3;
	return if $verts < 3;
	my $rot_ang = shift || 60;
	my $radius = shift || 50;
	my $color = shift || 0xFFFFFF;


	my $angle = deg2rad($rot_ang); 
	my $angle_inc = 2 * pi / $verts;

	my ($cx, $cy) = (50,50);

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

1;
