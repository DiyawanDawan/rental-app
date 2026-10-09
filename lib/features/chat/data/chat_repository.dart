import '../../../core/network/api_response.dart';
import 'chat_remote_datasource.dart';
import 'models/chat_model.dart';

class ChatRepository {
  const ChatRepository(this._remoteDataSource);

  final ChatRemoteDataSource _remoteDataSource;

  Future<ApiResponse<List<ChatRoomModel>>> getRooms([String? currentUserId]) =>
      _remoteDataSource.getRooms(currentUserId);

  Future<ApiResponse<List<ChatMessageModel>>> getMessages(
    String roomId,
    String currentUserId, {
    int page = 1,
    int limit = 30,
  }) =>
      _remoteDataSource.getMessages(roomId, currentUserId, page: page, limit: limit);

  Future<ApiResponse<ChatMessageModel>> sendMessage(
    String roomId,
    String content,
    String currentUserId, {
    String? type,
    String? mediaUrl,
  }) =>
      _remoteDataSource.sendMessage(
        roomId,
        content,
        currentUserId,
        type: type,
        mediaUrl: mediaUrl,
      );

  Future<ApiResponse<ChatRoomModel>> createRoom({
    String? mitraUserId,
    String? mitraId,
    String? bookingId,
    String? currentUserId,
  }) =>
      _remoteDataSource.createRoom(
        mitraUserId: mitraUserId,
        mitraId: mitraId,
        bookingId: bookingId,
        currentUserId: currentUserId,
      );

  Future<ApiResponse<void>> markAsRead(String roomId) => _remoteDataSource.markAsRead(roomId);
}
