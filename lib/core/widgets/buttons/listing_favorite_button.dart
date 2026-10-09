import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../config/color.dart';

/// Tombol favorit overlay di foto listing — outline putih + bayangan (Airbnb-style).
class ListingFavoriteButton extends StatelessWidget {
  const ListingFavoriteButton({
    required this.isFavorite,
    required this.onTap,
    this.size = listingIconSize,
    super.key,
  });

  /// Grid / carousel listing 172px — fixed logical px.
  static const double listingIconSize = 22;

  /// Card full-width (halaman list mobile, detail terkait).
  static const double fullIconSize = 26;

  static const double _hitSize = 36;

  static const List<Shadow> _iconShadow = [
    Shadow(
      color: Color(0xA6000000),
      blurRadius: 6,
      offset: Offset(0, 1),
    ),
  ];

  final bool isFavorite;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        splashColor: Colors.white24,
        highlightColor: Colors.white12,
        child: SizedBox(
          width: _hitSize,
          height: _hitSize,
          child: Center(
            child: Icon(
              LucideIcons.heart,
              size: size,
              color: isFavorite ? AppColors.critical : Colors.white,
              fill: isFavorite ? 1.0 : 0.0,
              shadows: _iconShadow,
            ),
          ),
        ),
      ),
    );
  }
}
