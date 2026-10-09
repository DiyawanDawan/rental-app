/// Append cache-bust query param when photo may have changed.
String cacheBustImageUrl(String url, {String? version}) {
  if (url.isEmpty) return url;
  if (version == null || version.isEmpty) return url;

  final separator = url.contains('?') ? '&' : '?';
  return '$url${separator}v=$version';
}
