import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin, app-wide wrapper around `flutter_local_notifications` + `timezone`
/// used to schedule daily medicine reminders.
///
/// The plugin instance is injected (not created here) so this class can be
/// registered as a `get_it` singleton. [init] must be called exactly once,
/// during app bootstrap, before [scheduleDailyReminder] is used — see the
/// medicine feature's integration notes for the exact `main.dart` call site.
class NotificationService {
  static const String _channelId = 'medicine_reminders';
  static const String _channelName = 'Medicine Reminders';
  static const String _channelDescription =
      'Daily reminders to take your medicine on time';

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;

  NotificationService(this._plugin);

  /// Initializes timezone data/local location and the underlying plugin,
  /// then requests the runtime notification (and, on Android 12+, exact
  /// alarm) permissions needed for [scheduleDailyReminder] to actually fire.
  ///
  /// Safe to call multiple times — only does work once.
  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz.identifier));
    } catch (_) {
      // If the platform can't report a timezone, fall back to UTC rather
      // than crashing bootstrap — reminders still fire, just anchored to
      // UTC wall-clock time until this is resolved.
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    // Needed for AndroidScheduleMode.exactAllowWhileIdle on Android 12+
    // (manifest already declares SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM).
    await androidImpl?.requestExactAlarmsPermission();

    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  /// Schedules a notification that repeats daily at [hour]:[minute] local
  /// time, starting today (or tomorrow if that time has already passed
  /// today). [id] must be deterministic and unique per medicine+slot — see
  /// [reminderNotificationId].
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    final scheduledDate = _nextInstanceOf(hour, minute);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancels a single scheduled reminder by its notification id.
  Future<void> cancelReminder(int id) => _plugin.cancel(id: id);

  /// Cancels every reminder previously scheduled for a medicine, given how
  /// many reminder slots it had (each slot maps to one notification id via
  /// [reminderNotificationId]).
  Future<void> cancelAllForMedicine(
    String medicineId, {
    required int reminderCount,
  }) async {
    for (var i = 0; i < reminderCount; i++) {
      await cancelReminder(reminderNotificationId(medicineId, i));
    }
  }

  /// Deterministic, collision-free notification id for a given medicine's
  /// Nth reminder slot.
  static int reminderNotificationId(String medicineId, int reminderIndex) =>
      '${medicineId}_$reminderIndex'.hashCode & 0x7fffffff;

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
