import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hikeappmobile/util/my_http.dart';

import '../model/rating.model.dart';
import '../util/constants.dart' as constants;


class CommentModal extends StatefulWidget {
  final String hikeTitle;

  const CommentModal({Key? key, required this.hikeTitle}) : super(key: key);

  @override
  _CommentModalState createState() => _CommentModalState();
}

class _CommentModalState extends State<CommentModal> {
  final _formKey = GlobalKey<FormState>();
  double _rating = 3;
  String _comment = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a comment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Add a comment',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
              onChanged: (value) {
                setState(() {
                  _comment = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a comment';
                }
                return null;
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
            if (_formKey.currentState!.validate()) {
              var rating = Rating();
              rating.comment = _comment;
              rating.rating = _rating;
              final response = await MyHttp.getClient().post(
                  Uri.parse('${constants.localhost}/hike/rate/${widget.hikeTitle}'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                  },
                  body: jsonEncode(rating)
              );
              if (response.statusCode != 204) {
                throw Exception("Failed to rate the hike!");
              }
              Navigator.of(context).pop();
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