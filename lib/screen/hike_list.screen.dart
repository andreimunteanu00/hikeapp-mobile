import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hikeappmobile/screen/hike_detail.screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../model/hike.model.dart';
import '../service/hike.service.dart';

class HikeListScreen extends StatefulWidget {
  const HikeListScreen({Key? key}) : super(key: key);

  @override
  HikeListScreenState createState() => HikeListScreenState();
}

class HikeListScreenState extends State<HikeListScreen> {
  final HikeService _entityService = HikeService.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Hike> _entities = [];
  String _sortBy = 'title';
  String _searchTerm = '';
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadEntities();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadEntities();
      }
    });
  }

  Future<void> _loadEntities() async {
    if (!_isLoading && _hasMore) {
      setState(() => _isLoading = true);

      try {
        final entities = await _entityService.getAllEntities(title: _searchTerm, sortField: _sortBy, page: _page, size: _pageSize);
        setState(() {
          _entities.addAll(entities);
          _page++;
          _isLoading = false;
          _hasMore = entities.length == _pageSize;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load entities')));
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(title: const Text('HikeApp')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Search by name'),
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
                    child: const Icon(Icons.search)
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'title', child: Text('Sort by title')),
                    DropdownMenuItem(value: 'allRatings', child: Text('Sort by rating')),
                    DropdownMenuItem(value: 'numberRatings', child: Text('Sort by popularity')),
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      _sortBy = value;
                      _resetEntities();
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _entities.length + (_hasMore ? 1 : 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == _entities.length) {
                      return _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox();
                    }
                    final Hike entity = _entities[index];
                    return GestureDetector(
                        onTap: () {
                          PersistentNavBarNavigator.pushNewScreen(
                            context,
                            screen: HikeDetailScreen(hikeTitle: entity.title!),
                            withNavBar: true,
                            pageTransitionAnimation: PageTransitionAnimation.cupertino,
                          );
                        },
                        child: Card(
                            child: Row(
                              children: [
                                Container(
                                    width:100,
                                    height: 150,
                                    // TODO change it with default
                                    child: entity.mainPicture?.base64 != null ? Image.memory(base64Decode(entity.mainPicture!.base64!)) : Image.network('https://www.google.com/search?q=Image+Decoration+deprecated+flutter&rlz=1C1GCEU_enRO1027RO1027&sxsrf=AJOqlzUggdOqsdmzx1JhxFgfupfFaKfDbA:1677518002812&source=lnms&tbm=isch&sa=X&ved=2ahUKEwi5uKXFmbb9AhVUtKQKHbb9B6oQ_AUoAXoECAEQAw&biw=1920&bih=929&dpr=1#imgrc=GfQxngkfsluSLM')
                                ),
                                SizedBox(
                                  width: screenWidth / 2,
                                  child: ListTile(
                                      title: Center(child: Text(entity.title!)),
                                      subtitle: Center(child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 16),
                                          Text('Difficulty: ${entity.difficulty?.toLowerCase()}'),
                                          Row(children: [Text('Rating: '), RatingBarIndicator(
                                            rating: entity.allRatings!,
                                            itemBuilder: (context, index) => const Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            itemCount: 5,
                                            itemSize: 20,
                                            direction: Axis.horizontal,
                                          )]),
                                          Text('No ratings: ${entity.numberRatings}')
                                        ],
                                      )
                                      )
                                  ),
                                )
                              ],
                            )
                        )
                    );
                  }
              )
          ),
          SizedBox(height: screenHeight / 100),
        ]
      )
    );
  }
}