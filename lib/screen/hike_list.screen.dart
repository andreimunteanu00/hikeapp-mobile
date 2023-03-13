import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../model/hike.model.dart';
import '../screen/hike_detail.screen.dart';
import '../service/hike.service.dart';
import '../util/constants.dart' as constants;
import '../widget/hike_item_list.widget.dart';


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
  final int _pageSize = 10;
  String _sortBy = 'title';
  String _searchTerm = '';
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(constants.failedToLoadData)));
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
      appBar: AppBar(title: const Text(constants.appTitle)),
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
                // TODO make a dropdown with icons
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
                      pageTransitionAnimation: PageTransitionAnimation.fade,
                    );
                  },
                  child: HikeItemList(entity: entity, screenWidth: screenWidth)
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