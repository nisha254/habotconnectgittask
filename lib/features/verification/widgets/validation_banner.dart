// lib/features/verification/widgets/validation_banner.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../features/verification/verification_controller.dart';

/// Displays status banners based on [VerificationState].
///
/// success      → green banner + metadata trace chips
/// failClosed   → red critical banner + gate label
/// networkError → amber warning banner
///
/// Stateless — reacts purely to passed props, zero local state.
class ValidationBanner extends StatelessWidget {
  final VerificationState state;
  final String message;
  final String? traceId;
  final String? logicHash;
  final String? predecessorId;
  final String? failClosedGate;

  const ValidationBanner({
    super.key,
    required this.state,
    required this.message,
    this.traceId,
    this.logicHash,
    this.predecessorId,
    this.failClosedGate,
  });

  @override
  Widget build(BuildContext context) {
    if (state == VerificationState.idle ||
        state == VerificationState.validating ||
        state == VerificationState.submitting) {
      return const SizedBox.shrink();
    }

    final config = _configFor(state);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: config.borderColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: config.iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      Icon(config.icon, color: config.iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.title,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: config.titleColor,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      // Gate label (only for fail-closed)
                      if (failClosedGate != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            failClosedGate!,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Message ─────────────────────────────────────────────────────
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: config.messageColor,
                    height: 1.55,
                  ),
            ),

            // ── Metadata chips (trace_id, logic_hash, predecessor_id) ───────
            if (traceId != null || predecessorId != null) ...[
              const SizedBox(height: 14),
              const _Divider(),
              const SizedBox(height: 10),
              if (traceId != null)
                _MetadataChip(
                  label: 'trace_id',
                  value: traceId!,
                  chipColor: config.chipColor,
                ),
              if (traceId != null) const SizedBox(height: 6),
              if (logicHash != null)
                _MetadataChip(
                  label: 'logic_hash',
                  value: '${logicHash!.substring(0, 20)}...',
                  chipColor: config.chipColor,
                ),
              if (logicHash != null) const SizedBox(height: 6),
              if (predecessorId != null)
                _MetadataChip(
                  label: 'predecessor_id',
                  value: predecessorId == 'null'
                      ? 'null  ←  first request in session'
                      : predecessorId!.length > 20
                          ? '${predecessorId!.substring(0, 20)}...'
                          : predecessorId!,
                  chipColor: config.chipColor,
                ),
            ],
          ],
        ),
      ),
    );
  }

  _BannerConfig _configFor(VerificationState state) {
    switch (state) {
      case VerificationState.success:
        return _BannerConfig(
          bgColor: AppColors.successLight,
          borderColor: AppColors.success.withValues(alpha: 0.4),
          iconBgColor: AppColors.success.withValues(alpha: 0.15),
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          titleColor: AppColors.success,
          messageColor: const Color(0xFF1A5C34),
          chipColor: AppColors.success.withValues(alpha: 0.09),
          title: 'Submission Successful',
        );
      case VerificationState.failClosedError:
        return _BannerConfig(
          bgColor: AppColors.errorLight,
          borderColor: AppColors.error.withValues(alpha: 0.4),
          iconBgColor: AppColors.error.withValues(alpha: 0.15),
          icon: Icons.block_rounded,
          iconColor: AppColors.error,
          titleColor: AppColors.error,
          messageColor: const Color(0xFF8B1A10),
          chipColor: AppColors.error.withValues(alpha: 0.09),
          title: 'Fail-Closed Security Triggered',
        );
      case VerificationState.networkError:
        return _BannerConfig(
          bgColor: AppColors.warningLight,
          borderColor: AppColors.warning.withValues(alpha: 0.4),
          iconBgColor: AppColors.warning.withValues(alpha: 0.15),
          icon: Icons.wifi_off_rounded,
          iconColor: AppColors.warning,
          titleColor: const Color(0xFF7A5800),
          messageColor: const Color(0xFF7A5800),
          chipColor: AppColors.warning.withValues(alpha: 0.09),
          title: 'Network Error',
        );
      default:
        return const _BannerConfig(
          bgColor: Colors.transparent,
          borderColor: Colors.transparent,
          iconBgColor: Colors.transparent,
          icon: Icons.info_outline,
          iconColor: Colors.grey,
          titleColor: Colors.grey,
          messageColor: Colors.grey,
          chipColor: Colors.transparent,
          title: '',
        );
    }
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: Color(0x22000000));
}

class _MetadataChip extends StatelessWidget {
  final String label;
  final String value;
  final Color chipColor;

  const _MetadataChip({
    required this.label,
    required this.value,
    required this.chipColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          Text(
            '$label:  ',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
                color: AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerConfig {
  final Color bgColor;
  final Color borderColor;
  final Color iconBgColor;
  final IconData icon;
  final Color iconColor;
  final Color titleColor;
  final Color messageColor;
  final Color chipColor;
  final String title;

  const _BannerConfig({
    required this.bgColor,
    required this.borderColor,
    required this.iconBgColor,
    required this.icon,
    required this.iconColor,
    required this.titleColor,
    required this.messageColor,
    required this.chipColor,
    required this.title,
  });
}
