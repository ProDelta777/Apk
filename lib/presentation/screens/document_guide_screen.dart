import 'package:flutter/material.dart';
import '../../data/models/document_guide.dart';

class DocumentGuideScreen extends StatelessWidget {
  final DocumentGuide guide;

  const DocumentGuideScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(guide.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(theme, "Purpose", guide.purpose),
            _buildSection(theme, "Eligibility", guide.eligibility),
            _buildListSection(theme, "Required Documents", guide.requiredDocuments),
            _buildListSection(theme, "Step-by-step Process", guide.processSteps, isNumbered: true),
            _buildSection(theme, "Estimated Time", guide.estimatedTime),
            _buildSection(theme, "Important Notes", guide.importantNotes, color: Colors.amber.shade700),
            _buildSection(theme, "Common Mistakes", guide.commonMistakes, color: Colors.red.shade400),

            if (guide.faq.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text("FAQ", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...guide.faq.map((q) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(76),
                  child: ExpansionTile(
                    title: Text(q["Q"] ?? "", style: const TextStyle(fontWeight: FontWeight.w600)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(q["A"] ?? ""),
                      )
                    ],
                  ),
                ),
              )),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content, {Color? color}) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          Text(content, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }

  Widget _buildListSection(ThemeData theme, String title, List<String> items, {bool isNumbered = false}) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isNumbered ? "${entry.key + 1}. " : "• ",
                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(entry.value, style: theme.textTheme.bodyLarge),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
