// test/validators_test.dart
//
// Unit tests for lib/core/utils/validators.dart
//
// Covers the three scenarios required by the hiring spec:
//   1. Valid payload   — all fields pass, predecessor_id valid
//   2. Null required field — Gate 1 should halt
//   3. Missing/invalid predecessor_id — Gate 2 should halt

import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/utils/validators.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // Full Name
  // ═══════════════════════════════════════════════════════════════════════════
  group('Validators.fullName', () {
    test('returns null for a valid full name', () {
      expect(Validators.fullName('Aisha Malik'), isNull);
      expect(Validators.fullName("O'Brien"), isNull);
      expect(Validators.fullName('Mary-Jane'), isNull);
    });

    test('returns error when null', () {
      expect(Validators.fullName(null), isNotNull);
    });

    test('returns error when empty string', () {
      expect(Validators.fullName(''), isNotNull);
      expect(Validators.fullName('   '), isNotNull);
    });

    test('returns error when shorter than 2 chars', () {
      expect(Validators.fullName('A'), isNotNull);
    });

    test('returns error for names with invalid characters', () {
      expect(Validators.fullName('John123'), isNotNull);
      expect(Validators.fullName('Ali@Khan'), isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Email
  // ═══════════════════════════════════════════════════════════════════════════
  group('Validators.email', () {
    test('returns null for valid email addresses', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('first.last+tag@sub.domain.org'), isNull);
    });

    test('returns error when null', () {
      expect(Validators.email(null), isNotNull);
    });

    test('returns error when empty', () {
      expect(Validators.email(''), isNotNull);
    });

    test('returns error for missing @ symbol', () {
      expect(Validators.email('notanemail.com'), isNotNull);
    });

    test('returns error for missing domain', () {
      expect(Validators.email('user@'), isNotNull);
    });

    test('returns error for missing TLD', () {
      expect(Validators.email('user@domain'), isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Phone
  // ═══════════════════════════════════════════════════════════════════════════
  group('Validators.phone', () {
    test('returns null for valid international phone numbers', () {
      expect(Validators.phone('+91 9876543210'), isNull);
      expect(Validators.phone('9876543210'), isNull);
      expect(Validators.phone('+1-800-555-0199'), isNull);
    });

    test('returns error when null', () {
      expect(Validators.phone(null), isNotNull);
    });

    test('returns error when empty', () {
      expect(Validators.phone(''), isNotNull);
    });

    test('returns error for too-short number', () {
      expect(Validators.phone('123'), isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Profile Category
  // ═══════════════════════════════════════════════════════════════════════════
  group('Validators.profileCategory', () {
    test('returns null for a selected category', () {
      expect(Validators.profileCategory('Learning Support Assistant'), isNull);
      expect(Validators.profileCategory('Parent'), isNull);
    });

    test('returns error when null', () {
      expect(Validators.profileCategory(null), isNotNull);
    });

    test('returns error when empty', () {
      expect(Validators.profileCategory(''), isNotNull);
      expect(Validators.profileCategory('  '), isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Predecessor ID — Gate 2 lineage validation
  // ═══════════════════════════════════════════════════════════════════════════
  group('Validators.predecessorId', () {
    const validSha256 =
        'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3';

    test('returns null for "null" sentinel (first request)', () {
      expect(Validators.predecessorId('null'), isNull);
    });

    test('returns null for a valid 64-char SHA-256 hex string', () {
      expect(Validators.predecessorId(validSha256), isNull);
    });

    test('returns error when value is null', () {
      expect(Validators.predecessorId(null), isNotNull);
    });

    test('returns error when value is empty string', () {
      expect(Validators.predecessorId(''), isNotNull);
      expect(Validators.predecessorId('   '), isNotNull);
    });

    test('returns error for a non-hex garbage string', () {
      expect(Validators.predecessorId('invalid-predecessor'), isNotNull);
    });

    test('returns error for a too-short hex string', () {
      // Only 32 chars — not a valid SHA-256
      expect(Validators.predecessorId('a665a45920422f9d417e4867efdc4fb8'), isNotNull);
    });

    test('returns error for a too-long hex string', () {
      expect(
        Validators.predecessorId('${validSha256}00extra'),
        isNotNull,
      );
    });

    test('returns error for uppercase hex (must be lowercase)', () {
      // Our pattern requires lowercase hex
      expect(
        Validators.predecessorId(validSha256.toUpperCase()),
        isNotNull,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Scenario 1 — Valid payload: isCompliant returns true
  // ═══════════════════════════════════════════════════════════════════════════
  group('Scenario 1 — Valid payload', () {
    test('isCompliant returns true when all fields are valid', () {
      expect(
        Validators.isCompliant(
          fullName: 'Aisha Malik',
          email: 'aisha@example.com',
          phone: '+91 9876543210',
          profileCategory: 'Learning Support Assistant',
        ),
        isTrue,
      );
    });

    test('isPredecessorIdCompliant returns true for "null" sentinel', () {
      expect(Validators.isPredecessorIdCompliant('null'), isTrue);
    });

    test('isPredecessorIdCompliant returns true for valid SHA-256', () {
      const sha =
          'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3';
      expect(Validators.isPredecessorIdCompliant(sha), isTrue);
    });

    test('validateAll returns all nulls for a fully valid payload', () {
      final result = Validators.validateAll(
        fullName: 'Aisha Malik',
        email: 'aisha@example.com',
        phone: '+91 9876543210',
        profileCategory: 'Learning Support Assistant',
        predecessorId: 'null',
      );
      expect(result['fullName'], isNull);
      expect(result['email'], isNull);
      expect(result['phone'], isNull);
      expect(result['profileCategory'], isNull);
      expect(result['predecessorId'], isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Scenario 2 — Null required field: Gate 1 must catch it
  // ═══════════════════════════════════════════════════════════════════════════
  group('Scenario 2 — Null required field (Gate 1)', () {
    test('isCompliant returns false when fullName is null', () {
      expect(
        Validators.isCompliant(
          fullName: null,
          email: 'aisha@example.com',
          phone: '+91 9876543210',
          profileCategory: 'Learning Support Assistant',
        ),
        isFalse,
      );
    });

    test('isCompliant returns false when email is null', () {
      expect(
        Validators.isCompliant(
          fullName: 'Aisha Malik',
          email: null,
          phone: '+91 9876543210',
          profileCategory: 'Learning Support Assistant',
        ),
        isFalse,
      );
    });

    test('isCompliant returns false when phone is empty string', () {
      expect(
        Validators.isCompliant(
          fullName: 'Aisha Malik',
          email: 'aisha@example.com',
          phone: '',
          profileCategory: 'Learning Support Assistant',
        ),
        isFalse,
      );
    });

    test('isCompliant returns false when profileCategory is null', () {
      expect(
        Validators.isCompliant(
          fullName: 'Aisha Malik',
          email: 'aisha@example.com',
          phone: '+91 9876543210',
          profileCategory: null,
        ),
        isFalse,
      );
    });

    test('validateAll reports only the failing field', () {
      final result = Validators.validateAll(
        fullName: null, // ← the bad field
        email: 'aisha@example.com',
        phone: '+91 9876543210',
        profileCategory: 'Learning Support Assistant',
      );
      expect(result['fullName'], isNotNull);  // must fail
      expect(result['email'], isNull);        // must pass
      expect(result['phone'], isNull);        // must pass
      expect(result['profileCategory'], isNull); // must pass
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Scenario 3 — Missing / invalid predecessor_id: Gate 2 must catch it
  // ═══════════════════════════════════════════════════════════════════════════
  group('Scenario 3 — Invalid predecessor_id (Gate 2)', () {
    test('isPredecessorIdCompliant returns false for null', () {
      expect(Validators.isPredecessorIdCompliant(null), isFalse);
    });

    test('isPredecessorIdCompliant returns false for empty string', () {
      expect(Validators.isPredecessorIdCompliant(''), isFalse);
    });

    test('isPredecessorIdCompliant returns false for garbage string', () {
      expect(Validators.isPredecessorIdCompliant('bad-lineage-xyz'), isFalse);
    });

    test('isPredecessorIdCompliant returns false for truncated SHA-256', () {
      // 63 chars — one short of a real SHA-256
      expect(
        Validators.isPredecessorIdCompliant(
          'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae',
        ),
        isFalse,
      );
    });

    test('validateAll reports predecessorId error when lineage is broken', () {
      final result = Validators.validateAll(
        fullName: 'Aisha Malik',
        email: 'aisha@example.com',
        phone: '+91 9876543210',
        profileCategory: 'Learning Support Assistant',
        predecessorId: 'broken-lineage', // ← invalid
      );
      expect(result['predecessorId'], isNotNull);
      // All other fields still pass
      expect(result['fullName'], isNull);
      expect(result['email'], isNull);
      expect(result['phone'], isNull);
      expect(result['profileCategory'], isNull);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Response validation (Gate 3)
  // ═══════════════════════════════════════════════════════════════════════════
  group('Validators.isResponseValid', () {
    test('returns true for response with "json" key', () {
      expect(Validators.isResponseValid({'json': {}, 'url': '...'}), isTrue);
    });

    test('returns true for response with "data" key', () {
      expect(Validators.isResponseValid({'data': 'raw'}), isTrue);
    });

    test('returns false for null response', () {
      expect(Validators.isResponseValid(null), isFalse);
    });

    test('returns false for response missing both json and data keys', () {
      expect(Validators.isResponseValid({'status': 'ok'}), isFalse);
    });
  });
}
