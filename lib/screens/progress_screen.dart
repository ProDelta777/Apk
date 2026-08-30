import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../providers/progress_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progress, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(context, progress),
                const SizedBox(height: 32),
                Text('Badges Earned', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                _buildBadgesGrid(context, progress),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, ProgressProvider progress) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(context, 'Level', '${progress.level}', LucideIcons.trendingUp, Theme.of(context).primaryColor),
        _buildStatCard(context, 'Total XP', '${progress.xp}', LucideIcons.star, Colors.amber),
        _buildStatCard(context, 'Day Streak', '${progress.streak}', LucideIcons.flame, Colors.deepOrange),
        _buildStatCard(context, 'Lessons', '${progress.completedLessons.length}', LucideIcons.checkCircle, Colors.blue),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildBadgesGrid(BuildContext context, ProgressProvider progress) {
    final badges = progress.earnedBadges;

    if (badges.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(LucideIcons.award, size: 64, color: Colors.grey.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('Complete lessons to earn badges!', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: const Icon(LucideIcons.award, color: Colors.amber, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              badge,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 2,
            ),
          ],
        );
      },
    );
  }
}
