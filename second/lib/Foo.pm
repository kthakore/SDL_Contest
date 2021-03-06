package Foo;
use strict;
use warnings;
use Inline with => 'SDL';
use SDL;

use Inline C => <<'END';
extern void mixaudio(void *unused, Uint8 *stream, int len);
unsigned int c_x = 0;
unsigned int c_y = 0;
unsigned int song_progress =0;
SDL_AudioCVT cvt;

void load_wav_file(char* file)
{
    int index;
    SDL_AudioSpec wave;
    Uint8 *data;
    Uint32 dlen;

    /* Load the sound file and convert it to 16-bit stereo at 22kHz */
    if ( SDL_LoadWAV(file, &wave, &data, &dlen) == NULL ) {
        fprintf(stderr, "Couldn't load %s: %s\n", file, SDL_GetError());
        return;
    }
    SDL_BuildAudioCVT(&cvt, wave.format, wave.channels, wave.freq,
                            AUDIO_S16,   2,             22050);
    cvt.buf = malloc(dlen*cvt.len_mult);
    memcpy(cvt.buf, data, dlen);
    cvt.len = dlen;
    SDL_ConvertAudio(&cvt);
    SDL_FreeWAV(data);



}


int _calc_offset ( SDL_Surface* surface, int x, int y )
{	
	int offset;
	offset  = (surface->pitch * y)/surface->format->BytesPerPixel;
	offset += x;
	return offset;
}

void set_pixel( SDL_Surface *surface, int x, int y, Uint32 val)
{

	int offset = _calc_offset( surface, x, y);
		if (SDL_MUSTLOCK(surface)) 
			if (SDL_LockSurface(surface) < 0) 
				return;

	((Uint32 *)surface->pixels)[offset] = val;

		// Unlock if needed
		if (SDL_MUSTLOCK(surface)) 
			SDL_UnlockSurface(surface);


}

Uint32 get_pixel32 (SDL_Surface *surface, int x, int y)
{
	
	/*Convert the pixels to 32 bit  */
	Uint32 *pixels = (Uint32 *)surface->pixels; 
	/*Get the requested pixel  */
	
	void* s =  pixels + _calc_offset(surface, x, y); 
	return *((Uint32*) s);
}

void mixaudio(void *unused, Uint8 *stream, int len)
{
	int i;

	SDL_Surface* screen = SDL_GetVideoSurface();
	for( i =0; i < len; i+=4 )
	{
		
		if( c_x < screen->w && c_y < screen->h)
		{
			c_y++;
		}
		else if( c_y >= screen->h && c_x < screen->w)
		{
			c_y=0;
			c_x++;
		}
		else if( c_x == 0 && c_y >= screen->h)
		{
			 c_x = 0;
			 c_y = 0;
		}

//		fprintf( stderr ," %d (%d,%d) \n",i,  c_x, c_y);

		Uint32 pix = get_pixel32( screen, c_x, c_y);

		Uint8 r, b, g, a;
	
		a = pix >> 24;
		b = pix >> 16;
		g = pix >> 8;
		r = pix ;

		stream[i]   += r + a ;
		stream[i+1] += g + b;
		stream[i+2] += b + g;
		stream[i+3] += a + r;


		if( i < cvt.len && 0)
		{
			unsigned int sp = song_progress + i;
			r = cvt.buf[sp];
			g = cvt.buf[sp+1];
			b = cvt.buf[sp+2];
			a = cvt.buf[sp+3];
			Uint32 pix;
			pix += a << 24;
			pix += g << 16;
			pix += b << 8;
			pix += r;

			set_pixel( screen, c_x, c_y,  pix );


		}
		else
		{
		
		set_pixel( screen, c_x, c_y,  0xFFFFFFFF );
		}
	}

	song_progress += i;



}

void PlaySound()
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


void render( SDL_Surface *screen )
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

			Uint32 value = i + i + j *23 * j + tick;
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
