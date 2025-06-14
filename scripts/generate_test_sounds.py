#!/usr/bin/env python3
"""
Generate test sounds for SetTimer app
Creates simple synthesized sounds for each sound pack
"""

import numpy as np
import wave
import os
from pathlib import Path

def generate_tone(frequency, duration, sample_rate=44100, amplitude=0.3):
    """Generate a simple sine wave tone"""
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    wave_data = amplitude * np.sin(2 * np.pi * frequency * t)
    return (wave_data * 32767).astype(np.int16)

def generate_beep(frequency, duration, fade_duration=0.05):
    """Generate a beep with fade in/out"""
    tone = generate_tone(frequency, duration)
    fade_samples = int(44100 * fade_duration)
    
    # Fade in
    for i in range(min(fade_samples, len(tone))):
        tone[i] = int(tone[i] * (i / fade_samples))
    
    # Fade out
    for i in range(min(fade_samples, len(tone))):
        idx = len(tone) - 1 - i
        tone[idx] = int(tone[idx] * (i / fade_samples))
    
    return tone

def save_wav(data, filename, sample_rate=44100):
    """Save audio data as WAV file"""
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(sample_rate)
        wav_file.writeframes(data.tobytes())

def generate_classic_sounds():
    """Generate Classic pack sounds - Clean and professional"""
    base_path = "assets/sounds/classic"
    
    # Set Start - Clean bell tone
    sound = generate_beep(800, 0.5)
    save_wav(sound, f"{base_path}/set_start.wav")
    
    # Set End - Lower bell tone
    sound = generate_beep(400, 0.8)
    save_wav(sound, f"{base_path}/set_end.wav")
    
    # Rest Start - Gentle tone
    sound = generate_beep(600, 0.6)
    save_wav(sound, f"{base_path}/rest_start.wav")
    
    # Rest End - Ready tone
    sound = generate_beep(800, 0.5)
    save_wav(sound, f"{base_path}/rest_end.wav")
    
    # Workout Complete - Success chord
    freq1 = generate_beep(523, 1.0)  # C
    freq2 = generate_beep(659, 1.0)  # E
    freq3 = generate_beep(784, 1.0)  # G
    sound = (freq1 + freq2 + freq3) // 3
    save_wav(sound, f"{base_path}/workout_complete.wav")
    
    # Countdown - Quick tick
    sound = generate_beep(1000, 0.1)
    save_wav(sound, f"{base_path}/countdown.wav")
    
    # Warning - Alert tone
    sound = generate_beep(1200, 0.3)
    save_wav(sound, f"{base_path}/warning.wav")

def generate_gym_sounds():
    """Generate Gym Beast pack sounds - Intense and motivational"""
    base_path = "assets/sounds/gym"
    
    # Set Start - Powerful horn
    sound = generate_beep(200, 0.8)
    save_wav(sound, f"{base_path}/set_start.wav")
    
    # Set End - Heavy bell
    sound = generate_beep(150, 1.2)
    save_wav(sound, f"{base_path}/set_end.wav")
    
    # Rest Start - Whistle-like
    sound = generate_beep(2000, 0.3)
    save_wav(sound, f"{base_path}/rest_start.wav")
    
    # Rest End - Power ready
    sound = generate_beep(300, 0.8)
    save_wav(sound, f"{base_path}/rest_end.wav")
    
    # Workout Complete - Victory fanfare
    freq1 = generate_beep(262, 1.5)  # C
    freq2 = generate_beep(330, 1.5)  # E
    sound = (freq1 + freq2) // 2
    save_wav(sound, f"{base_path}/workout_complete.wav")
    
    # Countdown - Intense beep
    sound = generate_beep(1500, 0.15)
    save_wav(sound, f"{base_path}/countdown.wav")
    
    # Warning - Air horn style
    sound = generate_beep(500, 0.5)
    save_wav(sound, f"{base_path}/warning.wav")

def generate_nature_sounds():
    """Generate Nature Zen pack sounds - Calm and natural"""
    base_path = "assets/sounds/nature"
    
    # Set Start - Wind chime
    freq1 = generate_beep(1047, 0.8)  # C6
    freq2 = generate_beep(1319, 0.8)  # E6 - Same duration
    sound = (freq1 + freq2) // 2
    save_wav(sound, f"{base_path}/set_start.wav")
    
    # Set End - Bamboo chime
    sound = generate_beep(880, 1.0)
    save_wav(sound, f"{base_path}/set_end.wav")
    
    # Rest Start - Water drop
    sound = generate_beep(1500, 0.2)
    save_wav(sound, f"{base_path}/rest_start.wav")
    
    # Rest End - Bird chirp
    sound = generate_beep(2000, 0.3)
    save_wav(sound, f"{base_path}/rest_end.wav")
    
    # Workout Complete - Nature harmony
    freq1 = generate_beep(523, 1.2)   # C5
    freq2 = generate_beep(659, 1.2)   # E5
    freq3 = generate_beep(784, 1.2)   # G5
    sound = (freq1 + freq2 + freq3) // 3
    save_wav(sound, f"{base_path}/workout_complete.wav")
    
    # Countdown - Soft click
    sound = generate_beep(3000, 0.05)
    save_wav(sound, f"{base_path}/countdown.wav")
    
    # Warning - Gentle chime
    sound = generate_beep(1200, 0.4)
    save_wav(sound, f"{base_path}/warning.wav")

