import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/document_repository.dart';

final documentRepositoryProvider = Provider((ref) => DocumentRepository());

final documentsProvider = StateNotifierProvider<DocumentNotifier, List<Map<String, dynamic>>>((ref) {
  return DocumentNotifier(ref.read(documentRepositoryProvider));
});

class DocumentNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final DocumentRepository _repository;

  DocumentNotifier(this._repository) : super([]) {
    loadDocuments();
  }

  Future<void> loadDocuments() async {
    final docs = await _repository.getDocuments();
    state = docs;
  }

  Future<void> addDocument(String title, String category, String path) async {
    await _repository.insertDocument(title, category, path);
    await loadDocuments();
  }

  Future<void> toggleFavorite(int id, int currentStatus) async {
    await _repository.toggleFavorite(id, currentStatus == 1 ? 0 : 1);
    await loadDocuments();
  }

  Future<void> deleteDocument(int id) async {
    await _repository.deleteDocument(id);
    await loadDocuments();
  }
}
