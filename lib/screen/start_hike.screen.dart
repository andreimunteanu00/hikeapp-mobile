import 'dart:async';
import 'dart:math' show cos, sqrt, asin;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hikeappmobile/model/hike_summary.dart';
import 'package:hikeappmobile/screen/no_hike_ongoing.screen.dart';
import 'package:hikeappmobile/service/hike_history.service.dart';
import 'package:hikeappmobile/util/colors.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../util/constants.dart' as constants;
import '../widget/timer.widget.dart';
import '../widget/weather.widget.dart';
import 'finish_hike.screen.dart';

class StartHikeScreen extends StatefulWidget {
  final String hikeTitle;
  final LatLng startPoint;
  final LatLng endPoint;
  final PersistentTabController controller;
  final Function(Widget) handleOnGoingHike;
  final Function(bool) handleStartNewHike;

  const StartHikeScreen({
    super.key,
    required this.endPoint,
    required this.startPoint,
    required this.hikeTitle,
    required this.controller,
    required this.handleOnGoingHike,
    required this.handleStartNewHike
  });

  @override
  StartHikeScreenState createState() => StartHikeScreenState();
}

class StartHikeScreenState extends State<StartHikeScreen> {
  late Completer<GoogleMapController> mapController = Completer();
  final Set<Marker> markers = {};
  Map<PolylineId, Polyline> polylineMap = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  String googleAPiKey = constants.googleApiDirectionsKey;
  LatLng userLocation = const LatLng(0, 0);
  late StreamSubscription<Position> positionStream;
  bool firstTime = true;
  bool isLoading = true;
  bool canStart = true;
  double distance = 0.0;
  late Timer timer;
  int secondsElapsed = 0;
  int minutesElapsed = 0;
  int hoursElapsed = 0;
  final Stopwatch stopwatch = Stopwatch();
  double temperatureAverage = 0.0;
  int temperatureAverageCount = 0;
  HikeHistoryService hikeHistoryService = HikeHistoryService.instance;

  void onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
  }

  void getUserLocation() async {
    positionStream = Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        userLocation = LatLng(position.latitude, position.longitude);
        getPolyline(userLocation, widget.endPoint);
      });
      if (firstTime) {
        setState(() {
          mapController.future.then((controller) =>
              controller.animateCamera(CameraUpdate.newLatLng(userLocation))
                  as CameraPosition);
          firstTime = false;
          isLoading = false;
        });
      }
      if (canStart) {
        checkFinish(position);
      }
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
        patterns: const [PatternItem.dot]);
    polylineCoordinates = [];
    polylineMap[id] = polyline;
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
  }

  double coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * 1000 * asin(sqrt(a));
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
        Duration elapsed = stopwatch.elapsed;
        hoursElapsed = (elapsed.inHours % 24);
        minutesElapsed = (elapsed.inMinutes % 60);
        secondsElapsed = (elapsed.inSeconds % 60);
      });
    });
    stopwatch.start();
  }

  void checkCanStart() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    final error = coordinateDistance(position.latitude, position.longitude,
        widget.startPoint.latitude, widget.startPoint.longitude);
    if (error > 50) {
      setState(() {
        canStart = false;
      });
    }
  }

  Future<bool> onBackPressed() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure you want to exit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void setMarkers() {
    markers.add(Marker(
        markerId: const MarkerId('endPosition'),
        infoWindow: const InfoWindow(title: 'End Position'),
        position: widget.endPoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRose,
        )));
  }

  void checkFinish(Position position) async {
    final distanceFromFinish = coordinateDistance(
        position.latitude,
        position.longitude,
        widget.endPoint.latitude,
        widget.endPoint.longitude);
    if (distanceFromFinish < 50) {
      widget.handleStartNewHike(true);
      stopwatch.stop();
      HikeSummary hikeSummary = HikeSummary(
          hikeTitle: widget.hikeTitle,
          elapsedTime: stopwatch.elapsed,
          temperatureAverage: temperatureAverage);
      await hikeHistoryService.postHikeHistory(hikeSummary);
      widget.handleOnGoingHike(FinishHikeScreen(
          hikeTitle: hikeSummary.hikeTitle,
          temperatureAverage: temperatureAverage,
          handleOnGoingHike: widget.handleOnGoingHike));
    }
  }

  void handleTempChanged(double value) {
    if (temperatureAverage == 0.0) {
      temperatureAverage = value;
      temperatureAverageCount++;
    } else {
      temperatureAverage += value;
      temperatureAverageCount++;
    }
  }

  @override
  void initState() {
    super.initState();
    checkCanStart();
    if (canStart) {
      getUserLocation();
      getTime();
      setMarkers();
    }
  }

  @override
  void dispose() {
    timer.cancel();
    positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text(constants.appTitle)),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_image.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Adjust the blur intensity as desired
            child:isLoading
                ? const Center(child: CircularProgressIndicator())
                : !canStart
                ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.9,
                      child: const Text(
                          'In order to commence, it is necessary for you to be in closer proximity to the start point.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20, color: Colors.white)
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      child: const Text('Retry'),
                      onPressed: () => checkCanStart(),
                    ),
                    ElevatedButton(
                      child: const Text('Exit'),
                      onPressed: () {
                        widget.controller.jumpToTab(1);
                        widget.handleStartNewHike(true);
                        widget.handleOnGoingHike(const NoHikeOngoingScreen());
                      }
                    ),
                  ],
                ))
                : WillPopScope(
              onWillPop: onBackPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TimerWidget(
                              secondsElapsed: secondsElapsed,
                              minutesElapsed: minutesElapsed,
                              hoursElapsed: hoursElapsed,
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              children: [
                                const SizedBox(width: 8.0),
                                const Icon(
                                  Icons.directions_run,
                                  size: 24.0,
                                  color: primary,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  '${distance.toStringAsFixed(0)} meters',
                                  style: const TextStyle(
                                    fontSize: 18.0, color: primary
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        WeatherWidget(
                          position: userLocation,
                          handleValueChanged: handleTempChanged,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight / 75),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: screenHeight / 1.6,
                        width: screenWidth,
                        child: GoogleMap(
                          onMapCreated: onMapCreated,
                          markers: markers,
                          initialCameraPosition: CameraPosition(
                              target: LatLng(
                                  (userLocation.latitude +
                                      widget.endPoint.latitude) /
                                      2,
                                  (userLocation.longitude +
                                      widget.endPoint.longitude) /
                                      2),
                              zoom: 11),
                          polylines: Set<Polyline>.of(polylineMap.values),
                          myLocationEnabled: true,
                          mapToolbarEnabled: true,
                          buildingsEnabled: false,
                          myLocationButtonEnabled: true,
                          mapType: MapType.normal,
                          zoomControlsEnabled: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      )
    );
  }
}
