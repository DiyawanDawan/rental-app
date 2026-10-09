import '../../../app/env.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';

class HealthRemoteDataSource {
  const HealthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse<Map<String, dynamic>>> check() async {
    final response = await _apiClient.getAbsolute<Map<String, dynamic>>(
      Uri.parse('${AppEnv.apiBaseUrl}/health'),
    );
    final data = response.data ?? <String, dynamic>{};
    return ApiResponse<Map<String, dynamic>>.fromJson(
      data,
      (json) => json as Map<String, dynamic>,
    );
  }
}
