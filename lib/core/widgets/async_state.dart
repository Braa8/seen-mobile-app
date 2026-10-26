import 'package:flutter/material.dart';
import '../theme/seen_theme.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message = 'نحضّر لك المشهد...'});
  final String message;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 2.5)),
      const SizedBox(height: 16), Text(message, style: Theme.of(context).textTheme.bodyMedium),
    ]),
  ));
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_off_rounded, size: 38, color: SeenColors.muted),
      const SizedBox(height: 12), Text(message, textAlign: TextAlign.center),
      const SizedBox(height: 16), OutlinedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('إعادة المحاولة')),
    ]),
  ));
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.subtitle, this.icon = Icons.inbox_outlined});
  final String title, subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(30),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 44, color: SeenColors.muted), const SizedBox(height: 12),
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 6), Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
    ]),
  ));
}
