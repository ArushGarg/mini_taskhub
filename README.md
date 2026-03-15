# 🗂️ Mini TaskHub

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Auth%20%2B%20DB-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Provider](https://img.shields.io/badge/State-Provider-FF6B6B?style=for-the-badge)

A sleek, production-grade personal task tracking app built with Flutter and Supabase.
Featuring the **DayTask** UI design, smooth staggered animations, and full CRUD task management.

[▶️ Demo Video (Google Drive)](https://drive.google.com/file/d/1HJL6yEdDFfspCi9P-WrHHNk0bLxdEsYn/view?usp=drivesdk/view)

</div>

---

## 📸 Screenshots

<div align="center">

| Splash | Login | Sign Up |
|--------|-------|---------|
| ![Splash](https://github.com/user-attachments/assets/a8a0a173-8963-4ae0-a07b-979cf2085d9e) | ![Login](https://github.com/user-attachments/assets/27014e05-85b7-48e5-a200-6319cac0b2b6) | ![SignUp](https://github.com/user-attachments/assets/14f858cf-0788-4574-8845-1b2039d04287) |

| Dashboard | Add Task |
|-----------|----------|
| ![Dashboard](https://github.com/user-attachments/assets/8a2481dd-feed-4160-b84e-04b316de7a5c) | ![AddTask](https://github.com/user-attachments/assets/f16fc2ee-a53d-4f7f-8c40-bd8b2330290e) |

</div>

---

## ✨ Features

- 🔐 **Authentication** — Email/password login & signup via Supabase Auth
- ✅ **Task Management** — Create, edit, delete, and complete tasks
- 💾 **Persistent Storage** — All tasks stored in Supabase PostgreSQL
- 🎨 **DayTask UI** — Dark navy theme `#1C2331` with golden yellow `#F5C518` accents
- 🎬 **Smooth Animations** — Staggered entrance, fade/slide transitions, press-to-scale buttons
- 📊 **Dashboard** — Completed task cards + ongoing task list with progress
- 👆 **Swipe to Delete** — Intuitive gesture-based task deletion
- ⚡ **Shimmer Loading** — Skeleton loader while fetching tasks
- 🌙 **Dark Theme** — Consistent dark design matching DayTask Figma
- 📱 **Responsive Design** — Works on all screen sizes
- 🧭 **Bottom Navigation** — Home, Chat, Add, Calendar, Alerts tabs

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter 3.x + Dart |
| Backend / Auth | Supabase (PostgreSQL + Auth) |
| State Management | Provider |
| Fonts | Google Fonts (Poppins) |
| Animations | Flutter built-in + staggered intervals |
| UI Components | flutter_slidable, shimmer |

---

## 📂 Folder Structure

```
lib/
├── main.dart                  # App entry point, Supabase init
├── app/
│   ├── theme.dart             # Global colors, typography, component themes
│   └── router.dart            # Centralized named route navigation
├── auth/
│   ├── splash_screen.dart     # Splash with DayTask branding + animations
│   ├── login_screen.dart      # DayTask login with staggered animations
│   ├── signup_screen.dart     # Registration screen
│   └── auth_service.dart      # Raw Supabase auth calls
├── dashboard/
│   ├── dashboard_screen.dart  # Home screen with bottom nav + task sections
│   ├── task_tile.dart         # Reusable swipeable task widget
│   ├── task_model.dart        # Task data model with fromJson/toJson/copyWith
│   └── add_task_sheet.dart    # Bottom sheet for add/edit task with date picker
├── providers/
│   ├── auth_provider.dart     # Auth state management
│   └── task_provider.dart     # Task CRUD state management
├── services/
│   └── supabase_service.dart  # All Supabase DB calls
└── utils/
    └── validators.dart        # Form validators with String extensions
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.x
- Dart 3.x
- A free [Supabase](https://supabase.com) account

### 1. Clone the repo
```bash
git clone https://github.com/ArushGarg/mini_taskhub.git
cd mini_taskhub
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Supabase Setup

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Navigate to **SQL Editor** and run the following:

```sql
create table tasks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null,
  description text,
  is_completed boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table tasks enable row level security;

create policy "Users can only access their own tasks"
  on tasks for all
  using (auth.uid() = user_id);
```

3. Go to **Settings → API** and copy your:
   - Project URL
   - Anon/Public Key

4. Paste them into `lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### 4. Run the app
```bash
flutter run
```

---

## 🔥 Hot Reload vs Hot Restart

| | Hot Reload ⚡ | Hot Restart 🔄 |
|--|--------------|----------------|
| **Speed** | ~1 second | ~3–5 seconds |
| **App State** | ✅ Preserved | ❌ Reset |
| **`initState()` runs** | ❌ No | ✅ Yes |
| **Use when** | UI tweaks, style changes | Logic changes, new providers |
| **Shortcut** | `r` in terminal | `R` in terminal |

> **Hot Reload** injects updated Dart code into the running VM without losing the current state — ideal for UI iteration.
> **Hot Restart** fully restarts the app from `main()`, reinitializing all state — needed when changing app-level logic.

---

## 🧪 Running Tests

```bash
flutter test
```

Includes unit test for `Task` model serialization (`fromJson`, `toJson`, `copyWith`).

---

## 🏗️ Architecture Decisions

- **Provider** chosen for simplicity and Flutter-native feel — no boilerplate overhead
- **AuthService** layer handles raw Supabase calls, fully decoupled from UI
- **SupabaseService** handles all DB operations — easy to swap backend if needed
- **Row Level Security** on Supabase ensures users only ever access their own data
- **Named routing** via `AppRouter` keeps navigation centralized and maintainable
- **`copyWith` pattern** on `Task` model follows immutable data best practices

---

## 🎯 Key Concepts Demonstrated

- ✅ OOP — Model classes, service classes, providers
- ✅ Async/Await — All Supabase calls properly awaited
- ✅ Extensions — `String` validators (`isValidEmail`, `isValidPassword`)
- ✅ Custom Widgets — `TaskTile`, `_DayTaskField`, `_YellowButton`
- ✅ REST + JSON — Via Supabase client SDK
- ✅ Responsive Design — `MediaQuery` aware layouts
- ✅ Animations — Staggered intervals, floating, press-scale, fade transitions
- ✅ Clean Architecture — Service → Provider → UI separation

---

## 📦 Dependencies

```yaml
supabase_flutter: ^2.3.0   # Auth + Database
provider: ^6.1.1            # State management
google_fonts: ^6.1.0        # Poppins typography
flutter_slidable: ^3.0.1    # Swipe-to-delete gesture
shimmer: ^3.0.0             # Loading skeleton effect
uuid: ^4.3.3                # UUID generation
```

---

## 🙋‍♂️ Author

**Arush Garg**
- GitHub: [@ArushGarg](https://github.com/ArushGarg)
- LinkedIn: [Arush Garg](https://linkedin.com/in/arushgarg/)

---

<div align="center">
  Made with ❤️ and Flutter
</div>
