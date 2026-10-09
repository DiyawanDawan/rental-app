import '../../../core/network/api_response.dart';
import 'health_remote_datasource.dart';

class HealthRepository {
  const HealthRepository(this._remoteDataSource);

  final HealthRemoteDataSource _remoteDataSource;

  Future<ApiResponse<Map<String, dynamic>>> check() {
    return _remoteDataSource.check();
  }
}
