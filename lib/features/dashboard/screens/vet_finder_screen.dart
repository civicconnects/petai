import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class VetFinderScreen extends StatefulWidget {
  const VetFinderScreen({super.key});

  @override
  State<VetFinderScreen> createState() => _VetFinderScreenState();
}

class _VetFinderScreenState extends State<VetFinderScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  
  // Default to a central location (e.g., San Francisco) if permission denied
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194);
  LatLng? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check Service
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _setDefaultLocation("Location services are disabled.");
      return;
    }

    // 2. Check Permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setDefaultLocation("Location permissions are denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setDefaultLocation("Location permissions are permanently denied.");
      return;
    }

    // 3. Get Position
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _loadMockVets(_currentPosition!);
      _moveCamera(_currentPosition!);
    } catch (e) {
      _setDefaultLocation("Error getting location: $e");
    }
  }

  void _setDefaultLocation(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _currentPosition = _defaultLocation;
        _isLoading = false;
      });
      _loadMockVets(_defaultLocation);
    }
  }

  Future<void> _moveCamera(LatLng pos) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: pos, zoom: 14.0),
    ));
  }

  void _loadMockVets(LatLng center) {
    // Generate some random vets around the center
    final List<Map<String, dynamic>> mockVets = [
      {
        'id': 'vet1',
        'name': 'Emergency Pet Hospital',
        'lat': center.latitude + 0.005,
        'lng': center.longitude + 0.005,
        'phone': '555-0101',
        'address': '123 Main St'
      },
      {
        'id': 'vet2',
        'name': 'City Vet Clinic',
        'lat': center.latitude - 0.004,
        'lng': center.longitude + 0.002,
        'phone': '555-0102',
        'address': '456 Oak Ave'
      },
      {
        'id': 'vet3',
        'name': 'Paws & Claws Care',
        'lat': center.latitude + 0.002,
        'lng': center.longitude - 0.006,
        'phone': '555-0103',
        'address': '789 Pine Blvd'
      },
    ];

    setState(() {
      _markers = mockVets.map((vet) {
        return Marker(
          markerId: MarkerId(vet['id']),
          position: LatLng(vet['lat'], vet['lng']),
          infoWindow: InfoWindow(
            title: vet['name'],
            snippet: vet['address'],
            onTap: () {
             // Optional: Show more info on tap
            }
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      }).toSet();
      
      // Add user location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: center,
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch dialer")));
      }
    }
  }

  Future<void> _openMaps(double lat, double lng) async {
    final Uri googleMapsUrl = Uri.parse("google.navigation:q=$lat,$lng&mode=d"); // Generic intent (Android)
    final Uri appleMapsUrl = Uri.parse("https://maps.apple.com/?daddr=$lat,$lng"); // Generic fallback

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl);
    } else {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Could not launch maps")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find a Vet'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? _defaultLocation,
              zoom: 14.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          
          // Bottom Sheet for List View
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.6,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)
                  ],
                ),
                child: Column(
                  children: [
                    // Handle Bar
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: _markers.length - 1, // Exclude user marker
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          // Filter out the user_location marker
                          final vetMarkers = _markers.where((m) => m.markerId.value != 'user_location').toList();
                          final marker = vetMarkers[index];
                          
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A90E2).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.local_hospital, color: Color(0xFF4A90E2)),
                            ),
                            title: Text(
                              marker.infoWindow.title ?? 'Vet Clinic',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(marker.infoWindow.snippet ?? ''),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.phone, color: Colors.green),
                                  onPressed: () => _makePhoneCall('555-010${index+1}'), // Mock logic
                                ),
                                IconButton(
                                  icon: const Icon(Icons.directions, color: Colors.blue),
                                  onPressed: () => _openMaps(marker.position.latitude, marker.position.longitude),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
