# Process Notes

## /scope

- **Idea evolution:** Started as a broad Instagram content pipeline (background removal → AI captions → scheduling → analytics → auto-responses). Conversation revealed the real, more urgent pain: no searchable product catalog — everything lives in her iPhone gallery and in her head. Pivoted hard to catalog-first.
- **Pushback received:** Asked to cut scope to one sharp thing for the hackathon. Sharat committed to cutting Instagram posting and automated responses without much resistance — he saw the logic clearly.
- **What resonated:** The Google Photos/Apple Photos album metaphor landed immediately. The collections concept (curated themed groupings like "Ugadi Specials") came from him unprompted — a genuine addition that strengthened the scope.
- **Active shaping:** Sharat drove the direction meaningfully. He surfaced the catalog problem himself (not prompted), named the priority stack (catalog → Instagram pipeline → DM integration), added multi-image/video per product and collections without being asked. Not a passive learner.
- **Deepening rounds:** 1 round. Surfaced: album-style UX, simple photo+one-line sharing, family-style access model, basic background removal integration with manual override, multi-image/video per product, curated collections.
- **References that resonated:** Google Photos/Apple Photos UX model resonated strongly. Ximilar and Wholetex were noted as partially relevant but he hadn't used them — used as directional validation, not deep inspiration.

## /prd

- **Key additions vs scope doc:** Background removal changed from automatic to opt-in per product — important UX shift. Share tray formalized as a persistent floating bottom element (not just a "share" action). New flow: save share tray directly as a collection. Quick-add from catalog grid without entering product detail. Upload attribution (who added each product) added. Separate logins per contributor confirmed (vs. shared passcode mentioned in scope).
- **What surprised him:** The multi-customer tray tracking idea came up naturally and he self-identified it as scope creep before being prompted — good instinct. The "save tray as collection" connection clicked immediately and he added it unprompted.
- **What he pushed back on / felt strongly about:** Background removal should be opt-in, not automatic. He clearly had a mental model from using PhotoRoom manually — forced auto-removal would feel wrong to him.
- **Scope guard moments:** Multi-customer tray history was surfaced and immediately deferred by Sharat himself. No friction needed.
- **Deepening rounds:** 0 rounds chosen. Sharat was confident in the spec after mandatory questions and opted to proceed. The mandatory questions were productive enough — his answers were detailed and he volunteered additions (save-tray-as-collection, opt-in background removal, upload attribution) without needing deeper prompting.
- **Active shaping:** Sharat drove requirements throughout. Notable self-directed additions: opt-in background removal, "Upload Next" flow, save tray as collection, upload attribution, quick-add from grid without entering product detail. He was not a passive answerer — he added real UX thinking at each step.

## /onboard

- **Technical experience:** 20-year backend engineer, knows Swift but no Mac currently. Chose Flutter as workaround. Picks up frontend easily.
- **AI tool experience:** GitHub Copilot, Codex (bug-fixing/autocomplete), recently started Claude Code. Reactive mode user — this is his first proactive/spec-first AI workflow.
- **Learning goals:** Master spec-driven development; build a reusable recipe for bigger projects. Strong meta-learning intent — he wants the process as much as the app.
- **Creative sensibility:** Microsoft/Google aesthetic. Clean, minimal, low click count. Functional-first, no unnecessary UI complexity.
- **Prior SDD experience:** Uses PRDs and user stories professionally. Not new to structured planning — just new to AI-assisted SDD.
- **Energy/engagement:** Focused and practical. Came in with a clear, real-world problem (wife's boutique workflow). Strong personal motivation. Will move fast once the spec is solid.

## /spec

- **Stack decisions:** Flutter + Riverpod + go_router. Appwrite self-hosted on cloud VM (not home server — changed mid-conversation when Sharat confirmed cloud VM availability). Ximilar for AI tagging. Remove.bg for background removal (PhotoRoom as fallback). Invite-link auth.
- **Key open questions resolved:** Stock status confirmed binary (in/out, default in) — rejected 3-state. Auth confirmed as invite link per contributor. Background removal confirmed as Remove.bg.
- **What he was confident about:** Data model shape, file structure, the Riverpod/go_router choices, Appwrite Functions as API proxy pattern. Answered "yes" without friction to all major proposals.
- **What surfaced as genuine uncertainty:** Deployment shifted from home server → cloud VM partway through. He hadn't fully decided this before the conversation.
- **Deepening rounds:** 0 rounds. Sharat chose to write the spec immediately after mandatory questions. Consistent with /prd behavior — confident, moves fast once the big decisions are locked.
- **Active shaping:** Lower than /scope and /prd — most proposals were accepted without modification. The one personal contribution: deployment choice (home server → cloud VM). Architecture proposals were accepted as presented.
- **Open issues flagged for /build:** Search denormalization for Appwrite full-text, Remove.bg 10MB file size limit, Ximilar response schema verification, Android deep link configuration for invite links, video support may need to be deferred.

## /checklist

- **Build mode:** Autonomous — straight through, no verification checkpoints. Sharat is taking a break and wants the agent to work uninterrupted.
- **Verification:** None. No checkpoints between items.
- **Git cadence:** Commit after each checklist item with message `Complete step N: [title]`.
- **Comprehension checks:** N/A (autonomous mode).
- **Check-in cadence:** N/A (autonomous mode).
- **Sequencing logic:** Scaffold → data models + Appwrite infra → auth → home screen → upload/storage → Appwrite Functions → bg removal + tag review + save → category/collection screens → product detail + edit → share tray → search → Devpost. Each step unblocks the next. Sharat identified scaffold, catalog model/object structure, and infra as the critical first block — auth added as an equally critical prerequisite (go_router redirects block all navigation without it).
- **Items:** 12 items, estimated ~4 hours total.
- **Deepening rounds:** 0 rounds. Sharat accepted the proposed sequence and item list without modification. He was focused and wanted to move fast.
- **Active shaping:** Low at this stage — Sharat confirmed scaffold/model/infra priority unprompted (aligned with spec dependencies), accepted autonomous mode recommendation for his experience level, and chose no verification (straight through). No pushback on item order or granularity.
- **Devpost submission:** APK + screenshots. No live deployment. Core story: "A private AI-powered product catalog for boutique owners — AI auto-tags garment type, fabric, color and occasion, owner searches inventory and shares curated selections to customers via WhatsApp or Instagram DM in under 30 seconds." GitHub repo: https://github.com/simplysarath/instagrammer. Note: Sharat initially proposed an Instagram-posting story that included cut features — redirected to the accurate v1 story.
- **Open issues carried into /build:** Search denormalization (handled in step 11 — write `search_text` field at save time), Remove.bg 10MB limit (handled in step 6 — compress with `sharp`), Ximilar response schema verification (step 6), Android deep link config (step 3), video support deferred (data model supports it, UI skips it in v1).
