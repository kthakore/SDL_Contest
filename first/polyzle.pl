use strict;
use warnings;
use SDL 2.532;
use SDL::Video;
use SDLx::App;
use SDL::Color;
use SDLx::Validate;
use SDLx::Text;
use Data::Dumper;

use lib 'lib';
use Polygon;

my $app = SDLx::App->new(
    title => "Polygon Trouble",
    eoq   => 1,
    depth => 32,
    flags => SDL_HWSURFACE | SDL_DOUBLEBUF,
    delay => 20,
    icon  => 'data/icon.bmp'
);

$app->stash->{text} = SDLx::Text->new(); 

$app->stash->{polygons} = [];
$app->stash->{score} = 0;
$app->add_show_handler(
    sub { $app->draw_rect( [ 0, 0, $app->w, $app->h ], 0 ); } );

foreach ( 0 .. 5 ) {
    my $sides = ( rand() * 5 ) + 3;
     my $tri   = Polygon->new(
        verts   => $sides,
        color   => rand_color(),
        bgcolor => 0x00000001,
        radius  => rand()*25 + 10,
        width   => 200,
        height  => 200,
        depth   => 32
    );

    $tri->attach( app => $app );

    push @{ $app->stash->{polygons} }, $tri;
}
$app->add_show_handler(
    sub { $app->stash->{text}->write_to( $app, "Score: ".$app->stash->{score} ) } 
	);


$app->add_show_handler( sub { $app->update() } );
$app->run();


sub rand_color{

	my $r = int( rand() * 0xFF ) + 0x22;
	my $g = int( rand() * 0xFF ) + 0x22;
	my $b = int( rand() * 0xFF ) + 0x22;
	my $color = SDL::Color->new( $r, $g, $b );

	$color = SDLx::Validate::num_rgba( $color );
	return $color;
}
