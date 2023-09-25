import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationPicker extends StatefulWidget {
  final Function(LatLng)? onLocationSelected;

  LocationPicker({super.key, this.onLocationSelected});

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  final LatLng _initialPosition = LatLng(37.7749, -122.4194); // San Francisco
  LatLng _selectedPosition = LatLng(0, 0);

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedPosition = position;
    });
    // widget.onLocationSelected!(LatLng(position.latitude, position.longitude));
    Navigator.pop(context, LatLng(position.latitude, position.longitude));
  }

  _moveToSelectedPosition() {
    if (_mapController != null) {
      return _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _selectedPosition, zoom: 15),
      ));
    }
  }

  Future<void> _searchLocation(String query) async {
    List<Location> locations = await locationFromAddress(query);
    if (locations.isNotEmpty) {
      setState(() {
        _selectedPosition =
            LatLng(locations[0].latitude, locations[0].longitude);
      });
      await _moveToSelectedPosition();
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context, LatLng(locations[0].latitude, locations[0].longitude));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Location'),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Location',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            _searchLocation(_searchController.text);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 400,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: _initialPosition, zoom: 13),
                    onTap: _onMapTapped,
                    onMapCreated: _onMapCreated,
                    markers: {
                      Marker(
                          markerId: MarkerId('selected'),
                          position: _selectedPosition),
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
