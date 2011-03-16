use strict;
use warnings;
use Inline with => 'SDL';
use SDL;
use SDLx::App;
use SDL::Audio;
use lib 'lib';
use Foo;
use Spotify;
use SDL::GFX::Primitives;

my $app = SDLx::App->new( width => 640, height => 258, eoq => 1, title => "Synthesia Kinda", init => SDL_INIT_VIDEO | SDL_INIT_AUDIO );

my $img = SDLx::Surface::load( image=>'test.bmp' );

foreach( 0...100 )
{

	my $x = rand() * $app->w;
	my $y = rand() * $app->h;
	my $r = rand() * 20 + 5;
	my $avg_points = Spotify::avg_color_in_circle( $img, [$x,$y], $r, [640,480]);
	$img->draw_circle_filled( [$x,$y],$r, $avg_points);

}

$img->blit( $app, [0,0,$img->w, $img->h], [0,0,$app->w, $app->h] );
$app->update();
$app->run();

Foo::load_wav_file("sample.wav");

Foo::PlaySound(); 

$app->add_show_handler( sub{ $app->update();} );


$app->run();

SDL::Audio::close();


