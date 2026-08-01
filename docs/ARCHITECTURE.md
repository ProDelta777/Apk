# LocalLink Architecture Guidelines

Welcome to the architectural overview of LocalLink, a hyper-local marketplace app designed to empower local shopkeepers by enabling zero-delay deliveries, direct interaction, and flexible local returns.

---

## 1. Project Structure (Scalable Flutter Layout)

We adopt a Feature-first or Layer-first approach. For LocalLink, since we have clear domains (Customer, Shopkeeper, Admin), a hybrid feature-based structure makes the codebase highly scalable and manageable.

```text
lib/
│
├── core/                   # App-wide constants, theme, routing, and utilities
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── router.dart         # Role-based GoRouter implementation
│
├── models/                 # Data classes and DTOs (Data Transfer Objects)
│   ├── user_model.dart
│   ├── shop_model.dart
│   ├── product_model.dart
│   └── order_model.dart
│
├── services/               # External APIs, Database logic
│   ├── supabase_service.dart # Centralized Supabase client logic
│   ├── ai_service.dart     # AI logic for Voice-to-Text (Placeholder for APIs like OpenAI Whisper)
│   ├── location_service.dart# Geo-location services
│   └── payment_service.dart# Mock implementations for UPI and COD
│
├── screens/                # UI Layer (Separated by User Role)
│   ├── auth/               # Login, Sign Up, OTP Verification
│   ├── customer/           # Customer flows (Discovery, Orders, Profile)
│   │   ├── home_screen.dart
│   │   ├── shop_detail.dart
│   │   └── order_details.dart
│   ├── shopkeeper/         # Shopkeeper flows (Dashboard, Add Product, Orders)
│   │   ├── dashboard_screen.dart
│   │   ├── add_product.dart
│   │   └── manage_orders.dart
│   └── admin/              # Admin flows (KYC, Analytics)
│
├── widgets/                # Reusable UI components (Buttons, Cards, Chat Bubbles)
│   ├── product_card.dart
│   ├── custom_button.dart
│   └── chat_bubble.dart
│
└── main.dart               # Entry point of the application
```

---

## 2. Business Logic Workflows

### Return Policy Workflow
LocalLink bypasses traditional central warehousing to offer rapid returns.
1. **Customer Action:** The user navigates to their `OrderDetailsScreen` and taps "Request Return/Exchange." They are prompted to select a reason and optionally attach photos.
2. **Database Update:** A new record is inserted into the `returns` table with status `'requested'`.
3. **Notification:** Supabase Realtime pushes a notification to the Shopkeeper App indicating a return request.
4. **Shopkeeper Approval:** The shopkeeper opens the request and either Accepts or Rejects it. (They can also chat directly with the customer to negotiate an exchange instead).
5. **Resolution:** If approved, the status changes to `'approved'`, and the physical exchange/return happens at the shop level (managed outside the digital platform, but logged for history).

### Local Discovery Workflow
The core value proposition of LocalLink is finding items near the user (1-5km radius).
1. **User Location:** The app captures the user's current GPS coordinates (lat, lng) via the `geolocator` package.
2. **Database Query:** The Flutter app calls a Supabase RPC (Remote Procedure Call) that utilizes the PostGIS extension.
   - We query the `shops` table using `ST_DWithin(location, ST_MakePoint(lng, lat)::geography, 5000)`.
   - The query filters for `is_open = true` and orders the results by `ST_Distance` to show the closest shops first.
3. **Display:** The `HomeScreen` lists these nearby shops or plots them on a MapView.

---

## 3. Step-by-Step Implementation Guide

### A. Supabase Setup
1. **Create Project:** Go to [Supabase](https://supabase.com/), create an account, and start a new project.
2. **Database Schema:**
   - Navigate to the SQL Editor in the Supabase dashboard.
   - Copy the contents of `database/schema.sql` (found in this repository) and execute it. This sets up all tables, enums, RLS policies, and enables PostGIS.
3. **Authentication:**
   - Go to Auth > Providers. Enable Email/Password or Phone Authentication (if using OTPs).
4. **API Keys:**
   - Go to Project Settings > API. Copy your `Project URL` and `anon public` key. You will need these for the Flutter app.

### B. Flutter Setup
1. **Prerequisites:** Ensure you have the Flutter SDK installed (`flutter doctor`).
2. **Initialize App:** (If not already created) run `flutter create locallink`.
3. **Dependencies:** Add the required packages to your `pubspec.yaml`:
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     supabase_flutter: ^2.0.0
     geolocator: ^11.0.0
     # Add others like google_maps_flutter, provider/riverpod based on state management choice.
   ```
4. **Configure Env:** Create a `.env` file at the root to store your Supabase credentials securely.
5. **Run the App:**
   ```bash
   flutter pub get
   flutter run
   ```