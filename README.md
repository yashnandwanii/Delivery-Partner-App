# Delivery Partner App

## Overview

This repository contains the Delivery Partner application for Meal Monkey. It has two main parts:

- `Backend/` — Node.js/Express backend that provides REST APIs, authentication, database access, and integrations (email, Firebase, etc.).
- `delivery_partner_app/` — Flutter mobile application used by delivery partners (Android/iOS).

This README explains the responsibilities of each part, how to run them locally, and important security steps (the repository previously had a committed `.env` file; see the Security section).

## Repository layout

- `Backend/` — server source, routes, controllers, models, and configuration.
- `delivery_partner_app/` — Flutter app code, `pubspec.yaml`, assets, and platform folders.
- `landing-page/`, `Meal-Monkey-main/`, etc. — other project artefacts (not required to run the delivery partner app).

## Backend (Node.js)

### What it is

The backend is a standard Node.js/Express application that exposes REST endpoints used by the delivery partner Flutter app. It connects to MongoDB, uses JWT for authentication, and supports file uploads and push notifications.

### Important files

- `Backend/server.js` — app entrypoint.
- `Backend/routes/` — API routes.
- `Backend/controllers/` — request handlers and business logic.
- `Backend/models/` — Mongoose models.
- `Backend/config/` — configuration and utilities (e.g., cloudinary config).
- `Backend/.env.example` — example environment variables (DO NOT commit real secrets).

### Environment

The backend expects a `.env` file at `Backend/.env` (local only). Example keys are in `Backend/.env.example`.

Key variables include:

- `MONGODB_URI` — MongoDB connection string
- `JWT_SECRET` — secret for signing JWT tokens
- `PORT` — server port (default shown in example: `6014`)

DO NOT commit `Backend/.env` to git. The repository now contains `Backend/.gitignore` and `Backend/.env.example` to help prevent accidental commits.

### Install & Run (Backend)

From the repository root (macOS / zsh):

```zsh
cd "Delivery-Partner-App/Backend"
npm install
# create a local .env using .env.example
cp .env.example .env
# Edit .env with your credentials, then run:
npm run dev    # if a dev script exists (nodemon)
# or
npm start
```

If you need to run database migrations or seed data, check for scripts in `Backend/package.json` or the `Backend/README.md` inside that folder.

### Common troubleshooting

- Ensure MongoDB user/password and network rules allow connections from your IP or app.
- If you regenerate `JWT_SECRET`, all existing tokens will be invalidated.

## Frontend (Flutter delivery partner app)

### What it is

The `delivery_partner_app/` folder contains a Flutter app used by delivery partners to accept and complete deliveries. It communicates with the backend APIs and supports push notifications.

### Important files

- `delivery_partner_app/lib/` — main app source
- `delivery_partner_app/pubspec.yaml` — Flutter dependencies and assets

### Prerequisites

- Install Flutter SDK: https://flutter.dev/docs/get-started/install
- Have Android Studio (or Xcode for iOS) and a connected device or emulator.

### Install & Run (Flutter)

From the repository root (macOS / zsh):

```zsh
cd "Delivery-Partner-App/delivery_partner_app"
flutter pub get
# Run on connected device or simulator
flutter run

# Build APK
flutter build apk --release

# Build iOS (macOS only)
flutter build ios --release
```

### Environment & configuration (Flutter)

If the Flutter app needs environment-like configuration (API base URL, Firebase config), check for files or instructions inside `delivery_partner_app/` (often `lib/config` or `.env` usage). Avoid committing secret API keys. Use platform secure storage for runtime secrets where appropriate.

## Security note — exposed `.env`

The repository previously had `Backend/.env` committed with secrets (database URI, JWT secret, etc.). I have taken the immediate steps to stop tracking `.env` and added `Backend/.env.example`. However, the sensitive values remain in the repository history.

Recommended actions (high priority):

1. Rotate any secrets that were exposed (DB credentials, JWT secret, API keys, Firebase service account keys, SMTP credentials).
2. Permanently remove `Backend/.env` from the git history if you want to prevent access from clones of the repo. This requires rewriting history and force-pushing.

Options to purge history:

- git-filter-repo (recommended):

```zsh
# Use a fresh clone of the repo
git clone --mirror https://github.com/<org>/<repo>.git
cd repo.git
git filter-repo --path Backend/.env --invert-paths
git push --force --all
git push --force --tags
```

- BFG Repo-Cleaner:

```zsh
# From a fresh clone
java -jar bfg.jar --delete-files .env
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force --all
git push --force --tags
```

Warning: Rewriting history is disruptive. All collaborators must re-clone or reset their local repositories after a force-push. Tell me if you want me to perform the purge and force-push; I'll coordinate and show the exact commands before executing.

## Rotating exposed secrets (quick checklist)

- MongoDB: create a new DB user with a new password or rotate credentials in your cloud provider, update `MONGODB_URI`.
- JWT: replace `JWT_SECRET` with a long random value (use a secrets manager).
- Google APIs: regenerate API keys, restrict them by referrer/IP, and update the app.
- Firebase: revoke service account keys and create new ones.
- SMTP or other third-party services: rotate API keys or passwords.

## Testing & Linting

- Backend: check `Backend/package.json` for test scripts (e.g., `npm test`). Run them from `Backend/`.
- Frontend: run Flutter tests via `flutter test` inside `delivery_partner_app/`.

## Contribution

1. Create an issue describing the change.
2. Create a branch from `main`.
3. Make changes, ensure tests pass, and open a PR.

## Contact / Next steps

If you want, I can:

- Purge `Backend/.env` from git history and force-push (I will coordinate the steps and warn collaborators).
- Rotate or help rotate any exposed credentials.
- Add CI checks to prevent committing `.env` files (pre-commit hooks or GitHub Actions).

Tell me which of the above you'd like me to do next.

---

Last updated: October 30, 2025

