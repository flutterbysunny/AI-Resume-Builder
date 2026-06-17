# 🤖 AI Resume Builder

Flutter app jo Gemini AI ka use karke professional resume banata hai — skills suggest karta hai, AI summary generate karta hai, aur ek polished PDF resume export karta hai.

## ✨ Features

- **Multi-step form** — Personal Info, Job Info, Skills, AI Summary
- **AI Skills Suggestion** — Job title ke basis pe Gemini relevant skills suggest karta hai
- **AI Summary Generator** — Professional resume summary AI se generate hoti hai
- **Work Experience & Education** — Multiple entries add/edit/delete kar sakte ho
- **Projects Section** — Tech stack chips ke saath project showcase
- **PDF Export** — Clean, professional resume PDF download/share/print kar sakte ho
- **Live PDF Preview** — Final resume preview karne ke baad download

## 🛠️ Tech Stack

| Layer | Tool |
|-------|------|
| Framework | Flutter |
| State Management | GetX |
| AI | Google Gemini API (`gemini-2.5-flash`) |
| PDF Generation | `pdf` + `printing` packages |
| Fonts | Google Fonts |

## 📂 Project Structure

```
lib/
├── main.dart
├── controllers/
│   └── resume_controller.dart      # GetX controller — state & logic
├── models/
│   └── resume_model.dart           # Resume, WorkExperience, Education, Project models
├── services/
│   └── gemini_service.dart         # Gemini API calls
├── views/
│   ├── form_screen.dart            # Multi-step input form
│   └── preview_screen.dart         # PDF preview & download
└── utils/
    └── pdf_generator.dart          # PDF layout & generation
```

## 🚀 Getting Started

### 1. Clone & Install

```bash
flutter pub get
```

### 2. Add Gemini API Key

`lib/services/gemini_service.dart` mein apni API key daalo:

```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY';
```

Free key le sakte ho [Google AI Studio](https://aistudio.google.com) se.

### 3. Run

```bash
flutter run
```

## 📋 App Flow

1. **Personal Info** — Name, email, phone, location, social links
2. **Job Info** — Job title, work experience entries, education entries
3. **Skills** — AI se skills suggest karo aur select karo (max 10)
4. **AI Summary** — AI se professional summary generate karo
5. **Preview & Download** — PDF preview dekho, download/share/print karo

## 📦 Key Dependencies

```yaml
get: ^4.6.6
http: ^1.2.0
pdf: ^3.10.8
printing: ^5.12.0
google_fonts: ^6.1.0
```

## 📄 License

Personal/educational use for free.