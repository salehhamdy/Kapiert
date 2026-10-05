# Privacy Policy

**Effective Date:** October 5, 2026  
**Last Updated:** October 5, 2026

**Kapiert** ("we," "our," or "the App") respects your privacy. This Privacy Policy explains how we collect, use, store, and protect your information when you use our mobile, desktop, and web applications, in compliance with GDPR, CCPA, and standard privacy principles.

---

## 1. Privacy-First Architecture

Kapiert is built with a **local-first philosophy**:
- **Zero Ads:** We do not display third-party advertisements.
- **Zero Data Selling:** We never sell, rent, trade, or monetize your personal information.
- **Offline / Guest Friendly:** You can use all core dictionary and quiz features without an account. All data remains stored solely on your device unless you choose to sign in.

---

## 2. Information We Collect

### A. In Guest Mode (No Account Required)
When using Kapiert without signing in, **all learning data is stored locally on your device**:
- **Local SQLite Database:** Stores your search/lookup history, quiz responses (correct/incorrect marks), current streak, and saved **Favorites**.
- **Local App Preferences (SharedPreferences):** Stores your UI preferences (dark/light theme, hints display toggle, last active study date).
- **No Personal Identifiers:** No name, email, IP address, or device fingerprint is attached to this data.

### B. In Signed-In Mode (Optional Cloud Sync)
If you choose to create an account to synchronize your progress across devices:
- **Account Credentials:** Email address, user display name, and authentication tokens (managed securely via Supabase Auth).
- **OAuth Data:** If you sign in using Google, we receive your email and basic public profile details (name and avatar photo URL).
- **Synced Learning Data:** Lookup history, quiz accuracy, daily streaks, article mastery breakdown, and favorite words are backed up to our cloud database.

### C. Network & Dictionary Requests
- When you look up a German noun or request random quiz words, the word string is sent via HTTPS to our FastAPI backend or Wiktionary fallback API.
- Search queries are evaluated in-memory and are not logged with personal user profiles or persistent trackers.

---

## 3. How We Use Your Information

We process collected information solely to:
1. Provide, maintain, and improve the German language learning experience.
2. Calculate learning analytics, article mastery statistics, and daily practice streaks.
3. Synchronize your learning progress and favorite words seamlessly across your devices.
4. Authenticate your account and protect against unauthorized access.

---

## 4. Data Storage, Security & Row Level Security (RLS)

- **Encryption in Transit:** All communication between the app, backend, and database uses TLS/HTTPS encryption.
- **Row Level Security (RLS):** Our cloud database (Supabase PostgreSQL) strictly enforces Row Level Security policies. Each user can only read, insert, update, or delete their own records.
- **Local Data Protection:** On mobile and desktop platforms, local SQLite database files are sandboxed within the application's private app directory.

---

## 5. Third-Party Service Providers

We use a minimal set of trusted third-party services:
- **Supabase:** Cloud database and authentication infrastructure. Hosted on secure SOC 2 / GDPR-compliant servers.
- **Google Sign-In:** Optional identity provider for OAuth authentication.
- **Wiktionary REST API:** Public educational dictionary service used for fallback noun definitions under CC BY-SA 3.0.

We do **not** integrate third-party ad networks, marketing trackers, or behavioural analytics SDKs.

---

## 6. Your Rights & Data Control (GDPR / CCPA)

You maintain complete ownership and control over your learning data:
- **Right to Access & View:** You can inspect your complete lookup and quiz history at any time in the History tab.
- **Right to Clear Data:** You can instantly wipe your local search and quiz history at any time via **Settings → Clear history**.
- **Right to Erasure (Account Deletion):** You can request complete deletion of your account and all associated cloud data via the app or by contacting maintainers.
- **Right to Portability:** You may request an export of your stored learning records.

---

## 7. Children's Privacy

Kapiert is designed as an educational tool for learners of all ages. We do not knowingly collect personal identifiable information from children under the age of 13. If you believe a child has provided us with personal information without parental consent, please contact us and we will promptly remove the data.

---

## 8. Changes to this Privacy Policy

We may update this Privacy Policy from time to time. Any changes will be reflected in the app and on our GitHub repository with an updated "Last Updated" date.

---

## 9. Contact Us

If you have questions, feedback, or data requests regarding this Privacy Policy, please open an issue or discussion on our [GitHub repository](https://github.com/salehhamdy/Kapiert).
