import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/maps_theme.dart';
import '../services/maps_service.dart';
import '../widgets/primary_app_bar.dart';
import '../services/permission_service.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  _MapsScreenState createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  LatLng _currentLocation = const LatLng(0, 0);
  bool _isLoading = true;
  final MapController _mapController = MapController();
  bool _mapInitialized = false;
  Marker? _singleMarker;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
  }

  Future<void> _checkPermissionAndGetLocation() async {
    bool hasPermission =
        await PermissionService.checkAndRequestLocationPermission(context);
    if (hasPermission) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    Geolocator.getPositionStream().listen((Position position) {
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _fetchRoute(LatLng destination) async {
    try {
      final routeData = await getRouteToMarker(_currentLocation, destination);
      setState(() {
        _routePoints = routeData['coordinates'];
      });
    } catch (e) {
      debugPrint('Error fetching route: $e');
    }
  }

  void _clearMarkerAndRoute() {
    setState(() {
      _singleMarker = null;
      _routePoints = [];
    });
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _singleMarker = Marker(
        point: point,
        width: 40.0,
        height: 40.0,
        child: GestureDetector(
          onTap: _clearMarkerAndRoute,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40.0,
          ),
        ),
        alignment: Alignment.topCenter,
      );
    });
    _fetchRoute(point);
  }

  void _onMapReady() {
    setState(() {
      _mapInitialized = true;
    });
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation,
        initialZoom: 15.0,
        onTap: _onMapTap,
        onMapReady: _onMapReady,
      ),
      children: [
        TileLayer(
          urlTemplate: MapTheme.defaultMap,
          userAgentPackageName: MapTheme.userAgentPackageName,
        ),
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            Marker(
              height: 70.0,
              alignment: Alignment.center,
              point: _currentLocation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade500,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            if (_singleMarker != null) _singleMarker!,
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PrimaryAppBar(title: 'Maps Screen'),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildMap(),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                if (_mapInitialized) {
                  _mapController.move(_currentLocation, 15.0);
                }
                _checkPermissionAndGetLocation();
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
