import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/dio_client.dart';

/// مزود DioClient — يُهيَّأ في main.dart عبر `DioClient.create(...)` ثم
/// يُحقن هنا بواسطة override، لأن البناء غير متزامن (FileStorage + dotenv).
final dioClientProvider = Provider<DioClient>((ref) {
  throw UnimplementedError('DioClient must be overridden in ProviderScope');
});
