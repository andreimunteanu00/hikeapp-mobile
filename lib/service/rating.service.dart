import 'dart:convert';

import '../model/rating.model.dart';
import '../util/my_http.dart';
import '../util/constants.dart' as constants;

class RatingService {

  static RatingService? _instance;

  RatingService._();

  static RatingService get instance {
    _instance ??= RatingService._();
    return _instance!;
  }

  Future<List<Rating>> getRatingForHikeTitle({String hikeTitle = 'title', int page = 0, int size = 10}) async {
    final response = await MyHttp.getClient().get(Uri.parse('${constants.localhost}/rating/byHikeTitle?hikeTitle=$hikeTitle&page=$page&size=$size'));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return (jsonResponse['content'] as List).map((json) => Rating.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rating for current hike!');
    }
  }

  Future<Rating> getRatingForCurrentUser(String hikeTitle) async {
    final response = await MyHttp.getClient().get(Uri.parse('${constants.localhost}/rating/byCurrentUser/$hikeTitle'));
    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        return Rating();
      }
      return Rating.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load rating for current user!');
    }
  }
}