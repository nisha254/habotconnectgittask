// lib/core/constants/app_strings.dart

/// All user-facing string constants.
/// Avoids magic strings scattered across the codebase.
class AppStrings {
  AppStrings._();

  // App
  static const String appTitle = 'DigiVir – LSA Profile Verification';

  // Screen
  static const String screenTitle = 'Profile Verification';
  static const String screenSubtitle = 'Learning Support Assistant (LSA) Onboarding';

  // Form labels
  static const String labelFullName = 'Full Name';
  static const String labelEmail = 'Email Address';
  static const String labelPhone = 'Phone Number';
  static const String labelCategory = 'Profile Category';
  static const String labelNotes = 'Additional Notes';

  // Hints
  static const String hintFullName = 'Enter your full name';
  static const String hintEmail = 'you@example.com';
  static const String hintPhone = '+91 XXXXX XXXXX';
  static const String hintNotes = 'Any additional information...';

  // Categories
  static const List<String> profileCategories = [
    'Academic Support',
    'Behavioral Support',
    'Communication Aid',
    'Learning Disabilities',
    'Emotional Support',
  ];

  // Validation
  static const String validationRequired = 'This field is required';
  static const String validationEmail = 'Enter a valid email address';
  static const String validationPhone = 'Enter a valid phone number';
  static const String validationName = 'Name must be at least 2 characters';

  // API / State
  static const String stateIdle = 'Ready to submit';
  static const String stateValidating = 'Validating form data...';
  static const String stateSubmitting = 'Submitting to DigiVir servers...';
  static const String stateSuccess = 'Profile submitted successfully!';
  static const String stateFailClosed = 'Fail-Closed: Submission halted due to invalid data';
  static const String stateNetworkError = 'Network error. Please try again.';

  // Friction logger
  static const String frictionTitle = 'UI Friction Log';
  static const String frictionEventLabel = 'Friction Event';
  static const String frictionClearedLabel = 'Resumed typing';

  // Buttons
  static const String btnSubmit = 'Submit Verification';
  static const String btnRetry = 'Retry Submission';
  static const String btnClear = 'Clear Form';

  // Metadata labels (for display)
  static const String metaTraceId = 'trace_id';
  static const String metaLogicHash = 'logic_hash';
  static const String metaPredecessorId = 'predecessor_id';
}
