import 'dart:convert';

import 'package:hikeappmobile/util/my_http.dart';

import '../model/hike.model.dart';

import '../util/constants.dart' as constants;

class HikeService {
  static HikeService? _instance;

  HikeService._();

  static HikeService get instance {
    _instance ??= HikeService._();
    return _instance!;
  }

  Future<List<Hike>> getAllEntities(
      {String title = '',
      String sortField = 'title',
      int page = 0,
      int size = 10}) async {
    final response = await MyHttp.getClient().get(Uri.parse(
        '${constants.localhost}/hike?title=$title&page=$page&size=$size&sortField=$sortField'));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return (jsonResponse['content'] as List)
          .map((json) => Hike.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load hikes');
    }
  }

  Future<Hike> getHikeByTitle(String hikeTitle) async {
    final response = await MyHttp.getClient()
        .get(Uri.parse('${constants.localhost}/hike/$hikeTitle'));
    if (response.statusCode == 200) {
      return Hike.fromJsonDetail(json.decode(response.body));
    } else {
      throw Exception('Failed to load hike');
    }
  }
}
