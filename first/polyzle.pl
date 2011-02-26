use strict;
use warnings;
use SDL;
use SDLx::App;
use Data::Dumper;

use lib 'lib';
use Factory;


my $surface = SDLx::App->new( eoq=> 1);
my $tri = Factory::polygon(3, 0, 20 );

SDL::GFX::Primitives::polygon_color( $surface, $tri->[0], $tri->[1], 4, 0xFF0000FF );

$surface->update();

$surface->run();
