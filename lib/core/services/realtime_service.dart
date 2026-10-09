import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import '../../app/env.dart';
import '../network/api_client.dart';
import '../network/api_endpoints.dart';
class RealTimeService {
  RealTimeService(this._apiClient);

  final ApiClient _apiClient;
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  Future<void> init() async {
    if (AppEnv.pusherKey.isEmpty) return;

    try {
      await pusher.init(
        apiKey: AppEnv.pusherKey,
        cluster: AppEnv.pusherCluster,
        onAuthorizer: (channelName, socketId, _options) async {
          final response = await _apiClient.post<Map<String, dynamic>>(
            ApiEndpoints.pusherAuth,
            data: {
              'socket_id': socketId,
              'channel_name': channelName,
            },
          );
          final data = response.data?['data'] as Map<String, dynamic>? ?? {};
          return data;
        },
        onEvent: (event) {
          debugPrint('Pusher Event: ${event.eventName}');
        },
      );
      await pusher.connect();
    } catch (e) {
      debugPrint('Pusher Init Error: $e');
    }
  }

  Future<void> subscribeToChat(String roomId, Function(Map<String, dynamic>) onMessage) async {
    final channelName = 'private-chat.$roomId';
    await pusher.subscribe(
      channelName: channelName,
      onEvent: (event) {
        if (event.eventName == 'new-message') {
          final data = jsonDecode(event.data);
          onMessage(data);
        }
      },
    );
  }

  Future<void> unsubscribeFromChat(String roomId) async {
    await pusher.unsubscribe(channelName: 'private-chat.$roomId');
  }

  void disconnect() {
    pusher.disconnect();
  }
}
