import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson.dart';
import '../data/course_data.dart';

class BookmarkProvider extends ChangeNotifier {
  SharedPreferences? _prefs;
  List<String> _bookmarkedLessonIds = [];

  List<String> get bookmarkedLessonIds => _bookmarkedLessonIds;

  BookmarkProvider() {
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    _prefs = await SharedPreferences.getInstance();
    _bookmarkedLessonIds = _prefs?.getStringList('bookmarks') ?? [];
    notifyListeners();
  }

  void toggleBookmark(String lessonId) {
    if (_bookmarkedLessonIds.contains(lessonId)) {
      _bookmarkedLessonIds.remove(lessonId);
    } else {
      _bookmarkedLessonIds.add(lessonId);
    }
    _saveBookmarks();
    notifyListeners();
  }

  bool isBookmarked(String lessonId) {
    return _bookmarkedLessonIds.contains(lessonId);
  }

  Future<void> _saveBookmarks() async {
    await _prefs?.setStringList('bookmarks', _bookmarkedLessonIds);
  }

  List<Lesson> getBookmarkedLessons() {
    List<Lesson> lessons = [];
    for (var course in CourseData.courses) {
      for (var level in course.levels) {
        for (var lesson in level.lessons) {
          if (_bookmarkedLessonIds.contains(lesson.id)) {
             lessons.add(lesson);
          }
        }
      }
    }
    return lessons;
  }
}
