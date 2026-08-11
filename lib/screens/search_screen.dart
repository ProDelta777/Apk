import 'package:flutter/material.dart';
import '../data/course_data.dart';
import '../models/lesson.dart';
import 'lesson_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  List<Lesson> _searchResults = [];

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchQuery = query;
        _searchResults = [];
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    List<Lesson> results = [];

    for (var course in CourseData.courses) {
      for (var level in course.levels) {
        for (var lesson in level.lessons) {
          if (lesson.title.toLowerCase().contains(lowercaseQuery) ||
              lesson.explanation.toLowerCase().contains(lowercaseQuery) ||
              (lesson.concept != null && lesson.concept!.toLowerCase().contains(lowercaseQuery))) {
            results.add(lesson);
          }
        }
      }
    }

    setState(() {
      _searchQuery = query;
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search for python, variables, html...',
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildEmptyState(context, 'Start typing to search across all courses.')
          : _searchResults.isEmpty
              ? _buildEmptyState(context, 'No results found for "$_searchQuery".')
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final lesson = _searchResults[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.search, color: Theme.of(context).primaryColor),
                        title: Text(lesson.title),
                        subtitle: Text(lesson.explanation, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          // Dummy courseId for search simplicity
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LessonScreen(lesson: lesson, courseId: 'unknown', totalLessons: 1),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
