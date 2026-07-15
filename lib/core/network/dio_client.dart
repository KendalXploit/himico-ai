import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/env_config.dart';

/// Thin wrapper around [Dio] configured for the Binance USDT-M Futures
/// public REST API. Centralizing this here keeps every data source
/// consistent (timeouts, headers, logging, error normalization).
class DioClient {
  DioClient() : dio = Dio(
          BaseOptions(
            baseUrl: EnvConfig.binanceFuturesBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: const {'Content-Type': 'application/json'},
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _logger.e(
            'Dio error: ${error.requestOptions.path}',
            error: error.message,
          );
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));
}
