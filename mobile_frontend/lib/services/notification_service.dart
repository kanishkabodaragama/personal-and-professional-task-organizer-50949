import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/task.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // PUBLIC_INTERFACE
  /// Initializes the notification service
  /// Sets up notification channels and permissions
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create notification channel for Android
    await _createNotificationChannel();

    _isInitialized = true;
  }

  /// Creates notification channel for Android
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_reminders',
      'Task Reminders',
      description: 'Notifications for task due date reminders',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Handles notification response when user taps on notification
  void _onNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    // Could navigate to specific task or task list
    debugPrint('Notification tapped: ${response.payload}');
  }

  // PUBLIC_INTERFACE
  /// Requests notification permissions from the user
  /// @returns true if permissions are granted
  Future<bool> requestPermissions() async {
    // Request permissions for Android 13+
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }

    // Request permissions for iOS
    final iosImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return true; // Assume granted for other platforms
  }

  // PUBLIC_INTERFACE
  /// Schedules a notification for a task's due date
  /// @param task - The task to schedule notification for
  /// @param reminderMinutes - Minutes before due date to send notification
  Future<void> scheduleTaskReminder(Task task, int reminderMinutes) async {
    if (!_isInitialized) await initialize();
    
    if (task.id == null || task.dueDate == null) return;

    // Calculate notification time
    final notificationTime = task.dueDate!.subtract(Duration(minutes: reminderMinutes));
    
    // Don't schedule if the notification time is in the past
    if (notificationTime.isBefore(DateTime.now())) return;

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'task_reminders',
        'Task Reminders',
        channelDescription: 'Notifications for task due date reminders',
        importance: Importance.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.zonedSchedule(
      task.id!, // Use task ID as notification ID
      'Task Reminder: ${task.title}',
      _getReminderMessage(task, reminderMinutes),
      tz.TZDateTime.from(notificationTime, tz.local),
      notificationDetails,
      payload: task.id.toString(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // PUBLIC_INTERFACE
  /// Cancels a scheduled notification for a task
  /// @param taskId - The ID of the task to cancel notification for
  Future<void> cancelTaskReminder(int taskId) async {
    await _notifications.cancel(taskId);
  }

  // PUBLIC_INTERFACE
  /// Cancels all scheduled notifications
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  // PUBLIC_INTERFACE
  /// Updates a task reminder by canceling the old one and scheduling a new one
  /// @param task - The task to update reminder for
  /// @param reminderMinutes - Minutes before due date to send notification
  Future<void> updateTaskReminder(Task task, int reminderMinutes) async {
    if (task.id != null) {
      await cancelTaskReminder(task.id!);
      await scheduleTaskReminder(task, reminderMinutes);
    }
  }

  /// Generates appropriate reminder message based on task and reminder time
  String _getReminderMessage(Task task, int reminderMinutes) {
    if (reminderMinutes == 0) {
      return '${task.title} is due now!';
    } else if (reminderMinutes < 60) {
      return '${task.title} is due in $reminderMinutes minutes';
    } else if (reminderMinutes < 1440) { // Less than 24 hours
      final hours = (reminderMinutes / 60).round();
      return '${task.title} is due in $hours hour${hours != 1 ? 's' : ''}';
    } else {
      final days = (reminderMinutes / 1440).round();
      return '${task.title} is due in $days day${days != 1 ? 's' : ''}';
    }
  }

  // PUBLIC_INTERFACE
  /// Checks if notifications are enabled for the app
  /// @returns true if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    // Check Android permission
    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final enabled = await androidImplementation.areNotificationsEnabled();
      return enabled ?? false;
    }

    // For iOS, assume enabled (would need more complex check)
    return true;
  }

  // PUBLIC_INTERFACE
  /// Gets a list of all pending notifications
  /// @returns List of pending notification requests
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
