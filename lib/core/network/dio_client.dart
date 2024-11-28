import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio) {
    _dio.options = BaseOptions(
      baseUrl: "https://api.themoviedb.org/3",
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 6000),
      headers: {
        "Authorization":
            "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzYjNjMzM5MWZiNTVhMDZjMDViM2M2ZGY0ZWI2MjZjNiIsIm5iZiI6MTczMjYzNTY5OS42MDc2MjQ4LCJzdWIiOiI2NzQ1ZWI0ZWQ0MDE0YzJkYjc3MGQxNGIiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.oI05eLZXQh8GdhLBXWofT8rn8s_onLmdtAwV1czQH3I",
        "Content-Type": "application/json",
      },
    );
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }
}
