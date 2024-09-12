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
 * FLAC decoder for SDL_sound.
 *
 * This driver handles FLAC audio, that is to say the Free Lossless Audio
 *  Codec. It depends on libFLAC for decoding, which can be grabbed from:
 *  http://flac.sourceforge.net
 *
 * Please see the file COPYING in the source's root directory.
 *
 *  This file written by Torbjörn Andersson. (d91tan@Update.UU.SE)
 */

#if HAVE_CONFIG_H
#  include <config.h>
#endif

#ifdef SOUND_SUPPORTS_FLAC

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "SDL_sound.h"

#define __SDL_SOUND_INTERNAL__
#include "SDL_sound_internal.h"

#include <FLAC/export.h>

/* FLAC 1.1.3 has FLAC_API_VERSION_CURRENT == 8 */
#if !defined(FLAC_API_VERSION_CURRENT) || FLAC_API_VERSION_CURRENT < 8
#define LEGACY_FLAC
#else
#undef LEGACY_FLAC
#endif

#ifdef LEGACY_FLAC
#include <FLAC/seekable_stream_decoder.h>

#define D_END_OF_STREAM               FLAC__SEEKABLE_STREAM_DECODER_END_OF_STREAM

#define d_new()                       FLAC__seekable_stream_decoder_new()
#define d_init(x)                     FLAC__seekable_stream_decoder_init(x)
#define d_process_metadata(x)         FLAC__seekable_stream_decoder_process_until_end_of_metadata(x)
#define d_process_one_frame(x)        FLAC__seekable_stream_decoder_process_single(x)
#define d_get_state(x)                FLAC__seekable_stream_decoder_get_state(x)
#define d_finish(x)                   FLAC__seekable_stream_decoder_finish(x)
#define d_delete(x)                   FLAC__seekable_stream_decoder_delete(x)
#define d_set_read_callback(x, y)     FLAC__seekable_stream_decoder_set_read_callback(x, y)
#define d_set_write_callback(x, y)    FLAC__seekable_stream_decoder_set_write_callback(x, y)
#define d_set_metadata_callback(x, y) FLAC__seekable_stream_decoder_set_metadata_callback(x, y)
#define d_set_error_callback(x, y)    FLAC__seekable_stream_decoder_set_error_callback(x, y)
#define d_set_client_data(x, y)       FLAC__seekable_stream_decoder_set_client_data(x, y)

typedef FLAC__SeekableStreamDecoder           decoder_t;
typedef FLAC__SeekableStreamDecoderReadStatus d_read_status_t;

#define D_SEEK_STATUS_OK              FLAC__SEEKABLE_STREAM_DECODER_SEEK_STATUS_OK
#define D_SEEK_STATUS_ERROR           FLAC__SEEKABLE_STREAM_DECODER_SEEK_STATUS_ERROR
#define D_TELL_STATUS_OK              FLAC__SEEKABLE_STREAM_DECODER_TELL_STATUS_OK
#define D_TELL_STATUS_ERROR           FLAC__SEEKABLE_STREAM_DECODER_TELL_STATUS_ERROR
#define D_LENGTH_STATUS_OK            FLAC__SEEKABLE_STREAM_DECODER_LENGTH_STATUS_OK
#define D_LENGTH_STATUS_ERROR         FLAC__SEEKABLE_STREAM_DECODER_LENGTH_STATUS_ERROR

#define d_set_seek_callback(x, y)     FLAC__seekable_stream_decoder_set_seek_callback(x, y)
#define d_set_tell_callback(x, y)     FLAC__seekable_stream_decoder_set_tell_callback(x, y)
#define d_set_length_callback(x, y)   FLAC__seekable_stream_decoder_set_length_callback(x, y)
#define d_set_eof_callback(x, y)      FLAC__seekable_stream_decoder_set_eof_callback(x, y)
#define d_seek_absolute(x, y)         FLAC__seekable_stream_decoder_seek_absolute(x, y)

typedef FLAC__SeekableStreamDecoderSeekStatus   d_seek_status_t;
typedef FLAC__SeekableStreamDecoderTellStatus   d_tell_status_t;
typedef FLAC__SeekableStreamDecoderLengthStatus d_length_status_t;
#else
#include <FLAC/stream_decoder.h>

