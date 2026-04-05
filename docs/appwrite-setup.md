# Appwrite Console Setup Guide — Sithara

This guide walks through creating the Appwrite database, collections, and storage buckets for the Sithara app. After completing these steps, no code changes are needed — the IDs used below match exactly what is already hardcoded in `lib/core/appwrite/constants.dart`.

---

## Prerequisites

- Appwrite instance running and accessible (self-hosted or Appwrite Cloud)
- You are logged in as a project Owner
- The Sithara project already exists in Appwrite

---

## Step 1 — Create the Database

1. Open the Appwrite Console and navigate to your project.
2. Click **Databases** in the left sidebar.
3. Click **Create Database**.
4. Set **Database ID** to: `sithara-db`
5. Set **Name** to: `Sithara DB`
6. Click **Create**.

---

## Step 2 — Create the `products` Collection

1. Inside `sithara-db`, click **Create Collection**.
2. Set **Collection ID** to: `products`
3. Set **Name** to: `Products`
4. Click **Create**.

### 2a — Set Permissions on `products`

1. Go to the **Settings** tab of the `products` collection.
2. Under **Permissions**, remove any default public permissions.
3. Add a **Team** permission for your team (e.g. `team:sithara-team`):
   - Read: enabled
   - Create: enabled
   - Update: enabled
   - Delete: enabled
4. Save.

### 2b — Add Attributes to `products`

Click the **Attributes** tab, then **Create Attribute** for each of the following:

| Attribute Key      | Type         | Size / Note              | Required |
|--------------------|--------------|--------------------------|----------|
| `description`      | String       | 2000 chars               | No       |
| `image_ids`        | String[]     | Array, 36 chars each     | Yes      |
| `primary_image_id` | String       | 36 chars                 | Yes      |
| `video_id`         | String       | 36 chars                 | No       |
| `tags`             | String       | 1000 chars (JSON string) | Yes      |
| `price`            | Float        |                          | No       |
| `stock_status`     | Enum         | Values: `in`, `out`      | Yes      |
| `bg_removal_status`| Enum         | Values: `none`, `pending`, `done` | Yes |
| `category`         | Enum         | Values: `sarees`, `salwars`, `modern`, `kids` | Yes |
| `uploaded_by`      | String       | 36 chars (user ID)       | Yes      |
| `search_text`      | String       | 4000 chars               | No       |

> **Note on `tags`**: Appwrite does not support nested objects natively. Store the `ProductTags` object as a JSON string (`jsonEncode(tags.toJson())`). The Dart `ProductTags.fromJson` method handles decoding.

### 2c — Create Indexes on `products`

Go to the **Indexes** tab and create:

| Index Key        | Type     | Attributes            | Orders |
|------------------|----------|-----------------------|--------|
| `category_idx`   | Key      | `category`            | ASC    |
| `stock_idx`      | Key      | `stock_status`        | ASC    |
| `uploaded_by_idx`| Key      | `uploaded_by`         | ASC    |
| `search_idx`     | Fulltext | `search_text`         | —      |

---

## Step 3 — Create the `collections` Collection

1. Inside `sithara-db`, click **Create Collection**.
2. Set **Collection ID** to: `collections`
3. Set **Name** to: `Collections`
4. Click **Create**.

### 3a — Set Permissions on `collections`

Same as `products`: Team members only with full CRUD access.

### 3b — Add Attributes to `collections`

| Attribute Key  | Type     | Size / Note          | Required |
|----------------|----------|----------------------|----------|
| `name`         | String   | 200 chars            | Yes      |
| `description`  | String   | 1000 chars           | No       |
| `product_ids`  | String[] | Array, 36 chars each | Yes      |
| `created_by`   | String   | 36 chars (user ID)   | Yes      |

### 3c — Create Indexes on `collections`

| Index Key        | Type | Attributes   | Orders |
|------------------|------|--------------|--------|
| `created_by_idx` | Key  | `created_by` | ASC    |

---

## Step 4 — Create Storage Bucket: `product-images`

1. Click **Storage** in the left sidebar.
2. Click **Create Bucket**.
3. Set **Bucket ID** to: `product-images`
4. Set **Name** to: `Product Images`
5. Under **Permissions**: Team members only (same as collections above).
6. Under **File Security**: Enable (so individual file permissions can be set).
7. **Allowed File Extensions**: `jpg`, `jpeg`, `png`, `webp`
8. **Maximum File Size**: `10485760` (10 MB)
9. Click **Create**.

---

## Step 5 — Create Storage Bucket: `product-videos`

1. Click **Create Bucket** again.
2. Set **Bucket ID** to: `product-videos`
3. Set **Name** to: `Product Videos`
4. Under **Permissions**: Team members only.
5. Under **File Security**: Enable.
6. **Allowed File Extensions**: `mp4`, `mov`
7. **Maximum File Size**: `104857600` (100 MB)
8. Click **Create**.

---

## Step 6 — Update Constants (if IDs differ)

