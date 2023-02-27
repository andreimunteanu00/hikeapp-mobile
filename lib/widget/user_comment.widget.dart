import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../model/rating.model.dart';

class UserCommentWidget extends StatelessWidget {
  final Rating? rating;

  const UserCommentWidget({super.key, this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /*CircleAvatar(
          backgroundImage: NetworkImage(rating!.user!.profilePicture!),
          radius: 20,
        ),*/
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rating!.user!.username!,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              RatingBarIndicator(
                rating: rating!.rating!,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 20.0,
              ),
              Text(
                rating!.comment!,
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                rating!.dateTimeRate!.toIso8601String(),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}