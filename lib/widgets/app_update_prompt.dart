import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/app_links.dart';
import 'package:c_editor/data/launch_external_url.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/services/app_update_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _remindAfterKey = 'app_update_remind_after';

String appUpdateErrorMessage(AppLocalizations l10n, Object error) {
  if (error is! AppUpdateException) return l10n.updateCheckUnknownAdvice;
  return switch (error.kind) {
    AppUpdateErrorKind.timeout => l10n.networkTimeoutAdvice,
    AppUpdateErrorKind.rateLimited => l10n.networkRateLimitAdvice,
    AppUpdateErrorKind.network => l10n.networkConnectionAdvice,
    AppUpdateErrorKind.unavailable => l10n.networkServiceAdvice,
    AppUpdateErrorKind.invalidResponse => l10n.networkResponseAdvice,
    AppUpdateErrorKind.unknown => l10n.updateCheckUnknownAdvice,
  };
}

/// A background check never blocks entry to the workspace or reports failures.
class AutomaticAppUpdateCheck extends StatefulWidget {
  const AutomaticAppUpdateCheck({super.key, required this.child, this.service});

  final Widget child;
  final AppUpdateService? service;

  @override
  State<AutomaticAppUpdateCheck> createState() =>
      _AutomaticAppUpdateCheckState();
}

class _AutomaticAppUpdateCheckState extends State<AutomaticAppUpdateCheck> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (mounted && context.read<SettingsCubit>().state.checkForUpdates) {
      checkForAppUpdates(context, automatic: true, service: widget.service);
    }
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) =>
            !previous.checkForUpdates && current.checkForUpdates,
        listener: (_, _) => _check(),
        child: widget.child,
      );
}

Future<void> checkForAppUpdates(
  BuildContext context, {
  bool automatic = false,
  AppUpdateService? service,
}) async {
  try {
    final result = await (service ?? AppUpdateService.instance).checkForUpdates(
      automatic: automatic,
    );
    if (!context.mounted) return;
    if (automatic &&
        (!context.read<SettingsCubit>().state.checkForUpdates ||
            ModalRoute.of(context)?.isCurrent == false)) {
      return;
    }
    if (result.status == AppUpdateCheckStatus.skipped) return;
    if (result.status == AppUpdateCheckStatus.upToDate) {
      if (!automatic) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            scrollable: true,
            title: Text(AppLocalizations.of(context)!.updateNotNeededTitle),
            content: Text(AppLocalizations.of(context)!.updateAlreadyLatest),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        );
      }
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (!context.mounted) return;
    if (automatic &&
        (prefs.getInt(_remindAfterKey) ?? 0) >
            DateTime.now().millisecondsSinceEpoch) {
      return;
    }
    final links = await AppLinks.load();
    if (!context.mounted) return;
    if (automatic &&
        (!context.read<SettingsCubit>().state.checkForUpdates ||
            ModalRoute.of(context)?.isCurrent == false)) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AppUpdateDialog(
        links: links,
        version: result.latestRelease!.version,
        releaseUrl: result.latestRelease!.releaseUrl.toString(),
      ),
    );
    // Returning to the workspace should not immediately reopen this dialog.
    await prefs.setInt(
      _remindAfterKey,
      DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch,
    );
  } catch (error) {
    if (automatic || !context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final message = appUpdateErrorMessage(l10n, error);
    final links = await AppLinks.load();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) =>
          AppUpdateDialog(links: links, errorMessage: message),
    );
  }
}

/// Shared by manual and automatic checks so version and download links agree.
class AppUpdateDialog extends StatelessWidget {
  const AppUpdateDialog({
    super.key,
    required this.links,
    this.version,
    this.releaseUrl,
    this.errorMessage,
  });

  final AppLinks links;
  final String? version;
  final String? releaseUrl;
  final String? errorMessage;

  Future<void> _open(BuildContext context, String url) async {
    var opened = false;
    try {
      opened = await launchExternalUrl(url);
    } catch (_) {
      // The platform may not have a browser or may refuse the launch.
    }
    if (opened || !context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: Text(l10n.error),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.externalLinkFailedAdvice),
            const SizedBox(height: 12),
            SelectableText(url),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Clipboard.setData(ClipboardData(text: url)),
            child: Text(l10n.copy),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chinese = Localizations.localeOf(context).languageCode == 'zh';
    return AlertDialog(
      key: const ValueKey('appUpdateDialog'),
      scrollable: true,
      constraints: const BoxConstraints(maxWidth: 520),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(
        errorMessage == null
            ? l10n.updateAvailableTitle
            : l10n.updateCheckFailedTitle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(errorMessage ?? l10n.updateAvailableBody(version!)),
          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(l10n.updateCheckFailedLinks),
          ] else ...[
            const SizedBox(height: 12),
            Text(l10n.updateSaveWorkGuidance),
          ],
          if (kIsWeb && errorMessage == null) ...[
            const SizedBox(height: 12),
            Text(l10n.webUpdateSaveAndRefresh),
          ],
          if (!kIsWeb || errorMessage != null) ...[
            if (errorMessage == null) ...[
              const SizedBox(height: 20),
              Text(l10n.updateDownload),
              const SizedBox(height: 4),
              Text(
                l10n.updateDownloadDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('appUpdateDownloadGithub'),
                  onPressed: () => _open(context, releaseUrl ?? links.releases),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.updateGithubDownload),
                ),
                if (chinese && links.baiduDownload.isNotEmpty)
                  OutlinedButton.icon(
                    key: const ValueKey('appUpdateDownloadBaidu'),
                    onPressed: () => _open(context, links.baiduDownload),
                    icon: const Icon(Icons.cloud_download_outlined),
                    label: Text(l10n.updateBaiduDownload),
                  ),
                if (errorMessage != null &&
                    chinese &&
                    links.updateBilibili.isNotEmpty)
                  OutlinedButton.icon(
                    key: const ValueKey('appUpdateBilibili'),
                    onPressed: () => _open(context, links.updateBilibili),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l10n.updateOpenBilibili),
                  ),
                if (errorMessage != null &&
                    !chinese &&
                    links.cEditorInviteLink.isNotEmpty)
                  OutlinedButton.icon(
                    key: const ValueKey('appUpdateDiscord'),
                    onPressed: () => _open(context, links.cEditorInviteLink),
                    icon: const Icon(Icons.forum_outlined),
                    label: Text(l10n.updateJoinDiscord),
                  ),
              ],
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            errorMessage == null
                ? l10n.updateLater
                : MaterialLocalizations.of(context).closeButtonLabel,
          ),
        ),
      ],
    );
  }
}
