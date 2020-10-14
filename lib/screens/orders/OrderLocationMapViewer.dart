import 'package:chipchop_seller/db/models/geopoint_data.dart';
import 'package:chipchop_seller/db/models/user_locations.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../app_localizations.dart';

class OrderLocationMapView extends StatefulWidget {
  final UserLocations loc;

  OrderLocationMapView(this.loc);

  @override
  _OrderLocationMapViewState createState() => _OrderLocationMapViewState();
}

class _OrderLocationMapViewState extends State<OrderLocationMapView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController mapController;
  String searchKey = "";
  GeoPointData geoData;
  Set<Marker> _markers = {};
  Geoflutterfire geo = Geoflutterfire();

  @override
  void initState() {
    super.initState();

    _animateToUser();

    _markers.add(
      Marker(
        markerId: MarkerId(
          widget.loc.geoPoint.geoHash,
        ),
        position: LatLng(widget.loc.geoPoint.geoPoint.latitude,
            widget.loc.geoPoint.geoPoint.longitude),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('title_add_location'),
          textAlign: TextAlign.start,
          style: TextStyle(color: CustomColors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: CustomColors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: CustomColors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: CustomColors.alertRed,
        onPressed: () {
          Navigator.pop(context);
        },
        label: Text(
          "Close",
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(widget.loc.geoPoint.geoPoint.latitude,
                      widget.loc.geoPoint.geoPoint.longitude),
                  zoom: 15),
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

  _animateToUser() async {
    Position pos = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);

    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(pos.latitude, pos.latitude),
      zoom: 12.0,
    )));
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }
}
