Title Slide
- Full Name: [Your Name]
- Email: [you@example.com]
- Phone: [XXX-XXX-XXXX]
- Role: DigiVir - Flutter Mobile App Developer

Slide 2 — Demo Walkthrough (embed video)
- Embedded 2–3 minute demo (Loom / Google Drive) — place link here
- Show app running the 3 test cases: Valid Submission, Missing Lineage, Fail-Closed

Slide 3 — Project Summary
- Purpose: Verify stateless UI, fail-closed security, and lineage headers
- Outcome: Stateless component + API gates + friction logging

Slide 4 — Byt Boundary & Stateless Paradigm
- Explain separation: UI stateless widgets, controller holds logic
- Files: `lib/features/verification/*` and `lib/core/utils/*`

Slide 5 — Submission Flow
- Form -> Controller -> ApiService
- Gates: Field compliance (Gate1), Predecessor lineage (Gate2), Response (Gate3)

Slide 6 — Metadata Headers
- `trace_id` (UUID v4), `logic_hash` (SHA-256 of payload), `predecessor_id`
- Location: `lib/core/utils/metadata_helper.dart`

Slide 7 — Fail-Closed Enforcement
- Description: any gate failure quarantines payload and halts movement
- Example messages and UI banner mapping

Slide 8 — UI Friction Tracking
- 5-second stall detection on Full Name field
- Files: `lib/core/utils/friction_logger.dart`, UI integration in controller/screen

Slide 9 — Test Cases & Results
- Case 1: Valid Submission — shows trace_id/log update
- Case 2: Missing Lineage — Gate 2 fail-closed
- Case 3: Fail-Closed Error State — missing fields

Slide 10 — Code Boundaries & Reuse
- Stateless widgets: SubmitButton, ValidationBanner, FormFieldTile
- Controller: `VerificationController` (single source of truth)

Slide 11 — How to Run Locally
- Commands (in repo root):
  - `flutter pub get`
  - `flutter run` (or use `dart run tool/demo_runner.dart` for headless demo)

Slide 12 — Demo Recording Instructions
- Use Loom or system screen recorder
- Start from home screen, run the three cases, narrate briefly
- Embed shareable link on Slide 2

Slide 13 — Attachments & Repo
- Repo link: [PUBLIC_REPO_URL]
- Slide deck link: [GOOGLE_SLIDES_LINK]

Slide 14 — Notes & Assumptions
- Demo runner uses httpbin.org with resilient fallback for offline demos
- `MetadataHelper.forceInvalidPredecessorForDemo` is a demo-only flag

Slide 15 — Contact / Q&A
- Your name and contact details
- Thanks
