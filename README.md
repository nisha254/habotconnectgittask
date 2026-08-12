# DigiVir — LSA Profile Verification App

> **HabotConnect Flutter Mobile Developer Hiring Project**
> Built to the "Byt Boundary Standard" — strict state separation, Fail-Closed security, and metadata lineage tracking.

---

## Project Overview

**DigiVir** is a Flutter mobile app that implements an **LSA (Learning Support Assistant) Profile Verification Screen**. It is built as a real-world, production-grade engineering submission for the HabotConnect / DigiVir hiring process.

The app demonstrates:

- **Byt Boundary Architecture** — modular, atomic, stateless Flutter components
- **Fail-Closed Security** — multi-gate outbound API governance
- **Metadata Lineage Tracking** — cryptographic session chaining via SHA-256
- **UI Friction Monitoring** — real-time 5-second stall detection with visual feedback

---

## Architecture — "Byt Boundary Standard"

All business logic is **completely separated** from UI. The widget tree is purely declarative and reactive.

```
UI Layer (StatelessWidgets)
        │
        │  ListenableBuilder (reactive rebuild)
        ▼
VerificationController (ChangeNotifier)
        │
        ├── Validators (pure functions, no side effects)
        ├── MetadataHelper (SHA-256, UUID v4, lineage chain)
        ├── FrictionLogger (5-second stall timer)
        └── ApiService (HTTP POST + 3-Gate Fail-Closed)
```

**Rules:**

- No `setState()` in widgets — all state in `VerificationController`
- No business logic in widgets — widgets receive data, they don't compute it
- All validators are pure functions (safe for unit testing with zero mocks)

---

## 📁 Project Structure

```
lib/
├── main.dart                                   # Entry point, system UI config
├── app/
│   └── app.dart                                # MaterialApp, Material 3 theme
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                     # All color tokens (Design System)
│   │   └── app_strings.dart                    # All UI strings & dropdown values
│   ├── models/
│   │   └── form_payload.dart                   # Null-safe data model, hasNullOrEmpty gate
│   └── utils/
│       ├── validators.dart                     # Gate 1, 2, 3 pure validation logic
│       ├── metadata_helper.dart                # UUID v4, SHA-256, predecessor chain
│       └── friction_logger.dart                # Timer-based UI stall detection
│
├── features/
│   └── verification/
│       ├── verification_controller.dart        # ChangeNotifier — 6 states, all logic
│       ├── verification_screen.dart            # Reactive screen — zero logic
│       └── widgets/
│           ├── profile_header.dart             # Gradient app header
│           ├── form_field_tile.dart            # Input field + lineage badge + friction badge
│           ├── submit_button.dart              # Multi-state adaptive button
│           └── validation_banner.dart          # Success / Fail-Closed / Network banners
│
└── services/
    └── api_service.dart                        # HTTP POST + Gate 1 → Gate 2 → Gate 3

test/
├── validators_test.dart                        # 44 unit tests (3 required scenarios)
└── widget_test.dart                            # 2 widget tests
```

---

## 🔐 Fail-Closed Security Architecture

The app enforces a **3-Gate security model**. No data ever reaches the server unless all gates pass. Default action is always **HALT & QUARANTINE**.

```
User taps Submit
      │
      ▼
┌─────────────────────────────────────┐
│  Gate 1 — Field Compliance          │  hasNullOrEmpty == true ?
│  (Pre-HTTP)                         │  → HALT. Payload quarantined.
└──────────────┬──────────────────────┘
               │ PASS
               ▼
┌─────────────────────────────────────┐
│  Gate 2 — Predecessor ID Lineage    │  predecessor_id malformed ?
│  (Pre-HTTP)                         │  → HALT. Lineage chain broken.
└──────────────┬──────────────────────┘
               │ PASS
               ▼
         HTTP POST fired
    (https://httpbin.org/post)
               │
               ▼
┌─────────────────────────────────────┐
│  Gate 3 — Response Validation       │  response missing 'json'/'data' ?
│  (Post-HTTP)                        │  → HALT. Data pipeline blocked.
└──────────────┬──────────────────────┘
               │ PASS
               ▼
   markSuccessfulTrace(traceId)
   → Predecessor chain advances
   → Success state shown
```

---

## 🔗 Metadata Headers & Lineage Chaining

Every API submission injects 3 mandatory metadata headers:

| Header           | Value                                | Description                      |
| ---------------- | ------------------------------------ | -------------------------------- |
| `trace_id`       | `UUID v4`                            | Unique identifier per request    |
| `logic_hash`     | `SHA-256(payloadJSON)`               | Integrity fingerprint of payload |
| `predecessor_id` | `SHA-256(prev_trace_id)` or `"null"` | Session lineage chain link       |

**Chaining Rules:**

```
Request 1  →  predecessor_id: "null"                   (first in session)
Request 2  →  predecessor_id: SHA-256(trace_id_1)      (64-char hex)
Request 3  →  predecessor_id: SHA-256(trace_id_2)      (64-char hex, new value)
```

