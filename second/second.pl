use strict;
use warnings;
use Inline with => 'SDL';
use SDL;
use SDLx::App;
use SDL::Audio;
use lib 'lib';
use Foo;

my $app = SDLx::App->new( width => 640, height => 258, eoq => 1, title => "Synthesia Kinda", init => SDL_INIT_VIDEO | SDL_INIT_AUDIO );

my $img = SDLx::Surface::load( image=>'test.bmp' );

$img->blit( $app, [0,0,$img->w, $img->h], [0,0,$app->w, $app->h] );
$app->update();

Foo::PlaySound(); 

$app->add_show_handler( sub{ $app->update();} );


$app->run();

SDL::Audio::close();


