# Sithara — Technical Spec

## Stack

| Layer | Choice | Docs |
|---|---|---|
| Client | Flutter (Dart) | https://docs.flutter.dev |
| State management | Riverpod 2.x | https://riverpod.dev/docs/introduction/getting_started |
| Navigation | go_router | https://pub.dev/packages/go_router |
| Backend (BaaS) | Appwrite (self-hosted) | https://appwrite.io/docs/advanced/self-hosting |
| File storage | Appwrite Storage | https://appwrite.io/docs/products/storage |
| Auth | Appwrite Auth | https://appwrite.io/docs/products/auth |
| Database | Appwrite Databases | https://appwrite.io/docs/products/databases |
| Serverless functions | Appwrite Functions (Node.js) | https://appwrite.io/docs/products/functions |
| AI tagging | Ximilar Fashion Tagging API | https://docs.ximilar.com/fashion/ |
| Background removal | Remove.bg API | https://www.remove.bg/api |
| Gallery picker | image_picker (Flutter) | https://pub.dev/packages/image_picker |
| Voice input | speech_to_text (Flutter) | https://pub.dev/packages/speech_to_text |
| Share sheet | share_plus (Flutter) | https://pub.dev/packages/share_plus |

**Rationale:** Appwrite is chosen over Firebase/Supabase because Sharat wants self-hosted with no cloud cost. Flutter is the platform — Appwrite's Flutter SDK is first-class and actively maintained (v20+). Riverpod is chosen over BLoC for its compile-safe async state handling, which fits the upload flow and global share tray cleanly.

---

## Runtime & Deployment

- **Client:** Flutter app targeting Android first, iOS later (when Mac is available)
- **Backend:** Appwrite self-hosted on a cloud VM via Docker Compose
- **Remote access:** Tailscale (zero-config VPN) for access outside the home network — https://tailscale.com/kb/1017/install
- **Environment variables:** Appwrite endpoint URL and project ID stored in `.env` (client); Ximilar and Remove.bg API keys stored as Appwrite Function environment variables (never in the client)
- **Demo target:** Installed APK on wife's Android phone; Appwrite running on cloud VM

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App (Android)                 │
│                                                          │
│  go_router ──► screens                                   │
│  Riverpod providers ──► repositories ──► Appwrite SDK    │
│                                                          │
│  ShareTrayNotifier (global, outside router)              │
└────────────────────────┬────────────────────────────────┘
                         │ HTTPS
                         ▼
┌─────────────────────────────────────────────────────────┐
│              Appwrite (self-hosted, cloud VM)            │
│                                                          │
│  Auth ──────────────────── invite links, JWT sessions    │
│  Databases ─────────────── products, collections         │
│  Storage ───────────────── product images + videos       │
│  Functions                                               │
│    ├── tag-product ──────── calls Ximilar API            │
│    └── remove-background ── calls Remove.bg API          │
└─────────────┬──────────────────────┬────────────────────┘
              │                      │
              ▼                      ▼
   ┌─────────────────┐    ┌────────────────────┐
   │  Ximilar API    │    │   Remove.bg API     │
   │  (fashion tags) │    │  (bg removal)       │
   └─────────────────┘    └────────────────────┘
```

---

## Flutter App

### State Management

Implements `prd.md > all epics` (global architecture).

Riverpod 2.x with `AsyncNotifier` for all async state. Key providers:

| Provider | Type | Scope |
|---|---|---|
| `authProvider` | `AsyncNotifier<User?>` | Global |
| `productListProvider(categoryId)` | `AsyncNotifier<List<Product>>` | Per-screen |
| `collectionListProvider` | `AsyncNotifier<List<Collection>>` | Global |
| `uploadProvider` | `Notifier<UploadState>` | Upload flow |
| `shareTrayProvider` | `Notifier<List<ShareItem>>` | Global (persists across navigation) |
| `searchProvider(query, categoryId?)` | `AsyncNotifier<SearchResults>` | Per-search |

### Navigation

Implements `prd.md > Catalog Home`, `prd.md > Contributor Access`.

**go_router** route map:

```dart
/                     → redirect to /home if authed, /login if not
/login                → LoginScreen
/invite/:token        → InviteScreen (deep link — accept invite, set password)

