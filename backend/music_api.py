import base64
import requests  # ✅ Use this library

# Send GET request to your Flask + ngrok endpoint
response = requests.get("https://1d3c-34-126-159-241.ngrok-free.app/music")
data = response.json()

# Save the base64-decoded audio to a file
with open("received_music.wav", "wb") as f:
    f.write(base64.b64decode(data['music']))
