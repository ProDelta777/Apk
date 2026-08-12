import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/darcula.dart';

import '../models/lesson.dart';
import '../providers/progress_provider.dart';
import '../providers/bookmark_provider.dart';
import 'compiler_screen.dart';

class LessonScreen extends StatelessWidget {
  final Lesson lesson;
  final String courseId;
  final int totalLessons;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.courseId,
    required this.totalLessons
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lesson.title),
        actions: [
          Consumer<BookmarkProvider>(
            builder: (context, bookmarkProvider, child) {
              bool isBookmarked = bookmarkProvider.isBookmarked(lesson.id);
              return IconButton(
                icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                onPressed: () {
                  bookmarkProvider.toggleBookmark(lesson.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isBookmarked ? 'Bookmark removed' : 'Lesson bookmarked')),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.title,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              lesson.explanation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            if (lesson.concept != null) ...[
              const SizedBox(height: 24),
              _buildSection(context, 'Concept', lesson.concept!),
            ],
            if (lesson.syntax != null) ...[
              const SizedBox(height: 24),
              _buildCodeBlock(context, 'Syntax', lesson.syntax!),
            ],
            if (lesson.codeExample != null) ...[
              const SizedBox(height: 24),
              _buildCodeBlock(context, 'Example', lesson.codeExample!),
            ],
             if (lesson.expectedOutput != null) ...[
              const SizedBox(height: 24),
              _buildOutputBlock(context, 'Expected Output', lesson.expectedOutput!),
            ],
            if (lesson.keyPoints != null) ...[
              const SizedBox(height: 24),
              _buildSection(context, 'Key Points', lesson.keyPoints!),
            ],
             if (lesson.commonMistakes != null) ...[
              const SizedBox(height: 24),
              _buildSection(context, 'Common Mistakes', lesson.commonMistakes!, icon: Icons.warning, color: Colors.orange),
            ],
            if (lesson.codeExample != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CompilerScreen(
                          initialCode: lesson.codeExample!,
                          language: lesson.language ?? 'python',
                          expectedOutput: lesson.expectedOutput,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.code),
                  label: const Text('Practice in Editor'),
                ),
              ),
            ],
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<ProgressProvider>().completeLesson(lesson.id, courseId, totalLessons);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lesson completed! +10 XP')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Mark as Completed', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, {IconData? icon, Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
            ],
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
          ],
        ),
        const SizedBox(height: 8),
        Text(content, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
      ],
    );
  }

  Widget _buildCodeBlock(BuildContext context, String title, String code) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
            IconButton(
              icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
              onPressed: () {
                 Clipboard.setData(ClipboardData(text: code));
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied to clipboard!')));
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFF2B2B2B), // standard dark theme bg
          ),
          clipBehavior: Clip.hardEdge,
          child: HighlightView(
            code,
            language: lesson.language ?? 'python',
            theme: darculaTheme,
            padding: const EdgeInsets.all(16),
            textStyle: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOutputBlock(BuildContext context, String title, String output) {
     return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade800),
          ),
          child: Text(
            output,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              color: Colors.white,
            )
          ),
        ),
      ],
    );
  }
}
