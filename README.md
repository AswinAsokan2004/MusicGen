# 🎶 MusicGen – Agentic AI Powered Generative Chatbot

**MusicGen** is a **multi-modal generative AI system** that combines **LLM-powered conversations** with **music generation**, all orchestrated by a **finely tuned Agentic AI (LLaMA3:8B)**.

The system intelligently decides whether to:

*  Provide a text response from the LLM
*  Or generate music (with customizable duration)

This creates a seamless blend of **conversational AI** and **creative audio generation**.

---

##  Project Structure

```
MusicGen/
│
├── backend/
│   └── main.py       # Backend logic (Agentic AI + LLM + Music generation)
│
├── frontend/
│   └── main.dart     # Flutter frontend (Chat interface + User input/output)
│
└── README.md         # Project documentation
```

---

##  Features

* **Agentic Decision Making** – Powered by **LLaMA3:8B**, finely tuned for real-time query analysis
* **Multi-modal Interaction** – Handles both natural language and music generation
* **Customizable Music Output** – Users can specify the **duration** of generated music
* **Seamless Frontend & Backend Integration** – Built with Flutter frontend and Python backend

---

##  Getting Started

### 1️ Clone the Repository

```bash
git clone https://github.com/AswinAsokan2004/MusicGen
cd MusicGen
```

### 2️⃣ Backend Setup

```bash
cd backend
pip install -r requirements.txt
python main.py
```

### 3️⃣ Frontend Setup (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

---

##  Tech Stack

* **Backend:** Python, LLaMA3:8B, Agentic AI, Generative Models
* **Frontend:** Flutter (Dart)
* **Integration:** REST APIs for communication between backend and frontend

---

##  Future Scope

* Advanced music customization (genre, instruments, style)
* Voice-based interactions
* Deployment as a web + mobile application

---

##  License

This project is licensed under the **MIT License** – feel free to use, modify, and contribute.
