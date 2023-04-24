import 'package:flutter/material.dart';
import 'package:hikeappmobile/screen/start_hike.screen.dart';
import 'package:hikeappmobile/service/auth.service.dart';
import 'package:hikeappmobile/service/hike.service.dart';
import 'package:hikeappmobile/service/rating.service.dart';
import 'package:hikeappmobile/widget/map_preview.widget.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../model/hike.model.dart';
import '../model/rating.model.dart';
import '../util/constants.dart' as constants;
import '../util/methods.dart';
import '../widget/current_user_comment.widget.dart';
import '../widget/hike_detail.widget.dart';
import '../widget/modal/ongoing_hike.modal.dart';
import '../widget/user_comment.widget.dart';

class HikeDetailScreen extends StatefulWidget {
  final Function(Widget) handleOnGoingHike;
  final Function(bool) handleStartNewHike;
  final bool startNewHike;
  final PersistentTabController controller;
  final String hikeTitle;

  const HikeDetailScreen({
    super.key,
    required this.hikeTitle,
    required this.controller,
    required this.handleOnGoingHike,
    required this.handleStartNewHike,
    required this.startNewHike
  });

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
  late Hike hike;

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
        final entities = await ratingService.getRatingForHikeTitle(
            hikeTitle: widget.hikeTitle, page: _page, size: _pageSize);
        final googleId = await Methods.giveGoogleIdFromToken();
        entities.removeWhere((entity) => entity.user!.googleId! == googleId);
        setState(() {
          _entities.addAll(entities);
          _page++;
          _isLoading = false;
          _hasMore = entities.length == _pageSize;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(constants.failedToLoadData)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                            hike = snapshot.data!;
                            return HikeDetailWidget(hike: snapshot.data!);
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          } else {
                            return const CircularProgressIndicator();
                          }
                        }),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Preview button
                        SizedBox(
                          width: 100,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (widget.startNewHike) {
                                setState(() {
                                  widget.handleStartNewHike(false);
                                });
                                widget.handleOnGoingHike(StartHikeScreen(
                                    hikeTitle: hike.title!,
                                    startPoint: hike.startPoint!,
                                    endPoint: hike.endPoint!,
                                    handleOnGoingHike: widget.handleOnGoingHike,
                                    handleStartNewHike:
                                        widget.handleStartNewHike));
                                Navigator.of(context).pop();
                                widget.controller.jumpToTab(3);
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const OngoingHikeModal();
                                    });
                              }
                            },
                            label: const Text('Start'),
                            icon: const Icon(Icons.start),
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        // Share button
                        SizedBox(
                          width: 125,
                          child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      contentPadding: const EdgeInsets.all(0.0),
                                      insetPadding: EdgeInsets.symmetric(
                                          vertical: screenWidth / 4),
                                      title: const Text('Preview'),
                                      content: MapPreviewWidget(
                                          startPosition: hike.startPoint!,
                                          endPosition: hike.endPoint!),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              label: const Text('Preview'),
                              icon: const Icon(Icons.map)),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        SizedBox(
                          width: 100,
                          child: ElevatedButton.icon(
                              onPressed: () {
                                // Add code to handle the share button press
                              },
                              label: const Text('Share'),
                              icon: const Icon(Icons.share)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<Rating>(
                        future: ratingService
                            .getRatingForCurrentUser(widget.hikeTitle),
                        builder: (_, snapshot) {
                          if (snapshot.hasData) {
                            return CurrentUserCommentWidget(
                                rating: snapshot.data!,
                                hikeTitle: widget.hikeTitle,
                                refresh: () => setState(() {}));
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          } else {
                            return const CircularProgressIndicator();
                          }
                        }),
                    const SizedBox(height: 16),
                    const Text(
                      "User's ratings",
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _entities.isEmpty
                        ? const Text('no rating yet!')
                        : Expanded(
                            child: ListView.builder(
                                controller: _scrollController,
                                itemCount:
                                    _entities.length + (_hasMore ? 1 : 0),
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == _entities.length) {
                                    return _isLoading
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : const SizedBox();
                                  }
                                  final entity = _entities[index];
                                  return UserCommentWidget(rating: entity);
                                })),
                    SizedBox(height: screenHeight / 60),
                  ],
                ))));
  }
}
