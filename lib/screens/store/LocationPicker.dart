import 'package:chipchop_seller/app_localizations.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatefulWidget {
  @override
  State createState() => LocationPickerState();
}

class LocationPickerState extends State<LocationPicker> {
  TextEditingController _addressController = TextEditingController();

  GoogleMapController mapController;
  Geoflutterfire geo = Geoflutterfire();

  final Set<Marker> _markers = {};
  String searchKey = "";
  Position pos;

  @override
  void initState() {
    super.initState();

    _animateToUser();
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Store Location"),
        backgroundColor: CustomColors.sellerPurple,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height - 300,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(12.9716, 77.5946),
                      ),
                      onTap: (latlang) {
                        if (_markers.length >= 1) {
                          _markers.clear();
                        }

                        _onAddMarkerButtonPressed(latlang);
                      },
                      compassEnabled: true,
                      onMapCreated: _onMapCreated,
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
                        color: CustomColors.sellerWhite,
                        child: TextField(
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: "Enter Address",
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
              Padding(
                padding: EdgeInsets.only(left: 15.0, top: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    AppLocalizations.of(context).translate('location'),
                    style: TextStyle(
                        fontFamily: "Georgia",
                        color: CustomColors.sellerGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, top: 10),
                child: Container(
                  child: TextField(
                    autofocus: false,
                    maxLines: 6,
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context).translate('location'),
                      fillColor: CustomColors.sellerWhite,
                      filled: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 3.0, horizontal: 3.0),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: CustomColors.sellerWhite),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            zoom: 10,
            target:
                LatLng(marks[0].position.latitude, marks[0].position.longitude),
          ),
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  _updateAddress(double latitude, double longitude) async {
    try {
      List<Placemark> marks =
          await Geolocator().placemarkFromCoordinates(latitude, longitude);

      String _address =
          (marks[0].thoroughfare != "" ? marks[0].thoroughfare + ",\n" : "") +
              (marks[0].subLocality != "" ? marks[0].subLocality + ",\n" : "") +
              (marks[0].locality != "" ? marks[0].locality + ",\n" : "") +
              (marks[0].administrativeArea != ""
                  ? marks[0].administrativeArea + ",\n"
                  : "") +
              (marks[0].country != "" ? marks[0].country + ",\n" : "") +
              (marks[0].postalCode != "" ? marks[0].postalCode + "" : "");

      setState(() {
        _addressController.text = _address;
      });
    } catch (err) {
      print(err.toString());
    }
  }

  void _onAddMarkerButtonPressed(LatLng latlang) async {
    String hashID = _loadAddress(latlang.latitude, latlang.longitude);
    await _updateAddress(latlang.latitude, latlang.longitude);

    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(hashID),
        position: latlang,
        infoWindow: InfoWindow(
          title: "address",
          //  snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  String _loadAddress(double latitude, double longitude) {
    GeoFirePoint point = geo.point(latitude: latitude, longitude: longitude);
    return point.hash;
  }

  _animateToUser() async {
    Position pos = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(pos.latitude, pos.latitude),
      zoom: 17.0,
    )));
    _loadAddress(pos.latitude, pos.longitude);
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
