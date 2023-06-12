import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hikeappmobile/model/hike_history.dart';
import 'package:hikeappmobile/service/hike_history.service.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../util/constants.dart' as constants;

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
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration:
                    const InputDecoration(hintText: 'Search by name'),
                    onChanged: (value) {
                      searchTerm = value;
                      if (searchTerm.isEmpty) {
                        resetEntities();
                      }
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      resetEntities();
                    },
                    child: const Icon(Icons.search)),
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
                        child: Row(
                          children: [
                            SizedBox(
                                width: 100,
                                height: 150,
                                // TODO change it with default
                                child: entity.hike!.mainPicture?.base64 != null
                                    ? Image.memory(base64Decode(entity.hike!.mainPicture!.base64!))
                                    : Image.network(
                                    'https://www.google.com/search?q=Image+Decoration+deprecated+flutter&rlz=1C1GCEU_enRO1027RO1027&sxsrf=AJOqlzUggdOqsdmzx1JhxFgfupfFaKfDbA:1677518002812&source=lnms&tbm=isch&sa=X&ved=2ahUKEwi5uKXFmbb9AhVUtKQKHbb9B6oQ_AUoAXoECAEQAw&biw=1920&bih=929&dpr=1#imgrc=GfQxngkfsluSLM')),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    entity.hike!.title!,
                                    style: const TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.timer),
                                      const SizedBox(width: 8.0),
                                      Text(formatDuration(entity.elapsedTime!)),
                                    ],
                                  ),
                                  const SizedBox(height: 16.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.star),
                                      const SizedBox(width: 8.0),
                                      Text(entity.hikePoints!.toStringAsFixed(2)),
                                    ],
                                  ),
                                ],
                              )
                          ],
                        ));
                  })),
          SizedBox(height: screenHeight / 100),
        ]));
  }
}