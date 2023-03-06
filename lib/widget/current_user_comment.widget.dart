import 'package:flutter/material.dart';
import 'package:hikeappmobile/service/rating.service.dart';
import 'package:hikeappmobile/widget/user_comment.widget.dart';

import '../model/rating.model.dart';
import 'modal/rating.modal.dart';
import 'modal/unrating.modal.dart';

class CurrentUserCommentWidget extends StatefulWidget {

  final Rating rating;
  final String hikeTitle;
  final Function refresh;

  const CurrentUserCommentWidget({Key? key, required this.rating, required this.hikeTitle, required this.refresh}) : super(key: key);

  @override
  State createState() => CurrentUserCommentWidgetState();

}

class CurrentUserCommentWidgetState extends State<CurrentUserCommentWidget> {
  final RatingService ratingService = RatingService.instance;

  void unrate() {
    showDialog(
      context: context,
      builder: (context) {
        return UnratingModal();
      }
    ).then((value) {
      if (value != null && value) {
        ratingService.unrate(widget.hikeTitle).then((_) {
          widget.refresh();
        });
      }
    });
  }

  void rate() {
    showDialog(
      context: context,
      builder: (context) {
        return RatingModal(hikeTitle: widget.hikeTitle, comment: widget.rating.comment, rating: widget.rating.rating);
      },
    ).then((value) {
      if (value) {
        widget.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.rating.user == null ? ElevatedButton(
      onPressed: rate,
      style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
      child: const Text(
        'Rate Hike',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ) : Column(
      children: [
        UserCommentWidget(rating: widget.rating, fromCurrentUser: true, rate: rate, unrate: unrate),
      ],
    );
  }
}
