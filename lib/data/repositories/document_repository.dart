import '../local/db_helper.dart';

class DocumentRepository {
  Future<int> insertDocument(String title, String category, String path) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('scanned_documents', {
      'title': title,
      'category': category,
      'path': path,
      'createdAt': DateTime.now().toIso8601String(),
      'isFavorite': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getDocuments() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('scanned_documents', orderBy: 'createdAt DESC');
  }

  Future<List<Map<String, dynamic>>> getFavoriteDocuments() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('scanned_documents', where: 'isFavorite = ?', whereArgs: [1], orderBy: 'createdAt DESC');
  }

  Future<void> toggleFavorite(int id, int isFavorite) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('scanned_documents', {'isFavorite': isFavorite}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteDocument(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('scanned_documents', where: 'id = ?', whereArgs: [id]);
  }
}
