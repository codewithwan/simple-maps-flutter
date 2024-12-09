import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

Future<Map<String, dynamic>> getRoute(LatLng start, LatLng end) async {
  final url =
      'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final route = data['routes'][0];
    final waypoints = data['waypoints'];
    return {
      'coordinates': (route['geometry']['coordinates'] as List)
          .map((coord) => LatLng(coord[1], coord[0]))
          .toList(),
      'distance': route['distance'],
      'duration': route['duration'],
      'startLocationName': waypoints[0]['name'],
      'endLocationName': waypoints[1]['name'],
    };
  } else {
    throw Exception('Failed to load route');
  }
}

Future<Map<String, dynamic>> getRouteToMarker(LatLng start, LatLng end) =>
    getRoute(start, end);
