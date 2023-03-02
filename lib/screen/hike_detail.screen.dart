import 'package:flutter/material.dart';
import 'package:hikeappmobile/service/hike.service.dart';
import 'package:hikeappmobile/service/rating.service.dart';

import '../model/hike.model.dart';
import '../model/rating.model.dart';
import '../widget/hike_detail.widget.dart';
import '../widget/user_comment.widget.dart';

class HikeDetailScreen extends StatefulWidget {

  final String hikeTitle;
  final HikeService hikeService = HikeService.instance;

  HikeDetailScreen({super.key, required this.hikeTitle});

  @override
  State createState() => HikeDetailScrenState();

}

class HikeDetailScrenState extends State<HikeDetailScreen> {

  final RatingService ratingService = RatingService.instance;
  final ScrollController _scrollController = ScrollController();
  List<Rating> _entities = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;
  int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    if (!_isLoading && _hasMore) {
      setState(() => _isLoading = true);
      try {
        final entities = await ratingService.getRatingForHikeTitle(hikeTitle: widget.hikeTitle, page: _page, size: _pageSize);
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('HikeApp')),
        body: Column(
      children: [
        SizedBox(
          height: screenHeight / 2,
          child: FutureBuilder<Hike>(
            future: widget.hikeService.getHikeByTitle(widget.hikeTitle),
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                return HikeDetailWidget(hike: snapshot.data!);
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            }
          )
        ),
        SizedBox(
          height: screenHeight / 2 - screenHeight / 5,
          child: Expanded(
            child: ListView.builder(
            controller: _scrollController,
                itemCount: _entities.length + (_hasMore ? 1 : 0),
                itemBuilder: (BuildContext context, int index) {
                  if (index == _entities.length) {
                    return _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox();
                  }
                  final entity = _entities[index];
                  return UserCommentWidget(rating: entity);
                }
            )
          ),
        )
      ],
    ));
  }
}