// lib/features/verification/widgets/submit_button.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../verification_controller.dart';

/// Submit / Retry button that adapts to current [VerificationState].
/// Stateless — all state passed in from parent.
class SubmitButton extends StatelessWidget {
  final VerificationState state;
  final VoidCallback? onSubmit;
  final VoidCallback? onRetry;
  final VoidCallback? onClear;

  const SubmitButton({
    super.key,
    required this.state,
    this.onSubmit,
    this.onRetry,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isLoading = state == VerificationState.validating ||
        state == VerificationState.submitting;
    final isError = state == VerificationState.failClosedError ||
        state == VerificationState.networkError;
    final isSuccess = state == VerificationState.success;

    return Column(
      children: [
        // Primary action button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              onPressed: isLoading || isSuccess
                  ? null
                  : isError
                      ? onRetry
                      : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: isError
                    ? AppColors.error
                    : isSuccess
                        ? AppColors.success
                        : AppColors.primary,
                disabledBackgroundColor: isSuccess
                    ? AppColors.success
                    : AppColors.primary.withValues(alpha: 0.6),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
                elevation: isLoading ? 0 : 3,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        key: const ValueKey('loading'),
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            state == VerificationState.validating
                                ? 'Validating...'
                                : 'Submitting...',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : isSuccess
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            key: ValueKey('success'),
                            children: [
                              Icon(Icons.check_circle_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Submitted Successfully',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : isError
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                key: ValueKey('retry'),
                                children: [
                                  Icon(Icons.refresh_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    AppStrings.btnRetry,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                key: ValueKey('submit'),
                                children: [
                                  Icon(Icons.send_rounded, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    AppStrings.btnSubmit,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
              ),
            ),
          ),
        ),
        // Clear form secondary button
        if (state != VerificationState.idle) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
              child: const Text(
                AppStrings.btnClear,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
