import 'package:flutter/material.dart';
import '../data/course_data.dart';
import 'quiz_screen.dart';

class QuizSetupScreen extends StatelessWidget {
  const QuizSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Quiz'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Quiz Length', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28)),
            const SizedBox(height: 16),
            Text('Test your knowledge with a custom quiz. How many questions would you like to answer?', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 48),
            _buildQuizOption(context, 5, 'Quick session'),
            _buildQuizOption(context, 10, 'Standard practice'),
            _buildQuizOption(context, 15, 'Deep dive'),
            _buildQuizOption(context, 20, 'Mastery challenge'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizOption(BuildContext context, int count, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text('$count Questions', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.play_arrow),
        onTap: () {
          // For the mock system, we just take up to the available number of questions.
          // Real system would fetch $count random questions.
          final questionsToUse = CourseData.questionBank.take(count).toList();

          if (questionsToUse.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No questions available right now.')));
            return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => QuizScreen(question: questionsToUse.first), // Simple routing for demo purposes
            ),
          );
        },
      ),
    );
  }
}
