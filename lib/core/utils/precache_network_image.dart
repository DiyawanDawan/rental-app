import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Precache a network image before route push for smoother Hero / detail transitions.
Future<void> precacheNetworkImageUrl(BuildContext context, String? url) async {
  if (url == null || url.isEmpty) return;
  await precacheImage(CachedNetworkImageProvider(url), context);
}
