import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapPreviewWidget extends StatefulWidget {
  final LatLng startPosition;
  final LatLng endPosition;

  const MapPreviewWidget({super.key, required this.startPosition, required this.endPosition});

  @override
  MapPreviewWidgetState createState() => MapPreviewWidgetState();
}

class MapPreviewWidgetState extends State<MapPreviewWidget> {

  late Completer<GoogleMapController> mapController = Completer();
  final Set<Marker> markers = {};
  late Position currentPosition;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  // TODO not ok
  String googleAPiKey = "AIzaSyCLBLimbgcnj-1nHDWIInOnTlShWsZF-r4";

  void onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
  }

  @override
  void initState() {
    super.initState();
    markers.add(
        Marker(
          markerId: MarkerId('startPosition'),
          infoWindow: const InfoWindow(title: 'Start Position'),
          position: widget.startPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        )
    );
    markers.add(
        Marker(
            markerId: MarkerId('endPosition'),
            infoWindow: const InfoWindow(title: 'End Position'),
            position: widget.endPosition,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRose,
            )
        )
    );
    getPolyline(widget.startPosition, widget.endPosition);
    mapController.future.then((controller) => controller.animateCamera(CameraUpdate.newLatLng(widget.startPosition)) as CameraPosition);
    setState(() {});
  }

  addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        points: polylineCoordinates,
        color: Colors.blueAccent,
        width: 5,
        jointType: JointType.mitered,
        patterns: const [PatternItem.dot]
    );
    polylines[id] = polyline;
    setState(() {

    });
  }

  getPolyline(LatLng start, LatLng end) async {
    print(start);
    print(end);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(end.latitude, end.longitude),
        travelMode: TravelMode.walking);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    addPolyLine();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: onMapCreated,
        markers: markers,
        initialCameraPosition: CameraPosition(
            target: LatLng(
                (widget.startPosition.latitude + widget.endPosition.latitude) / 2,
                (widget.startPosition.longitude + widget.endPosition.longitude) / 2
            ),
            zoom: 11
        ),
        polylines: Set<Polyline>.of(polylines.values),
        myLocationEnabled: false,
        mapToolbarEnabled: true,
        buildingsEnabled: false,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        zoomControlsEnabled: true,
      ),
    );
  }
}