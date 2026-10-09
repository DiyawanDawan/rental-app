import 'package:flutter/material.dart';
import '../../../../core/widgets/feedback/app_empty_state.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/decorations.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../application/chat_service.dart';
import '../../data/models/chat_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatMessagesPage extends StatefulWidget {
  const ChatMessagesPage({required this.roomId, required this.name, super.key});

  final String roomId;
  final String name;

  @override
  State<ChatMessagesPage> createState() => _ChatMessagesPageState();
}

class _ChatMessagesPageState extends State<ChatMessagesPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatService>().loadMessages(widget.roomId);
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ChatService>().loadMoreMessages(widget.roomId);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    context.read<ChatService>().leaveRoom(widget.roomId);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    context.read<ChatService>().sendMessage(widget.roomId, content);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name.isNotEmpty ? widget.name : 'Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatService>(
              builder: (context, service, child) {
                if (service.status == ChatStatus.loading && service.messages.isEmpty) {
                  return const AppLoadingView();
                }

                if (service.messages.isEmpty) {
                  return Center(
                    child: AppEmptyState(
                      icon: LucideIcons.messageSquare,
                      title: 'Mulai Percakapan',
                      message: 'Kirim pesan pertama Anda kepada ${widget.name.isNotEmpty ? widget.name : 'mitra'}.',
                    ),
                  );
                }

                final hasMoreLoading = service.loadingMoreMessages;
                return ListView.builder(
                  controller: _scrollController,
                  padding: AppPadding.list,
                  reverse: true,
                  itemCount: service.messages.length + (hasMoreLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (hasMoreLoading && index == service.messages.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange),
                          ),
                        ),
                      );
                    }
                    final message = service.messages[index];
                    return _MessageBubble(message: message);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppDecorations.softShadow(opacity: 0.12, blur: 4, offsetY: -2, tint: AppColors.navy),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: const InputDecoration(
                    hintText: 'Tulis pesan...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            CircleAvatar(
              backgroundColor: AppColors.orange,
              radius: 20.r,
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(LucideIcons.send, color: AppColors.onDark, size: 18),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final ChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isMe ? AppColors.orange : AppColors.neutral100,
          borderRadius: BorderRadius.only(
            topLeft: AppShapes.md.topLeft,
            topRight: AppShapes.md.topRight,
            bottomLeft: isMe ? AppShapes.md.bottomLeft : Radius.zero,
            bottomRight: isMe ? Radius.zero : AppShapes.md.bottomRight,
          ),
          boxShadow: isMe
              ? null
              : AppDecorations.softShadow(opacity: 0.08, blur: 6, offsetY: 2),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  message.mediaUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(LucideIcons.imageOff),
                ),
              ),
              AppGap.xs,
            ],
            if (message.content.isNotEmpty)
              Text(
                message.content,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isMe ? AppColors.onDark : AppColors.navy,
                ),
              ),
            AppGap.xxs,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isMe ? AppColors.onDarkMuted : AppColors.textTertiary,
                    fontSize: 9.sp,
                  ),
                ),
                if (isMe) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    message.isRead ? LucideIcons.checkCheck : LucideIcons.check,
                    size: 12.sp,
                    color: AppColors.onDarkMuted,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '';
    final local = date.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
