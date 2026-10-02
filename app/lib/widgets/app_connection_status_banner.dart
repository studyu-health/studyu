import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class const AppConnectionStatusBannerHost({
  required final Widget child,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final status = state.connectionStatus;
        final showBanner =
            !state.isPreview && status != AppConnectionStatus.healthy;

        return Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              child: showBanner
                  ? _AppConnectionStatusBanner(status: status)
                  : const SizedBox.shrink(),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class const _AppConnectionStatusBanner({
  required final AppConnectionStatus status,
}) extends StatelessWidget {
  static const _borderRadius = 18.0;
  static const _outerPadding = EdgeInsets.fromLTRB(12, 8, 12, 0);
  static const _innerPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static const _iconContainerSize = 30.0;
  static const _iconSize = 17.0;
  static const _messageTextColor = Color(0xFF18405A);
  static const _messageFontSize = 13.5;
  static const _messageLineHeight = 1.28;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final message = switch (status) {
      AppConnectionStatus.deviceOffline => loc.connection_banner_device_offline,
      AppConnectionStatus.backendUnavailable =>
        loc.connection_banner_backend_unavailable,
      AppConnectionStatus.healthy => '',
    };

    return SafeArea(
      bottom: false,
      child: Semantics(
        container: true,
        liveRegion: true,
        label: message,
        child: Padding(
          padding: _outerPadding,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_borderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                key: ValueKey(status),
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.84),
                      _accentColor(status).withValues(alpha: 0.10),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(_borderRadius),
                  border: Border.all(
                    color: _accentColor(status).withValues(alpha: 0.24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: _innerPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: _iconContainerSize,
                      height: _iconContainerSize,
                      decoration: BoxDecoration(
                        color: _accentColor(status).withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        status == AppConnectionStatus.deviceOffline
                            ? Icons.cloud_off
                            : Icons.cloud_queue,
                        color: _accentColor(status),
                        size: _iconSize,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _messageTextColor,
                              fontWeight: FontWeight.w600,
                              height: _messageLineHeight,
                              fontSize: _messageFontSize,
                            ) ??
                            const TextStyle(
                              color: _messageTextColor,
                              fontWeight: FontWeight.w600,
                              height: _messageLineHeight,
                              fontSize: _messageFontSize,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _accentColor(AppConnectionStatus status) {
    return switch (status) {
      AppConnectionStatus.deviceOffline => const Color(0xFF2D7FF9),
      AppConnectionStatus.backendUnavailable => const Color(0xFF4A8CFF),
      AppConnectionStatus.healthy => const Color(0xFF2D7FF9),
    };
  }
}