#define D_END_OF_STREAM               FLAC__STREAM_DECODER_END_OF_STREAM

#define d_new()                       FLAC__stream_decoder_new()
#define d_process_metadata(x)         FLAC__stream_decoder_process_until_end_of_metadata(x)
#define d_process_one_frame(x)        FLAC__stream_decoder_process_single(x)
#define d_get_state(x)                FLAC__stream_decoder_get_state(x)
#define d_finish(x)                   FLAC__stream_decoder_finish(x)
#define d_delete(x)                   FLAC__stream_decoder_delete(x)

typedef FLAC__StreamDecoder           decoder_t;
typedef FLAC__StreamDecoderReadStatus d_read_status_t;

#define D_SEEK_STATUS_OK              FLAC__STREAM_DECODER_SEEK_STATUS_OK
#define D_SEEK_STATUS_ERROR           FLAC__STREAM_DECODER_SEEK_STATUS_ERROR
#define D_TELL_STATUS_OK              FLAC__STREAM_DECODER_TELL_STATUS_OK
#define D_TELL_STATUS_ERROR           FLAC__STREAM_DECODER_TELL_STATUS_ERROR
#define D_LENGTH_STATUS_OK            FLAC__STREAM_DECODER_LENGTH_STATUS_OK
#define D_LENGTH_STATUS_ERROR         FLAC__STREAM_DECODER_LENGTH_STATUS_ERROR

#define d_seek_absolute(x, y)         FLAC__stream_decoder_seek_absolute(x, y)

typedef FLAC__StreamDecoderSeekStatus   d_seek_status_t;
typedef FLAC__StreamDecoderTellStatus   d_tell_status_t;
typedef FLAC__StreamDecoderLengthStatus d_length_status_t;
#endif

#define D_WRITE_CONTINUE     FLAC__STREAM_DECODER_WRITE_STATUS_CONTINUE
#define D_READ_END_OF_STREAM FLAC__STREAM_DECODER_READ_STATUS_END_OF_STREAM
#define D_READ_ABORT         FLAC__STREAM_DECODER_READ_STATUS_ABORT
#define D_READ_CONTINUE      FLAC__STREAM_DECODER_READ_STATUS_CONTINUE

#define d_error_status_string FLAC__StreamDecoderErrorStatusString

typedef FLAC__StreamDecoderErrorStatus d_error_status_t;
typedef FLAC__StreamMetadata           d_metadata_t;
typedef FLAC__StreamDecoderWriteStatus d_write_status_t;


static int FLAC_init(void);
static void FLAC_quit(void);
static int FLAC_open(Sound_Sample *sample, const char *ext);
static void FLAC_close(Sound_Sample *sample);
static Uint32 FLAC_read(Sound_Sample *sample);
static int FLAC_rewind(Sound_Sample *sample);
static int FLAC_seek(Sound_Sample *sample, Uint32 ms);

static const char *extensions_flac[] = { "FLAC", "FLA", NULL };

const Sound_DecoderFunctions __Sound_DecoderFunctions_FLAC =
{
    {
        extensions_flac,
        "Free Lossless Audio Codec",
        "Torbjörn Andersson <d91tan@Update.UU.SE>",
        "http://flac.sourceforge.net/"
    },

    FLAC_init,       /*   init() method */
    FLAC_quit,       /*   quit() method */
    FLAC_open,       /*   open() method */
    FLAC_close,      /*  close() method */
    FLAC_read,       /*   read() method */
    FLAC_rewind,     /* rewind() method */
    FLAC_seek        /*   seek() method */
};

/* This is what we store in our internal->decoder_private field. */
typedef struct
{
    decoder_t *decoder;
    SDL_RWops *rw;
    Sound_Sample *sample;
    Uint32 frame_size;
    Uint8 is_flac;
    Uint32 stream_length;
} flac_t;


static void free_flac(flac_t *f)
{
    d_finish(f->decoder);
    d_delete(f->decoder);
    free(f);
} /* free_flac */