/home                 → HomeScreen (category tiles + collection tiles + search)
/category/:id         → CategoryScreen (product grid)
/collection/:id       → CollectionScreen (product grid, same component)
/product/:id          → ProductDetailScreen
/product/:id/edit     → ProductEditScreen

/upload/pick          → PickScreen (gallery picker)
/upload/bg-removal    → BgRemovalScreen (opt-in step)
/upload/tags          → TagReviewScreen (AI tag confirmation + price + stock)
```

The **ShareTray** is not a route. It is a persistent overlay widget rendered above the router's `Navigator`, driven by `shareTrayProvider`. It appears automatically when the tray has at least one item.

```
┌──────────────────────────────┐
│  MaterialApp.router          │
│  ┌──────────────────────┐    │
│  │  Current route screen │    │
│  └──────────────────────┘    │
│  ┌──────────────────────┐    │  ← ShareTrayBar, visible when tray.length > 0
│  │ [img][img] Share (2) │    │
│  └──────────────────────┘    │
└──────────────────────────────┘
```

### Shared Widgets

Reusable components consumed across multiple screens:

| Widget | Used by |
|---|---|
| `ProductCard` | CategoryScreen, CollectionScreen, SearchResults, ShareTrayExpanded |
| `CategoryTile` | HomeScreen |
| `StockIndicator` | ProductCard, ProductDetailScreen, TagReviewScreen |
| `TagChip` | TagReviewScreen, ProductDetailScreen |
| `SearchBarWidget` | HomeScreen, CategoryScreen |

---

## Appwrite Backend

### Auth

Implements `prd.md > Contributor Access`.

- **Method:** Appwrite Email/Password auth + Team Invites
- **Flow:** Owner opens Appwrite console → creates a Team → generates invite link → sends to contributor → contributor opens deep link in app (`/invite/:token`) → sets password → account created → added to Team
- **Permissions:** All Team members have identical read/write access to all Appwrite collections and storage buckets. No role hierarchy in v1.
- **Upload attribution:** Every product document stores `uploaded_by: $userId` captured from the Appwrite session at save time. Displayed in product detail.
- **Session management:** Appwrite SDK handles JWT refresh automatically.

### Database Collections

Implements `prd.md > Adding a Product`, `prd.md > Browsing and Product Detail`, `prd.md > Collections`.

**products**

| Field | Type | Notes |
|---|---|---|
| `$id` | string | Appwrite auto-generated |
| `description` | string | Optional short description |
| `image_ids` | string[] | Appwrite Storage file IDs, ordered |
| `primary_image_id` | string | Which image is the catalog thumbnail |
| `video_id` | string? | Optional, Appwrite Storage file ID |
| `tags` | object | See ProductTags below |
| `price` | number? | Optional, private — never in share output |
| `stock_status` | string | `"in"` (default) \| `"out"` |
| `bg_removal_status` | string | `"none"` \| `"pending"` \| `"done"` |
| `category` | string | `"sarees"` \| `"salwars"` \| `"modern"` \| `"kids"` |
| `uploaded_by` | string | Appwrite user ID |
| `$createdAt` | datetime | Appwrite auto-generated |

**ProductTags** (embedded object within product):

| Field | Type | Notes |
|---|---|---|
| `garment_type` | string | Required — only enforced non-empty field |
| `fabric` | string? | e.g. "cotton", "silk", "georgette" |
| `color` | string? | e.g. "red", "navy", "multicolor" |
| `occasion` | string? | e.g. "casual", "wedding", "festive" |
| `age_group` | string? | e.g. "women", "kids", "teens" |

**collections**

| Field | Type | Notes |
|---|---|---|
| `$id` | string | Appwrite auto-generated |
| `name` | string | Required, e.g. "Ugadi Specials" |
| `description` | string? | Optional |
| `product_ids` | string[] | Ordered list of product document IDs |
| `created_by` | string | Appwrite user ID |
| `$createdAt` | datetime | Appwrite auto-generated |

### Storage Buckets

| Bucket | Contents | Access |
|---|---|---|
| `product-images` | Original + bg-removed product photos | Team members only |
| `product-videos` | Optional product videos | Team members only |

Files are uploaded directly from the Flutter client using the Appwrite Flutter SDK (chunked upload for files >5MB). The `tag-product` and `remove-background` functions read from these buckets server-side.

### Appwrite Functions

Implements `prd.md > Adding a Product` (AI tagging + background removal).

API keys for external services live **only** as Appwrite Function environment variables. Never in the Flutter client.

#### `tag-product`

- **Runtime:** Node.js 18
- **Trigger:** Called by Flutter client after image upload, passing `file_id`
- **Logic:**
  1. Download image from Appwrite Storage using `file_id`
  2. POST to Ximilar Fashion Tagging API (`https://api.ximilar.com/tagging/fashion/v2/tag`)
  3. Map Ximilar response fields to ProductTags schema
  4. Return `{ garment_type, fabric, color, occasion, age_group }`