def generate_electronic_sounds():
    """Generate Electronic pack sounds - Modern and futuristic"""
    base_path = "assets/sounds/electronic"
    
    # Set Start - Digital beep
    sound = generate_beep(1000, 0.3)
    save_wav(sound, f"{base_path}/set_start.wav")
    
    # Set End - Synth end
    sound = generate_beep(500, 0.6)
    save_wav(sound, f"{base_path}/set_end.wav")
    
    # Rest Start - Electronic tone
    sound = generate_beep(1500, 0.4)
    save_wav(sound, f"{base_path}/rest_start.wav")
    
    # Rest End - Digital ready
    sound = generate_beep(1200, 0.3)
    save_wav(sound, f"{base_path}/rest_end.wav")
    
    # Workout Complete - Victory synth
    freq1 = generate_beep(440, 1.0)   # A4
    freq2 = generate_beep(554, 1.0)   # C#5
    freq3 = generate_beep(659, 1.0)   # E5
    sound = (freq1 + freq2 + freq3) // 3
    save_wav(sound, f"{base_path}/workout_complete.wav")
    
    # Countdown - Digital tick
    sound = generate_beep(2000, 0.08)
    save_wav(sound, f"{base_path}/countdown.wav")
    
    # Warning - Electronic alert
    sound = generate_beep(1800, 0.4)
    save_wav(sound, f"{base_path}/warning.wav")

def generate_minimal_sounds():
    """Generate Minimal pack sounds - Subtle and unobtrusive"""
    base_path = "assets/sounds/minimal"
    
    # Set Start - Soft click
    sound = generate_beep(2000, 0.1)
    save_wav(sound, f"{base_path}/set_start.wav")
    
    # Set End - Quiet beep
    sound = generate_beep(1000, 0.2)
    save_wav(sound, f"{base_path}/set_end.wav")
    
    # Rest Start - Subtle tone
    sound = generate_beep(1500, 0.15)
    save_wav(sound, f"{base_path}/rest_start.wav")
    
    # Rest End - Gentle click
    sound = generate_beep(2000, 0.1)
    save_wav(sound, f"{base_path}/rest_end.wav")
    
    # Workout Complete - Soft success
    sound = generate_beep(800, 0.8)
    save_wav(sound, f"{base_path}/workout_complete.wav")
    
    # Countdown - Minimal tick
    sound = generate_beep(3000, 0.03)
    save_wav(sound, f"{base_path}/countdown.wav")
    
    # Warning - Quiet alert
    sound = generate_beep(1500, 0.2)
    save_wav(sound, f"{base_path}/warning.wav")

def convert_wav_to_mp3():
    """Convert WAV files to MP3 (requires pydub and ffmpeg)"""
    try:
        from pydub import AudioSegment
        import glob
        
        wav_files = glob.glob("assets/sounds/**/*.wav", recursive=True)
        for wav_file in wav_files:
            mp3_file = wav_file.replace('.wav', '.mp3')
            audio = AudioSegment.from_wav(wav_file)
            audio.export(mp3_file, format="mp3", bitrate="128k")
            os.remove(wav_file)  # Remove WAV file
            print(f"Converted: {wav_file} -> {mp3_file}")
    except ImportError:
        print("pydub not available, keeping WAV files")
        print("To convert to MP3, install: pip install pydub")

def main():
    """Generate all sound packs"""
    print("🎵 Generating SetTimer Sound Packs...")
    
    print("📦 Generating Classic pack...")
    generate_classic_sounds()
    
    print("💪 Generating Gym Beast pack...")
    generate_gym_sounds()
    
    print("🌿 Generating Nature Zen pack...")
    generate_nature_sounds()
    
    print("🎵 Generating Electronic pack...")
    generate_electronic_sounds()
    
    print("🔕 Generating Minimal pack...")
    generate_minimal_sounds()
    
    print("🔄 Converting to MP3...")
    convert_wav_to_mp3()
    
    print("✅ All sound packs generated successfully!")
    print("📁 Files saved to: assets/sounds/")

if __name__ == "__main__":
    main() 