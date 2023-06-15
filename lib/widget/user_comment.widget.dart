import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import '../model/rating.model.dart';

class UserCommentWidget extends StatelessWidget {
  final Rating? rating;
  final bool? fromCurrentUser;
  final Function? rate;
  final Function? unrate;

  const UserCommentWidget({
    this.rating,
    this.fromCurrentUser = false,
    this.rate,
    super.key,
    this.unrate
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(96, 137, 110, 0.5),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: MemoryImage(
                      base64.decode(rating!.user!.profilePicture!.base64!)),
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rating!.user!.username!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white
                            ),
                          ),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm')
                                .format(rating!.dateTimeRate!),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      rating!.comment!.isNotEmpty
                          ? Text(rating!.comment!, style: const TextStyle(color: Colors.white))
                          : const SizedBox.shrink(),
                      const SizedBox(height: 5),
                      fromCurrentUser == true
                          ? Row(
                              children: [
                                RatingBarIndicator(
                                  rating: rating!.rating!,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  itemCount: 5,
                                  itemSize: 20,
                                  direction: Axis.horizontal,
                                ),
                                const Spacer(),
                                InkWell(
                                    onTap: () {
                                      rate!();
                                    },
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 24.0,
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                    onTap: () {
                                      unrate!();
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 24.0,
                                    ))
                              ],
                            )
                          : RatingBarIndicator(
                              rating: rating!.rating!,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 20,
                              direction: Axis.horizontal,
                            ),
                    ],
                  ),
                ),
              ],
            )));
  }
}
