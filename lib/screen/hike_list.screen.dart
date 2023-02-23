import 'package:flutter/material.dart';

import '../model/hike.model.dart';
import '../service/hike.service.dart';

class HikeListScreen extends StatefulWidget {
  const HikeListScreen({Key? key}) : super(key: key);

  @override
  HikeListScreenState createState() => HikeListScreenState();
}

class HikeListScreenState extends State<HikeListScreen> {
  final HikeService _entityService = HikeService();
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

    WidgetsBinding.instance.addPostFrameCallback((_){
      Future.delayed(const Duration(milliseconds: 2000), () {
        // your code here
      });
    });

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load entities')));
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

    return Column(
      children: [
        SizedBox(height: screenHeight / 10),
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
                    _resetEntities();
                  },
                ),
              ),
              const SizedBox(width: 8.0),
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
                return _isLoading ? Center(child: CircularProgressIndicator()) : SizedBox();
              }
              final entity = _entities[index];
              return ListTile(
                title: Text(entity.title!),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: ${entity.description}'),
                    Text('Rating: ${entity.allRatings}'),
                    Text('No ratings: ${entity.numberRatings}')
                  ],
                ),
              );
            }
          )
        ),
        SizedBox(height: screenHeight / 100),
      ]
    );
  }
}