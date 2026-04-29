import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class RegisterMaps extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;

  const RegisterMaps({required this.destinationLat, required this.destinationLng});

  @override
  _RegisterMapsState createState() => _RegisterMapsState();
}

class _RegisterMapsState extends State<RegisterMaps> {
  GoogleMapController? _controller;
  double zoomLevel = 14;
  String textValue = "";
  Timer? timeHandle;
  int markerCount = 0;
  double? currentLat;
  double? currentLng;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  // Variables to manage visibility of buttons
  bool isDroppinVisible = true;
  bool isMyLocationVisible = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition();
        setState(() {
          currentLat = position.latitude;
          currentLng = position.longitude;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      // Default to Lahore coordinates if location fails
      setState(() {
        currentLat = 24.8607;
        currentLng = 67.0011;
      });
    }
  }

  @override
  void dispose() {
    timeHandle?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void textChanged(String val) {
    setState(() {
      textValue = val;
    });
    timeHandle?.cancel();
    timeHandle = Timer(const Duration(seconds: 3), () {
      if (textValue.isNotEmpty) {
        print("Calling API Here: $textValue");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                currentLat ?? 24.8607,
                currentLng ?? 67.0011,
              ),
              zoom: zoomLevel,
            ),
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onLongPress: (LatLng latLng) {
              _addMarker(latLng);
            },
          ),
          if (isDroppinVisible)
            GestureDetector(
              onTap: () {
                setState(() {
                  zoomLevel += 1;
                  isDroppinVisible = false;
                });
                _controller?.animateCamera(CameraUpdate.zoomIn());
              },
              child: Center(
                child: Image.asset(
                  'assets/droppin.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          if (isMyLocationVisible)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (currentLat != null && currentLng != null) {
                          _addPolyline(
                              currentLat!, currentLng!, widget.destinationLat,
                              widget.destinationLng);
                        }
                        setState(() {
                          isMyLocationVisible = false;
                          isDroppinVisible = false;
                        });
                      },
                      child: Image.asset(
                        'assets/mylocation.png',
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _addMarker(LatLng position) {
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId('marker_$markerCount'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Location',
            snippet: '${position.latitude}, ${position.longitude}',
          ),
        ),
      );
      markerCount++;
    });
  }

  void _addPolyline(double currentLat, double destLat, double currentLng, double destLng) {
    setState(() {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: [
            LatLng(currentLat, currentLng),
            LatLng(destLat, destLng),
          ],
          color: Colors.blue,
          width: 2,
        ),
      );
    });
  }
}
