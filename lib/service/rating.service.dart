import 'dart:convert';

import 'package:http/http.dart';

import '../model/rating.model.dart';
import '../util/my_http.dart';
import '../util/constants.dart' as constants;

class RatingService {

  static RatingService? _instance;

  RatingService._(); // Private constructor

  static RatingService get instance {
    _instance ??= RatingService._();
    return _instance!;
  }

  Future<List<Rating>> getRatingForHikeTitle({String hikeTitle = 'title', int page = 0, int size = 10}) async {
    print('${constants.localhost}/rating/byHikeTitle?hikeTitle=$hikeTitle&page=$page&size=$size');
    final response = await MyHttp.getClient().get(Uri.parse('${constants.localhost}/rating/byHikeTitle?hikeTitle=$hikeTitle&page=$page&size=$size'));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      final entities = (jsonResponse['content'] as List).map((json) => Rating.fromJson(json)).toList();
      print(entities[0].toJson());
      return entities;
    } else {
      throw Exception('Failed to load hikes');
    }
  }
}