# Sithara — Product Requirements

## Problem Statement

A solo boutique owner manages hundreds of product photos entirely on her iPhone gallery, with all inventory knowledge in her head. Every time a customer asks "show me red cotton sarees under ₹2000," she manually digs through photos — a slow, error-prone process that doesn't scale. Sithara replaces that workflow with a private, searchable product catalog that trusted contributors can build together, and the owner can query and share from in under 30 seconds.

---

## User Stories

### Epic: Catalog Home

- As a boutique owner, I want to see all my products organized by category on the home screen so that I can browse my inventory at a glance.
  - [ ] Home screen displays category tiles (Sarees, Salwars, Modern, Kids) and any created collections in a grid
  - [ ] Each category tile shows a thumbnail from the most recently added product and a product count
  - [ ] Collection tiles are displayed alongside category tiles on the home screen
  - [ ] If no products have been added yet, the home screen shows a clear empty state with a prompt to add the first product

- As a boutique owner, I want a persistent search bar with voice input so that I can find products by speaking naturally while I'm with a customer.
  - [ ] Search bar is visible and accessible from the home screen and within category views
  - [ ] A microphone icon in the search bar lets her speak a query
  - [ ] Searching from the home screen returns results grouped by category (e.g., "Sarees (3), Salwars (1)")
  - [ ] Searching from within a category filters results within that category only
  - [ ] Results are displayed as product cards (image + description) sorted by relevance
  - [ ] If search returns no results, an appropriate empty state is shown (not a blank screen)

### Epic: Adding a Product

- As a contributor, I want to upload multiple photos and an optional video for a single product so that the catalog captures the full look.
  - [ ] Tapping the Add button opens a product creation flow
  - [ ] She can pick multiple photos and an optional video from the device gallery
  - [ ] An optional in-app camera is available if gallery picker isn't sufficient
  - [ ] Photos are shown as a horizontal scroll of thumbnails with ability to remove individual ones before proceeding
  - [ ] A "Done" button completes the upload for that product; an "Upload Next" option immediately starts a new product without returning to home

- As a contributor, I want background removal to be available as an opt-in step so that product photos can be cleaned up without being forced through the process every time.
  - [ ] During the upload flow, she is offered an optional "Remove Background" action
  - [ ] If selected, a progress indicator is shown while the API processes the image
  - [ ] She must review and approve the background-removed result before it is saved
  - [ ] If background removal has not been reviewed, the product displays a "Background Pending Review" visual indicator in the catalog
  - [ ] She can skip background removal entirely — the product saves with the original photo

- As a contributor, I want AI to suggest product tags and for me to review them so that tagging is fast but I stay in control.
  - [ ] After photos are selected, AI tagging runs automatically and a progress bar is shown
  - [ ] AI suggests: garment type, fabric, color, occasion, age group
  - [ ] She sees an "Accept All" button to take AI suggestions as-is
  - [ ] Each tag is individually editable — she can tap any tag to change it or delete it
  - [ ] She can add tags the AI missed
  - [ ] Tags cannot be saved as completely empty — at least garment type must be set
  - [ ] The upload attribution is captured automatically (who added the product, from their login)

- As a contributor, I want to optionally add price and stock status on the same screen as tag confirmation so that I can capture private inventory data without an extra step.
  - [ ] Price field and stock status are on the tag confirmation screen (not a separate step)
  - [ ] Stock status is shown as a color indicator (green = in stock, red = out of stock, grey = not set)
  - [ ] Price field is optional — products can be saved without a price
  - [ ] Price and stock status are never visible in shared output sent to customers

### Epic: Browsing and Product Detail

- As a boutique owner, I want to browse products within a category and quickly add them to a share tray without opening each one so that I can build a customer selection fast.
  - [ ] Tapping a category tile opens a grid of product cards for that category
  - [ ] Each product card shows the primary product image, a short description, and stock color indicator
  - [ ] A quick-add action on each card adds the product to the share tray without navigating to the detail screen
  - [ ] Products with pending background review show a visual badge on their card

- As a boutique owner, I want to open a product and see all its photo variations so that I can pick the best image to share with a customer.
  - [ ] Tapping a product opens a detail screen with a swipeable photo gallery
  - [ ] She can select which photo variation to use when sharing
  - [ ] Full metadata is visible: tags, price, stock color indicator, description, upload attribution
  - [ ] "Add to Share Tray" and "Add to Collection" actions are available from the detail screen
  - [ ] She can edit product details (tags, price, stock, description) from the detail screen

### Epic: Share Tray

- As a boutique owner, I want a persistent floating share tray so that I can keep adding products while browsing and share everything at once when I'm ready.
  - [ ] A floating tray is visible at the bottom of the screen whenever it has at least one item
  - [ ] As products are added, their thumbnails fill in along the bottom
  - [ ] Tapping the tray expands it to a full list view of selected products
  - [ ] In the expanded view, each product shows its selected image and an editable one-line description
  - [ ] A "Share" button triggers the system share sheet (WhatsApp, Instagram DM, etc.)
  - [ ] After sharing, she has the option to clear the tray
  - [ ] She can remove individual items from the tray in the expanded view