#ifdef LEGACY_FLAC
static d_read_status_t read_callback(
    const decoder_t *decoder, FLAC__byte buffer[],
    unsigned int *bytes, void *client_data)
#else
static d_read_status_t read_callback(
    const decoder_t *decoder, FLAC__byte buffer[],
    size_t *bytes, void *client_data)
#endif
{
    flac_t *f = (flac_t *) client_data;
    Uint32 retval;

    retval = SDL_RWread(f->rw, (Uint8 *) buffer, 1, *bytes);

    if (retval == 0)
    {
        *bytes = 0;
        f->sample->flags |= SOUND_SAMPLEFLAG_EOF;
        return(D_READ_END_OF_STREAM);
    } /* if */

    if (retval == -1)
    {
        *bytes = 0;
        f->sample->flags |= SOUND_SAMPLEFLAG_ERROR;
        return(D_READ_ABORT);
    } /* if */

    if (retval < *bytes)
    {
        *bytes = retval;
        f->sample->flags |= SOUND_SAMPLEFLAG_EAGAIN;
    } /* if */

    return(D_READ_CONTINUE);
} /* read_callback */


static d_write_status_t write_callback(
    const decoder_t *decoder, const FLAC__Frame *frame,
    const FLAC__int32 * const buffer[],
    void *client_data)
{
    flac_t *f = (flac_t *) client_data;
    Uint32 i, j;
    Uint32 sample;
    Uint8 *dst;

    f->frame_size = frame->header.channels * frame->header.blocksize
        * frame->header.bits_per_sample / 8;

    if (f->frame_size > f->sample->buffer_size)
        Sound_SetBufferSize(f->sample, f->frame_size);

    dst = f->sample->buffer;

    /* If the sample is neither exactly 8-bit nor 16-bit, it will have to
     * be converted. Unfortunately the buffer is read-only, so we either
     * have to check for each sample, or make a copy of the buffer. I'm
     * not sure which way is best, so I've arbitrarily picked the former.
     */
    if (f->sample->actual.format == AUDIO_S8)
    {
        for (i = 0; i < frame->header.blocksize; i++)
            for (j = 0; j < frame->header.channels; j++)
            {
                sample = buffer[j][i];
                if (frame->header.bits_per_sample < 8)
                    sample <<= (8 - frame->header.bits_per_sample);
                *dst++ = sample & 0x00ff;
            } /* for */
    } /* if */
    else
    {
        for (i = 0; i < frame->header.blocksize; i++)
            for (j = 0; j < frame->header.channels; j++)
            {
                sample = buffer[j][i];
                if (frame->header.bits_per_sample < 16)
                    sample <<= (16 - frame->header.bits_per_sample);
                else if (frame->header.bits_per_sample > 16)
                    sample >>= (frame->header.bits_per_sample - 16);
#if SDL_BYTEORDER == SDL_BIG_ENDIAN
                *dst++ = (sample & 0xff00) >> 8;
                *dst++ = sample & 0x00ff;
#else
                *dst++ = sample & 0x00ff;
                *dst++ = (sample & 0xff00) >> 8;
#endif
            } /* for */
    } /* else */

    return(D_WRITE_CONTINUE);
} /* write_callback */


static void metadata_callback(
    const decoder_t *decoder,
    const d_metadata_t *metadata,
    void *client_data)
{
    flac_t *f = (flac_t *) client_data;

    SNDDBG(("FLAC: Metadata callback.\n"));

    /* There are several kinds of metadata, but STREAMINFO is the only
     * one that always has to be there.
     */
    if (metadata->type == FLAC__METADATA_TYPE_STREAMINFO)
    {
        SNDDBG(("FLAC: Metadata is streaminfo.\n"));

        f->is_flac = 1;
        f->sample->actual.channels = metadata->data.stream_info.channels;
        f->sample->actual.rate = metadata->data.stream_info.sample_rate;

        if (metadata->data.stream_info.bits_per_sample > 8)
            f->sample->actual.format = AUDIO_S16SYS;
        else
            f->sample->actual.format = AUDIO_S8;
    } /* if */
} /* metadata_callback */


