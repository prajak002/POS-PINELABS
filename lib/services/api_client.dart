import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../core/constants.dart';
import '../models/auth_models.dart';
import '../models/menu_item_simple.dart';
import '../models/menu_response.dart';
// import '../models/transaction.dart';
// import '../models/order.dart';
// import '../models/sync_models.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: AppConstants.baseUrl)
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST(AppConstants.loginEndpoint)
  Future<LoginResponse> login(@Body() LoginRequest request);

  // Menu APIs
  @GET(AppConstants.menuEndpoint)
  Future<MenuResponse> getMenu(@Header('Authorization') String token);

  @POST(AppConstants.menuEndpoint)
  Future<MenuItemSimple> addMenuItem(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> menuData,
  );

  @DELETE(AppConstants.menuEndpoint)
  Future<void> deleteMenuItem(
    @Header('Authorization') String token,
    @Body() Map<String, dynamic> deleteData,
  );
}

class DioClient {
  static Dio createDio() {
    final dio = Dio();

    dio.options = BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    // Add interceptors
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    return dio;
  }

  static void addAuthInterceptor(Dio dio, String token) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ));
  }
}
