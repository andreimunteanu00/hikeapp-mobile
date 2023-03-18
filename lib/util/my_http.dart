import 'package:http_interceptor/http/http.dart';

import 'intercept.dart';

class MyHttp {
  static final InterceptedClient _client = InterceptedClient.build(
    interceptors: [HttpInterceptor()],
  );

  static InterceptedClient getClient() {
    return _client;
  }
}
