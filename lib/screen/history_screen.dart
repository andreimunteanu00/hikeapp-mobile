import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hikeappmobile/service/hike_history.service.dart';
import 'package:hikeappmobile/model/hike_history.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import '../util/constants.dart' as constants;
import '../widget/hike_item_list.widget.dart';
import 'hike_detail.screen.dart';

class HikeHistoryScreen extends StatefulWidget {
  final PersistentTabController controller;
  final Function(Widget) handleOnGoingHike;

  const HikeHistoryScreen({super.key, required this.controller, required this.handleOnGoingHike});

  @override
  _HikeHistoryScreenState createState() => _HikeHistoryScreenState();
}

class _HikeHistoryScreenState extends State<HikeHistoryScreen> {
  final HikeHistoryService _entityService = HikeHistoryService.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<HikeHistory> _entities = [];
  final int _pageSize = 10;
  String _searchTerm = '';
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  bool startNewHike = true;

  handleStartNewHike(bool value) {
    setState(() {
      startNewHike = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEntities();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadEntities();
      }
    });
  }

  Future<void> _loadEntities() async {
    if (!_isLoading && _hasMore) {
      setState(() => _isLoading = true);
      try {
        final entities = await _entityService.getAllEntities(
            title: _searchTerm,
            page: _page,
            size: _pageSize);
        setState(() {
          _entities.addAll(entities);
          _page++;
          _isLoading = false;
          _hasMore = entities.length == _pageSize;
        });
      } catch (e) {
        print(e);
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(constants.failedToLoadData)));
      }
    }
  }

  void _resetEntities() {
    setState(() {
      _entities.clear();
      _page = 0;
      _hasMore = true;
    });
    _loadEntities();
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(title: const Text(constants.appTitle)),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration:
                    const InputDecoration(hintText: 'Search by name'),
                    onChanged: (value) {
                      _searchTerm = value;
                      if (_searchTerm.isEmpty) {
                        _resetEntities();
                      }
                    },
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      _resetEntities();
                    },
                    child: const Icon(Icons.search)),
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _entities.length + (_hasMore ? 1 : 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == _entities.length) {
                      return _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox();
                    }
                    final HikeHistory entity = _entities[index];
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