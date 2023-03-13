import 'dart:async';
import 'dart:math' show cos, sqrt, asin;

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../util/constants.dart' as constants;
import '../widget/timer.widget.dart';
class StartHikeScreen extends StatefulWidget {
  final LatLng startPoint;
  final LatLng finalDestination;

  const StartHikeScreen({super.key, required this.finalDestination, required this.startPoint});

  @override
  StartHikeScreenState createState() => StartHikeScreenState();
}

class StartHikeScreenState extends State<StartHikeScreen> {
  late Completer<GoogleMapController> mapController = Completer();
  final Set<Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = constants.googleApiDirections;
  LatLng userLocation = const LatLng(0, 0);
  late StreamSubscription<Position> positionStream;
  bool firstTime = true;
  double distance = 0.0;
  bool isLoading = true;
  bool canStart = true;
  late Timer timer;
  int secondsElapsed = 0;
  int minutesElapsed = 0;
  int hoursElapsed = 0;

  void onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
  }

  void getUserLocation() async {
    positionStream = Geolocator.getPositionStream().listen(
      (Position position) {
        setState(() {
          userLocation = LatLng(position.latitude, position.longitude);
          getPolyline(userLocation, widget.finalDestination);
          isLoading = false;
          if (firstTime) {
            mapController.future.then((controller) => controller.animateCamera(CameraUpdate.newLatLng(userLocation)) as CameraPosition);
            firstTime = false;
            isLoading = false;
          }
        });
    });
  }


  addPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        points: polylineCoordinates,
        color: Colors.blueAccent,
        width: 5,
        jointType: JointType.mitered,
        patterns: const [PatternItem.dot]
    );
    polylineCoordinates = [];
    polylines[id] = polyline;
  }

  getPolyline(LatLng start, LatLng end) async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleAPiKey,
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(end.latitude, end.longitude),
        travelMode: TravelMode.walking);
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    calculateDistance();
    addPolyLine();
    setState(() {});
  }

  double coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  void calculateDistance() {
    distance = 0.0;
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      distance += coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }
  }

  void getTime() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        secondsElapsed++;
        if (secondsElapsed >= 60) {
          secondsElapsed = 0;
          minutesElapsed++;
        }
        if (minutesElapsed >= 60) {
          minutesElapsed = 0;
          hoursElapsed++;
        }
      });
    });
  }

  void checkCanStart() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    final error = coordinateDistance(position.latitude, position.longitude,
        widget.startPoint.latitude, widget.startPoint.longitude);
    print('sssss');
    if (error * 1000 > 50) {
      setState(() {
        canStart = false;
      });
    }
  }

  Future<bool> onBackPressed() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }

  @override
  void initState() {
    super.initState();
    checkCanStart();
    getUserLocation();
    getTime();
    markers.add(
        Marker(
            markerId: const MarkerId('endPosition'),
            infoWindow: const InfoWindow(title: 'End Position'),
            position: widget.finalDestination,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRose,
            )
        )
    );
  }

  @override
  void dispose() {
    timer.cancel();
    positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(constants.appTitle)),
      body: isLoading ? const Center(child: CircularProgressIndicator()) :
      !canStart ? Center(child: Column(children: [
        const Text('Can\'t start'),
        ElevatedButton(
          child: const Text('Retry'),
          onPressed: () => checkCanStart(),
        ),
      ],)) : WillPopScope(
        onWillPop: onBackPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TimerWidget(secondsElapsed: secondsElapsed, minutesElapsed: minutesElapsed, hoursElapsed: hoursElapsed),
            const SizedBox(height: 8.0),
            Center(
              child: Text(
                'Distance: ${distance.toStringAsFixed(2)} meters',
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wb_sunny,
                  size: 24.0,
                ),
                SizedBox(width: 8.0),
                Text(
                  'zxczx',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                SizedBox(width: 16.0),
                Icon(
                  Icons.thermostat,
                  size: 24.0,
                ),
                SizedBox(width: 8.0),
                Text(
                  'zxc °C',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ],
            ),
          ],
        ),
            Expanded(
              child: GoogleMap(
                onMapCreated: onMapCreated,
                markers: markers,
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                        (userLocation.latitude + widget.finalDestination.latitude) / 2,
                        (userLocation.longitude + widget.finalDestination.longitude) / 2
                    ),
                    zoom: 11
                ),
                polylines: Set<Polyline>.of(polylines.values),
                myLocationEnabled: true,
                mapToolbarEnabled: true,
                buildingsEnabled: false,
                myLocationButtonEnabled: true,
                mapType: MapType.normal,
                zoomControlsEnabled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}