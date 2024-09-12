/*
 * SDL_sound -- An abstract sound format decoding API.
 * Copyright (C) 2001  Ryan C. Gordon.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 * libmpg123 decoder for SDL_sound. This is a very lightweight MP3 decoder,
 *  which is included with the SDL_sound source, so that it doesn't rely on
 *  unnecessary external libraries.
 *
 * libmpg123 is part of mpg123, and can be found in its original
 *  form at: http://www.mpg123.org/
 *
 * Please see the file LICENSE.txt in the source's root directory. The included
 *  source code for libmpg123 falls under the LGPL, which is the same license
 *  as SDL_sound (so you can consider it a single work).
 *
 *  This file written by Ryan C. Gordon. (icculus@icculus.org)
 */

#if HAVE_CONFIG_H
#  include <config.h>
#endif

#ifdef SOUND_SUPPORTS_MPG123

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mpg123.h>

#include "SDL_sound.h"

#define __SDL_SOUND_INTERNAL__
#include "SDL_sound_internal.h"

static int MPG123_init(void);
static void MPG123_quit(void);
static int MPG123_open(Sound_Sample *sample, const char *ext);
static void MPG123_close(Sound_Sample *sample);
static Uint32 MPG123_read(Sound_Sample *sample);
static int MPG123_rewind(Sound_Sample *sample);
static int MPG123_seek(Sound_Sample *sample, Uint32 ms);

/* !!! FIXME: MPEG and MPG extensions? */
static const char *extensions_mpg123[] = { "MP3", NULL };
const Sound_DecoderFunctions __Sound_DecoderFunctions_MPG123 =
{
    {
        extensions_mpg123,
        "MP3 decoding via libmpg123",
        "Ryan C. Gordon <icculus@icculus.org>",
        "http://www.icculus.org/SDL_sound/"
    },

    MPG123_init,       /*   init() method */
    MPG123_quit,       /*   quit() method */
    MPG123_open,       /*   open() method */
    MPG123_close,      /*  close() method */
    MPG123_read,       /*   read() method */
    MPG123_rewind,     /* rewind() method */
    MPG123_seek        /*   seek() method */
};


static int mpg123_inited = 0;

static int MPG123_init(void)
{
    assert(mpg123_inited == 0);
    mpg123_inited = (mpg123_init() == MPG123_OK);
    return mpg123_inited;
} /* MPG123_init */


static void MPG123_quit(void)
{
    mpg123_inited = 0;
    mpg123_exit();
} /* MPG123_quit */


/* bridge rwops reading to libmpg123 hooks. */
static ssize_t rwread(void *p, void *buf, size_t len)
{
    return (ssize_t) SDL_RWread((SDL_RWops*)p, buf, 1, len);
} /* rwread */


/* bridge rwops seeking to libmpg123 hooks. */
static off_t rwseek(void *p, off_t pos, int whence)
{
    return (off_t) SDL_RWseek((SDL_RWops*)p, pos, whence);
} /* rwseek */


static const char *set_error(mpg123_handle *mp, const int err)
{
    char buffer[128];
    const char *str;

    if ((err == MPG123_ERR) && (mp != NULL))
        str = mpg123_strerror(mp);
    else
        str = mpg123_plain_strerror(err);

    memcpy(buffer,"MPG123: ",8);
    strncpy(buffer+8, str, 120);
    buffer[127] = '\0';
    __Sound_SetError(buffer);

    return(NULL);  /* this is for BAIL_MACRO to not try to reset the string. */
} /* set_error */


/* Make sure we are only given decoded data in a format we can handle. */
static int set_formats(mpg123_handle *mp)
{
    int rc = 0;
    const long *rates = NULL;
    size_t ratecount = 0;
    const int channels = MPG123_STEREO | MPG123_MONO;
    const int encodings = /* !!! FIXME: SDL 1.3 can do sint32 and float32.
                          MPG123_ENC_SIGNED_32 | MPG123_ENC_FLOAT_32 | */
                          MPG123_ENC_SIGNED_8 | MPG123_ENC_UNSIGNED_8 |
                          MPG123_ENC_SIGNED_16 | MPG123_ENC_UNSIGNED_16;

    mpg123_rates(&rates, &ratecount);

    rc = mpg123_format_none(mp);
    while ((ratecount--) && (rc == MPG123_OK))
        rc = mpg123_format(mp, *(rates++), channels, encodings);

    return(rc);
} /* set_formats */


