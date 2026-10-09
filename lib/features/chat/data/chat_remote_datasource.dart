import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import 'models/chat_model.dart';

class ChatRemoteDataSource {
  const ChatRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse<List<ChatRoomModel>>> getRooms([String? currentUserId]) async {
    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.chatRooms);

    return ApiResponse<List<ChatRoomModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
              .whereType<Map<String, dynamic>>()
              .map((e) => ChatRoomModel.fromJson(e, currentUserId))
              .toList()
          : <ChatRoomModel>[],
    );
  }

  Future<ApiResponse<List<ChatMessageModel>>> getMessages(
    String roomId,
    String currentUserId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.chatMessages(roomId),
      queryParameters: {'page': page, 'limit': limit},
    );

    return ApiResponse<List<ChatMessageModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json
              .whereType<Map<String, dynamic>>()
              .map((e) => ChatMessageModel.fromJson(e, currentUserId))
              .toList()
          : <ChatMessageModel>[],
    );
  }

  Future<ApiResponse<ChatMessageModel>> sendMessage(
    String roomId,
    String content,
    String currentUserId, {
    String? type,
    String? mediaUrl,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.chatMessages(roomId),
      data: {
        'content': content,
        if (type != null) 'type': type,
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
      },
    );

    return ApiResponse<ChatMessageModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => ChatMessageModel.fromJson(json as Map<String, dynamic>, currentUserId),
    );
  }

  Future<ApiResponse<ChatRoomModel>> createRoom({
    String? mitraUserId,
    String? mitraId,
    String? bookingId,
    String? currentUserId,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.chatRooms,
      data: {
        if (mitraUserId != null) 'mitraUserId': mitraUserId,
        if (mitraId != null) 'mitraId': mitraId,
        if (bookingId != null) 'bookingId': bookingId,
      },
    );

    return ApiResponse<ChatRoomModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => ChatRoomModel.fromJson(json as Map<String, dynamic>, currentUserId),
    );
  }

  Future<ApiResponse<void>> markAsRead(String roomId) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(ApiEndpoints.chatRead(roomId));

    return ApiResponse<void>.fromJson(
      response.data ?? <String, dynamic>{},
      (_) {},
    );
  }
}
