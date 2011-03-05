use strict;
use warnings;
use SDL 2.532;
use SDL::Video;
use SDLx::App;
use Data::Dumper;

use lib 'lib';
use Polygon;

my $app = SDLx::App->new(
    title => "Polygon Trouble",
    eoq   => 1,
    depth => 32,
    flags => SDL_HWSURFACE | SDL_DOUBLEBUF,
    delay => 60,
    icon  => 'data/icon.bmp'
);

$app->stash->{polygons} = [];
$app->add_show_handler(
    sub { $app->draw_rect( [ 0, 0, $app->w, $app->h ], 0 ); } );

foreach ( 0 .. 5 ) {
    my $sides = ( rand() * 5 ) + 3;
    my $color = int( rand() * 0xffffffff ) + 0x11111111;
    my $tri   = Polygon->new(
        verts   => $sides,
        color   => $color,
        bgcolor => 0x00000011,
        radius  => rand()*25 + 10,
        width   => 200,
        height  => 200,
        depth   => 32
    );

    $tri->attach( app => $app );

    push @{ $app->stash->{polygons} }, $tri;
}
$app->add_show_handler( sub { $app->update() } );
$app->run();