static void error_callback(
    const decoder_t *decoder,
    d_error_status_t status,
    void *client_data)
{
    flac_t *f = (flac_t *) client_data;

    __Sound_SetError(d_error_status_string[status]);
    f->sample->flags |= SOUND_SAMPLEFLAG_ERROR;
} /* error_callback */


static d_seek_status_t seek_callback(
    const decoder_t *decoder,
    FLAC__uint64 absolute_byte_offset,
    void *client_data)
{
    flac_t *f = (flac_t *) client_data;

    if (SDL_RWseek(f->rw, absolute_byte_offset, RW_SEEK_SET) >= 0)
    {
        return(D_SEEK_STATUS_OK);
    } /* if */

    return(D_SEEK_STATUS_ERROR);
} /* seek_callback*/


static d_tell_status_t tell_callback(
    const decoder_t *decoder,
    FLAC__uint64 *absolute_byte_offset,
    void *client_data)
{
    flac_t *f = (flac_t *) client_data;
    int pos;

    pos = SDL_RWtell(f->rw);

    if (pos < 0)
    {
        return(D_TELL_STATUS_ERROR);
    } /* if */

    *absolute_byte_offset = pos;
    return(D_TELL_STATUS_OK);
} /* tell_callback */


static d_length_status_t length_callback(
    const decoder_t *decoder,
    FLAC__uint64 *stream_length,
    void *client_data)
{
    flac_t *f = (flac_t *) client_data;

    if (f->sample->flags & SOUND_SAMPLEFLAG_CANSEEK)
    {
        *stream_length = f->stream_length;
        return(D_LENGTH_STATUS_OK);
    } /* if */

    return(D_LENGTH_STATUS_ERROR);
} /* length_callback */


static FLAC__bool eof_callback(
    const decoder_t *decoder,
    void *client_data)
{
    flac_t *f = (flac_t *) client_data;
    int pos;

    /* Maybe we could check for SOUND_SAMPLEFLAG_EOF here instead? */
    pos = SDL_RWtell(f->rw);
    
    if (pos >= 0 && pos >= f->stream_length)
    {
        return(true);
    } /* if */

    return(false);
} /* eof_callback */


static int FLAC_init(void)
{
    return(1);  /* always succeeds. */
} /* FLAC_init */


static void FLAC_quit(void)
{
    /* it's a no-op. */
} /* FLAC_quit */


#define FLAC_MAGIC 0x43614C66  /* "fLaC" in ASCII. */

