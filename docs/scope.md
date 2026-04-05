# Sithara — Smart Boutique Catalog

## Idea
A private, searchable product catalog for a small clothing boutique — where anyone in the family can upload photos, AI handles the tagging, and the owner can search and share products to customers in seconds.

## Who It's For
**Primary user:** Sharat's wife — a solo boutique owner selling sarees, salwars, and other ethnic and modern clothing. She currently manages all product photos in her iPhone gallery, carries the entire inventory knowledge in her head, and manually digs through hundreds of photos every time a customer asks for something specific. This app replaces that fragile, unscalable workflow.

**Secondary users:** Sharat and a small circle of trusted contributors who can upload and tag photos on her behalf.

## Inspiration & References
- **Google Photos / Apple Photos** — the album-grid UX: products grouped by major category, browse visually, drill down. Familiar, fast, zero learning curve.
- **Ximilar AI Fashion Tagging** (https://www.ximilar.com/services/fashion-tagging/) — AI that auto-assigns fabric, color, occasion, style from a photo. The model for how auto-classification should work.
- **Wholetex** (https://www.wholetex.com/) — catalog-first, WhatsApp-native approach used by Indian ethnic wear sellers. Validates the catalog → WhatsApp sharing model.

**Design energy:** Clean, minimal, functional-first. Microsoft/Google aesthetic — low click count, intuitive hierarchy, no decorative chrome. This is a tool she'll open many times a day; it needs to feel fast and obvious.

## Goals
- Give the boutique a real, searchable product catalog that lives outside anyone's head
- Allow trusted contributors to add products so the owner isn't the only one who can build the catalog
- Make it possible to respond to a customer query ("show me red cotton sarees under ₹2000") in under 30 seconds
- Support curated collections for occasions and campaigns (e.g., "Ugadi Specials", "Cocktail Party Sarees")
- Keep sensitive data (price, stock status) private — never exposed to customers
- Create the foundation that an Instagram posting pipeline can be built on later

## What "Done" Looks Like
After 3-4 hours of building:
- A Flutter app where a contributor can upload a product photo (or multiple photos + a video for one product)
- Background removal runs automatically on upload (basic integration, with manual override)
- AI suggests tags: garment type, fabric, color, occasion, age group — human confirms or edits
- Optional private fields: price, stock status
- Catalog home screen shows product albums grouped by major category (sarees, salwars, modern, kids)
- Search/filter works across tags — find "red cotton saree for women" from anywhere in the catalog
- Collections: owner can create named collections (e.g., "Ugadi Specials") by selecting products
- Share: select 1 or more products → share photos + single-line description to WhatsApp or Instagram DM
- Family-style access — a small group of trusted people can contribute without a complex auth system

## What's Explicitly Cut
- **Instagram posting pipeline** — AI captions, hashtag generation, scheduling, posting. This is Priority 2. Not in this version.
- **Automated Instagram/DM responses** — Priority 3. Not in this version.
- **Analytics** — what posts are performing, engagement tracking. Not in this version.
- **Customer-facing catalog / e-commerce** — no public storefront, no checkout, no cart. This stays private.
- **Price visibility to customers** — prices are private by design. Intentional — creates curiosity, drives DMs.
- **Complex role-based access** — no admin/editor/viewer hierarchy. Simple shared family access only.

## Loose Implementation Notes
- **Platform:** Flutter (cross-platform, Windows dev → iOS target later)
- **Storage:** Cloud backend (Google Drive or equivalent) — gets photos off the iPhone and into a searchable store
- **AI classification:** Call an AI/vision API on upload to suggest tags. Human reviews and confirms before saving. Non-blocking — she can skip confirmation and go with AI defaults.
- **Background removal:** Integrate a basic background removal API (e.g., Remove.bg) in the upload flow, with ability to skip or manually adjust.
- **Data model:** Product has multiple images + optional video, confirmed tags, optional private fields (price, stock). Collections are manually curated lists of products with a name and optional description.
- **Share flow:** Select products → generates a shareable package (images + one-line descriptions) → system share sheet to WhatsApp / Instagram DM.
- **Auth:** Simple shared passcode or invite-link model for family contributors. No full user account system needed for v1.
