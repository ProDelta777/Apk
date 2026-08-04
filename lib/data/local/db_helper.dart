import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE scanned_documents (
  id $idType,
  title $textType,
  category $textType,
  path $textType,
  createdAt $textType,
  isFavorite $integerType
)
''');

    await db.execute('''
CREATE TABLE checklists (
  id $idType,
  documentType $textType,
  item $textType,
  isCompleted $integerType
)
''');

    await db.execute('''
CREATE TABLE reminders (
  id $idType,
  title $textType,
  expiryDate $textType,
  isNotified $integerType
)
''');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