- **Env vars:** `XIMILAR_API_KEY`, `APPWRITE_API_KEY`, `APPWRITE_ENDPOINT`, `APPWRITE_PROJECT_ID`
- **Error:** If Ximilar call fails, return empty tags object — Flutter shows editable empty chips, user fills in manually

#### `remove-background`

- **Runtime:** Node.js 18
- **Trigger:** Called by Flutter client when user opts in, passing `file_id`
- **Logic:**
  1. Download image from Appwrite Storage using `file_id`
  2. POST image to Remove.bg API (`https://api.remove.bg/v1.0/removebg`)
  3. Upload result PNG back to `product-images` bucket
  4. Return `{ new_file_id }`
- **Env vars:** `REMOVEBG_API_KEY`, `APPWRITE_API_KEY`, `APPWRITE_ENDPOINT`, `APPWRITE_PROJECT_ID`
- **Error:** If Remove.bg fails, return `{ error: "bg_removal_failed" }` — Flutter shows error message, user can skip or retry

---

## Feature Screens

### Home Screen

Implements `prd.md > Catalog Home`.

- Grid of `CategoryTile` widgets (Sarees, Salwars, Modern, Kids) — thumbnail from most recent product + count
- Collection tiles rendered alongside category tiles (same grid, different tap handler)
- Empty state shown when no products exist
- Persistent `SearchBarWidget` at top with mic icon
- FAB (floating action button) → `/upload/pick`
- `ShareTrayBar` overlay at bottom (when tray has items)

### Category Screen / Collection Screen

Implements `prd.md > Browsing and Product Detail`.

