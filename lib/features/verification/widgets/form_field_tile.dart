import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/friction_logger.dart';

/// Reusable form field widget with per-field validation lineage indicator
/// and real-time UI friction monitoring visual feedback.
///
/// Stateless — caller owns all state.
class FormFieldTile extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final int maxLines;
  final bool enabled;
  final VoidCallback? onFocused;
  final VoidCallback? onUnfocused;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  /// Per-field validation lineage state from the controller.
  /// null = idle, true = passed, false = failed.
  final bool? validationState;
  /// Real-time friction status (specifically for monitored fields like Full Name).
  final FrictionStatus? frictionStatus;

  const FormFieldTile({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.focusNode,
    this.nextFocusNode,
    this.maxLines = 1,
    this.enabled = true,
    this.onFocused,
    this.onUnfocused,
    this.onChanged,
    this.prefixIcon,
    this.validationState,
    this.frictionStatus,
  });

  @override
  Widget build(BuildContext context) {
    final isStalled = frictionStatus == FrictionStatus.stalled;
    final isTracking = frictionStatus == FrictionStatus.tracking;
    final isResumed = frictionStatus == FrictionStatus.resumed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row with required-star, friction badge, and lineage badge
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
              ),
              if (validator != null) ...[
                const SizedBox(width: 3),
                const Text(
                  '*',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
              const Spacer(),
              // ── Real-time Friction Status Badge ─────────────────────────
              if (frictionStatus != null && frictionStatus != FrictionStatus.idle) ...[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: isStalled
                      ? _FrictionBadge(
                          key: const ValueKey('f_stalled'),
                          label: '⏳ 5s Stall Detected',
                          color: AppColors.warning,
                          bgColor: AppColors.frictionBg,
                          borderColor: AppColors.frictionBorder,
                        )
                      : isResumed
                          ? _FrictionBadge(
                              key: const ValueKey('f_resumed'),
                              label: 'Typing Resumed',
                              color: AppColors.success,
                              bgColor: AppColors.successLight,
                              borderColor: AppColors.success.withValues(alpha: 0.4),
                            )
                          : isTracking
                              ? _FrictionBadge(
                                  key: const ValueKey('f_tracking'),
                                  label: 'Friction Monitor Active (5s)',
                                  color: AppColors.primary,
                                  bgColor: AppColors.primaryLight,
                                  borderColor: AppColors.primary.withValues(alpha: 0.4),
                                )
                              : const SizedBox.shrink(),
                ),
                const SizedBox(width: 6),
              ],
              // ── Validation lineage badge ──────────────────────────────────
              if (validationState != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: validationState!
                      ? const _LineageBadge(
                          key: ValueKey('pass'),
                          label: 'Passed',
                          color: AppColors.success,
                          icon: Icons.check_circle_rounded,
                        )
                      : const _LineageBadge(
                          key: ValueKey('fail'),
                          label: 'Failed',
                          color: AppColors.error,
                          icon: Icons.cancel_rounded,
                        ),
                ),
            ],
          ),
        ),

        // Input container with visual highlight when stalled
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: isStalled
                ? [
                    BoxShadow(
                      color: AppColors.warning.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Focus(
            onFocusChange: (focused) {
              if (focused) {
                onFocused?.call();
              } else {
                onUnfocused?.call();
              }
            },
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              focusNode: focusNode,
              maxLines: maxLines,
              enabled: enabled,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
              onChanged: onChanged,
              onFieldSubmitted: (_) {
                if (nextFocusNode != null) {
                  FocusScope.of(context).requestFocus(nextFocusNode);
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w400,
                    ),
                prefixIcon: prefixIcon,
                filled: true,
                fillColor: isStalled
                    ? AppColors.frictionBg
                    : enabled
                        ? AppColors.inputFillColor
                        : AppColors.surfaceVariant,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: maxLines > 1 ? 14 : 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isStalled ? AppColors.frictionBorder : AppColors.inputBorder,
                    width: isStalled ? 2.0 : 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isStalled ? AppColors.warning : AppColors.inputFocusBorder,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.error, width: 1.5),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                errorStyle: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),

        // Helper stall message below input if user stalled
        if (isStalled) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.timer, size: 13, color: AppColors.frictionText),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Friction event logged: User paused typing for > 5 seconds.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.frictionText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Pill badge for friction status (Tracking, Stalled, Resumed).
class _FrictionBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  const _FrictionBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Small pill badge shown in the label row to indicate lineage pass/fail.
class _LineageBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _LineageBadge({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
  });

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
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
