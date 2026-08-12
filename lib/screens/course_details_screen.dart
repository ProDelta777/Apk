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
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
        ...level.lessons.map((lesson) => _buildLessonItem(context, lesson)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLessonItem(BuildContext context, Lesson lesson) {
    return Consumer<ProgressProvider>(
      builder: (context, progress, child) {
        bool isCompleted = progress.completedLessons.contains(lesson.id);

        // Unlocking logic: Level 1 is always unlocked.
        // Higher levels require the immediate previous level to be completed.
        bool isUnlocked = false;
        if (lesson.levelNumber == 1 || isCompleted) {
            isUnlocked = true;
        } else {
            // check if previous level is completed
            Lesson? prevLesson = course.getLessonByLevel(lesson.levelNumber - 1);
            if (prevLesson != null && progress.completedLessons.contains(prevLesson.id)) {
                isUnlocked = true;
            }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isUnlocked ? null : Theme.of(context).cardColor.withOpacity(0.5),
          child: ListTile(
            leading: Icon(
              isCompleted ? Icons.check_circle : (isUnlocked ? Icons.play_circle_outline : Icons.lock),
              color: isCompleted ? Theme.of(context).primaryColor : Colors.grey,
            ),
            title: Text(
                lesson.title,
                style: TextStyle(color: isUnlocked ? null : Colors.grey)
            ),
            trailing: Icon(Icons.chevron_right, color: isUnlocked ? null : Colors.grey),
            onTap: () {
              if (!isUnlocked) {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Complete previous levels to unlock this level.'))
                 );
                 return;
              }
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
