import 'package:http_interceptor/http_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HttpInterceptor extends InterceptorContract {

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String token = sharedPreferences.getString('token')!;
    if (token.isNotEmpty) {
      data.headers.putIfAbsent('Authorization', () => 'Bearer $token');
    }
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async => data;

}