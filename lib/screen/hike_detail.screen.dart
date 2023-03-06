import 'package:flutter/material.dart';

import 'package:hikeappmobile/service/auth.service.dart';
import 'package:hikeappmobile/service/hike.service.dart';
import 'package:hikeappmobile/service/rating.service.dart';
import '../util/methods.dart';
import '../model/hike.model.dart';
import '../model/rating.model.dart';
import '../widget/hike_detail.widget.dart';
import '../widget/user_comment.widget.dart';
import '../widget/current_user_comment.widget.dart';
import '../util/constants.dart' as constants;


class HikeDetailScreen extends StatefulWidget {
  final String hikeTitle;

  const HikeDetailScreen({super.key, required this.hikeTitle});

  @override
  State createState() => HikeDetailScrenState();
}

class HikeDetailScrenState extends State<HikeDetailScreen> {
  final HikeService hikeService = HikeService.instance;
  final AuthService authService = AuthService.instance;
  final RatingService ratingService = RatingService.instance;
  final ScrollController _scrollController = ScrollController();
  final List<Rating> _entities = [];
  final int _pageSize = 10;
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    if (!_isLoading && _hasMore) {
      setState(() => _isLoading = true);
      try {
        final entities = await ratingService.getRatingForHikeTitle(hikeTitle: widget.hikeTitle, page: _page, size: _pageSize);
        final googleId = await Methods.giveUsernameFromToken();
        entities.removeWhere((entity) => entity.user!.googleId! == googleId);
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text(constants.appTitle)),
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenHeight + screenHeight / 2,
          child: Column(
            children: [
              SizedBox(height: screenHeight / 60),
              FutureBuilder<Hike>(
                future: hikeService.getHikeByTitle(widget.hikeTitle),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    return HikeDetailWidget(hike: snapshot.data!);
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                }
              ),
              const SizedBox(height: 16),
              FutureBuilder<Rating>(
                future: ratingService.getRatingForCurrentUser(widget.hikeTitle),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    return CurrentUserCommentWidget(rating: snapshot.data!, hikeTitle: widget.hikeTitle, refresh: () => setState(() {}));
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                }
              ),
              const SizedBox(height: 16),
              const Text(
                "User's ratings",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _entities.isEmpty ? const Text('no rating yet!') : Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _entities.length + (_hasMore ? 1 : 0),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == _entities.length) {
                      return _isLoading
                          ? const Center(
                          child: CircularProgressIndicator())
                          : const SizedBox();
                    }
                    final entity = _entities[index];
                    return UserCommentWidget(rating: entity);
                  }
                )
              ),
              SizedBox(height: screenHeight / 60),
            ],
          )
        )
      )
    );
  }
}