If you used different IDs than specified above, update `lib/core/appwrite/constants.dart`:

```dart
class AppwriteConstants {
  static const String databaseId = 'sithara-db';           // your DB ID
  static const String productsCollectionId = 'products';   // your collection ID
  static const String collectionsCollectionId = 'collections';
  static const String productImagesBucketId = 'product-images';
  static const String productVideosBucketId = 'product-videos';
  static const String tagProductFunctionId = 'tag-product';
  static const String removeBackgroundFunctionId = 'remove-background';
}
```

---

## Appwrite CLI Alternative

If you prefer the CLI over the web console, install the [Appwrite CLI](https://appwrite.io/docs/tooling/command-line/installation) and run:

```bash
# Login and select your project
appwrite login
appwrite client --project-id YOUR_PROJECT_ID

# Create the database
appwrite databases create \
  --database-id sithara-db \
  --name "Sithara DB"

# Create products collection
appwrite databases createCollection \
  --database-id sithara-db \
  --collection-id products \
  --name "Products" \
  --document-security true

# Add attributes to products
appwrite databases createStringAttribute \
  --database-id sithara-db --collection-id products \
  --key description --size 2000 --required false

appwrite databases createStringAttribute \
  --database-id sithara-db --collection-id products \
  --key primary_image_id --size 36 --required true

appwrite databases createStringAttribute \
  --database-id sithara-db --collection-id products \
  --key video_id --size 36 --required false

appwrite databases createStringAttribute \
  --database-id sithara-db --collection-id products \
  --key tags --size 1000 --required true

appwrite databases createFloatAttribute \
  --database-id sithara-db --collection-id products \
  --key price --required false

appwrite databases createEnumAttribute \
  --database-id sithara-db --collection-id products \
  --key stock_status --elements '["in","out"]' --required true --default in

appwrite databases createEnumAttribute \
  --database-id sithara-db --collection-id products \
  --key bg_removal_status --elements '["none","pending","done"]' --required true --default none

appwrite databases createEnumAttribute \
  --database-id sithara-db --collection-id products \
  --key category --elements '["sarees","salwars","modern","kids"]' --required true

appwrite databases createStringAttribute \
  --database-id sithara-db --collection-id products \
  --key uploaded_by --size 36 --required true

appwrite databases createStringAttribute \
  --database-id sithara-db --collection-id products \
  --key search_text --size 4000 --required false

# Note: array attributes (image_ids, product_ids) require --array true flag
appwrite databases createStringAttribute \
  --database-id sithara-db --collection-id products \
  --key image_ids --size 36 --required true --array true

# Create indexes for products
appwrite databases createIndex \
  --database-id sithara-db --collection-id products \
  --key category_idx --type key --attributes '["category"]'

appwrite databases createIndex \
  --database-id sithara-db --collection-id products \
  --key stock_idx --type key --attributes '["stock_status"]'

appwrite databases createIndex \
  --database-id sithara-db --collection-id products \
  --key uploaded_by_idx --type key --attributes '["uploaded_by"]'

appwrite databases createIndex \
  --database-id sithara-db --collection-id products \
  --key search_idx --type fulltext --attributes '["search_text"]'

# Create collections collection
appwrite databases createCollection \
  --database-id sithara-db \
  --collection-id collections \
  --name "Collections" \
  --document-security true

# Add attributes to collections
appwrite databases createStringAttribute \
  --database-id sithara-db --collection-id collections \
  --key name --size 200 --required true

appwrite databases createStringAttribute \
  --database-id sithara-db --collection-id collections \
  --key description --size 1000 --required false

appwrite databases createStringAttribute \
  --database-id sithara-db --collection-id collections \
  --key product_ids --size 36 --required true --array true

appwrite databases createStringAttribute \
  --database-id sithara-db --collection-id collections \
  --key created_by --size 36 --required true

appwrite databases createIndex \
  --database-id sithara-db --collection-id collections \
  --key created_by_idx --type key --attributes '["created_by"]'

# Create storage buckets
appwrite storage createBucket \
  --bucket-id product-images \
  --name "Product Images" \
  --file-security true \
  --allowed-file-extensions '["jpg","jpeg","png","webp"]' \
  --maximum-file-size 10485760

appwrite storage createBucket \
  --bucket-id product-videos \
  --name "Product Videos" \
  --file-security true \
  --allowed-file-extensions '["mp4","mov"]' \
  --maximum-file-size 104857600
```

> **Permissions via CLI**: After creating collections and buckets, set team permissions using:
> ```bash
> appwrite databases updateCollection \
>   --database-id sithara-db \
>   --collection-id products \
>   --permissions 'read("team:YOUR_TEAM_ID")' 'create("team:YOUR_TEAM_ID")' \
>                 'update("team:YOUR_TEAM_ID")' 'delete("team:YOUR_TEAM_ID")'
> ```
> Replace `YOUR_TEAM_ID` with the actual team ID from the Appwrite console (Members > Teams).
