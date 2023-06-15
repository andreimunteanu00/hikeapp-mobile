import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../model/hike.model.dart';

class HikeItemList extends StatelessWidget {
  const HikeItemList({
    Key? key,
    required this.entity,
    required this.screenWidth,
  }) : super(key: key);

  final Hike entity;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Card(
        color: const Color.fromRGBO(96, 137, 110, 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Set the border radius
          side: BorderSide(
            color: Color.fromRGBO(96, 137, 110, 0.5), // Set the border color
            width: 1.0, // Set the border width
          ),
        ),
        child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
                width: screenWidth / 4,
                height: 125,
                child: entity.mainPicture?.base64 != null
                    ? Image.memory(base64Decode(entity.mainPicture!.base64!))
                    : Image.asset('assets/images/default_avatar.png')),
          ),
          SizedBox(
            width: screenWidth / 2,
            child: ListTile(
                title: Center(child: Text(entity.title!, style: const TextStyle(color: Colors.white))),
                subtitle: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text('Difficulty: ${entity.difficulty?.toLowerCase()}', style: const TextStyle(color: Colors.white)),
                        Row(children: [
                          const Text('Rating: ', style: const TextStyle(color: Colors.white)),
                          RatingBarIndicator(
                            rating: entity.allRatings!,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20,
                            direction: Axis.horizontal,
                          )
                        ]),
                        Text('No ratings: ${entity.numberRatings}', style: const TextStyle(color: Colors.white))
                      ],
                    )
                )
            ),
          )
        ],
      )),
    );
  }
}
