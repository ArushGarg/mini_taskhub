🚀 Mini TaskHub

A modern task management mobile application built with Flutter and Supabase, designed with a sleek DayTask-inspired UI.
The app enables users to securely manage daily tasks with smooth animations, responsive design, and real-time cloud storage.

📱 Demo

🎥 Demo Video: Add your demo link here

📸 Screenshots
<div align="center">
Splash	Login	Sign Up
<img src="screenshots/splash.png" width="250">	<img src="screenshots/login.png" width="250">	<img src="screenshots/signup.png" width="250">
Dashboard	Add Task
<img src="screenshots/dashboard.png" width="250">	<img src="screenshots/addtask.png" width="250">
</div>
✨ Features
🔐 Authentication

Secure email/password login & signup

Powered by Supabase Auth

Persistent login sessions

✅ Task Management

Create new tasks

Edit existing tasks

Mark tasks as completed

Delete tasks with swipe gesture

📊 Dashboard

View completed tasks

Track ongoing tasks

Organized task list

🎨 UI/UX

DayTask inspired dark theme

Smooth staggered animations

Press-scale buttons

Shimmer loading skeletons

📱 Responsive

Works across different screen sizes

Clean mobile-first layout

🛠️ Tech Stack
Category	Technology
Framework	Flutter
Language	Dart
Backend	Supabase
Database	PostgreSQL
State Management	Provider
UI Libraries	flutter_slidable, shimmer
Fonts	Google Fonts (Poppins)
🏗️ Architecture

The project follows a clean and modular architecture.

lib
│
├── app
│   ├── theme.dart
│   └── router.dart
│
├── auth
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   └── auth_service.dart
│
├── dashboard
│   ├── dashboard_screen.dart
│   ├── task_tile.dart
│   ├── task_model.dart
│   └── add_task_sheet.dart
│
├── providers
│   ├── auth_provider.dart
│   └── task_provider.dart
│
├── services
│   └── supabase_service.dart
│
└── utils
    └── validators.dart
⚙️ Installation
1️⃣ Clone the Repository
git clone https://github.com/ArushGarg/mini_taskhub.git
cd mini_taskhub
2️⃣ Install Dependencies
flutter pub get
3️⃣ Setup Supabase

Create a new project on Supabase and run:

create table tasks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users(id) on delete cascade not null,
  title text not null,
  description text,
  is_completed boolean default false,
  created_at timestamp with time zone default timezone('utc', now()) not null
);

Enable Row Level Security:

alter table tasks enable row level security;

Add policy:

create policy "Users can only access their own tasks"
on tasks for all
using (auth.uid() = user_id);
4️⃣ Add Supabase Keys

Update main.dart:

await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
5️⃣ Run the App
flutter run
📦 Dependencies
supabase_flutter: ^2.3.0
provider: ^6.1.1
google_fonts: ^6.1.0
flutter_slidable: ^3.0.1
shimmer: ^3.0.0
uuid: ^4.3.3
🧪 Testing

Run tests using:

flutter test
📚 Key Concepts Demonstrated

Object Oriented Programming

State Management using Provider

REST API interaction

Async/Await programming

Clean architecture

Reusable Flutter widgets

Animation in Flutter

Form validation

👨‍💻 Author

Arush Garg

GitHub
https://github.com/ArushGarg

LinkedIn
https://linkedin.com/in/arushgarg

📄 License

This project was developed as part of an internship assessment for Techstax.
