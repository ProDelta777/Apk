import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../data/course_data.dart';
import 'quiz_screen.dart';
import 'bookmarks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PRECODE',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 4),
              Text(
                'Learn. Code. Build.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              _buildProgressOverview(context),
              const SizedBox(height: 32),
              _buildDailyChallenge(context),
              const SizedBox(height: 32),
              _buildBookmarksLink(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressOverview(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progress, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Progress', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(label: 'XP', value: '${progress.xp}'),
                  _StatItem(label: 'Level', value: '${progress.level}'),
                  _StatItem(label: 'Streak', value: '${progress.streak} days'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyChallenge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
      ),
      child: Row(
        children: [
          Icon(Icons.star, color: Theme.of(context).colorScheme.secondary, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Challenge', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
                const SizedBox(height: 4),
                Text('Test your skills and earn extra XP!', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
               Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QuizScreen(question: CourseData.dailyChallenges.first)),
                );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Play'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksLink(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.bookmark, color: Colors.amber),
      ),
      title: const Text('My Bookmarks', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: const Text('Access your saved lessons quickly.'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookmarksScreen()),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00FF7F))),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
