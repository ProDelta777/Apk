import 'package:flutter/material.dart';
import '../data/course_data.dart';
import '../models/quiz_question.dart';
import 'quiz_screen.dart';
import 'quiz_setup_screen.dart';
import 'compiler_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildScratchpadCard(context),
          const SizedBox(height: 16),
          _buildQuizSetupCard(context),
          const SizedBox(height: 32),
          Text('Daily Challenges', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...CourseData.dailyChallenges.map((challenge) => _buildChallengeCard(context, challenge)),
        ],
      ),
    );
  }

  Widget _buildQuizSetupCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.blue.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.blue),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const QuizSetupScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              const Icon(Icons.quiz, size: 40, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Custom Quiz', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('Test yourself with 5, 10, or 20 questions.', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScratchpadCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CompilerScreen(
                initialCode: '// Write your code here\n',
                language: 'Global',
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.code, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Code Scratchpad', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('Practice writing code freely.', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, QuizQuestion challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => QuizScreen(question: challenge)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.star, color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Challenge', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(challenge.question, style: Theme.of(context).textTheme.bodyLarge),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
