import 'package:flutter/material.dart';
import '../data/course_data.dart';
import '../models/quiz_question.dart';
import 'quiz_screen.dart';

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
          Text('Daily Challenges', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ...CourseData.dailyChallenges.map((challenge) => _buildChallengeCard(context, challenge)).toList(),
        ],
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
