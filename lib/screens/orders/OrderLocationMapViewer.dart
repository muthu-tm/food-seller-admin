import 'dart:async';

import 'package:chipchop_seller/db/models/user_locations.dart';
import 'package:chipchop_seller/screens/utils/CustomColors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import '../../app_localizations.dart';

class OrderLocationMapView extends StatefulWidget {
  final UserLocations loc;

  OrderLocationMapView(this.loc);

  @override
  _OrderLocationMapViewState createState() => _OrderLocationMapViewState();
}

class _OrderLocationMapViewState extends State<OrderLocationMapView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String searchKey = "";

  LocationData currentLocation;
// a reference to the destination location
  LocationData destinationLocation;
// wrapper around the location API
  Location location;

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();

  double cameraZoom = 13;
  double cameraTilt = 80;
  double cameraBearing = 30;

  StreamSubscription<LocationData> subscription;

  @override
  void dispose() {
    super.dispose();

    subscription.cancel();
  }

  @override
  void initState() {
    super.initState();

    location = new Location();

    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event
    subscription = location.onLocationChanged.listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      currentLocation = cLoc;
      if (currentLocation != null) updatePinOnMap();
    });

    setInitialLocation();

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

  void setInitialLocation() async {
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocation = await location.getLocation();

    // hard-coded destination for this example
    destinationLocation = LocationData.fromMap({
      "latitude": widget.loc.geoPoint.geoPoint.latitude,
      "longitude": widget.loc.geoPoint.geoPoint.longitude
    });
  }

  void updatePinOnMap() async {
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      // zoom: cameraZoom,
      tilt: cameraTilt,
      bearing: cameraBearing,
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
    );
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    // do this inside the setState() so Flutter gets notified
    // that a widget update is due
    setState(() {
      // updated position
      var pinPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);

      // the trick is to remove the marker (by id)
      // and add it again at the updated location
      _markers.removeWhere((m) => m.markerId.value == 'sourcePin');
      _markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition, // updated position
      ));
    });
  }

  void showPinsOnMap() {
    // get a LatLng for the source location
    // from the LocationData currentLocation object
    var pinPosition =
        LatLng(currentLocation.latitude, currentLocation.longitude);
    // get a LatLng out of the LocationData object
    var destPosition =
        LatLng(destinationLocation.latitude, destinationLocation.longitude);
    // add the initial source location pin
    _markers.add(Marker(
      markerId: MarkerId('sourcePin'),
      position: pinPosition,
    ));
    // destination pin
    _markers.add(Marker(
      markerId: MarkerId('destPin'),
      position: destPosition,
    ));
    // set the route lines on the map from source to destination
    // for more info follow this tutorial
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: cameraZoom,
        tilt: cameraTilt,
        bearing: cameraBearing,
        target: LatLng(widget.loc.geoPoint.geoPoint.latitude,
            widget.loc.geoPoint.geoPoint.longitude));
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: cameraZoom,
          tilt: cameraTilt,
          bearing: cameraBearing);
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Order Location View",
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: initialCameraPosition,
              compassEnabled: true,
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: true,
              tiltGesturesEnabled: false,
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
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(
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

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);

    if (currentLocation != null) showPinsOnMap();
  }
}
