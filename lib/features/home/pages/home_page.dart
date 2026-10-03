import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/data/favorite_locations_data.dart';
import '../../../core/models/favorite_location.dart';
import '../../../core/services/location_service.dart';
import '../widgets/favorite_list_sheet.dart';
import '../widgets/location_details_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final LocationService _locationService = const LocationService();

  /// Starting view: Khulna city, so every favorite marker is visible.
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(22.8120, 89.5550),
    zoom: 12.6,
  );

  static const MarkerId _currentLocationMarkerId = MarkerId('current_location');

  bool _isLoadingLocation = false;
  bool _locationPermissionGranted = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkExistingPermission();
  }

  /// If permission was granted before, enable the blue "my location" dot
  /// and Google's built-in location button right away (no prompt).
  Future<void> _checkExistingPermission() async {
    final granted = await _locationService.hasPermission();
    if (mounted && granted) {
      setState(() => _locationPermissionGranted = true);
    }
  }

  // ---------------------------------------------------------------------------
  // Markers
  // ---------------------------------------------------------------------------

  Set<Marker> get _markers {
    final markers = <Marker>{
      for (final location in favoriteLocations)
        Marker(
          markerId: location.markerId,
          position: location.latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: location.name,
            snippet: 'ID: ${location.id}',
          ),
          onTap: () => LocationDetailsSheet.show(context, location),
        ),
    };

    final position = _currentPosition;
    if (position != null) {
      markers.add(
        Marker(
          markerId: _currentLocationMarkerId,
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: 'You are here',
            snippet:
                '${position.latitude.toStringAsFixed(5)}, '
                '${position.longitude.toStringAsFixed(5)}',
          ),
        ),
      );
    }
    return markers;
  }

  // ---------------------------------------------------------------------------
  // Camera helpers
  // ---------------------------------------------------------------------------

  Future<void> _moveCamera(LatLng target, {double zoom = 16}) async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: zoom)),
    );
  }

  // ---------------------------------------------------------------------------
  // Current location: get location -> lat/lng -> move camera -> show user
  // ---------------------------------------------------------------------------

  Future<void> _goToCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final Position position = await _locationService.getCurrentPosition();
      debugPrint('Current position: ${position.latitude}, ${position.longitude}');

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _locationPermissionGranted = true;
      });

      final target = LatLng(position.latitude, position.longitude);
      await _moveCamera(target);

      final controller = await _controller.future;
      await controller.showMarkerInfoWindow(_currentLocationMarkerId);
    } on LocationException catch (error) {
      _showLocationError(error);
    } catch (error) {
      _showLocationError(LocationException(error.toString()));
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _showLocationError(LocationException error) {
    if (!mounted) return;
    SnackBarAction? action;
    if (error.openSettings) {
      action = SnackBarAction(
        label: 'SETTINGS',
        onPressed: _locationService.openAppSettings,
      );
    } else if (error.openLocationSettings) {
      action = SnackBarAction(
        label: 'TURN ON',
        onPressed: _locationService.openLocationSettings,
      );
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
          action: action,
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Favorite list
  // ---------------------------------------------------------------------------

  Future<void> _openFavoriteList() async {
    final FavoriteLocation? selected =
        await FavoriteListSheet.show(context, favoriteLocations);
    if (selected == null) return;

    await _moveCamera(selected.latLng);
    final controller = await _controller.future;
    await controller.showMarkerInfoWindow(selected.markerId);
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Finder'),
        backgroundColor: colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'Favorite Locations',
            icon: const Icon(Icons.star_rounded),
            onPressed: _openFavoriteList,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCamera,
            markers: _markers,
            // Blue dot + Google's own location button (needs permission).
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: _locationPermissionGranted,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            compassEnabled: true,
            // Keep the Google logo / zoom controls clear of our buttons.
            padding: const EdgeInsets.only(bottom: 140),
            onMapCreated: (GoogleMapController controller) {
              if (!_controller.isCompleted) _controller.complete(controller);
            },
          ),
          if (_currentPosition != null)
            Positioned(
              top: 12,
              left: 12,
              right: 72,
              child: _CurrentLocationCard(position: _currentPosition!),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FloatingActionButton.extended(
            heroTag: 'favorites_fab',
            onPressed: _openFavoriteList,
            icon: const Text('📍', style: TextStyle(fontSize: 18)),
            label: const Text('Favorite Locations'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'my_location_fab',
            onPressed: _isLoadingLocation ? null : _goToCurrentLocation,
            icon: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.my_location),
            label: const Text('My Location'),
          ),
        ],
      ),
    );
  }
}

/// Small card showing the latitude & longitude returned by geolocator.
class _CurrentLocationCard extends StatelessWidget {
  const _CurrentLocationCard({required this.position});

  final Position position;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.person_pin_circle, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'My Current Location',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Lat: ${position.latitude.toStringAsFixed(6)}\n'
                    'Lng: ${position.longitude.toStringAsFixed(6)}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