static int MPG123_open(Sound_Sample *sample, const char *ext)
{
    Sound_SampleInternal *internal = (Sound_SampleInternal *) sample->opaque;
    mpg123_handle *mp = NULL;
    long rate = 0;
    int channels = 0;
    int fmt = 0;
    int rc = 0;
    int seekable = 0;

    if ((mp = mpg123_new(NULL, &rc)) == NULL)
        goto mpg123_open_failed;
    else if ((rc = set_formats(mp)) != MPG123_OK)
        goto mpg123_open_failed;
    else if ((rc = mpg123_replace_reader_handle(mp, rwread, rwseek, NULL)) != MPG123_OK)
        goto mpg123_open_failed;
    else if ((rc = mpg123_open_handle(mp, internal->rw)) != MPG123_OK)
        goto mpg123_open_failed;
    else if ((rc = mpg123_scan(mp)) != MPG123_OK)
        goto mpg123_open_failed;  /* !!! FIXME: this may be wrong. */
    else if ((rc = mpg123_getformat(mp, &rate, &channels, &fmt)) != MPG123_OK)
        goto mpg123_open_failed;

    if (mpg123_seek(mp, 0, SEEK_END) >= 0)  /* can seek? */
    {
        if ((rc = (int) mpg123_seek(mp, 0, SEEK_SET)) < 0)
            goto mpg123_open_failed;
        seekable = 1;
    } /* if */

    internal->decoder_private = mp;
    sample->actual.rate = rate;
    sample->actual.channels = channels;

    rc = MPG123_BAD_OUTFORMAT;  /* in case this fails... */
    if (fmt == MPG123_ENC_SIGNED_8)
        sample->actual.format = AUDIO_S8;
    else if (fmt == MPG123_ENC_UNSIGNED_8)
        sample->actual.format = AUDIO_U8;
    else if (fmt == MPG123_ENC_SIGNED_16)
        sample->actual.format = AUDIO_S16SYS;
    else if (fmt == MPG123_ENC_UNSIGNED_16)
         sample->actual.format = AUDIO_U16SYS;
    /* !!! FIXME: SDL 1.3 can do sint32 and float32 ...
    else if (fmt == MPG123_ENC_SIGNED_32)
        sample->actual.format = AUDIO_S32SYS;
    else if (fmt == MPG123_ENC_FLOAT_32)
        sample->actual.format = AUDIO_F32SYS;
    */
    else
        goto mpg123_open_failed;

    SNDDBG(("MPG123: Accepting data stream.\n"));

    sample->flags = SOUND_SAMPLEFLAG_NONE;
    if (seekable)
    {
        sample->flags |= SOUND_SAMPLEFLAG_CANSEEK;
    } /* if */

    return(1); /* we'll handle this data. */

mpg123_open_failed:
    set_error(mp, rc);
    mpg123_delete(mp);  /* NULL is safe. */
    return(0);
} /* MPG123_open */


static void MPG123_close(Sound_Sample *sample)
{
    Sound_SampleInternal *internal = (Sound_SampleInternal *) sample->opaque;
    mpg123_handle *mp = ((mpg123_handle *) internal->decoder_private);

    mpg123_close(mp);  /* don't need this at the moment, but it's safe. */
    mpg123_delete(mp);
} /* MPG123_close */


static Uint32 MPG123_read(Sound_Sample *sample)
{
    Sound_SampleInternal *internal = (Sound_SampleInternal *) sample->opaque;
    mpg123_handle *mp = ((mpg123_handle *) internal->decoder_private);
    size_t bw = 0;
    const int rc = mpg123_read(mp, (unsigned char *) internal->buffer,
                               internal->buffer_size, &bw);
    if (rc == MPG123_DONE)
        sample->flags |= SOUND_SAMPLEFLAG_EOF;
    else if (rc != MPG123_OK)
    {
        sample->flags |= SOUND_SAMPLEFLAG_ERROR;
        set_error(mp, rc);
    } /* else if */

    return((Uint32) bw);
} /* MPG123_read */


static int MPG123_rewind(Sound_Sample *sample)
{
    Sound_SampleInternal *internal = (Sound_SampleInternal *) sample->opaque;
    mpg123_handle *mp = ((mpg123_handle *) internal->decoder_private);
    const int rc = (int) mpg123_seek(mp, 0, SEEK_SET);
    BAIL_IF_MACRO(rc < 0, set_error(mp, rc), 0);
    return(1);
} /* MPG123_rewind */


static int MPG123_seek(Sound_Sample *sample, Uint32 ms)
{
    Sound_SampleInternal *internal = (Sound_SampleInternal *) sample->opaque;
    mpg123_handle *mp = ((mpg123_handle *) internal->decoder_private);
    const float frames_per_ms = ((float) sample->actual.rate) / 1000.0f;
    const off_t frame_offset = (off_t) (frames_per_ms * ((float) ms));
    const int rc = (int) mpg123_seek(mp, frame_offset , SEEK_SET);
    BAIL_IF_MACRO(rc < 0, set_error(mp, rc), 0);
    return(1);
} /* MPG123_seek */

#endif /* SOUND_SUPPORTS_MPG123 */

/* end of mpg123.c ... */
