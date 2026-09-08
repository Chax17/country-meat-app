import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dedicated service to coordinate OS notification permission requests.
///
/// Keeps permission logic completely isolated from business state (AppState).
class NotificationPermissionService {
  static const String _kPrefInitialPromptAttempted =
      'hasPromptedInitialNotificationPermission';

  static final NotificationPermissionService _instance =
      NotificationPermissionService._internal();
  factory NotificationPermissionService() => _instance;
  NotificationPermissionService._internal();

  /// Checks if the initial notification permission request has already been attempted.
  Future<bool> hasPromptedInitialPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kPrefInitialPromptAttempted) ?? false;
    } catch (e) {
      debugPrint('Error reading notification permission flag: $e');
      return false;
    }
  }

  /// Marks the initial notification permission request as attempted.
  Future<void> _markInitialPromptAttempted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kPrefInitialPromptAttempted, true);
    } catch (e) {
      debugPrint('Error setting notification permission flag: $e');
    }
  }

  /// Handles the initial notification permission request on first app open.
  ///
  /// Only prompts if not previously attempted and not already granted or permanently blocked.
  Future<void> requestInitialPermissionIfNeeded() async {
    try {
      final alreadyPrompted = await hasPromptedInitialPermission();
      if (alreadyPrompted) {
        return;
      }

      final status = await Permission.notification.status;
      if (status.isGranted || status.isProvisional || status.isPermanentlyDenied) {
        await _markInitialPromptAttempted();
        return;
      }

      // First time and permission is requestable: prompt the native OS dialog
      await Permission.notification.request();

      // Persist that the initial request attempt was made so that
      // a denial does not cause repeated prompts on future app launches.
      await _markInitialPromptAttempted();
    } catch (e) {
      debugPrint('Error during initial notification permission request: $e');
    }
  }

  /// Handles notification permission request after a successful order placement.
  ///
  /// If the user previously denied permission and the OS still permits
  /// requesting it, displays the native prompt. Does nothing if already
  /// granted or permanently denied.
  Future<void> requestPostOrderPermissionIfNeeded() async {
    try {
      final status = await Permission.notification.status;

      // If already granted, provisional, or permanently blocked in settings, do nothing
      if (status.isGranted || status.isProvisional || status.isPermanentlyDenied) {
        return;
      }

      // If status is denied and the OS allows another request, prompt the native dialog
      if (status.isDenied) {
        await Permission.notification.request();
        await _markInitialPromptAttempted();
      }
    } catch (e) {
      debugPrint('Error during post-order notification permission request: $e');
    }
  }
}
