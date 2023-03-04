import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../model/hike.model.dart';
import 'carousel_slider_hike.widget.dart';

class HikeDetailWidget extends StatefulWidget {

  final Hike hike;

  const HikeDetailWidget({super.key, required this.hike});

  @override
  HikeDetailWidgetState createState() => HikeDetailWidgetState();
}

class HikeDetailWidgetState extends State<HikeDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CarouselSliderHike(pictureList: widget.hike.pictureList!),
        Card(child: Column(children: [Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            widget.hike.title!,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
          SizedBox(height: 8.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.hike.description!,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                RatingBar.builder(
                  initialRating: widget.hike.allRatings!,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 20.0,
                  itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (value) {},
                ),
                SizedBox(width: 8.0),
                Text(
                  '(${widget.hike.numberRatings})',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),]))
      ],
    );
  }

}