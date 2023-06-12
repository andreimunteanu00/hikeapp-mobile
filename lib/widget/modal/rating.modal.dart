import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hikeappmobile/service/rating.service.dart';

import '../../model/rating.model.dart';

class RatingModal extends StatefulWidget {
  final String hikeTitle;
  final String? comment;
  final double? rating;

  const RatingModal(
      {Key? key,
      required this.hikeTitle,
      required this.comment,
      required this.rating})
      : super(key: key);

  @override
  RatingModalState createState() => RatingModalState();
}

class RatingModalState extends State<RatingModal> {
  final RatingService ratingService = RatingService.instance;
  final formKey = GlobalKey<FormState>();
  double defaultRating = 3;
  String defaultComment = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a comment'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: widget.rating ?? 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  defaultRating = rating;
                });
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: widget.comment ?? '',
              decoration: const InputDecoration(
                hintText: 'Add a comment',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              onChanged: (value) {
                setState(() {
                  defaultComment = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              var rating = Rating();
              rating.comment = defaultComment;
              rating.rating = defaultRating;
              if (!(defaultRating == widget.rating &&
                  (defaultComment == '' || defaultComment == widget.comment))) {
                await ratingService.rate(widget.hikeTitle, rating);
                Navigator.of(context).pop(true);
              } else {
                Navigator.of(context).pop(false);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Comment added'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text('SUBMIT'),
        ),
      ],
    );
  }
}
