// lib/features/verification/verification_controller.dart
import 'package:flutter/foundation.dart';
import '../../core/models/form_payload.dart';
import '../../core/utils/friction_logger.dart';
import '../../core/utils/validators.dart';
import '../../services/api_service.dart';

/// All possible states of the Verification screen.
enum VerificationState {
  idle,
  validating,
  submitting,
  success,
  failClosedError,
  networkError,
}

/// State controller for the LSA Profile Verification screen.
///
/// Follows Byt boundary principles:
///   - ALL business logic lives here. The UI layer holds zero logic.
///   - UI is purely reactive to this controller's exposed state via ListenableBuilder.
///   - No setState() ever called from a widget — only notifyListeners() here.
class VerificationController extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // ── Form field values ────────────────────────────────────────────────────────
  String? fullName;
  String? email;
  String? phone;
  String? profileCategory;
  String? notes;

  // ── Screen state ─────────────────────────────────────────────────────────────
  VerificationState _state = VerificationState.idle;
  String _statusMessage = '';
  String? _lastTraceId;
  String? _lastLogicHash;
  String? _lastPredecessorId;
  bool _isFailClosed = false;
  String? _failClosedGate;

  // ── Per-field validation lineage ──────────────────────────────────────────────
  // null  = not yet validated (idle)
  // true  = field passed validation
  // false = field failed validation
  bool? _nameValid;
  bool? _emailValid;
  bool? _phoneValid;
  bool? _categoryValid;

  // ── Friction log ──────────────────────────────────────────────────────────────
  final List<FrictionEvent> _frictionLog = [];
  late final FrictionLogger _frictionLogger;
  FrictionStatus _frictionStatus = FrictionStatus.idle;
  FrictionEvent? _latestFrictionEvent;

  VerificationController() {
    _frictionLogger = FrictionLogger(
      fieldName: 'Full Name',
      onEvent: _onFrictionEvent,
      onStatusChanged: (status) {
        _frictionStatus = status;
        notifyListeners();
      },
    );
  }

  // ── Public getters ─────────────────────────────────────────────────────────────
  VerificationState get state => _state;
  String get statusMessage => _statusMessage;
  String? get lastTraceId => _lastTraceId;
  String? get lastLogicHash => _lastLogicHash;
  String? get lastPredecessorId => _lastPredecessorId;
  bool get isFailClosed => _isFailClosed;
  String? get failClosedGate => _failClosedGate;

  bool get isLoading =>
      _state == VerificationState.validating ||
      _state == VerificationState.submitting;

  List<FrictionEvent> get frictionLog => List.unmodifiable(_frictionLog);
  bool get hasFrictionEvents => _frictionLog.isNotEmpty;
  FrictionStatus get frictionStatus => _frictionStatus;
  FrictionEvent? get latestFrictionEvent => _latestFrictionEvent;
  bool get isNameStalled => _frictionStatus == FrictionStatus.stalled;

  // Per-field lineage validation status
  bool? get nameValid => _nameValid;
  bool? get emailValid => _emailValid;
  bool? get phoneValid => _phoneValid;
  bool? get categoryValid => _categoryValid;

  /// True if at least one field has been validated (lineage run).
  bool get hasValidationLineage =>
      _nameValid != null ||
      _emailValid != null ||
      _phoneValid != null ||
      _categoryValid != null;

  // ── Friction Logger ──────────────────────────────────────────────────────────
  void onNameFieldFocused() => _frictionLogger.startTracking();
  void onNameFieldInteracted() => _frictionLogger.onUserInteracted();
  void onNameFieldUnfocused() => _frictionLogger.stopTracking();

  void _onFrictionEvent(FrictionEvent event) {
    _frictionLog.add(event);
    _latestFrictionEvent = event;
    notifyListeners();
  }

  // ── Field update methods ─────────────────────────────────────────────────────
  void updateFullName(String value) {
    fullName = value.isEmpty ? null : value;
    onNameFieldInteracted();
  }

  void updateEmail(String value) {
    email = value.isEmpty ? null : value;
  }

  void updatePhone(String value) {
    phone = value.isEmpty ? null : value;
  }

  void updateProfileCategory(String? value) {
    profileCategory = value;
    notifyListeners();
  }

  void updateNotes(String value) {
    notes = value.isEmpty ? null : value;
  }

  // ── Submission ────────────────────────────────────────────────────────────────
  Future<void> submit() async {
    // ── Step 1: Run per-field validation lineage ─────────────────────────────
    _setState(VerificationState.validating, 'Validating form data...');
    await Future.delayed(const Duration(milliseconds: 500));

    // Compute and expose per-field results for the lineage indicator.
    _nameValid = Validators.fullName(fullName) == null;
    _emailValid = Validators.email(email) == null;
    _phoneValid = Validators.phone(phone) == null;
    _categoryValid = Validators.profileCategory(profileCategory) == null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    final payload = FormPayload(
      fullName: fullName,
      email: email,
      phone: phone,
      profileCategory: profileCategory,
      notes: notes,
    );

    // ── Step 2: Submit via API service (runs Fail-Closed gates inside) ────────
    _setState(VerificationState.submitting, 'Submitting to DigiVir servers...');

    final result = await _apiService.submitVerificationForm(payload);

    _lastTraceId = result.traceId;
    _lastLogicHash = result.logicHash;
    _lastPredecessorId = result.predecessorId;
    _isFailClosed = result.isFailClosed;
    _failClosedGate = result.failClosedGate;

    if (result.success) {
      _setState(VerificationState.success, result.message);
    } else if (result.isFailClosed) {
      _setState(VerificationState.failClosedError, result.message);
    } else {
      _setState(VerificationState.networkError, result.message);
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────────
  void reset() {
    fullName = null;
    email = null;
    phone = null;
    profileCategory = null;
    notes = null;
    _lastTraceId = null;
    _lastLogicHash = null;
    _lastPredecessorId = null;
    _isFailClosed = false;
    _failClosedGate = null;
    _nameValid = null;
    _emailValid = null;
    _phoneValid = null;
    _categoryValid = null;
    _frictionLog.clear();
    _frictionStatus = FrictionStatus.idle;
    _latestFrictionEvent = null;
    _frictionLogger.stopTracking();
    _setState(VerificationState.idle, '');
  }

  void retryFromError() {
    _setState(VerificationState.idle, '');
  }

  // ── Private helpers ───────────────────────────────────────────────────────────
  void _setState(VerificationState state, String message) {
    _state = state;
    _statusMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _frictionLogger.dispose();
    super.dispose();
  }
}
