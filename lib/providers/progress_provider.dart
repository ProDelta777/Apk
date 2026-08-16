import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  int _xp = 0;
  int _level = 1;
  int _streak = 0;
  String _lastActiveDate = '';
  List<String> _completedLessons = [];
  Map<String, int> _courseProgress = {}; // courseId -> percentage

  int get xp => _xp;
  int get level => _level;
  int get streak => _streak;
  List<String> get completedLessons => _completedLessons;

  List<String> get earnedBadges {
    List<String> badges = [];
    if (_completedLessons.isNotEmpty) badges.add('First Lesson');
    if (_completedLessons.length >= 10) badges.add('10 Lessons');
    if (_streak >= 7) badges.add('7 Day Streak');
    // Add more badge logic as needed based on specific courses
    return badges;
  }

  ProgressProvider() {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    _prefs = await SharedPreferences.getInstance();
    _xp = _prefs?.getInt('xp') ?? 0;
    _level = _prefs?.getInt('level') ?? 1;
    _streak = _prefs?.getInt('streak') ?? 0;
    _lastActiveDate = _prefs?.getString('lastActiveDate') ?? '';
    _completedLessons = _prefs?.getStringList('completedLessons') ?? [];

    // Load course progress (simple JSON string representation for now)
    // Real implementation would use jsonDecode
    _checkStreak();
    notifyListeners();
  }

  void _checkStreak() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    if (_lastActiveDate.isEmpty) {
      _lastActiveDate = today;
      _streak = 1;
      _saveProgress();
    } else if (_lastActiveDate != today) {
       DateTime last = DateTime.parse(_lastActiveDate);
       DateTime current = DateTime.parse(today);
       if (current.difference(last).inDays == 1) {
         _streak++;
       } else if (current.difference(last).inDays > 1) {
         _streak = 1; // Reset streak
       }
       _lastActiveDate = today;
       _saveProgress();
    }
  }

  void completeLesson(String lessonId, String courseId, int totalLessonsInCourse) {
    if (!_completedLessons.contains(lessonId)) {
      _completedLessons.add(lessonId);
      _xp += 10;
      _checkLevelUp();

      // Update course progress
      int currentCompleted = _courseProgress[courseId] ?? 0;
      _courseProgress[courseId] = currentCompleted + 1;

      _saveProgress();
      notifyListeners();
    }
  }

  void completeQuiz() {
    _xp += 20;
    _checkLevelUp();
    _saveProgress();
    notifyListeners();
  }

  void _checkLevelUp() {
    // Simple level system: 100 XP per level
    int newLevel = (_xp ~/ 100) + 1;
    if (newLevel > _level) {
      _level = newLevel;
    }
  }

  double getCourseProgress(String courseId, int totalLessons) {
    if (totalLessons == 0) return 0.0;
    int completed = getCourseCompletedCount(courseId);
    return completed / totalLessons;
  }

  int getCourseCompletedCount(String courseId) {
      int completed = 0;
      String prefixShort = '${courseId.substring(0, 2)}_';
      String prefixFull = '${courseId}_';
      for (String lessonId in _completedLessons) {
       if (lessonId.startsWith(prefixShort) || lessonId.startsWith(prefixFull)) {
          completed++;
       }
    }
    return completed;
  }

  Future<void> _saveProgress() async {
    if (_prefs == null) return;
    await _prefs?.setInt('xp', _xp);
    await _prefs?.setInt('level', _level);
    await _prefs?.setInt('streak', _streak);
    await _prefs?.setString('lastActiveDate', _lastActiveDate);
    await _prefs?.setStringList('completedLessons', _completedLessons);
  }

  Future<void> resetProgress() async {
    _xp = 0;
    _level = 1;
    _streak = 0;
    _completedLessons = [];
    _courseProgress = {};
    _lastActiveDate = '';

    if (_prefs != null) {
      await _prefs?.clear();
    }
    notifyListeners();
  }
}
