use strict;
use warnings;
use Inline with => 'SDL';
use SDL;
use SDLx::App;
use SDL::Audio;
use lib 'lib';
use Foo;

my $app = SDLx::App->new( width => 640, height => 480, eoq => 1, title => "Grovvy XS Effects", init => SDL_INIT_VIDEO | SDL_INIT_AUDIO );

Foo::PlaySound('sample.wav'); 

$app->add_show_handler( sub{ Foo::render(@_) } );

$app->run();

SDL::Audio::close();