static int FLAC_open(Sound_Sample *sample, const char *ext)
{
    Sound_SampleInternal *internal = (Sound_SampleInternal *) sample->opaque;
    SDL_RWops *rw = internal->rw;
    decoder_t *decoder;
    flac_t *f;
    int i;
    int has_extension = 0;
    Uint32 pos;

    /*
     * If the extension is "flac", we'll believe that this is really meant
     *  to be a FLAC stream, and will try to grok it from existing metadata.
     *  metadata searching can be a very expensive operation, however, so
     *  unless the user swears that it is a FLAC stream through the extension,
     *  we decide what to do based on the existance of a 32-bit magic number.
     */
    for (i = 0; extensions_flac[i] != NULL; i++)
    {
        if (__Sound_strcasecmp(ext, extensions_flac[i]) == 0)
        {
            has_extension = 1;
            break;
        } /* if */
    } /* for */

    if (!has_extension)
    {
        int rc;
        Uint32 flac_magic = SDL_ReadLE32(rw);
        BAIL_IF_MACRO(flac_magic != FLAC_MAGIC, "FLAC: Not a FLAC stream.", 0);

        /* move back over magic number for metadata scan... */
        rc = SDL_RWseek(internal->rw, -((long) sizeof(flac_magic)), RW_SEEK_CUR);
        BAIL_IF_MACRO(rc < 0, ERR_IO_ERROR, 0);
    } /* if */

    f = (flac_t *) malloc(sizeof (flac_t));
    BAIL_IF_MACRO(f == NULL, ERR_OUT_OF_MEMORY, 0);
    
    decoder = d_new();
    if (decoder == NULL)
    {
        free(f);
        BAIL_MACRO(ERR_OUT_OF_MEMORY, 0);
    } /* if */

#ifdef LEGACY_FLAC
    d_set_read_callback(decoder, read_callback);
    d_set_write_callback(decoder, write_callback);
    d_set_metadata_callback(decoder, metadata_callback);
    d_set_error_callback(decoder, error_callback);
    d_set_seek_callback(decoder, seek_callback);
    d_set_tell_callback(decoder, tell_callback);
    d_set_length_callback(decoder, length_callback);
    d_set_eof_callback(decoder, eof_callback);

    d_set_client_data(decoder, f);
#endif

    f->rw = internal->rw;
    f->sample = sample;
    f->decoder = decoder;
    f->sample->actual.format = 0;
    f->is_flac = 0 /* !!! FIXME: should be "has_extension", not "0". */;

    internal->decoder_private = f;
    /* really should check the init return value here: */
#ifdef LEGACY_FLAC
    d_init(decoder);
#else
    FLAC__stream_decoder_init_stream(decoder, read_callback, seek_callback,
                                     tell_callback, length_callback,
                                     eof_callback, write_callback,
                                     metadata_callback, error_callback, f);
#endif

    sample->flags = SOUND_SAMPLEFLAG_NONE;

    pos = SDL_RWtell(f->rw);
    if (SDL_RWseek(f->rw, 0, RW_SEEK_END) > 0)
    {
        f->stream_length = SDL_RWtell(f->rw);
        if (SDL_RWseek(f->rw, pos, RW_SEEK_SET) == -1)
        {
            free_flac(f);
            BAIL_MACRO(ERR_IO_ERROR, 0);
        } /* if */
        sample->flags = SOUND_SAMPLEFLAG_CANSEEK;
    } /* if */

    /*
     * If we are not sure this is a FLAC stream, check for the STREAMINFO
     * metadata block. If not, we'd have to peek at the first audio frame
     * and get the sound format from there, but that is not yet
     * implemented.
     */
    if (!f->is_flac)
    {
        d_process_metadata(decoder);

        /* Still not FLAC? Give up. */
        if (!f->is_flac)
        {
            free_flac(f);
            BAIL_MACRO("FLAC: No metadata found. Not a FLAC stream?", 0);
        } /* if */
    } /* if */

    SNDDBG(("FLAC: Accepting data stream.\n"));
    return(1);
} /* FLAC_open */


static void FLAC_close(Sound_Sample *sample)
{
    Sound_SampleInternal *internal = (Sound_SampleInternal *) sample->opaque;
    flac_t *f = (flac_t *) internal->decoder_private;

    free_flac(f);
} /* FLAC_close */


static Uint32 FLAC_read(Sound_Sample *sample)
{
    Sound_SampleInternal *internal = (Sound_SampleInternal *) sample->opaque;
    flac_t *f = (flac_t *) internal->decoder_private;

    if (!d_process_one_frame(f->decoder))
    {
        sample->flags |= SOUND_SAMPLEFLAG_ERROR;
        BAIL_MACRO("FLAC: Couldn't decode frame.", 0);
    } /* if */

    if (d_get_state(f->decoder) == D_END_OF_STREAM)
    {
        sample->flags |= SOUND_SAMPLEFLAG_EOF;
        return(0);
    } /* if */

        /* An error may have been signalled through the error callback. */    
    if (sample->flags & SOUND_SAMPLEFLAG_ERROR)
        return(0);

    return(f->frame_size);
} /* FLAC_read */


static int FLAC_rewind(Sound_Sample *sample)
{
    return FLAC_seek(sample, 0);
} /* FLAC_rewind */


static int FLAC_seek(Sound_Sample *sample, Uint32 ms)
{
    Sound_SampleInternal *internal = (Sound_SampleInternal *) sample->opaque;
    flac_t *f = (flac_t *) internal->decoder_private;

    d_seek_absolute(f->decoder, (ms * sample->actual.rate) / 1000);
    return(1);
} /* FLAC_seek */

#endif /* SOUND_SUPPORTS_FLAC */

/* end of flac.c ... */