> ⚠️ `predecessor_id` chain is **session-level**, not form-level.
> Clearing the form does NOT reset the chain.
> Only app restart resets the chain (static field in `MetadataHelper`).

---

## ⏱️ UI Friction Monitoring

The **Full Name** field has a built-in 5-second stall detector:

| State                   | What Happens                                     |
| ----------------------- | ------------------------------------------------ |
| Field focused           | `⏱️ Friction Monitor Active (5s)` badge appears  |
| No typing for 5 seconds | `⏳ 5s Stall Detected` amber badge + border glow |
| Resume typing           | `▶️ Typing Resumed` green badge                  |
| Field unfocused         | Badge clears, timer cancelled                    |

When a stall is detected:

1. **Label badge** updates live on the field
2. **Amber border glow** appears around the input
3. **Floating SnackBar toast** pops up (visible even when scrolled away)
4. **Friction Log Panel** at bottom records timestamp

---

## 🧪 Testing — 3 Required Scenarios

All 3 scenarios from the hiring specification are unit-tested and UI-demonstrable:

### Scenario 1 — Valid Submission (Success)

Fill all fields correctly → tap **Submit Verification**

- All 3 Gates pass
- Green success banner shows `trace_id`, `logic_hash`, `predecessor_id`
- Chain advances for next request

### Scenario 2 — Missing Lineage (Gate 2 Fail-Closed)

Tap **🧪 Test Gate 2 (Simulate Missing Lineage)** button

- `predecessor_id` is forced invalid before HTTP call
- Gate 2 halts execution — **zero network request fired**
- Red Fail-Closed banner: `Gate 2 — predecessor_id lineage invalid`

### Scenario 3 — Required Field Empty (Gate 1 Fail-Closed)

Leave any required field empty → tap **Submit Verification**

- Gate 1 catches the empty/null field
- Inline form error + Red Fail-Closed banner
- `Gate 1 — Required field is null or empty`

---

## ✅ Test Results

```bash
flutter analyze
# Analyzing my_app... No issues found!

flutter test
# 46/46 All tests passed!
```

| Test File              | Tests  | Result      |
| ---------------------- | ------ | ----------- |
| `validators_test.dart` | 44     | ✅ All Pass |
| `widget_test.dart`     | 2      | ✅ All Pass |
| **Total**              | **46** | **✅ 100%** |

---

## 🚀 Getting Started

### Prerequisites

- Flutter `3.44.9` or higher
- Dart `3.12.2` or higher
- Android Studio / VS Code with Flutter plugin

### Run the App

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/digivir_flutter_app.git
cd digivir_flutter_app

# Install dependencies
flutter pub get

# Run on device / emulator
flutter run

# Run on Linux desktop
flutter run -d linux

# Run all tests
flutter test

# Static analysis
flutter analyze
```

---

## 📦 Dependencies

| Package         | Version  | Purpose                                       |
| --------------- | -------- | --------------------------------------------- |
| `uuid`          | `^4.5.1` | UUID v4 generation for `trace_id`             |
| `crypto`        | `^3.0.6` | SHA-256 for `logic_hash` and `predecessor_id` |
| `http`          | `^1.2.2` | HTTP POST to API endpoint                     |
| `flutter_lints` | `^6.0.0` | Static analysis rules                         |

---

## 🌐 API Endpoint

**Endpoint:** `https://httpbin.org/post`

httpbin is a public HTTP mirror service that reflects every request back as JSON, including:

- `json`: Parsed request body
- `headers`: All injected metadata headers (`trace_id`, `logic_hash`, `predecessor_id`)
- `data`: Raw request body string

Gate 3 validates the response by checking for the `json` or `data` key.

---

## 🛠️ Key Design Decisions

### Why `ChangeNotifier` + `ListenableBuilder`?

Pure `ChangeNotifier` requires zero third-party state management packages. `ListenableBuilder` rebuilds only the affected subtree. No `setState`, no `StatefulWidget` needed in the feature layer.

### Why Fail-Closed instead of Fail-Open?

In data governance systems, the default action must be HALT. If a gate condition cannot be verified (missing field, broken lineage, invalid response), the data must be quarantined. Transmitting unverified data is a security violation.

### Why does `predecessor_id` persist across form clears?

The lineage chain is **session-level**, tracking every successful API call across the session. A "Clear Form" action only clears UI input — it does not end the session. Resetting the chain on form clear would make every submission appear as a "first request", defeating the purpose of lineage tracking.

### Why compute `predecessor_id` once per submission?

Calling `computePredecessorId()` twice (once for Gate 2 check, once inside `buildHeaders()`) creates a hidden coupling risk: if `_lastSuccessfulTraceId` changes between the two calls (e.g. in an async context), the validated value and the injected header value could differ silently. Computing once and passing explicitly is the safe, deterministic approach.

---

## 👤 Developer

- **Name:** Nisha Aishwarya Yadav
- **Email:** nishaishwaryadav24@gmail.com
- **Phone:** +91 6266448520
- **Submission:** HabotConnect — DigiVir Flutter Mobile App Developer

---

## 📄 License

This project is submitted as part of a hiring evaluation and is not licensed for public distribution.
