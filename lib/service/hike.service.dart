import 'dart:convert';

import 'package:hikeappmobile/util/my_http.dart';

import '../model/hike.model.dart';

import '../util/constants.dart' as constants;

class HikeService {

  static HikeService? _instance;

  HikeService._(); // Private constructor

  static HikeService get instance {
    _instance ??= HikeService._();
    return _instance!;
  }

  Future<List<Hike>> getAllEntities({String title = '', String sortField = 'title', int page = 0, int size = 10}) async {
    final response = await MyHttp.getClient().get(Uri.parse('${constants.localhost}/hike?title=$title&page=$page&size=$size&sortField=$sortField'));

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      final entities = (jsonResponse['content'] as List).map((json) => Hike.fromJson(json)).toList();
      return entities;
    } else {
      throw Exception('Failed to load hikes');
    }
  }

  Future<Hike> getHikeByTitle(String hikeTitle) async {
    final response = await MyHttp.getClient().get(Uri.parse('${constants.localhost}/hike/$hikeTitle'));
    if (response.statusCode == 200) {
      Hike x = Hike.fromJsonPictureList(json.decode(response.body));
      return x;
    }  else {
      throw Exception('Failed to load hike');
    }
  }
}