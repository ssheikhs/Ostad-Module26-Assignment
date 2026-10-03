import 'package:flutter/material.dart';

import '../../../core/models/favorite_location.dart';

/// Bottom sheet that shows the details of a tapped favorite marker.
class LocationDetailsSheet extends StatelessWidget {
  const LocationDetailsSheet({super.key, required this.location});

  final FavoriteLocation location;

  static Future<void> show(BuildContext context, FavoriteLocation location) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => LocationDetailsSheet(location: location),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text('Favorite Location', style: theme.textTheme.titleLarge),
              ],
            ),
            const Divider(height: 24),
            _DetailRow(label: 'ID', value: '${location.id}'),
            _DetailRow(label: 'Name', value: location.name),
            const SizedBox(height: 8),
            _DetailRow(label: 'Latitude', value: '${location.latitude}'),
            _DetailRow(label: 'Longitude', value: '${location.longitude}'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              '$label:',
              style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, style: textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
