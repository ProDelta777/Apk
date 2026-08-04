
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/document_controller.dart';
import 'package:path/path.dart' as p;

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(documentsProvider);
    final theme = Theme.of(context);

    final favorites = docs.where((d) => d['isFavorite'] == 1).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search functionality coming soon')),
              );
            }
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: "All"),
                Tab(text: "Favorites"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(docs, theme, ref),
                  _buildList(favorites, theme, ref),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, ThemeData theme, WidgetRef ref) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: theme.colorScheme.surfaceContainerHighest),
            const SizedBox(height: 16),
            Text("No documents found.", style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final doc = items[index];
        final id = doc['id'] as int;
        final title = doc['title'] as String;
        final path = doc['path'] as String;
        final isFav = (doc['isFavorite'] as int) == 1;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf, color: theme.colorScheme.primary, size: 40),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(p.basename(path), maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(isFav ? Icons.star : Icons.star_border, color: isFav ? Colors.amber : null),
                  onPressed: () => ref.read(documentsProvider.notifier).toggleFavorite(id, doc['isFavorite']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, ref, id),
                ),
              ],
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF viewing capability coming soon')),
              );
            },
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Document?"),
        content: const Text("Are you sure you want to delete this document from the local storage?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(documentsProvider.notifier).deleteDocument(id);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red))
          ),
        ],
      )
    );
  }
}
