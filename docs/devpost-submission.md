# Devpost Submission: Sithara

## Project Name
Sithara

## Tagline
A private AI-powered product catalog for boutique owners — search, tag, and share in under 30 seconds.

## Description (paste into Devpost description field)

Sithara is a private product catalog app built for boutique owners who manage their inventory entirely through their phone. Before Sithara, the process looked like this: take a product photo, manually remove the background in PhotoRoom, copy it to WhatsApp, type a description, send to the customer — repeated for every product, every time.

Sithara replaces that workflow with a catalog that thinks alongside the owner.

**What it does:**
- **Smart upload**: Select product photos from your gallery. Sithara automatically calls the Ximilar Fashion Tagging API to identify garment type, fabric, color, occasion, and age group — you review and edit the AI's suggestions before saving.
- **Optional background removal**: One tap sends your photo to Remove.bg. Review the before/after, approve or skip.
- **Searchable inventory**: Every product is tagged and indexed for full-text search. Voice search (via speech_to_text) lets you search hands-free.
- **Collections**: Curate themed product groupings (e.g. "Ugadi Specials") for organized sharing.
- **Share tray**: Browse your catalog, add products to a persistent share tray, customize descriptions, then share to WhatsApp or Instagram DM with one tap via the system share sheet. Prices are never included — only images and descriptions.

**Built for real use**: This was built for a real boutique owner's real pain. The app is already installed on her Android phone with a live Appwrite backend.

## Built With
- Flutter (Dart)
- Riverpod 2.x
- go_router
- Appwrite (self-hosted) — Auth, Databases, Storage, Functions
- Ximilar Fashion Tagging API
- Remove.bg API
- speech_to_text
- share_plus
- image_picker
- Tailscale (VPN for remote backend access)

## GitHub Repository
https://github.com/simplysarath/instagrammer

## Try It Out
[Upload APK to a file host and link here, OR note: "Install APK on Android device for demo"]

## APK Build Notes
The release APK could not be built during automated build prep because the Android SDK is not installed on the build machine (this is a dev-only machine without Android Studio). To build the APK before submitting:

**Option A — Build on this machine:**
1. Install Android Studio from https://developer.android.com/studio
2. After installation, run: `flutter doctor` to verify Android SDK is detected
3. Then run from the `sithara/` directory:
   ```
   flutter build apk --debug
   ```
   (Debug APK is fine for a hackathon demo — no signing config required)
4. APK will be at: `sithara/build/app/outputs/flutter-apk/app-debug.apk`

**Option B — Build on any machine with Android Studio already installed:**
1. Clone the repo: `git clone https://github.com/simplysarath/instagrammer`
2. `cd instagrammer/sithara`
3. Copy `.env` with Appwrite endpoint, project ID, and API keys (not committed — you have these)
4. `flutter pub get`
5. `flutter build apk --debug`

## Screenshots needed (take these from the running app):
1. Home screen with category tiles (ideally with a product or two)
2. Tag review screen (step 3 of upload) showing AI-suggested tags
3. Share tray expanded (showing 1-2 products with editable descriptions)
4. Search results (search for a garment type and show results)

## Team
- Sarath Singamsetty (solo)

## Submission checklist before hitting Submit:
- [ ] Project name is "Sithara"
- [ ] Tagline filled in
- [ ] Description pasted and reviewed
- [ ] Built-with tags added (Flutter, Dart, Appwrite, Riverpod, go_router, Ximilar, Remove.bg)
- [ ] GitHub repo linked: https://github.com/simplysarath/instagrammer
- [ ] At least 2-3 screenshots uploaded
- [ ] APK uploaded or linked
- [ ] docs/ folder artifacts included (scope.md, prd.md, spec.md, checklist.md are in the repo already)
