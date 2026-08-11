import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/course_data.dart';
import '../models/course.dart';
import '../providers/progress_provider.dart';
import 'course_details_screen.dart';
import 'search_screen.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: CourseData.courses.length,
        itemBuilder: (context, index) {
          return _buildCourseCard(context, CourseData.courses[index]);
        },
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Course course) {
    return Consumer<ProgressProvider>(
      builder: (context, progress, child) {
        int totalLessons = course.totalLessons;
        double percentage = progress.getCourseProgress(course.id, totalLessons);
        int completedCount = progress.getCourseCompletedCount(course.id);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CourseDetailsScreen(course: course)),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.code, color: Theme.of(context).primaryColor), // Using standard icon as placeholder
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course.title, style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 4),
                            Text('$completedCount / $totalLessons Lessons Completed', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(course.description, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    color: Theme.of(context).primaryColor,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text('${(percentage * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
