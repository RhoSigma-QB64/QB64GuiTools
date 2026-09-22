'  mp3dec.bi (also needs mp3dec.h and minimp3.h)
'  - include this file at the top of your QB64(PE) program code
'  - adjust the path in the DECLARE LIBRARY line according to your needs
'
'  minimp3 wrapper code for QB64(PE)
'  - tested and works with all QB64 versions since v0.927 (when _SNDRAW was implemented)
'    up to the modern most recent versions by the Phoenix Edition (QB64-PE)
'
'  To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide.
'  This software is distributed without any warranty.
'  See <http://creativecommons.org/publicdomain/zero/1.0/>.

DECLARE LIBRARY "QB64GuiTools\src_INetRadio\inline\mp3dec" 'path to mp3dec.h/minimp3.h
    FUNCTION mp3_decoder_init% ()
    'call first, returns -1 on success or 0 if out of memory (always safe, it's
    'not overwriting values if already initialized)
    FUNCTION mp3_decoder_loop% (mp3dat$, BYVAL mp3len&, BYVAL volume!, BYVAL decinfo%&)
    'call in loop, decodes a frame and sends samples to _SNDRAW unless volume! is negative
    '              if return is -1, then remove decinfo.fit.frame_bytes from mp3dat$
    '              before next call i.e. mp3dat$ = MID$(mp3dat$, decinfo.fit.frame_bytes + 1)
    '              if return is 0, then track ends or has error, mp3_decoder_info TYPE
    '              is invalid in this case, leave loop and call mp3_decoder_free()
    '(always safe, returns 0 if decoder is not properly initialized)
    SUB mp3_decoder_free ()
    'call finally, frees all resources (always safe, will only free if initialized)
END DECLARE

TYPE mp3dec_frame_info_t
    frame_bytes AS LONG 'consumed input bytes for this frame
    frame_offset AS LONG 'frame header offset (on resync, mostly 0)
    channels AS LONG 'used channels in this frame (1 = mono, 2 = stereo)
    hz AS LONG 'original sample frequency of this frame
    layer AS LONG 'the used MPEG layer in this frame (always 3 here)
    bitrate_kbps AS LONG 'the used bitrate in this frame
END TYPE
TYPE mp3_decoder_info
    fit AS mp3dec_frame_info_t
    pcm_out AS _OFFSET 'pointer to sample buffer (interleaved L/R samples in stereo)
    pcm_frames AS LONG 'num sample frames (frames * channels = num samples)
END TYPE
'The pcm_out buffer is usually provided for the purpose to use the decoded
'samples for things like drawing an oscilloscope, writing them into a file
'or do any other technical analysis with it.
'Unless you've specified a negative volume! to mp3_decoder_loop(), you don't
'need to send the samples to _SNDRAW, for any given volume! >= 0.0 that's
'already done internally in mp3_decoder_loop().
'-----
'Guaranteed pcm_out buffer size,
'it equals MINIMP3_MAX_SAMPLES_PER_FRAME * 2 sample values of type SINGLE.
CONST PCM_OUT_SIZE = 18432
'You can use it to make the buffer acessible for _MEMxxx commands as shown:
'   DIM pcm AS _MEM
'   pcm = _MEM(decinfo.pcm_out, PCM_OUT_SIZE)
'   'do stuff
'   _MEMFREE pcm
'-----
'Between mp3_decoder_init(), if successful, and mp3_decoder_free() the pcm_out
'buffer is always guaranteed to be a valid memory region of PCM_OUT_SIZE bytes.
'-----
'However, the address may change with every mp3_decoder_loop() call and only if
'pcm_frames is greater than zero after each call, the buffer actually contains
'new sample data.
'-----
'Note that pcm_frames may be zero even when mp3_decoder_loop() returns -1, if
'the decoder skipped invalid data or the track end is reached. That said, you
'must always use the pcm_out/pcm_frames values of the current loop iteration
'for any operations you wanna do with the sample data.
'-----
'If the frame's original sample frequency differs from the actual _SNDRATE,
'then pcm_out and pcm_frames contain the already resampled values matching
'the _SNDRATE of your system. However, to keep the implementation reasonable
'this is only true for _SNDRATEs up to 88200 Hz, that's twice the usual
'44100 Hz, and should be sufficient for most user systems.

