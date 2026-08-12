// lib/features/verification/verification_screen.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import 'verification_controller.dart';
import 'widgets/profile_header.dart';
import 'widgets/form_field_tile.dart';
import 'widgets/submit_button.dart';
import 'widgets/validation_banner.dart';

/// LSA Profile Verification Screen.
///
/// Byt boundary contract:
///   - Holds NO business logic.
///   - All state owned by [VerificationController].
///   - Rebuilt reactively via [ListenableBuilder] — no setState() calls.
///   - Each sub-widget is stateless and receives exactly what it needs.
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late final VerificationController _controller;

  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _notesFocus = FocusNode();

  int _lastNotifiedFrictionCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = VerificationController();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    // Show a floating SnackBar toast whenever a new friction stall event is logged
    if (_controller.frictionLog.length > _lastNotifiedFrictionCount) {
      _lastNotifiedFrictionCount = _controller.frictionLog.length;
      final latest = _controller.latestFrictionEvent;
      if (latest != null && latest.type == 'stall' && mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '⏱️ UI Friction Event: 5-second stall logged on "Full Name"',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD97706),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _notesCtrl]) {
      c.dispose();
    }
    for (final f in [_nameFocus, _emailFocus, _phoneFocus, _notesFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      _controller.submit();
    }
  }

  void _handleClear() {
    _formKey.currentState?.reset();
    for (final c in [_nameCtrl, _emailCtrl, _phoneCtrl, _notesCtrl]) {
      c.clear();
    }
    _lastNotifiedFrictionCount = 0;
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final state = _controller.state;
          final isLocked =
              _controller.isLoading || state == VerificationState.success;

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: ProfileHeader()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Status banner (success / fail-closed / network) ──
                        ValidationBanner(
                          state: state,
                          message: _controller.statusMessage,
                          traceId: _controller.lastTraceId,
                          logicHash: _controller.lastLogicHash,
                          predecessorId: _controller.lastPredecessorId,
                          failClosedGate: _controller.failClosedGate,
                        ),

                        // ── Validation lineage summary strip ────────────────
                        if (_controller.hasValidationLineage) ...[
                          _ValidationLineageStrip(
                            nameValid: _controller.nameValid,
                            emailValid: _controller.emailValid,
                            phoneValid: _controller.phoneValid,
                            categoryValid: _controller.categoryValid,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Personal information card ───────────────────────
                        _SectionCard(
                          title: 'Personal Information',
                          icon: Icons.person_outline_rounded,
                          children: [
                            FormFieldTile(
                              label: AppStrings.labelFullName,
                              hint: AppStrings.hintFullName,
                              controller: _nameCtrl,
                              focusNode: _nameFocus,
                              nextFocusNode: _emailFocus,
                              enabled: !isLocked,
                              validator: Validators.fullName,
                              prefixIcon: const Icon(Icons.badge_outlined,
                                  color: AppColors.textSecondary, size: 20),
                              validationState: _controller.nameValid,
                              frictionStatus: _controller.frictionStatus,
                              onFocused: _controller.onNameFieldFocused,
                              onUnfocused: _controller.onNameFieldUnfocused,
                              onChanged: _controller.updateFullName,
                            ),
                            const SizedBox(height: 18),
                            FormFieldTile(
                              label: AppStrings.labelEmail,
                              hint: AppStrings.hintEmail,
                              controller: _emailCtrl,
                              focusNode: _emailFocus,
                              nextFocusNode: _phoneFocus,
                              enabled: !isLocked,
                              validator: Validators.email,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: AppColors.textSecondary, size: 20),
                              validationState: _controller.emailValid,
                              onChanged: _controller.updateEmail,
                            ),
                            const SizedBox(height: 18),
                            FormFieldTile(
                              label: AppStrings.labelPhone,
                              hint: AppStrings.hintPhone,
                              controller: _phoneCtrl,
                              focusNode: _phoneFocus,
                              nextFocusNode: _notesFocus,
                              enabled: !isLocked,
                              validator: Validators.phone,
                              keyboardType: TextInputType.phone,
                              prefixIcon: const Icon(Icons.phone_outlined,
                                  color: AppColors.textSecondary, size: 20),
                              validationState: _controller.phoneValid,
                              onChanged: _controller.updatePhone,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Profile category card ───────────────────────────
                        _SectionCard(
                          title: 'Profile Category',
                          icon: Icons.category_outlined,
                          children: [
                            _DropdownWithLineage(
                              controller: _controller,
                              isLocked: isLocked,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Additional notes card ───────────────────────────
                        _SectionCard(
                          title: 'Additional Notes',
                          icon: Icons.notes_rounded,
                          isOptional: true,
                          children: [
                            FormFieldTile(
                              label: AppStrings.labelNotes,
                              hint: AppStrings.hintNotes,
                              controller: _notesCtrl,
                              focusNode: _notesFocus,
                              enabled: !isLocked,
                              maxLines: 4,
                              textInputAction: TextInputAction.done,
                              onChanged: _controller.updateNotes,
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Submit / Retry / Clear ──────────────────────────
                        SubmitButton(
                          state: state,
                          onSubmit: _handleSubmit,
                          onRetry: _controller.retryFromError,
                          onClear: _handleClear,
                          onTestMissingLineage: _controller.testMissingLineageGate,
                        ),

                        const SizedBox(height: 24),

                        // ── Friction log ────────────────────────────────────
                        if (_controller.hasFrictionEvents)
                          _FrictionLogPanel(
                            events: _controller.frictionLog
                                .map((e) => e.toString())
                                .toList(),
                          ),

                        const SizedBox(height: 16),

                        Center(
                          child: Text(
                            'DigiVir · HabotConnect · Byt v1.0',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textHint,
                                      fontSize: 11,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Validation Lineage Strip ──────────────────────────────────────────────────

/// Summary strip showing all four fields' validation status at once.
class _ValidationLineageStrip extends StatelessWidget {
  final bool? nameValid;
  final bool? emailValid;
  final bool? phoneValid;
  final bool? categoryValid;

  const _ValidationLineageStrip({
    this.nameValid,
    this.emailValid,
    this.phoneValid,
    this.categoryValid,
  });

  @override
  Widget build(BuildContext context) {
    final allPassed = nameValid == true &&
        emailValid == true &&
        phoneValid == true &&
        categoryValid == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: allPassed ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: allPassed
              ? AppColors.success.withValues(alpha: 0.35)
              : AppColors.error.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allPassed
                    ? Icons.verified_rounded
                    : Icons.warning_amber_rounded,
                size: 15,
                color: allPassed ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 6),
              Text(
                'Validation Lineage',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          allPassed ? AppColors.success : AppColors.error,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _LineageChip(label: 'Full Name', passed: nameValid),
              _LineageChip(label: 'Email', passed: emailValid),
              _LineageChip(label: 'Phone', passed: phoneValid),
              _LineageChip(label: 'Category', passed: categoryValid),
            ],
          ),
        ],
      ),
    );
  }
}

class _LineageChip extends StatelessWidget {
  final String label;
  final bool? passed;

  const _LineageChip({required this.label, required this.passed});

  @override
  Widget build(BuildContext context) {
    final color = passed == null
        ? AppColors.textSecondary
        : passed!
            ? AppColors.success
            : AppColors.error;
    final icon = passed == null
        ? Icons.radio_button_unchecked
        : passed!
            ? Icons.check_circle_rounded
            : Icons.cancel_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dropdown with Lineage Badge ───────────────────────────────────────────────

class _DropdownWithLineage extends StatelessWidget {
  final VerificationController controller;
  final bool isLocked;

  const _DropdownWithLineage({
    required this.controller,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                AppStrings.labelCategory,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
              ),
              const SizedBox(width: 3),
              const Text(
                '*',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              // Lineage badge for category
              if (controller.categoryValid != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: controller.categoryValid!
                      ? _Badge(
                          key: const ValueKey('cat_pass'),
                          label: 'Passed',
                          color: AppColors.success,
                          icon: Icons.check_circle_rounded,
                        )
                      : _Badge(
                          key: const ValueKey('cat_fail'),
                          label: 'Failed',
                          color: AppColors.error,
                          icon: Icons.cancel_rounded,
                        ),
                ),
            ],
          ),
        ),
        DropdownButtonFormField<String>(
          initialValue: controller.profileCategory,
          hint: const Text('Select category'),
          validator: Validators.profileCategory,
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.layers_outlined,
                color: AppColors.textSecondary, size: 20),
            filled: true,
            fillColor:
                isLocked ? AppColors.surfaceVariant : AppColors.inputFillColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.inputBorder)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.inputBorder, width: 1.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.inputFocusBorder, width: 2)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.error, width: 1.5)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.error, width: 2)),
          ),
          items: AppStrings.profileCategories
              .map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat, style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged:
              isLocked ? null : controller.updateProfileCategory,
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({super.key, required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isOptional;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 17),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                ),
                if (isOptional) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Optional',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ── Friction Log Panel ────────────────────────────────────────────────────────

class _FrictionLogPanel extends StatelessWidget {
  final List<String> events;

  const _FrictionLogPanel({required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.frictionBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.frictionBorder, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color:
                        AppColors.frictionBorder.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.timer_outlined,
                      color: AppColors.frictionText, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.frictionTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.frictionText,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color:
                        AppColors.frictionBorder.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${events.length} event${events.length == 1 ? '' : 's'}',
                    style:
                        Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.frictionText,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Stall detection > 5 s on "Full Name" field',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.frictionText.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
            ),
            const SizedBox(height: 12),
            ...events.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      event.contains('STALL')
                          ? Icons.hourglass_empty_rounded
                          : Icons.play_circle_outline_rounded,
                      size: 14,
                      color: event.contains('STALL')
                          ? AppColors.error
                          : AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.frictionText,
                              fontSize: 11,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
