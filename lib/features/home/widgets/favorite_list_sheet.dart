import 'package:flutter/material.dart';

import '../../../core/models/favorite_location.dart';

/// Bottom sheet listing all favorite locations.
/// Returns the tapped [FavoriteLocation] (or null if dismissed).
class FavoriteListSheet extends StatelessWidget {
  const FavoriteListSheet({super.key, required this.locations});

  final List<FavoriteLocation> locations;

  static Future<FavoriteLocation?> show(
    BuildContext context,
    List<FavoriteLocation> locations,
  ) {
    return showModalBottomSheet<FavoriteLocation>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => FavoriteListSheet(locations: locations),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text(
                    'Favorite Locations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: locations.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final location = locations[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                    ),
                    title: Text(location.name),
                    subtitle: Text(
                      'ID: ${location.id}  •  '
                      '${location.latitude}, ${location.longitude}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pop(location),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
