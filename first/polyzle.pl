use strict;
use warnings;
use SDL;
use SDLx::App;
use Data::Dumper;

use lib 'lib';
use Polygon;


my $surface = SDLx::App->new( eoq=> 1);
my $tri = Polygon->new( surf => $surface, verts => 5, color => 0xff00ffff, center => [200, 300], radius => 100 );

$tri->attach( app => $surface );
$surface->run();
