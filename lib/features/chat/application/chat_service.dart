import 'package:flutter/foundation.dart';

import '../../../core/utils/error_message_util.dart';
import '../../../core/services/realtime_service.dart';
import '../../auth/application/auth_service.dart';
import '../data/chat_repository.dart';
import '../data/models/chat_model.dart';

enum ChatStatus { initial, loading, loaded, failure }

class ChatService extends ChangeNotifier {
  ChatService(this._repository, this._authService, this._realTimeService);

  final ChatRepository _repository;
  final AuthService _authService;
  final RealTimeService _realTimeService;

  ChatStatus _status = ChatStatus.initial;
  List<ChatRoomModel> _rooms = [];
  List<ChatMessageModel> _messages = [];
  String? _message;
  int _messagePage = 1;
  bool _hasMoreMessages = true;
  bool _loadingMoreMessages = false;

  ChatStatus get status => _status;
  List<ChatRoomModel> get rooms => List.unmodifiable(_rooms);
  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  String? get errorMessage => _message;
  bool get hasMoreMessages => _hasMoreMessages;
  bool get loadingMoreMessages => _loadingMoreMessages;

  Future<void> loadRooms() async {
    final userId = _authService.user?.id;
    _status = ChatStatus.loading;
    notifyListeners();

    try {
      final response = await _repository.getRooms(userId);
      _rooms = response.data ?? [];
      _status = ChatStatus.loaded;
    } catch (error) {
      _message = userFacingError(error);
      _status = ChatStatus.failure;
    }
    notifyListeners();
  }

  Future<void> loadMessages(String roomId) async {
    final userId = _authService.user?.id ?? '';
    if (userId.isEmpty) return;

    _status = ChatStatus.loading;
    _messagePage = 1;
    _hasMoreMessages = true;
    notifyListeners();

    try {
      final response = await _repository.getMessages(roomId, userId, page: 1);
      _messages = response.data ?? [];
      _status = ChatStatus.loaded;
      await _repository.markAsRead(roomId);
      final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
      if (roomIndex != -1 && _rooms[roomIndex].unreadCount > 0) {
        final current = _rooms[roomIndex];
        _rooms[roomIndex] = ChatRoomModel(
          id: current.id,
          name: current.name,
          lastMessage: current.lastMessage,
          lastMessageTime: current.lastMessageTime,
          unreadCount: 0,
          otherUserAvatar: current.otherUserAvatar,
          customerId: current.customerId,
          mitraUserId: current.mitraUserId,
          bookingId: current.bookingId,
        );
      }

      // Start listening for real-time messages
      await _realTimeService.subscribeToChat(roomId, (data) {
        final newMsg = ChatMessageModel.fromJson(data, userId);
        if (!_messages.any((m) => m.id == newMsg.id)) {
          _messages.insert(0, newMsg);
          _updateRoomLastMessage(roomId, newMsg.content, newMsg.createdAt);
          notifyListeners();
        }
      });
    } catch (error) {
      _message = userFacingError(error);
      _status = ChatStatus.failure;
    }
    notifyListeners();
  }

  Future<ChatRoomModel?> createRoom({
    String? mitraUserId,
    String? mitraId,
    String? bookingId,
  }) async {
    final currentUserId = _authService.user?.id;
    _status = ChatStatus.loading;
    notifyListeners();

    try {
      final response = await _repository.createRoom(
        mitraUserId: mitraUserId,
        mitraId: mitraId,
        bookingId: bookingId,
        currentUserId: currentUserId,
      );
      final room = response.data;
      if (room != null) {
        final existingIndex = _rooms.indexWhere((r) => r.id == room.id);
        if (existingIndex >= 0) {
          _rooms[existingIndex] = room;
        } else {
          _rooms = [room, ..._rooms];
        }
      }
      _status = ChatStatus.loaded;
      notifyListeners();
      return room;
    } catch (error) {
      _message = userFacingError(error);
      _status = ChatStatus.failure;
      notifyListeners();
      return null;
    }
  }

  Future<void> leaveRoom(String roomId) async {
    await _realTimeService.unsubscribeFromChat(roomId);
  }

  Future<void> loadMoreMessages(String roomId) async {
    if (_loadingMoreMessages || !_hasMoreMessages) return;
    final userId = _authService.user?.id ?? '';
    if (userId.isEmpty) return;

    _loadingMoreMessages = true;
    notifyListeners();

    try {
      final nextPage = _messagePage + 1;
      final response = await _repository.getMessages(roomId, userId, page: nextPage);
      final newItems = response.data ?? [];
      if (newItems.isEmpty) {
        _hasMoreMessages = false;
      } else {
        _messagePage = nextPage;
        for (final item in newItems) {
          if (!_messages.any((m) => m.id == item.id)) {
            _messages.add(item);
          }
        }
      }
    } catch (_) {}
    _loadingMoreMessages = false;
    notifyListeners();
  }

  Future<bool> sendMessage(
    String roomId,
    String content, {
    String? type,
    String? mediaUrl,
  }) async {
    final userId = _authService.user?.id ?? '';
    if (userId.isEmpty) return false;

    try {
      final response = await _repository.sendMessage(
        roomId,
        content,
        userId,
        type: type,
        mediaUrl: mediaUrl,
      );
      if (response.data != null) {
        final newMsg = response.data!;
        if (!_messages.any((m) => m.id == newMsg.id)) {
          _messages.insert(0, newMsg);
          _updateRoomLastMessage(roomId, newMsg.content, newMsg.createdAt);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  void _updateRoomLastMessage(String roomId, String lastMessage, String lastMessageTime) {
    final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex != -1) {
      final current = _rooms[roomIndex];
      _rooms[roomIndex] = ChatRoomModel(
        id: current.id,
        name: current.name,
        lastMessage: lastMessage,
        lastMessageTime: lastMessageTime,
        unreadCount: current.unreadCount,
        otherUserAvatar: current.otherUserAvatar,
        customerId: current.customerId,
        mitraUserId: current.mitraUserId,
        bookingId: current.bookingId,
      );
    }
  }
}
