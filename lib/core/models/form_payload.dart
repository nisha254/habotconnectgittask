import 'dart:convert';

class FormPayload {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? profileCategory;
  final String? notes;

  const FormPayload({
    this.fullName,
    this.email,
    this.phone,
    this.profileCategory,
    this.notes,
  });

  /// Returns true if any required field is null or empty.
  bool get hasNullOrEmpty {
    return fullName == null || fullName!.trim().isEmpty ||
        email == null || email!.trim().isEmpty ||
        phone == null || phone!.trim().isEmpty ||
        profileCategory == null || profileCategory!.trim().isEmpty;
  }

  /// Converts to JSON map for API submission.
  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'profile_category': profileCategory,
        'notes': notes ?? '',
        'submitted_at': DateTime.now().toIso8601String(),
      };

  /// JSON string representation of the payload (used for hashing).
  String toJsonString() => jsonEncode(toJson());

  /// Creates a copy with updated fields.
  FormPayload copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? profileCategory,
    String? notes,
  }) {
    return FormPayload(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileCategory: profileCategory ?? this.profileCategory,
      notes: notes ?? this.notes,
    );
  }
}
