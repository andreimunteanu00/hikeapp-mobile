import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../model/hike.model.dart';
import '../screen/hike_detail.screen.dart';
import '../service/hike.service.dart';
import '../util/constants.dart' as constants;
import '../widget/hike_item_list.widget.dart';

class HikeListScreen extends StatefulWidget {
  final PersistentTabController controller;
  final Function(Widget) handleOnGoingHike;

  const HikeListScreen({
    Key? key,
    required this.controller,
    required this.handleOnGoingHike
  }) : super(key: key);

  @override
  HikeListScreenState createState() => HikeListScreenState();
}

class HikeListScreenState extends State<HikeListScreen> {
  final HikeService hikeService = HikeService.instance;
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<Hike> hikeList = [];
  final int pageSize = 10;
  String sortBy = 'title';
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
        final entities = await hikeService.getAllEntities(
            title: searchTerm,
            sortField: sortBy,
            page: page,
            size: pageSize);
        setState(() {
          hikeList.addAll(entities);
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
      hikeList.clear();
      page = 0;
      hasMore = true;
    });
    fetchData();
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
                            suffixIcon: !searchTerm.isEmpty ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                searchTerm = '';
                                resetEntities();
                              }
                            ) : null,
                            // Add a search icon or button to the search bar
                            prefixIcon: IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () {
                                resetEntities();
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          onEditingComplete: () {
                            resetEntities();
                          },
                          onChanged: (value) {
                            searchTerm = value;
                            if (searchTerm.isEmpty) {
                              resetEntities();
                            }
                          },
                        ),
                      ),
                      SizedBox(width: screenWidth / 20),
                      DropdownButton<String>(
                        value: sortBy,
                        borderRadius: BorderRadius.circular(20.0),
                        items: const [
                          DropdownMenuItem(
                              value: 'title', child: Icon(Icons.abc_rounded)),
                          DropdownMenuItem(
                              value: 'allRatings', child: Icon(Icons.star_rate)),
                          DropdownMenuItem(
                              value: 'numberRatings', child: Icon(Icons.numbers_rounded)),
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            sortBy = value;
                            resetEntities();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                        controller: scrollController,
                        itemCount: hikeList.length + (hasMore ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == hikeList.length) {
                            return isLoading
                                ? const Center(child: CircularProgressIndicator())
                                : const SizedBox();
                          }
                          final Hike entity = hikeList[index];
                          return GestureDetector(
                              onTap: () {
                                PersistentNavBarNavigator.pushNewScreen(
                                  context,
                                  screen: HikeDetailScreen(
                                      hikeTitle: entity.title!,
                                      controller: widget.controller,
                                      handleOnGoingHike: widget.handleOnGoingHike,
                                      handleStartNewHike: handleStartNewHike,
                                      startNewHike: startNewHike),
                                  withNavBar: true,
                                  pageTransitionAnimation:
                                      PageTransitionAnimation.fade,
                                );
                              },
                              child: HikeItemList(
                                  entity: entity, screenWidth: screenWidth));
                        })),
                SizedBox(height: screenHeight / 100),
          ]))],
        ));
  }
}
