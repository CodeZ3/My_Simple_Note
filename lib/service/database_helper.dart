import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Helper class to manage SQLite database operations.
class DatabaseHelper {
  // Database configuration constants
  static const String _dbName = 'notes.db'; // Name of the database file
  static const int _dbVersion = 1; // Database version for migrations
  static const String _tableName = 'notes'; // Name of the table
  static const String _colId = 'id'; // Column for unique note ID (Primary Key)
  static const String _colTitle = 'title'; // Column for note title
  static const String _colContent = 'content'; // Column for note content
  static const String _colDateAdded = 'date_added'; // Column for note creation date

  static Database? _database; // Singleton instance of the database

  /// Singleton pattern to ensure only one instance of DatabaseHelper exists.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  /// Returns the database instance, initializes it if not already initialized.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database by setting the path and opening the connection.
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath(); // Get the default database path
    final path = join(dbPath, _dbName); // Construct the full path for the database
    print("Database path: $path"); // Debug log for database path
    return await openDatabase(
      path,
      version: _dbVersion, // Database version
      onCreate: _onCreate, // Callback to handle table creation
    );
  }

  /// Callback method to create the database schema during the first initialization.
Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE $_tableName (
      $_colId INTEGER PRIMARY KEY AUTOINCREMENT,
      $_colTitle TEXT NOT NULL,
      $_colContent TEXT NOT NULL,
      $_colDateAdded TEXT NOT NULL
    )
  ''');
}

  /// Inserts a new note into the database.
  ///
  /// Adds the current timestamp to the `date_added` field automatically.
  /// Returns the ID of the inserted note.
  Future<int> insertNote(Map<String, dynamic> note) async {
    final db = await database; // Get the database instance
    note[_colDateAdded] = DateTime.now().toIso8601String(); // Add current date-time
    return await db.insert(_tableName, note); // Insert the note into the table
  }

  /// Fetches all notes from the database.
  ///
  /// Notes are ordered by the `date_added` column in descending order.
  /// Returns a list of maps, where each map represents a note.
  Future<List<Map<String, dynamic>>> fetchNotes() async {
    final db = await database;
    return await db.query('notes', orderBy: 'date_added DESC');
  }

  /// Updates an existing note in the database.
  /// Expects the `id` field to identify the note to be updated.
  /// Returns the number of rows affected.
  Future<int> updateNote(int id, Map<String, dynamic> note) async {
    final db = await database; // Get the database instance
    return await db.update(
      _tableName, // Table name
      note, // Updated note data
      where: '$_colId = ?', // Where clause to find the note by ID
      whereArgs: [id], // Arguments for the where clause
    );
  }



  /// Deletes a note from the database.
  /// Expects the `id` of the note to be deleted.
  /// Returns the number of rows affected.
  Future<int> deleteNote(int id) async {
    final db = await database; // Get the database instance
    return await db.delete(
      _tableName, // Table name
      where: '$_colId = ?', // Where clause to find the note by ID
      whereArgs: [id], // Arguments for the where clause
    );
  }
}
