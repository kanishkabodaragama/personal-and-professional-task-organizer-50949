import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseService {
  static Database? _database;
  static const String tableName = 'tasks';

  // PUBLIC_INTERFACE
  /// Gets the database instance, creating it if necessary
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database and creates tables
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTable,
    );
  }

  /// Creates the tasks table
  Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        dueDate INTEGER,
        category TEXT NOT NULL,
        priority TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  // PUBLIC_INTERFACE
  /// Inserts a new task into the database
  /// @param task - The task to insert
  /// @returns The ID of the inserted task
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert(tableName, task.toMap());
  }

  // PUBLIC_INTERFACE
  /// Retrieves all tasks from the database
  /// @returns List of all tasks
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // PUBLIC_INTERFACE
  /// Updates an existing task in the database
  /// @param task - The task to update
  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.update(
      tableName,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // PUBLIC_INTERFACE
  /// Deletes a task from the database
  /// @param id - The ID of the task to delete
  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // PUBLIC_INTERFACE
  /// Gets tasks by category
  /// @param category - The category to filter by
  /// @returns List of tasks in the specified category
  Future<List<Task>> getTasksByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // PUBLIC_INTERFACE
  /// Gets tasks due on a specific date
  /// @param date - The date to check for due tasks
  /// @returns List of tasks due on the specified date
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'dueDate >= ? AND dueDate <= ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }
}
