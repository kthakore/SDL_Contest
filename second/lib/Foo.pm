package Foo;
use strict;
use warnings;
use Inline with => 'SDL';
use SDL;

use Inline C => <<'END';
extern void mixaudio(void *unused, Uint8 *stream, int len);

void mixaudio(void *unused, Uint8 *stream, int len)
{
    int i;
    Uint32 amount;

	SDL_Surface* video = SDL_GetVideoSurface();
	Uint8* pix_2_audio = (Uint8*)video->pixels;
	for( i =0; i < len; i++ )
	{
		stream[i] = pix_2_audio[i];
	}

}

void PlaySound(char *file)
{
    SDL_AudioSpec fmt;

    /* Set 16-bit stereo audio at 22Khz */
    fmt.freq = 22050;
    fmt.format = AUDIO_S16;
    fmt.channels = 2;
    fmt.samples = 512;        /* A good value for games */
    fmt.callback = mixaudio;
    fmt.userdata = NULL;

    /* Open the audio device and start playing sound! */
    if ( SDL_OpenAudio(&fmt, NULL) < 0 ) {
        fprintf(stderr, "Unable to open audio: %s\n", SDL_GetError());
        exit(1);
    }
    SDL_PauseAudio(0);
}


void render( float delta, SDL_Surface *screen )
{   
	// Lock surface if needed
	if (SDL_MUSTLOCK(screen)) 
		if (SDL_LockSurface(screen) < 0) 
			return;

	// Ask SDL for the time in milliseconds
	int tick = SDL_GetTicks();

	// Declare a couple of variables
	int i, j, yofs, ofs;

	// Draw to screen
	yofs = 0;
	for (i = 0; i < screen->h; i++)
	{
		for (j = 0, ofs = yofs; j < screen->w; j++, ofs++)
		{

			Uint32 value = i * i + j * j + tick;
			Uint8 a = value >> 2;
			Uint8 b = value >> 4;
			Uint8 g = value >> 8;
			Uint8 r = value >> 16;

			Uint32 map_val = SDL_MapRGBA( screen->format, r, g, b, a);
			((unsigned int*)screen->pixels)[ofs] = map_val;
		}
		yofs += screen->pitch / 4;
	}

	// Unlock if needed
	if (SDL_MUSTLOCK(screen)) 
		SDL_UnlockSurface(screen);

	// Tell SDL to update the whole screen
	SDL_UpdateRect(screen, 0, 0, screen->w,screen->h);    
}

END

1;
