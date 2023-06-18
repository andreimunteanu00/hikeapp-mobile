import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hikeappmobile/model/hike_history.dart';
import 'package:hikeappmobile/service/hike_history.service.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../util/constants.dart' as constants;
import '../util/halfbar_progress.dart';

class HikeHistoryScreen extends StatefulWidget {
  final PersistentTabController controller;
  final Function(Widget) handleOnGoingHike;

  const HikeHistoryScreen({super.key, required this.controller, required this.handleOnGoingHike});

  @override
  HikeHistoryScreenState createState() => HikeHistoryScreenState();
}

class HikeHistoryScreenState extends State<HikeHistoryScreen> {
  final HikeHistoryService hikeHistoryService = HikeHistoryService.instance;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<HikeHistory> hikeHistoryList = [];
  final int pageSize = 10;
  String searchTerm = '';
  bool isLoading = false;
  bool hasMore = true;
  int page = 0;
  bool startNewHike = true;

  handleStartNewHike(bool value) {
    setState(() {
      startNewHike = value;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        fetchData();
      }
    });
  }

  Future<void> fetchData() async {
    if (!isLoading && hasMore) {
      setState(() => isLoading = true);
      try {
        final entities = await hikeHistoryService.getAllEntities(
            title: searchTerm,
            page: page,
            size: pageSize);
        setState(() {
          hikeHistoryList.addAll(entities);
          page++;
          isLoading = false;
          hasMore = entities.length == pageSize;
        });
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(constants.failedToLoadData)));
      }
    }
  }

  void resetEntities() {
    setState(() {
      hikeHistoryList.clear();
      page = 0;
      hasMore = true;
    });
    fetchData();
  }

  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          // Add a clear button to the search bar
                          suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                searchTerm = '';
                                resetEntities();
                              }
                          ),
                          // Add a search icon or button to the search bar
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              resetEntities();
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        onChanged: (value) {
                          searchTerm = value;
                          if (searchTerm.isEmpty) {
                            resetEntities();
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                  child: ListView.builder(
                      controller: scrollController,
                      itemCount: hikeHistoryList.length + (hasMore ? 1 : 0),
                      itemBuilder: (BuildContext context, int index) {
                        if (index == hikeHistoryList.length) {
                          return isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : const SizedBox();
                        }
                        final HikeHistory entity = hikeHistoryList[index];
                        return Card(
                            color: const Color.fromRGBO(96, 137, 110, 0.5),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0), // Set the border radius
                              side: const BorderSide(
                                color: Color.fromRGBO(96, 137, 110, 0.5), // Set the border color
                                width: 1.0, // Set the border width
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: 100,
                                      height: 150,
                                      child: entity.hike!.mainPicture?.base64 != null
                                          ? Image.memory(base64Decode(entity.hike!.mainPicture!.base64!))
                                          : Image.asset('assets/images/default_avatar.png')),
                                  const SizedBox(width: 25),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          entity.hike!.title!,
                                          style: const TextStyle(
                                            fontSize: 24.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10.0),
                                        Row(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.timer, color: Colors.white),
                                                Text(formatDuration(entity.elapsedTime!)),
                                              ],
                                            ),
                                            const SizedBox(width: 10.0),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.star, color: Colors.amber),
                                                Text(entity.hikePoints!.toStringAsFixed(2)),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                ],
                              ),
                            ));
                      })),
              SizedBox(height: screenHeight / 100),
          ]),
            )
          ],
        ));
  }
}