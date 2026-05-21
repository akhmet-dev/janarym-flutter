# Жанарым — AI Дауыстық Ассистент

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart" />
  <img src="https://img.shields.io/badge/Firebase-orange?logo=firebase" />
  <img src="https://img.shields.io/badge/OpenAI-GPT--4-green?logo=openai" />
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-lightgrey" />
</p>

---

## 🇰🇿 Қазақша

**Жанарым** — көзі нашар көретін адамдарға арналған AI дауыстық ассистент. Камера, дауыс командалары және жасанды интеллект арқылы қоршаған ортаны сипаттайды.

### Мүмкіндіктер
- 📸 **Камера сипаттамасы** — алдыңызда не тұрғанын айтады
- 🎙️ **Дауыс командалары** — экранды бір рет басыңыз, сұрағыңызды айтыңыз
- 🤖 **GPT-4 Vision** — фотосуретті талдап, қысқа жауап береді
- 🔊 **TTS** — жауапты дауыспен оқиды
- 🌐 **3 тіл** — қазақша, орысша, ағылшынша
- 📍 **Навигация, қауіпсіздік, оқу, сауда режимдері**
- 🆘 **SOS жіберу** — жақын адамдарға дереу хабар жіберу

### Іске қосу
```bash
git clone https://github.com/akhmet-dev/janarym-flutter
cd janarym-flutter
flutter pub get
flutter run
```

> **Ескерту:** Firebase конфигурациясы (`GoogleService-Info.plist`) және OpenAI API кілті қажет.

---

## 🇷🇺 Русский

**Жанарым** — AI голосовой ассистент для людей с нарушением зрения. Описывает окружающую среду с помощью камеры, голосовых команд и искусственного интеллекта.

### Возможности
- 📸 **Описание через камеру** — говорит что находится перед вами
- 🎙️ **Голосовые команды** — нажмите на экран, задайте вопрос
- 🤖 **GPT-4 Vision** — анализирует фото, даёт короткий ответ
- 🔊 **TTS** — озвучивает ответы
- 🌐 **3 языка** — казахский, русский, английский
- 📍 **Режимы** — навигация, безопасность, чтение, покупки
- 🆘 **Отправка SOS** — мгновенное оповещение близких

### Запуск
```bash
git clone https://github.com/akhmet-dev/janarym-flutter
cd janarym-flutter
flutter pub get
flutter run
```

> **Важно:** Требуется Firebase конфигурация (`GoogleService-Info.plist`) и ключ OpenAI API.

---

## 🇬🇧 English

**Janarym** — an AI voice assistant for visually impaired users. Describes the surrounding environment using the camera, voice commands, and artificial intelligence.

### Features
- 📸 **Camera description** — tells you what's in front of you
- 🎙️ **Voice commands** — tap the screen and ask your question
- 🤖 **GPT-4 Vision** — analyzes the frame and gives a short answer
- 🔊 **TTS** — reads the answer aloud
- 🌐 **3 languages** — Kazakh, Russian, English
- 📍 **Modes** — navigation, security, reading, shopping
- 🆘 **SOS** — instantly notifies your trusted contact

### Getting Started
```bash
git clone https://github.com/akhmet-dev/janarym-flutter
cd janarym-flutter
flutter pub get
flutter run
```

> **Note:** Firebase config (`GoogleService-Info.plist`) and OpenAI API key are required.

---

## 🛠 Tech Stack

| Технология / Технология / Technology | Мақсаты / Назначение / Purpose |
|---|---|
| Flutter + Dart | Мобильді фреймворк / Мобильный фреймворк / Mobile framework |
| Firebase Auth | Аутентификация / Аутентификация / Authentication |
| Cloud Firestore | Дерекқор / База данных / Database |
| OpenAI GPT-4.1 | AI жауаптар / AI ответы / AI responses |
| OpenAI Whisper | Сөйлеуді тану / Распознавание речи / Speech recognition |
| OpenAI TTS | Дауыс синтезі / Синтез голоса / Voice synthesis |
| flutter_tts | Жергілікті TTS / Локальный TTS / Local TTS fallback |
| speech_to_text | Жергілікті STT / Локальный STT / Local STT |
| camera | Камера / Камера / Camera |
| flutter_blue_plus | Bluetooth (AR) | Bluetooth (AR) |

---

<p align="center">Made with ❤️ for visually impaired users · Көзі нашар адамдар үшін · Для людей с нарушением зрения</p>
