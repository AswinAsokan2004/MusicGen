import torch
import torchaudio
from audiocraft.models import MusicGen
print("Audiocraft is installed!")
import os

def generate_music(description="Hero entry mass music", duration=10, output_path="output.wav"):
    print("Loading model...")
    model = MusicGen.get_pretrained('facebook/musicgen-small')

    print(f"Generating music for prompt: '{description}'...")
    model.set_generation_params(duration=duration, use_sampling=True, top_k=250)
    output = model.generate(descriptions=[description], progress=True, return_tokens=True)
    audio_tensor = output[0]

    # Ensure tensor is in the correct format
    if audio_tensor.ndim == 3:
        audio_tensor = audio_tensor.squeeze(0)
    elif audio_tensor.ndim == 1:
        audio_tensor = audio_tensor.unsqueeze(0)
    elif audio_tensor.ndim != 2:
        raise ValueError(f"Unexpected tensor shape: {audio_tensor.shape}")

    torchaudio.save(output_path, audio_tensor.cpu(), 16000)
    print(f"✅ Audio saved to: {output_path}")
    return output_path

if __name__ == "__main__":
    generate_music("A very mass Bollywood style music for the entry of a hero", 10)
