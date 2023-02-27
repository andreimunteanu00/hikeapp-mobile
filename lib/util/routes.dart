import 'package:flutter/cupertino.dart';
import 'package:hikeappmobile/main.dart';
import 'package:hikeappmobile/screen/hike_detail.screen.dart';

import '../model/hike.model.dart';

class Routes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const Main(),
    '/child': (context) => HikeDetailScreen(hike: Hike())
  };
}