- As a boutique owner, I want to save my share tray as a collection so that a good customer selection becomes reusable.
  - [ ] In the expanded tray view, a "Save as Collection" option is available
  - [ ] Tapping it prompts for a collection name
  - [ ] The collection appears on the home screen alongside category tiles

### Epic: Collections

- As a boutique owner, I want to create named collections so that I can organize products around themes, occasions, or campaigns.
  - [ ] A "New Collection" action is available from the home screen
  - [ ] She names the collection and optionally adds a description
  - [ ] The collection appears on the home screen as a tile alongside categories
  - [ ] Tapping a collection tile opens it as a browsable grid of its products

- As a boutique owner, I want to add a product to a collection while browsing so that I can build collections without interrupting my workflow.
  - [ ] From a product detail screen, an "Add to Collection" action is available
  - [ ] Tapping it shows a list of existing collections with a search
  - [ ] She selects one and the product is added
  - [ ] A product can belong to multiple collections

### Epic: Contributor Access

- As a contributor, I want to log in with my own account so that my uploads are tracked and the catalog shows who added each product.
  - [ ] Each contributor has their own login (separate credentials, not a shared passcode)
  - [ ] All contributors have the same access level — no role hierarchy in v1
  - [ ] Every product records the contributor who uploaded it, visible in the product detail
  - [ ] The owner can invite contributors (invite link or simple code — exact mechanism TBD in /spec)

---

## What We're Building

Everything the app must do for a complete, submittable v1:

1. **Home screen** — category tiles + collection tiles in a grid, product counts on each tile, persistent search bar with voice input, Add button, floating share tray
2. **Context-aware search** — searches within current category or across all categories from home; results as product cards sorted by relevance; empty state when no results
3. **Product upload flow** — gallery picker (+ optional in-app camera), multiple photos + optional video, optional background removal (opt-in, review-gated), AI tagging with progress bar (Accept All or edit per tag), price/stock on tag confirmation screen, upload attribution captured
4. **AI tag confirmation screen** — AI suggestions as editable chips, Accept All shortcut, add/remove tags, price field, stock color indicator, save triggers product to appear in catalog
5. **Background removal review** — opt-in, reviewed before product loses "pending" badge, skippable
6. **Product catalog grid** — products organized by category, product card with image + description + stock indicator + pending badge if applicable, quick-add to share tray from card
7. **Product detail screen** — swipeable photo gallery, select variation, full metadata view, edit product, add to share tray, add to collection
8. **Floating share tray** — persistent bottom tray, fills with thumbnails, expandable list view, editable descriptions, share via system share sheet, save as collection, clear after send
9. **Collections** — create named collections, tile on home screen, add products from detail screen, save share tray as collection
10. **Contributor access** — separate logins, same permissions, upload attribution on every product

---

## What We'd Add With More Time

- **Multi-customer tray sessions** — track what was shared with which customer, with a history of past sessions. Natural next step once the single-tray model is proven.
- **Instagram posting pipeline** — AI captions, hashtag generation, scheduling, and direct posting to Instagram. This is the original Priority 2 idea that motivated the whole app.
- **Background removal manual adjustment** — if the API does a poor job, let her touch up the mask rather than just accept or reject.
- **Automated DM responses** — detect customer messages, pull matching products from catalog, auto-draft a reply. Priority 3 from the original scope.
- **Analytics** — which products are shared most, what categories customers ask for. Useful once data volume builds.
- **Customer-facing catalog** — a shareable read-only link to a filtered collection, no login required for customers.

---

## Non-Goals

- **Instagram posting in this version** — AI captions, hashtag generation, scheduling, and posting are explicitly cut. The catalog is the foundation; the pipeline comes later.
- **Automated DM responses** — no chatbot, no automated customer-facing replies.
- **Role-based access control** — no admin/editor/viewer hierarchy. Same permissions for all contributors. Simple and fast to build.
- **Public storefront or e-commerce** — this is a private tool. No public catalog URL, no checkout, no cart for customers.
- **Price visibility in shared output** — prices are strictly private. They never appear in anything shared to a customer, by design.
- **Complex auth infrastructure** — no OAuth, no email verification flows, no password reset for v1. Invite-link or passcode model to be decided in /spec.

---

## Open Questions

- **Auth mechanism** — invite link, shared passcode, or email+password? Needs to be answered in /spec since it affects the contributor onboarding flow. Leaning toward invite link for simplicity.
- **AI tagging API** — which vision API to use for garment classification? Ximilar was referenced in scope but not confirmed. Needs to be decided in /spec (affects data model and tag schema).
- **Background removal API** — Remove.bg was referenced in scope. Confirm this is the choice or evaluate alternatives in /spec.
- **Search implementation** — full-text search across tags and descriptions. Does this run locally (simple for v1, no infra) or hit a backend query? Can wait until /spec.
- **Cloud storage choice** — Google Drive was mentioned in scope as an option. Needs confirmation in /spec since it affects photo upload and retrieval architecture.
- **Stock status values** — is it binary (in stock / out of stock) or does it include a third state like "low stock"? Green/red/grey implies three states — confirm with Sharat before /spec.
