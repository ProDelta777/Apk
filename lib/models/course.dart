import 'lesson.dart';
import 'quiz_question.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String icon;
  final List<CourseLevel> levels;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.levels,
  });

  int get totalLessons {
    return levels.fold(0, (sum, level) => sum + level.lessons.length);
  }

  Lesson? getLessonByLevel(int levelNumber) {
    for (var section in levels) {
      for (var lesson in section.lessons) {
        if (lesson.levelNumber == levelNumber) {
          return lesson;
        }
      }
    }
    return null;
  }
}

class CourseLevel {
  final String title; // "FOUNDATION (Levels 1-20)", etc.
  final List<Lesson> lessons;
  final List<QuizQuestion> quizzes;

  CourseLevel({
    required this.title,
    required this.lessons,
    required this.quizzes,
  });
}
