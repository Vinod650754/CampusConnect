# Campus Connect Frontend Deployment

## Backend API

Production API base URL:

`https://campus-connect-backend-lln0.onrender.com/api/v1`

## Local development

Keep `.env` local and uncommitted. The existing `.env` can continue to point to the local emulator/backend.

## Production Android APK

From the Flutter project root:

```bash
flutter clean
flutter pub get
flutter build apk --release \
  --dart-define=BASE_URL=https://campus-connect-backend-lln0.onrender.com/api/v1 \
  --dart-define=ENVIRONMENT=production
```

APK output:

`build/app/outputs/flutter-apk/app-release.apk`

## GitHub

Do not commit `.env`, build output, or local IDE/Gradle files. The repository `.gitignore` excludes these local files.

```bash
git add .
git commit -m "Connect Flutter app to production API"
git push origin main
```

If the repository does not have a remote yet:

```bash
git remote add origin <YOUR_GITHUB_REPOSITORY_URL>
git branch -M main
git push -u origin main
```

## Flutter Web (optional)

```bash
flutter build web --release \
  --dart-define=BASE_URL=https://campus-connect-backend-lln0.onrender.com/api/v1 \
  --dart-define=ENVIRONMENT=production
```

Deploy the generated `build/web` directory as a static site on a service such as Firebase Hosting or Render Static Site.
