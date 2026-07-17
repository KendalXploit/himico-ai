import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/dio_client.dart';

/// Root dependency-injection graph.
/// Feature-level providers depend on these instead of instantiating
/// their own network/storage clients — keeps the app testable and
/// avoids duplicated Dio/Hive/SecureStorage instances.

final dioClientProvider = Provider<DioClient>((ref) => DioClient());

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);
