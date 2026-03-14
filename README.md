# Petzy Admin 🐾
> *A modern Flutter admin panel for pet e-commerce management — built with love for pets and clean code.*

---

## What is Petzy Admin?

Petzy Admin is a comprehensive admin panel built with Flutter and Firebase for managing the Petzy pet e-commerce platform. From inventory management to order processing, everything is real-time, intuitive, and beautifully designed for efficient store administration.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔥 **Real-time Dashboard** | Live sales analytics and store metrics |
| � **Product Management** | Add, edit, and manage pet products with images |
| � **Order Management** | Process orders, update status, and handle returns |
| � **Customer Management** | View customer profiles and purchase history |
| � **Secure Admin Access** | Role-based authentication with Google Sign-In |
| 📊 **Analytics & Reports** | Sales reports, inventory insights |
| � **Push Notifications** | Send promotional messages to customers |
| 🏪 **Store Settings** | Configure store policies and preferences |

---

## 🛠️ Tech Stack

```
Flutter          →  Cross-platform admin UI framework
BLoC             →  State management for admin operations
Firebase         →  Firestore + Authentication for admin backend
Cloudinary       →  Product image storage & delivery
Material 3       →  Modern admin design system
Charts           →  Data visualization for analytics
```

---

## 📦 Dependencies

```yaml
flutter_bloc: ^9.1.1
cloud_firestore: ^5.6.8
firebase_auth: ^5.5.4
firebase_core: ^3.13.1
google_sign_in: ^6.3.0
image_picker: ^1.1.2
cloudinary_public: ^0.23.1
google_fonts: ^6.2.1
fl_chart: ^0.69.2
data_table_2: ^2.5.15
lottie: ^3.3.1
shimmer: ^3.0.0
shared_preferences: ^2.5.3
```

---

## 📁 Project Structure

```
lib/
├── features/
│   ├── core/            # Utilities, colors, themes
│   ├── data/            # Data sources, repository implementations
│   ├── domain/          # Models, repositories, use cases
│   └── presentation/    # Admin screens, BLoCs, widgets
├── admin/
│   ├── dashboard/       # Analytics dashboard
│   ├── products/        # Product management
│   ├── orders/          # Order processing
│   ├── customers/       # Customer management
│   └── settings/        # Admin settings
├── firebase_options.dart
└── main.dart
```

---

<p align="center">Made with ❤️ using Flutter</p>
