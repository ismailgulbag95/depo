import os
import wave
import math
import struct

def generate_wav(filepath, duration_sec, sample_rate=44100, num_channels=1, sampwidth=2, sound_type="click"):
    num_samples = int(duration_sec * sample_rate)
    samples = []
    
    for i in range(num_samples):
        t = float(i) / sample_rate
        val = 0.0
        
        if sound_type == "click":
            # Sharp transient click
            envelope = math.exp(-t * 60.0)
            val = math.sin(2.0 * math.pi * 1800.0 * t) * envelope * 0.7
            val += (math.sin(2.0 * math.pi * 3200.0 * t) * envelope * 0.3)
            
        elif sound_type == "pack":
            # Solid mechanical latch / thud
            envelope = math.exp(-t * 35.0)
            freq = 320.0 - (t * 400.0)
            val = (math.sin(2.0 * math.pi * max(60.0, freq) * t) + 0.3 * math.sin(2.0 * math.pi * 840.0 * t)) * envelope
            
        elif sound_type == "gavel":
            # Deep wooden thud with secondary reverb ring
            envelope = math.exp(-t * 14.0)
            val = (math.sin(2.0 * math.pi * 110.0 * t) * 0.8 + 
                   math.sin(2.0 * math.pi * 220.0 * t) * 0.4 +
                   math.sin(2.0 * math.pi * 55.0 * t) * 0.5) * envelope
            # Add initial transient snap
            if t < 0.03:
                val += math.sin(2.0 * math.pi * 900.0 * t) * math.exp(-t * 120.0) * 0.6
                
        elif sound_type == "coin":
            # Dual crisp high-pitched chime (E6 + B6)
            envelope = math.exp(-t * 8.0)
            val = (math.sin(2.0 * math.pi * 1318.5 * t) * 0.5 + 
                   math.sin(2.0 * math.pi * 1975.5 * t) * 0.5) * envelope
            if t > 0.08:
                t2 = t - 0.08
                env2 = math.exp(-t2 * 9.0)
                val += (math.sin(2.0 * math.pi * 2637.0 * t2) * 0.6) * env2
                
        elif sound_type == "crush":
            # Heavy metal crunch and low frequency rumble
            envelope = math.exp(-t * 5.0)
            noise = (math.sin(17.3 * i) * 0.3)
            rumble = math.sin(2.0 * math.pi * (65.0 - t * 20.0) * t)
            crunch = math.sin(2.0 * math.pi * 320.0 * t * (1.0 + noise)) * 0.4
            val = (rumble * 0.6 + crunch * 0.5 + noise * 0.2) * envelope
            
        elif sound_type == "hit":
            # Sharp blade slash followed by impact thud
            envelope = math.exp(-t * 22.0)
            slash = math.sin(2.0 * math.pi * (1200.0 - t * 3000.0) * t) * 0.5
            thud = math.sin(2.0 * math.pi * 90.0 * t) * 0.6
            val = (slash + thud) * envelope
            
        elif sound_type == "victory":
            # 3-note ascending arpeggio fanfare (C5 -> E5 -> G5)
            if t < 0.12:
                freq = 523.25 # C5
                env = math.exp(-t * 12.0)
            elif t < 0.24:
                freq = 659.25 # E5
                env = math.exp(-(t - 0.12) * 12.0)
            else:
                freq = 783.99 # G5
                env = math.exp(-(t - 0.24) * 6.0)
            val = (math.sin(2.0 * math.pi * freq * t) + 0.25 * math.sin(4.0 * math.pi * freq * t)) * env
            
        elif sound_type == "warning":
            # Dual pulse high-pitch alarm beep
            pulse = math.sin(2.0 * math.pi * 6.0 * t)
            if pulse > 0.0:
                val = math.sin(2.0 * math.pi * 880.0 * t) * 0.7
            else:
                val = 0.0
                
        # Clamp to -1.0 .. 1.0
        val = max(-1.0, min(1.0, val))
        int_sample = int(val * 32767.0 * 0.85)
        samples.append(int_sample)
        
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    with wave.open(filepath, 'w') as wav_file:
        wav_file.setnchannels(num_channels)
        wav_file.setsampwidth(sampwidth)
        wav_file.setframerate(sample_rate)
        raw_data = struct.pack('<' + ('h' * len(samples)), *samples)
        wav_file.writeframes(raw_data)
    print(f"Generated: {filepath} ({len(samples)} samples)")

if __name__ == "__main__":
    out_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")
    generate_wav(os.path.join(out_dir, "gavel.wav"), 0.6, sound_type="gavel")
    generate_wav(os.path.join(out_dir, "coin.wav"), 0.7, sound_type="coin")
    generate_wav(os.path.join(out_dir, "click.wav"), 0.12, sound_type="click")
    generate_wav(os.path.join(out_dir, "crush.wav"), 1.2, sound_type="crush")
    generate_wav(os.path.join(out_dir, "hit.wav"), 0.35, sound_type="hit")
    generate_wav(os.path.join(out_dir, "victory.wav"), 0.8, sound_type="victory")
    generate_wav(os.path.join(out_dir, "warning.wav"), 0.6, sound_type="warning")
    generate_wav(os.path.join(out_dir, "pack.wav"), 0.25, sound_type="pack")
    print("All audio files generated successfully!")
