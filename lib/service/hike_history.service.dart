import 'dart:convert';

import 'package:hikeappmobile/model/hike_summary.dart';
import 'package:hikeappmobile/util/my_http.dart';

import '../util/constants.dart' as constants;

class HikeHistoryService {

  static HikeHistoryService? _instance;

  HikeHistoryService._();

  static HikeHistoryService get instance {
    _instance ??= HikeHistoryService._();
    return _instance!;
  }

  Future<void> postHikeHistory(HikeSummary hikeSummary) async {
    final response = await MyHttp.getClient().post(
        Uri.parse('${constants.localhost}/hike-history'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(hikeSummary)
    );
    if (response.statusCode != 204) {
      throw Exception("Failed to post history for hike!");
    }
  }
}