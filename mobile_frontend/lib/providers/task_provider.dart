import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = false;
  
  List<Task> get tasks => _filteredTasks;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  
  TaskProvider() {
    _initializeNotifications();
    loadTasks();
  }
  
  /// Initializes notification service
  Future<void> _initializeNotifications() async {
    await _notificationService.initialize();
  }
  
  // PUBLIC_INTERFACE
  /// Loads all tasks from the database
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _tasks = await _databaseService.getAllTasks();
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // PUBLIC_INTERFACE
  /// Adds a new task
  /// @param task - The task to add
  Future<void> addTask(Task task) async {
    try {
      final id = await _databaseService.insertTask(task);
      final newTask = task.copyWith(id: id);
      _tasks.add(newTask);
      
      // Schedule notification if reminder is enabled
      if (newTask.hasReminder && newTask.dueDate != null) {
        await _notificationService.scheduleTaskReminder(
          newTask, 
          newTask.reminderMinutes,
        );
      }
      
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }
  
  // PUBLIC_INTERFACE
  /// Updates an existing task
  /// @param task - The task to update
  Future<void> updateTask(Task task) async {
    try {
      await _databaseService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        
        // Handle notification updates
        if (task.id != null) {
          if (task.hasReminder && task.dueDate != null) {
            // Schedule or update notification
            await _notificationService.updateTaskReminder(
              task, 
              task.reminderMinutes,
            );
          } else {
            // Cancel notification if reminder is disabled
            await _notificationService.cancelTaskReminder(task.id!);
          }
        }
        
        _applyFilters();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }
  
  // PUBLIC_INTERFACE
  /// Deletes a task
  /// @param taskId - The ID of the task to delete
  Future<void> deleteTask(int taskId) async {
    try {
      await _databaseService.deleteTask(taskId);
      
      // Cancel any scheduled notification
      await _notificationService.cancelTaskReminder(taskId);
      
      _tasks.removeWhere((task) => task.id == taskId);
      _applyFilters();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }
  
  // PUBLIC_INTERFACE
  /// Toggles the completion status of a task
  /// @param taskId - The ID of the task to toggle
  Future<void> toggleTaskCompletion(int taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await updateTask(updatedTask);
    }
  }
  
  // PUBLIC_INTERFACE
  /// Sets the search query and filters tasks
  /// @param query - The search query string
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }
  
  // PUBLIC_INTERFACE
  /// Sets the selected category filter
  /// @param category - The category to filter by
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }
  
  /// Applies current filters to the task list
  void _applyFilters() {
    _filteredTasks = _tasks.where((task) {
      // Category filter
      if (_selectedCategory != 'All' && task.category != _selectedCategory) {
        return false;
      }
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        return task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               task.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      
      return true;
    }).toList();
    
    // Sort by due date and completion status
    _filteredTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }
      return 0;
    });
  }
  
  // PUBLIC_INTERFACE
  /// Gets tasks for a specific date (for calendar view)
  /// @param date - The date to get tasks for
  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == date.year &&
             task.dueDate!.month == date.month &&
             task.dueDate!.day == date.day;
    }).toList();
  }
  
  // PUBLIC_INTERFACE
  /// Gets the count of tasks for a specific category
  /// @param category - The category to count tasks for
  int getTaskCountForCategory(String category) {
    if (category == 'All') {
      return _tasks.length;
    }
    return _tasks.where((task) => task.category == category).length;
  }
  
  // PUBLIC_INTERFACE
  /// Gets all unique categories from existing tasks
  List<String> getAvailableCategories() {
    final categories = <String>{'All'};
    for (final task in _tasks) {
      if (task.category.isNotEmpty) {
        categories.add(task.category);
      }
    }
    return categories.toList()..sort();
  }
  
  // PUBLIC_INTERFACE
  /// Clears all active filters
  void clearAllFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _applyFilters();
    notifyListeners();
  }
  
  // PUBLIC_INTERFACE
  /// Checks if any filters are currently active
  bool get hasActiveFilters {
    return _searchQuery.isNotEmpty || _selectedCategory != 'All';
  }
}
