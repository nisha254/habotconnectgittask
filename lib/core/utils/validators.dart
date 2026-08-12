// lib/core/utils/validators.dart

/// Form field validators following Byt boundary — pure functions, no side effects.
/// Each validator returns null if valid, or an error string if invalid.
/// No UI or network dependencies — safe to call from tests, controller, or service.
class Validators {
  Validators._();

  // ── SHA-256 hash pattern (64 lowercase hex chars) ──────────────────────────
  static final RegExp _sha256Pattern = RegExp(r'^[a-f0-9]{64}$');

  // ── Field validators ────────────────────────────────────────────────────────

  /// Validates full name — non-null, non-empty, at least 2 chars, letters only.
  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s'-]+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name may only contain letters, spaces, hyphens, or apostrophes';
    }
    return null;
  }

  /// Validates email — non-null, valid RFC-like format.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates phone — non-null, accepts international formats (7–15 digits).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Validates dropdown — must be selected (non-null, non-empty).
  static String? profileCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a profile category';
    }
    return null;
  }

  /// Optional notes — always valid.
  static String? notes(String? value) => null;

  // ── Metadata / Lineage validators ────────────────────────────────────────────

  /// Validates a predecessor_id value.
  ///
  /// A predecessor_id is valid when:
  ///   - It is the literal string `"null"` → this is the first-ever request
  ///     in the session (no prior successful submission exists yet), OR
  ///   - It is a 64-character lowercase hex string (valid SHA-256 digest of
  ///     the last successful trace_id).
  ///
  /// Any other value (empty string, garbage, wrong length) is INVALID and
  /// must trigger a Fail-Closed halt — the lineage chain is broken.
  static String? predecessorId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'predecessor_id is missing — lineage chain broken';
    }
    final trimmed = value.trim();
    // "null" is the sentinel for first request — valid.
    if (trimmed == 'null') return null;
    // Otherwise it must be a valid SHA-256 hex digest.
    if (!_sha256Pattern.hasMatch(trimmed)) {
      return 'predecessor_id is not a valid SHA-256 hash — lineage invalid';
    }
    return null;
  }

  // ── Composite compliance gates ────────────────────────────────────────────────

  /// Gate 1 — Field compliance.
  /// Returns true if ALL required form fields are individually valid.
  static bool isCompliant({
    required String? fullName,
    required String? email,
    required String? phone,
    required String? profileCategory,
  }) {
    return Validators.fullName(fullName) == null &&
        Validators.email(email) == null &&
        Validators.phone(phone) == null &&
        Validators.profileCategory(profileCategory) == null;
  }

  /// Gate 2 — Predecessor ID / lineage compliance.
  /// Returns true if the predecessor_id is valid per [predecessorId] rules.
  /// Must be checked AFTER Gate 1 — if this returns false, halt immediately.
  static bool isPredecessorIdCompliant(String? predId) {
    return predecessorId(predId) == null;
  }

  /// Gate 3 — Response validation.
  ///
  /// Validates the structure of the HTTP response body received from the
  /// endpoint. The check must match what the actual endpoint returns.
  ///
  /// Endpoint: https://httpbin.org/post
  /// httpbin mirrors everything you POST back inside a JSON object that
  /// always contains both "json" (the parsed request body) and "data"
  /// (the raw request body string). Either key being present is sufficient
  /// to confirm a valid, non-corrupted response.
  ///
  /// If you ever switch endpoints (e.g. to jsonplaceholder), update this
  /// check to match that endpoint's response shape — e.g. `containsKey('id')`.
  static bool isResponseValid(Map<String, dynamic>? response) {
    if (response == null) return false;
    // httpbin.org/post always returns "json" and/or "data" keys.
    return response.containsKey('json') || response.containsKey('data');
  }

  /// Returns a map of field-name → error-string for each field.
  /// null value means the field is valid.
  /// Used to drive the per-field validation lineage indicator in the UI.
  static Map<String, String?> validateAll({
    required String? fullName,
    required String? email,
    required String? phone,
    required String? profileCategory,
    String? predecessorId,
  }) {
    return {
      'fullName': Validators.fullName(fullName),
      'email': Validators.email(email),
      'phone': Validators.phone(phone),
      'profileCategory': Validators.profileCategory(profileCategory),
      'predecessorId': predecessorId != null
          ? Validators.predecessorId(predecessorId)
          : null,
    };
  }
}
