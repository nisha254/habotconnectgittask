// lib/core/utils/metadata_helper.dart
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

/// Generates mandatory API metadata headers per HabotConnect Byt standard.
///
/// Headers injected on every submission:
///   - trace_id      : UUID v4, unique per request
///   - logic_hash    : SHA-256 of the serialized payload JSON
///   - predecessor_id: SHA-256 of the last successful trace_id,
///                     OR the literal string "null" if this is the first
///                     successful submission in the current session.
///
/// Predecessor chain rule:
///   1st request  → predecessor_id = "null"
///   2nd request  → predecessor_id = SHA-256(traceId of 1st successful request)
///   3rd request  → predecessor_id = SHA-256(traceId of 2nd successful request)
///   …and so on.
///
/// [buildHeaders] accepts a pre-computed [predecessorId] so that
/// the value used in Gate-2 validation and the value injected into the
/// HTTP header are guaranteed to be identical — no risk of a double-call
/// producing a different value.
class MetadataHelper {
  MetadataHelper._();

  static const _uuid = Uuid();

  // Demo/testing hook: when true, computePredecessorId() will return
  // an invalid (empty) string to allow demonstration of a Gate-2
  // Fail-Closed condition during automated demos. Default: false.
  // NOTE: Keep this as a clearly-named demo-only flag.
  static bool forceInvalidPredecessorForDemo = false;

  /// Tracks the last successful trace_id for predecessor chaining.
  /// null  → no successful submission has occurred yet in this session.
  static String? _lastSuccessfulTraceId;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Generates a fresh UUID v4 trace_id.
  static String generateTraceId() => _uuid.v4();

  /// Computes the SHA-256 digest of [payloadJson] (used as logic_hash).
  static String computeLogicHash(String payloadJson) {
    final bytes = utf8.encode(payloadJson);
    return sha256.convert(bytes).toString();
  }

  /// Computes the predecessor_id for the *current* submission.
  ///
  /// Returns:
  ///   - `"null"` (literal string) if no successful request has been made yet.
  ///   - The SHA-256 hex digest of [_lastSuccessfulTraceId] otherwise.
  ///
  /// Call this ONCE per submission cycle and store the result in a local
  /// variable. Pass that variable to both [isPredecessorIdCompliant] (Gate 2)
  /// and [buildHeaders] — this avoids any double-call / value-mismatch risk.
  static String computePredecessorId() {
    if (forceInvalidPredecessorForDemo) return '';
    if (_lastSuccessfulTraceId == null) return 'null';
    return sha256.convert(utf8.encode(_lastSuccessfulTraceId!)).toString();
  }

  /// Records a successful submission so the next request's predecessor_id
  /// can be derived from this [traceId].
  ///
  /// Always call this immediately after a confirmed successful API response —
  /// never before, never on error paths.
  ///
  /// Logs a debug message so you can verify in the console that the chain
  /// has been updated and that the next predecessor_id will be a valid SHA-256
  /// (not "null").
  static void markSuccessfulTrace(String traceId) {
    _lastSuccessfulTraceId = traceId;
    final nextPredecessorId = computePredecessorId();

    // ── Debug log — verifies chain update ──────────────────────────────────
    developer.log(
      '[MetadataHelper] ✅ markSuccessfulTrace() called.\n'
      '  Stored trace_id   : $traceId\n'
      '  Next predecessor_id (SHA-256 of above): $nextPredecessorId\n'
      '  → Second request will use a valid 64-char SHA-256, NOT "null".',
      name: 'DigiVir.MetadataHelper',
    );
  }

  /// Resets the predecessor chain (e.g. on session logout or app restart).
  /// After calling this, the next submission will treat itself as first-ever
  /// and send predecessor_id = "null".
  static void resetChain() {
    _lastSuccessfulTraceId = null;
    developer.log(
      '[MetadataHelper] 🔄 Chain reset — next request will use predecessor_id = "null".',
      name: 'DigiVir.MetadataHelper',
    );
  }

  /// Builds the complete HTTP header map for a submission request.
  ///
  /// [predecessorId] must be pre-computed via [computePredecessorId] and
  /// passed in explicitly — this guarantees the same value that passed
  /// Gate-2 validation is the value injected into the header (single source
  /// of truth, no double-call risk).
  static Map<String, String> buildHeaders({
    required String traceId,
    required String payloadJson,
    required String predecessorId,           // ← explicit param, not re-computed
    Map<String, String>? additionalHeaders,
  }) {
    return {
      'Content-Type': 'application/json',
      'trace_id': traceId,
      'logic_hash': computeLogicHash(payloadJson),
      'predecessor_id': predecessorId,       // ← same value used in Gate-2
      ...?additionalHeaders,
    };
  }
}
