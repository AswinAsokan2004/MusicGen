import torch
import torchaudio
from audiocraft.models import MusicGen
import os

# Load model
model = MusicGen.get_pretrained('facebook/musicgen-small')

# Set generation parameters
def generate_music_tensors(description, duration):
    model.set_generation_params(duration=duration, use_sampling=True, top_k=250)
    output = model.generate(descriptions=[description], progress=True, return_tokens=True)
    return output[0]

def save_audio(audio_tensor, sample_rate=16000, output_path="output.wav"):
    if audio_tensor.ndim == 3:
        audio_tensor = audio_tensor.squeeze(0)
    elif audio_tensor.ndim == 1:
        audio_tensor = audio_tensor.unsqueeze(0)
    elif audio_tensor.ndim != 2:
        raise ValueError(f"Unexpected tensor shape: {audio_tensor.shape}")

    audio_tensor = audio_tensor.cpu()
    torchaudio.save(output_path, audio_tensor, sample_rate)
    return output_path

if __name__ == "__main__":
    description = "A very mass bollywood style music for the entry of hero"
    duration = 10  # in seconds

    print("Generating music...")
    music_tensor = generate_music_tensors(description, duration)
    output_path = save_audio(music_tensor)

    print(f"Music generated and saved to: {output_path}")
