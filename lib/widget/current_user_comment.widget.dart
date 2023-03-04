import 'package:flutter/material.dart';
import 'package:hikeappmobile/widget/user_comment.widget.dart';

import '../model/rating.model.dart';
import 'comment_modal.widget.dart';

class CurrentUserCommentWidget extends StatefulWidget {

  final Rating rating;
  final String hikeTitle;

  const CurrentUserCommentWidget({Key? key, required this.rating, required this.hikeTitle}) : super(key: key);

  @override
  State createState() => CurrentUserCommentWidgetState();

}

class CurrentUserCommentWidgetState extends State<CurrentUserCommentWidget> {

  void rate() {
    showDialog(
      context: context,
      builder: (context) {
        return CommentModal(hikeTitle: widget.hikeTitle);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.rating.user == null ? ElevatedButton(
      onPressed: rate,
      child: Text('ADD COMMENT'),
    ) : Column(
      children: [
        UserCommentWidget(widget.rating),
        ElevatedButton(
          onPressed: rate,
          child: Text('EDIT COMMENT'),
        )
      ],
    );
  }
}
