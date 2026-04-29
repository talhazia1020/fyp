import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class Maps extends StatefulWidget {
  final Function(String, String, String) onAddressSelected;

  const Maps({required this.onAddressSelected, Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

GoogleMapController? _controller;
double zoomLevel = 14;

class _MyAppState extends State<Maps> {
  String textValue = "";
  Timer? timeHandle;
  int markerCount = 0;
  String address = '';
  double? currentLat;
  double? currentLng;
  Set<Marker> markers = {};
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  void textChanged(String val) {
    textValue = val;
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
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onLongPress: (LatLng latLng) {
              _addMarker(latLng);
            },
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                zoomLevel += 1;
              });
              _controller?.animateCamera(CameraUpdate.zoomIn());
            },
            child: Center(
              child: Container(
                child: const Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Address: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            address,
                            style: TextStyle(
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (String value) {
                    // Search functionality - you can integrate a geocoding service here
                    _searchLocation(value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Search',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addMarker(LatLng position) {
    setState(() {
      markers.clear();
      markers.add(
        Marker(
          markerId: MarkerId('selected_location'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: '${position.latitude}, ${position.longitude}',
          ),
        ),
      );
      currentLat = position.latitude;
      currentLng = position.longitude;
      address = '${position.latitude}, ${position.longitude}';
      widget.onAddressSelected(address, position.latitude.toString(), position.longitude.toString());
    });
  }

  void _searchLocation(String query) {
    // For now, just show a message - you can integrate a geocoding API like Google Places
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Searching for: $query'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
