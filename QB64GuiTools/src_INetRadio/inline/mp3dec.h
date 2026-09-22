/*
    mp3dec.h (also needs minimp3.h in same location)

    minimp3 wrapper code for QB64(PE)
    - tested and works with all QB64 versions since v0.927 (when _SNDRAW was implemented)
      up to the modern most recent versions by the Phoenix Edition (QB64-PE)

    To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this software to the public domain worldwide.
    This software is distributed without any warranty.
    See <http://creativecommons.org/publicdomain/zero/1.0/>.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MINIMP3_IMPLEMENTATION
#define MINIMP3_ONLY_MP3
#define MINIMP3_FLOAT_OUTPUT
#include "minimp3.h"

struct mp3_decoder_info {
    mp3dec_frame_info_t fit;
    ptrszint pcm_out;
    int32_t pcm_frames;
};

mp3dec_t *inp_decoder = NULL;
mp3d_sample_t *out_decoded = NULL;
mp3d_sample_t *out_resampled = NULL;

void mp3_decoder_free() {
    if (out_resampled) {free(out_resampled); out_resampled = NULL;}
    if (out_decoded) {free(out_decoded); out_decoded = NULL;}
    if (inp_decoder) {free(inp_decoder); inp_decoder = NULL;}
}

int16_t mp3_decoder_init() {
    if (!inp_decoder) inp_decoder = (mp3dec_t*) malloc(sizeof(mp3dec_t));
    if (!out_decoded) out_decoded = (mp3d_sample_t*) malloc(sizeof(mp3d_sample_t) * MINIMP3_MAX_SAMPLES_PER_FRAME * 2);
    if (!out_resampled) out_resampled = (mp3d_sample_t*) malloc(sizeof(mp3d_sample_t) * MINIMP3_MAX_SAMPLES_PER_FRAME * 2);
    if (inp_decoder) mp3dec_init(inp_decoder);
    if (!inp_decoder || !out_decoded || !out_resampled) {mp3_decoder_free(); return 0;}
    return -1;
}

int mp3_decoder_resample(uint32_t input_frames, uint32_t num_channels, double current_freq, double target_freq)
{
    if (target_freq <= 0.0 || target_freq > 88200.0) return 0;

    double resample_ratio = target_freq / current_freq;
    uint32_t new_frames = (uint32_t) (input_frames * resample_ratio);

    for (uint32_t frame_idx = 0; frame_idx < new_frames; frame_idx++) {
        double src_frame_pos = frame_idx / resample_ratio;
        uint32_t frame_low = (uint32_t) src_frame_pos;
        uint32_t frame_high = frame_low + 1;

        mp3d_sample_t weight = (mp3d_sample_t) (src_frame_pos - frame_low);

        if (frame_high >= input_frames) frame_high = input_frames - 1;
        if (frame_low >= input_frames) frame_low = input_frames - 1;

        for (uint32_t ch = 0; ch < num_channels; ch++) {
            uint32_t idx_low = (frame_low * num_channels) + ch;
            uint32_t idx_high = (frame_high * num_channels) + ch;
            uint32_t idx_out = (frame_idx * num_channels) + ch;

            out_resampled[idx_out] = (1.0f - weight) * out_decoded[idx_low] +
                                     weight * out_decoded[idx_high];
        }
    }
    return new_frames;
}

int func__sndrate();
#ifdef _SDL_H // old SDL versions (don't have the optional handle argument)
void sub__sndraw(double left, double right, int32 passed);
void mp3_decoder_sndraw_mono(double left) {sub__sndraw(left, 0, 0);}
void mp3_decoder_sndraw_stereo(double left, double right) {sub__sndraw(left, right, 1);}
#else
void sub__sndraw(float left, float right, int32_t handle, int32_t passed);
void mp3_decoder_sndraw_mono(double left) {sub__sndraw(left, 0, 0, 0);}
void mp3_decoder_sndraw_stereo(double left, double right) {sub__sndraw(left, right, 0, 1);}
#endif

int16_t mp3_decoder_loop(const char *mp3dat, uint32_t mp3len, float volume, ptrszint decinfo) {
    int smp, rsmp; mp3d_sample_t *pcm;
    mp3_decoder_info *di = (mp3_decoder_info*) decinfo;

    if (!inp_decoder || !out_decoded || !out_resampled) {mp3_decoder_free(); return 0;}

    smp = mp3dec_decode_frame(inp_decoder, (const uint8_t*) mp3dat, (int) mp3len, out_decoded, (mp3dec_frame_info_t*) decinfo);
    if (smp > 0) {
        pcm = out_decoded;
        if (di->fit.hz != func__sndrate()) {
            rsmp = mp3_decoder_resample(smp, di->fit.channels, di->fit.hz, func__sndrate());
            if (rsmp > 0) {
                smp = rsmp; pcm = out_resampled;
            }
        }
        if (volume >= 0.0) {
            switch (di->fit.channels) {
                case 1: { // mono sound
                    for (int i = 0; i < smp;) {mp3_decoder_sndraw_mono(pcm[i++] * volume);}
                    break;
                }
                case 2: { // stereo sound
                    for (int i = 0; i < smp * 2;) {mp3_decoder_sndraw_stereo(pcm[i] * volume, pcm[i + 1] * volume); i += 2;}
                    break;
                }
            }
        }
        di->pcm_out = (ptrszint) pcm;
        di->pcm_frames = smp;
    } else {
        di->pcm_out = (ptrszint) out_decoded;
        di->pcm_frames = 0;
    }
    return (di->fit.frame_bytes > 0) ? -1 : 0;
}

