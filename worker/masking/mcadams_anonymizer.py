"""McAdams coefficient transformation for voice de-identification.

This is the VoicePrivacy Challenge B1 baseline: shift the angles of LPC poles
by a power exponent alpha, which moves formants and changes the perceived
vocal-tract shape without altering speech content. Defeats most automated
speaker-identification systems while preserving prosody, timing, and
non-speech audio (laughter, breathing, hesitations).

Pure numpy + scipy. CPU-only. Roughly real-time on a single core.

References
----------
- Patino, Tomashenko, Todisco, et al., "Speaker anonymisation using the
  McAdams coefficient", Interspeech 2021.
"""

from __future__ import annotations

import numpy as np
import scipy.signal as sps
from scipy.io import wavfile
from scipy.linalg import solve_toeplitz


def _read_wav(path: str):
    sr, data = wavfile.read(path)
    if data.ndim > 1:
        data = data.mean(axis=1)
    if data.dtype == np.int16:
        data = data.astype(np.float32) / 32768.0
    elif data.dtype == np.int32:
        data = data.astype(np.float32) / 2147483648.0
    elif data.dtype == np.uint8:
        data = (data.astype(np.float32) - 128.0) / 128.0
    else:
        data = data.astype(np.float32)
    return sr, data


def _write_wav(path: str, sr: int, data: np.ndarray):
    peak = float(np.max(np.abs(data))) if data.size else 0.0
    if peak > 0.99:
        data = data / peak * 0.99
    pcm = (data * 32767.0).clip(-32768, 32767).astype(np.int16)
    wavfile.write(path, sr, pcm)


def _lpc(x: np.ndarray, order: int) -> np.ndarray:
    """Levinson-Durbin LPC via scipy. Returns coefficients [1, a1, ..., a_p]."""
    if len(x) < order + 1:
        return np.concatenate([[1.0], np.zeros(order)])
    r = np.correlate(x, x, mode='full')[len(x) - 1: len(x) + order]
    if r[0] <= 1e-10:
        return np.concatenate([[1.0], np.zeros(order)])
    try:
        a_minus = solve_toeplitz(r[:order], -r[1:order + 1])
    except (np.linalg.LinAlgError, ValueError):
        return np.concatenate([[1.0], np.zeros(order)])
    return np.concatenate([[1.0], a_minus])


def mcadams_anonymize(
    input_wav: str,
    output_wav: str,
    alpha: float = 0.8,
    lpc_order: int = 20,
    frame_size_ms: float = 20.0,
    hop_size_ms: float = 10.0,
) -> None:
    """Anonymise speech in `input_wav` and write result to `output_wav`.

    alpha < 1 compresses formant angles (lower-pitched, "deeper" voice);
    alpha > 1 expands them (higher-pitched, "thinner" voice). Default 0.8
    is the most-used VoicePrivacy setting.
    """
    sr, audio = _read_wav(input_wav)
    if audio.size == 0:
        _write_wav(output_wav, sr, audio)
        return

    frame_len = max(64, int(sr * frame_size_ms / 1000))
    hop_len = max(32, int(sr * hop_size_ms / 1000))
    pre_emph = 0.97

    emphasized = np.concatenate([[audio[0]], audio[1:] - pre_emph * audio[:-1]]).astype(np.float32)
    n = len(emphasized)

    if n < frame_len:
        # Too short to frame meaningfully — pass through silently
        _write_wav(output_wav, sr, audio)
        return

    output = np.zeros(n + frame_len, dtype=np.float32)
    window = np.hanning(frame_len).astype(np.float32)
    n_frames = 1 + (n - frame_len) // hop_len

    for i in range(n_frames):
        start = i * hop_len
        frame = emphasized[start:start + frame_len]
        if np.max(np.abs(frame)) < 1e-6:
            # silent frame — keep zeros, no need to filter
            continue

        windowed = frame * window
        a = _lpc(windowed, lpc_order)
        try:
            poles = np.roots(a)
        except (np.linalg.LinAlgError, ValueError):
            output[start:start + frame_len] += windowed
            continue

        new_poles = np.empty_like(poles)
        for j, p in enumerate(poles):
            mag = np.abs(p)
            ang = np.angle(p)
            # Real-axis poles (ang ≈ 0 or ±π) carry no formant info — leave alone.
            if 0 < ang < np.pi:
                new_ang = ang ** alpha
            elif -np.pi < ang < 0:
                new_ang = -((-ang) ** alpha)
            else:
                new_ang = ang
            new_poles[j] = mag * np.exp(1j * new_ang)

        new_a = np.real(np.poly(new_poles))

        # Drop unstable filters (any pole on/outside the unit circle).
        if np.any(np.abs(np.roots(new_a)) >= 1.0):
            output[start:start + frame_len] += windowed
            continue

        residual = sps.lfilter(a, [1.0], windowed)
        modified = sps.lfilter([1.0], new_a, residual).astype(np.float32)
        output[start:start + frame_len] += modified

    output = output[:len(audio)]
    de_emphasized = sps.lfilter([1.0], [1.0, -pre_emph], output).astype(np.float32)
    _write_wav(output_wav, sr, de_emphasized)
