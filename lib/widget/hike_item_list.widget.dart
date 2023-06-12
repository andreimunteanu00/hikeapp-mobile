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
    return Card(
        child: Row(
      children: [
        SizedBox(
            width: 100,
            height: 150,
            // TODO change it with default
            child: entity.mainPicture?.base64 != null
                ? Image.memory(base64Decode(entity.mainPicture!.base64!))
                : Image.network(
                    'https://www.google.com/search?q=Image+Decoration+deprecated+flutter&rlz=1C1GCEU_enRO1027RO1027&sxsrf=AJOqlzUggdOqsdmzx1JhxFgfupfFaKfDbA:1677518002812&source=lnms&tbm=isch&sa=X&ved=2ahUKEwi5uKXFmbb9AhVUtKQKHbb9B6oQ_AUoAXoECAEQAw&biw=1920&bih=929&dpr=1#imgrc=GfQxngkfsluSLM')),
        SizedBox(
          width: screenWidth / 2,
          child: ListTile(
              title: Center(child: Text(entity.title!)),
              subtitle: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text('Difficulty: ${entity.difficulty?.toLowerCase()}'),
                      Row(children: [
                        const Text('Rating: '),
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
                      Text('No ratings: ${entity.numberRatings}')
                    ],
                  )
              )
          ),
        )
      ],
    ));
  }
}