- Reuses same `ProductGrid` component — different data source (category filter vs collection's `product_ids[]`)
- Each `ProductCard` shows: primary image, description, `StockIndicator`, pending-bg badge if `bg_removal_status == "pending"`
- Quick-add icon on each card → adds to `shareTrayProvider` without navigating away
- Tapping card body → `/product/:id`

### Product Detail Screen

Implements `prd.md > Browsing and Product Detail`.

- Swipeable `PageView` of all images (`image_ids[]`)
- Image selector row — tap to set active image for sharing
- Full metadata: tags (read-only chips), price, `StockIndicator`, description, `uploaded_by` name, created date
- Actions: **Add to Share Tray**, **Add to Collection**, **Edit**
- Edit → `/product/:id/edit` (same TagReview form, pre-populated)

### Upload Flow

Implements `prd.md > Adding a Product`.

Three-screen modal stack pushed on top of the main navigator:

**PickScreen (`/upload/pick`)**
- `image_picker` multi-select from gallery
- Optional in-app camera capture
- Horizontal thumbnail scroll with remove-X on each
- "Done" → `/upload/bg-removal`
- "Upload Next" (after save) → returns to PickScreen, clears state

**BgRemovalScreen (`/upload/bg-removal`)**
- Opt-in screen — default action is "Skip"
- "Remove Background" button → calls `remove-background` Appwrite Function
- Progress indicator while processing
- Shows before/after comparison for review
- "Approve" → updates `upload_provider` with `new_file_id`; `bg_removal_status = "done"`
- "Reject" / "Skip" → keeps original; `bg_removal_status = "none"`
- → `/upload/tags`

**TagReviewScreen (`/upload/tags`)**
- Triggers `tag-product` function call on mount using primary image
- Progress bar while Ximilar processes
- Tags rendered as `TagChip` widgets — individually editable, deletable
- "Accept All" shortcut button
- "Add tag" input for tags AI missed
- `garment_type` chip cannot be left empty (inline validation)
- Price field (number input, optional)
- `StockIndicator` toggle (In / Out, default In)
- "Save Product" → writes to Appwrite DB → pops upload stack → catalog refreshes

### Share Tray

Implements `prd.md > Share Tray`.

**ShareTrayBar** (persistent overlay):
- Renders when `shareTrayProvider.state.length > 0`
- Shows product thumbnails left-to-right + item count + "Share" button
- Tap anywhere on tray → expands to `ShareTrayExpanded`

**ShareTrayExpanded** (bottom sheet):
- Full list of selected products
- Each row: selected image thumbnail + editable one-line description field
- Remove individual items
- **Share** → builds share package (images + descriptions, no prices) → `share_plus` system share sheet → WhatsApp, Instagram DM, etc.
- After share: "Clear Tray" option
- **Save as Collection** → bottom sheet input for collection name → writes new collection doc to Appwrite → appears on HomeScreen

### Search

Implements `prd.md > Catalog Home` (search stories).

- `SearchBarWidget` calls Appwrite Database query on text change (debounced 300ms)
- Query strategy: Appwrite full-text search across `description` + structured filter on `tags.garment_type`, `tags.color`, `tags.fabric`, `tags.occasion`
- Voice input via `speech_to_text` → transcribed text populates search bar → same query path
- From HomeScreen: results grouped by category (`"Sarees (3), Salwars (1)"`)
- From CategoryScreen: results filtered to that category only
- Empty state shown when no results (not a blank screen)

---

## Data Model

### ProductTags — Ximilar Response Mapping

Ximilar returns a rich response. We extract and map only these fields:

```
Ximilar field              → ProductTags field
─────────────────────────────────────────────
category.name              → garment_type
fabric.name                → fabric
dominant_color.name        → color
occasions[0].name          → occasion
age_group.name             → age_group
```

Unmapped Ximilar fields are discarded. If a field is missing from the response, the corresponding ProductTag field is left null (shown as an empty editable chip).

### Share Output Format

When sharing, the Flutter client builds the payload:

```
For each product in share tray:
  - image: selected image file (downloaded from Appwrite Storage)
  - text: editable one-line description (from ShareTrayExpanded)

Explicitly excluded: price, stock_status, uploaded_by, tags
```

`share_plus` passes images + text to the system share sheet.

---

## File Structure

```
sithara/
├── lib/
│   ├── main.dart                         → entry point, ProviderScope
│   ├── app.dart                          → MaterialApp.router, theme setup
│   ├── router.dart                       → go_router route definitions
│   │
│   ├── core/
│   │   ├── appwrite/
│   │   │   ├── appwrite_client.dart      → Appwrite SDK singleton init
│   │   │   └── constants.dart            → endpoint, project ID, collection IDs, bucket IDs
│   │   ├── theme/
│   │   │   └── app_theme.dart            → Material 3 theme, colors, typography
│   │   └── utils/
│   │       └── share_utils.dart          → builds share package from tray items
│   │
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   └── auth_repository.dart  → Appwrite Auth wrapper (login, logout, invite)
│   │   │   ├── providers/
│   │   │   │   └── auth_provider.dart    → AsyncNotifier<User?>
│   │   │   └── screens/
│   │   │       ├── login_screen.dart
│   │   │       └── invite_screen.dart    → deep link /invite/:token handler
│   │   │
│   │   ├── catalog/
│   │   │   ├── data/
│   │   │   │   ├── product_repository.dart      → Appwrite DB CRUD for products
│   │   │   │   └── collection_repository.dart   → Appwrite DB CRUD for collections
│   │   │   ├── models/
│   │   │   │   ├── product.dart                 → Product data class + fromJson/toJson
│   │   │   │   ├── product_tags.dart             → ProductTags + fromXimilarResponse()
│   │   │   │   └── collection.dart              → Collection data class
│   │   │   ├── providers/
│   │   │   │   ├── product_provider.dart         → productListProvider(categoryId)
│   │   │   │   └── collection_provider.dart      → collectionListProvider
│   │   │   └── screens/
│   │   │       ├── home_screen.dart              → category + collection tiles grid
│   │   │       ├── category_screen.dart          → product grid, category-filtered
│   │   │       ├── collection_screen.dart        → product grid, collection-filtered
│   │   │       └── product_detail_screen.dart    → swipeable gallery + metadata + actions
│   │   │
│   │   ├── upload/
│   │   │   ├── data/
│   │   │   │   ├── storage_repository.dart       → Appwrite Storage upload (chunked)
│   │   │   │   ├── ximilar_service.dart          → calls tag-product Appwrite Function
│   │   │   │   └── bg_removal_service.dart       → calls remove-background Appwrite Function
│   │   │   ├── models/
│   │   │   │   └── upload_state.dart             → UploadState (files, bg status, tags draft)
│   │   │   ├── providers/
│   │   │   │   └── upload_provider.dart          → Notifier<UploadState> (upload flow state machine)
│   │   │   └── screens/
│   │   │       ├── pick_screen.dart              → multi-photo gallery picker
│   │   │       ├── bg_removal_screen.dart        → opt-in Remove.bg step
│   │   │       └── tag_review_screen.dart        → tag chips + price + stock + save
│   │   │
│   │   ├── share_tray/
│   │   │   ├── models/
│   │   │   │   └── share_item.dart               → product snapshot for tray
│   │   │   ├── providers/
│   │   │   │   └── share_tray_provider.dart      → Notifier<List<ShareItem>> (global)
│   │   │   └── widgets/
│   │   │       ├── share_tray_bar.dart           → floating bottom bar overlay
│   │   │       └── share_tray_expanded.dart      → full list + share + save as collection
│   │   │
│   │   └── search/
│   │       ├── models/
│   │       │   └── search_results.dart           → SearchResults (grouped by category)
│   │       ├── providers/
│   │       │   └── search_provider.dart          → searchProvider(query, categoryId?)
│   │       └── widgets/
│   │           ├── search_bar_widget.dart        → persistent search bar + mic icon
│   │           └── search_results_widget.dart    → result cards grouped by category
│   │
│   └── shared/
│       └── widgets/
│           ├── product_card.dart                 → image + description + stock + quick-add
│           ├── category_tile.dart                → thumbnail + label + count
│           ├── stock_indicator.dart              → green/red dot widget
│           └── tag_chip.dart                     → editable/deletable chip
│
├── appwrite_functions/
│   ├── tag-product/
│   │   ├── src/
│   │   │   └── main.js                           → downloads image, calls Ximilar, returns tags
│   │   └── package.json
│   └── remove-background/
│       ├── src/
│       │   └── main.js                           → downloads image, calls Remove.bg, re-uploads result
│       └── package.json
│
├── docs/                                         → hackathon artifacts (scope, prd, spec, checklist)
├── process-notes.md
├── pubspec.yaml
└── .env                                          → APPWRITE_ENDPOINT, APPWRITE_PROJECT_ID (local dev)
```

---

## Key Technical Decisions

**1. Appwrite Functions as API proxy (not direct client calls)**
External API keys (Ximilar, Remove.bg) live only as Appwrite Function environment variables. The Flutter client calls Appwrite Functions, which call external APIs server-side. Tradeoff: adds one network hop and requires deploying/maintaining two Functions. Accepted because: keys in a Flutter binary are extractable and could result in API cost theft.

**2. Share tray as a Riverpod global notifier outside the router**
The share tray must survive screen transitions — implemented as a persistent overlay above `MaterialApp.router` driven by `shareTrayProvider`. Tradeoff: slightly more complex app scaffold. Accepted because: routing the tray as a screen would break the "keep browsing while building a selection" UX pattern central to the PRD.

**3. Tags as a structured object, not a flat string array**
ProductTags is a typed object with named fields rather than `tags: ["red", "saree", "cotton"]`. Tradeoff: less flexible if Ximilar adds new tag dimensions. Accepted because: structured tags enable precise search filtering ("color=red AND garment_type=saree"), and map cleanly onto Ximilar's response schema with a `fromXimilarResponse()` factory method.

**4. Stock status binary (in / out), default in**
Three-state model (in/out/not-set) was considered but rejected. Default is always "in stock" — owner explicitly marks out of stock. Tradeoff: no "unknown" state. Accepted because: simpler UI, faster to add products, matches the boutique's real workflow (everything she photographs is available).

---

## Dependencies & External Services

| Service | Purpose | Pricing | Docs |
|---|---|---|---|
| Appwrite (self-hosted) | Auth, DB, Storage, Functions | Free (self-hosted) | https://appwrite.io/docs |
| Ximilar Fashion Tagging | AI garment classification | ~$0.003/image, free tier available | https://docs.ximilar.com/fashion/ |
| Remove.bg | Background removal | 50 free credits/month, ~$0.10/image after | https://www.remove.bg/api |
| Tailscale | VPN for remote access to Appwrite | Free for personal use | https://tailscale.com/kb/1017/install |
| image_picker (Flutter) | Gallery + camera access | Free, pub.dev | https://pub.dev/packages/image_picker |
| speech_to_text (Flutter) | Voice search input | Free, pub.dev | https://pub.dev/packages/speech_to_text |
| share_plus (Flutter) | System share sheet | Free, pub.dev | https://pub.dev/packages/share_plus |

**API keys needed at build time:**
- `XIMILAR_API_KEY` — set as Appwrite Function env var
- `REMOVEBG_API_KEY` — set as Appwrite Function env var
- `APPWRITE_ENDPOINT` — Appwrite server URL (in `.env` for local dev, hardcoded for release build)
- `APPWRITE_PROJECT_ID` — from Appwrite console

---

## Open Issues

**Search depth:** Appwrite's built-in full-text search covers string fields. Tags are a nested object — Appwrite supports querying nested fields but full-text across nested strings may need flattening at write time (e.g., also write `search_text: "red cotton saree festive women"` as a denormalized string field on the product). Worth testing early in `/build`.

**Remove.bg image size limit:** Remove.bg free tier has a 10MB file size limit. Product photos from modern iPhones can exceed this. May need to compress images before calling the API (use Flutter's `image` package to resize to max 4MP before upload to Remove.bg function).

**Ximilar response schema:** The field mapping in this spec (`category.name → garment_type`) is based on Ximilar documentation. Verify actual response shape with a test call early in `/build` before building the `fromXimilarResponse()` factory.

**Invite link deep linking on Android:** go_router deep links require Android app link / intent filter configuration in `AndroidManifest.xml`. This is a one-time setup step but easy to miss — flag for early `/build` testing.

**Video support scope:** The PRD includes optional video per product. Video upload and playback add complexity (chunked upload, video player widget). If time is tight during `/build`, video can be deferred — the data model supports it but the UI can show images only in v1.
