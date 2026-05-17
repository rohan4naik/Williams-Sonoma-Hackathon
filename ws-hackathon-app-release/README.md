# 🍳 Williams-Sonoma Registry Hackathon App

Welcome to the **Williams-Sonoma Hackathon App**! This premium iOS application features a fully-integrated **Registry AI Assistant** designed to help users build their registries, plan events, and dynamically suggest matching cookware, dinnerware, and tabletop products.

---

## 🚀 Getting Started & Setup

To protect sensitive API credentials, the project uses a secure local configuration that is excluded from Git tracking. Anyone cloning the repository can set up the AI assistant in **10 seconds** by following these steps:

### 1. Configure your API Secrets Plist

1. Open the repository folder and navigate to the project directory: `WSHackathonApp/`
2. Locate the template file named `Secrets-Template.plist`.
3. **Duplicate / Copy** `Secrets-Template.plist` and rename the copy to exactly **`Secrets.plist`** in the same folder.
4. Open your new `Secrets.plist` and replace the placeholder text with your Groq API Key:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>GroqAPIKey</key>
	<string>YOUR_GROQ_API_KEY_HERE</string>
</dict>
</plist>
```

> [!NOTE]
> The app uses a dynamic `#filePath` resolver to automatically find your local `Secrets.plist` at compile time on **any machine**, regardless of the developer's Mac username or directory structure. It works instantly out of the box!

---

## ✨ Features

### 💬 Williams-Sonoma Registry AI Assistant
* **Smart Recommendations:** Uses Groq's high-speed `llama-3.3-70b-versatile` model to provide fast, event-themed recommendations (e.g. customized birthdays, weddings).
* **Strict Guardrails:** Programmed with strict system prompts only to answer queries related to Williams-Sonoma products and party planning.
* **Direct Add to Registry:** Product cards inside the chat bubble feature a direct dynamic add-to-registry action.
* **Aesthetic Styling:** Matching User bubbles (Black) and AI bubbles (SystemGray6) complete with dynamic typing indicators and interactive sparkly circular avatars.
* **Real-time Image Generator:** Dynamically extracts keywords from suggested items and fetches high-end Unsplash catalog images matching the item category. No broken links or loading spinners!

---

## 🛠️ Tech Stack & Architecture
* **Language:** Swift 5.10 / Swift 6 (isolated concurrency models)
* **Framework:** SwiftUI
* **Design Pattern:** MVVM (Model-View-ViewModel)
* **LLM Engine:** Groq API Completion Engine (Low-Latency HTTP Client)
