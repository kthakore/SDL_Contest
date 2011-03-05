use strict;
use warnings;
use SDL 2.532;
use SDL::Video;
use SDLx::App;
use Data::Dumper;

use lib 'lib';
use Polygon;


my $app = SDLx::App->new( title => "Polygon Trouble", eoq=> 1, depth => 32, flags => SDL_HWSURFACE | SDL_DOUBLEBUF, delay => 60, icon => 'data/icon.bmp' );
my $tri = Polygon->new( verts => 5, color => 0xff00ffff, bgcolor => 0x00000011, radius => 20, width => 200, height => 200, depth => 32 );

$tri->attach( app => $app );
$app->run();
