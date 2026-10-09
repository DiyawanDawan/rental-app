/// Shared element Hero tags — list → detail transitions.
abstract final class AppHeroTags {
  static String tourImage(String tourId) => 'tour-image-$tourId';
  static String vehiclePhoto(String vehicleId) => 'vehicle-photo-$vehicleId';
  static String destinationPhoto(String url) => 'dest-photo-$url';
  static String blogImage(String slug) => 'blog-hero-$slug';
  static String mitraAvatar(String mitraId) => 'mitra-avatar-$mitraId';
}
