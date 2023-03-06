import 'dart:convert';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hikeappmobile/model/picture.model.dart';

class CarouselSliderHike extends StatefulWidget {

  final List<Picture?>? pictureList;

  const CarouselSliderHike({super.key, required this.pictureList});

  @override
  CarouselSliderHikeState createState() => CarouselSliderHikeState();
}

class CarouselSliderHikeState extends State<CarouselSliderHike> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return CarouselSlider(
      options: CarouselOptions(
        height: screenHeight / 4,
        enlargeCenterPage: true,
        enableInfiniteScroll: false
      ),
      items: widget.pictureList!.map((picture) {
        Uint8List imageBytes = base64Decode((picture!.base64!));
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Colors.green,
              ),
              child: Image.memory(
                imageBytes,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }).toList(),
    );
  }

}