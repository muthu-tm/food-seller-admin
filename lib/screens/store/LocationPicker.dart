import 'package:chipchop_seller/app_localizations.dart';
import 'package:chipchop_seller/db/models/geopoint_data.dart';
import 'package:chipchop_seller/db/models/store.dart';
import 'package:chipchop_seller/screens/home/HomeScreen.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:chipchop_seller/screens/utils/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatefulWidget {
  LocationPicker(this.store);

  final Store store;
  @override
  State createState() => LocationPickerState();
}

class LocationPickerState extends State<LocationPicker> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  GoogleMapController mapController;
  Geoflutterfire geo = Geoflutterfire();

  GeoPointData geoData;

  final Set<Marker> _markers = {};
  String searchKey = "";

  @override
  void initState() {
    super.initState();
    this.searchKey = widget.store.address.pincode;
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('title_add_location'),
        ),
        backgroundColor: CustomColors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.green,
        onPressed: () {
          if (geoData == null || geoData.geoHash.isEmpty) {
            _scaffoldKey.currentState.showSnackBar(
              CustomSnackBar.errorSnackBar(
                  "Please PIN your location correctly!", 2),
            );
            return;
          }
          widget.store.geoPoint = geoData;
          try {
            widget.store.create();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => HomeScreen(),
                settings: RouteSettings(name: '/'),
              ),
            );
          } catch (err) {
            _scaffoldKey.currentState.showSnackBar(
              CustomSnackBar.errorSnackBar(
                  "Sorry, Unable to create your store now. Please try again later!",
                  2),
            );
          }
        },
        label: Text(
          AppLocalizations.of(context).translate('button_create_store'),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: LatLng(12.9716, 77.5946), zoom: 5),
              onTap: (latlang) {
                if (_markers.length >= 1) {
                  _markers.clear();
                }

                _onAddMarkerButtonPressed(latlang);
              },
              compassEnabled: true,
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: true,
              mapToolbarEnabled: true,
              myLocationEnabled: true,
              markers: _markers,
              mapType: MapType.normal,
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 80,
              child: Card(
                elevation: 5.0,
                color: CustomColors.white,
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)
                        .translate('hint_search_with_picode'),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(5),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () async {
                        if (searchKey != "") await _searchAndNavigate();
                      },
                    ),
                  ),
                  autofocus: false,
                  onChanged: (val) {
                    setState(
                      () {
                        searchKey = val;
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _searchAndNavigate() async {
    try {
      List<Placemark> marks =
          await Geolocator().placemarkFromAddress(searchKey);
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 11,
            target:
                LatLng(marks[0].position.latitude, marks[0].position.longitude),
          ),
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  void _onAddMarkerButtonPressed(LatLng latlang) async {
    String hashID = _loadAddress(latlang.latitude, latlang.longitude);

    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(hashID),
        position: latlang,
        infoWindow: InfoWindow(
          title: "${widget.store.name}",
          //  snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  String _loadAddress(double latitude, double longitude) {
    GeoFirePoint point = geo.point(latitude: latitude, longitude: longitude);
    GeoPointData geoPoint = GeoPointData();
    geoPoint.geoHash = point.hash;
    geoPoint.geoPoint = point.geoPoint;
    geoData = geoPoint;
    return point.hash;
  }

  _animateToUser() async {
    Position pos = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(pos.latitude, pos.latitude),
      zoom: 10.0,
    )));
    _loadAddress(pos.latitude, pos.longitude);
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
