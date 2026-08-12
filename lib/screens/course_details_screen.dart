import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../providers/progress_provider.dart';
import 'lesson_screen.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Course course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            ...course.levels.map((level) => _buildLevelSection(context, level)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelSection(BuildContext context, CourseLevel level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            level.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        ...level.lessons.map((lesson) => _buildLessonItem(context, lesson)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLessonItem(BuildContext context, Lesson lesson) {
    return Consumer<ProgressProvider>(
      builder: (context, progress, child) {
        bool isCompleted = progress.completedLessons.contains(lesson.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              isCompleted ? Icons.check_circle : Icons.play_circle_outline,
              color: isCompleted ? Theme.of(context).primaryColor : Colors.grey,
            ),
            title: Text(lesson.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LessonScreen(lesson: lesson, courseId: course.id, totalLessons: course.totalLessons),
                ),
              );
            },
          ),
        );
      }
    );
  }
}
