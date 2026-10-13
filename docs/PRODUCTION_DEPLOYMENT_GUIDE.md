# Kapiert Production Deployment & Release Guide

This guide details all necessary steps to take Kapiert from local development to production for thousands of users across Google Play, App Store, Desktop, and Web.

---

## 1. Supabase Production Authentication & Email (OTP)

Supabase's default email service (`mail.app.supabase.io`) is **strictly a dev sandbox** capped at **3 emails/hour**. For production, you must connect a dedicated transactional SMTP provider so that OTP codes arrive instantly in every user's inbox (Gmail, Apple, Outlook, etc.).

### Step 1.1: Connect a Free Transactional SMTP Provider (Resend)

[Resend](https://resend.com) is the recommended email delivery partner for Supabase (3,000 free emails/month, 100/day).

1. Sign up for a free account at [resend.com](https://resend.com).
2. Go to **API Keys** ➔ click **Create API Key** (name it `Kapiert Production`). Copy the key (`re_...`).
3. If you have a custom domain (e.g. `kapiert.app`), add it in **Domains** and verify the DNS records (DKIM, SPF). If you don't have a domain yet, you can test with `onboarding@resend.dev`.
4. In your [Supabase Dashboard](https://supabase.com/dashboard):
   - Navigate to **Project Settings** (gear icon) ➔ **Authentication** ➔ scroll to **SMTP Settings**.
   - Toggle **Enable Custom SMTP**: `ON`
   - Configure the fields:
     - **Sender email**: `auth@yourdomain.com` (or `onboarding@resend.dev`)
     - **Sender name**: `Kapiert`
     - **Host**: `smtp.resend.com`
     - **Port**: `465` (SSL) or `587` (TLS)
     - **Username**: `resend`
     - **Password**: `<Paste your Resend API Key>`
   - Click **Save**.

### Step 1.2: Configure the 6-Digit OTP Email Templates

Supabase's default template sends a magic link instead of a 6-digit code. Update it with Kapiert's pre-styled responsive email templates:

1. In Supabase Dashboard, go to **Authentication** ➔ **Email Templates**.
2. **Confirm signup**:
   - Open [`supabase/email_templates/confirm_signup.html`](file:///c:/Users/ASUS/Downloads/German_Articles/supabase/email_templates/confirm_signup.html).
   - Copy the HTML and paste it into the **Message Body**.
   - Subject: `Confirm your Kapiert account - {{ .Token }}`.
   - Click **Save**.
3. **Reset password**:
   - Open [`supabase/email_templates/reset_password.html`](file:///c:/Users/ASUS/Downloads/German_Articles/supabase/email_templates/reset_password.html).
   - Copy the HTML and paste it into the **Message Body**.
   - Subject: `Reset your Kapiert password - {{ .Token }}`.
   - Click **Save**.

### Step 1.3: Update Rate Limits for Production

1. In Supabase Dashboard, navigate to **Authentication** ➔ **Rate Limits**.
2. Adjust:
   - **Email per hour**: Increase from default to `60` or `120` (as supported by your SMTP tier).
   - **Token refresh limits**: As required by your traffic estimates.

---

## 2. Supabase Database Schema & RLS Verification

Ensure your production database has all required tables, Row Level Security (RLS) policies, and user trigger functions applied.

1. Open Supabase Dashboard ➔ **SQL Editor**.
2. If not already executed, paste and run [`supabase/migrations/20260101000000_initial_schema.sql`](file:///c:/Users/ASUS/Downloads/German_Articles/supabase/migrations/20260101000000_initial_schema.sql).
3. Verify that the following tables exist in **Table Editor** (`public` schema):
   - `profiles`
   - `lookup_history`
   - `streaks`
   - `favorites`
   - `user_settings`
4. Verify that RLS is **Enabled** on all 5 tables.

---

## 3. Deploying the FastAPI Backend

While Kapiert operates 100% offline with pre-seeded SQLite dictionary data, the backend powers online search, compound noun analysis, Wiktionary fallbacks, and 4-language example sentences.

### Deploying to Render (1-Click)
1. Push your repository to GitHub.
2. Sign in to [Render](https://render.com) ➔ click **New +** ➔ **Blueprint**.
3. Connect your repository. Render reads [`render.yaml`](file:///c:/Users/ASUS/Downloads/German_Articles/render.yaml) and provisions the service automatically.
4. Copy your live service URL: `https://kapiert-backend.onrender.com`.

---

## 4. Building the Flutter App for Production Release

### Step 4.1: Android Keystore Signing

1. Generate a release keystore (if you haven't already):
   ```bash
   keytool -genkey -v -keystore android/app/upload-keystore.jks \
     -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload -keypass <password> -storepass <password>
   ```
2. Reference the keystore in `android/key.properties` (added to `.gitignore`).

### Step 4.2: Build Android App Bundle (AAB for Google Play)

Compile the app with production `--dart-define` parameters so that secrets and endpoints are baked securely into the binary without manual in-app configuration:

```bash
cd flutter_app

flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://kapiert-backend.onrender.com \
  --dart-define=SUPABASE_URL=https://dydcdfzbynoeashxoerv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
```

The resulting bundle will be located at:
`flutter_app/build/app/outputs/bundle/release/app-release.aab`

### Step 4.3: Build Android APK (Direct Distribution / Testing)

```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://kapiert-backend.onrender.com \
  --dart-define=SUPABASE_URL=https://dydcdfzbynoeashxoerv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
```

The resulting APK will be located at:
`flutter_app/build/app/outputs/flutter-apk/app-release.apk`

### Step 4.4: Windows Desktop Release

```bash
flutter build windows --release \
  --dart-define=API_BASE_URL=https://kapiert-backend.onrender.com \
  --dart-define=SUPABASE_URL=https://dydcdfzbynoeashxoerv.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
```

---

## 5. Pre-Release Quality Assurance Checklist

Before uploading builds to app stores or releasing:

- [ ] **Feature Tests**: Specific unit/widget tests pass.
- [ ] **Full Suite**: All 186 Flutter tests pass (`flutter test`).
- [ ] **Backend Tests**: All 21 API/translation tests pass (`pytest tests/ -v`).
- [ ] **Static Analysis**: Zero warnings (`flutter analyze`).
- [ ] **Email Delivery**: Sign up with a new email and verify that the 6-digit OTP code arrives in < 5 seconds and authenticates properly.
