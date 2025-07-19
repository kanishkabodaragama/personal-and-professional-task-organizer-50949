# Task Notification Features

This document describes the notification features implemented in the Task Organizer mobile app.

## Features Implemented

### 1. Local Notifications Integration
- Integrated `flutter_local_notifications` plugin for cross-platform local notifications
- Added `timezone` package for proper scheduling of notifications
- Configured Android permissions and notification channels

### 2. Task Reminder System
- Users can enable/disable reminders for individual tasks
- Configurable reminder times:
  - At due time
  - 15 minutes before
  - 30 minutes before
  - 1 hour before
  - 2 hours before
  - 1 day before
  - 2 days before
  - 1 week before

### 3. Enhanced Task Model
- Added `hasReminder` boolean field to track if reminder is enabled
- Added `reminderMinutes` integer field to store reminder time preference
- Updated database schema with migration support for existing installations

### 4. User Interface Updates
- Added reminder settings section in Add/Edit Task screen
- Reminder options appear when a due date is set
- Visual indicators on task cards showing when reminders are active
- Settings screen includes notification permission management

### 5. Notification Management
- Automatic scheduling of notifications when tasks are created/updated
- Automatic cancellation when tasks are deleted or reminders disabled
- Permission request handling for Android 13+ and iOS
- Proper notification channels for Android

## Usage

1. **Setting up a reminder:**
   - Create or edit a task
   - Set a due date
   - Enable the reminder toggle
   - Choose when to be notified (default: 1 hour before)

2. **Managing notification permissions:**
   - Go to Settings
   - Find the "Notifications" section
   - Enable/disable due date reminders
   - Grant permissions when prompted

3. **Visual indicators:**
   - Tasks with active reminders show a notification bell icon
   - Task cards display priority flags and reminder status

## Technical Implementation

### Database Changes
- Added two new columns to tasks table:
  - `hasReminder INTEGER NOT NULL DEFAULT 0`
  - `reminderMinutes INTEGER NOT NULL DEFAULT 60`
- Implemented database migration from version 1 to version 2

### Android Configuration
- Added notification permissions in AndroidManifest.xml
- Enabled core library desugaring for Java 8+ features
- Configured notification receivers for boot completion

### Notification Service
- Singleton service managing all notification operations
- Timezone-aware scheduling using `TZDateTime`
- Proper cleanup when tasks are modified or deleted
- Permission handling for different Android versions

## Future Enhancements

Potential improvements that could be added:
- Custom notification sounds
- Recurring reminders
- Smart notification grouping
- Notification action buttons (Mark as complete, Snooze)
- Integration with system calendar
- Multiple reminders per task
