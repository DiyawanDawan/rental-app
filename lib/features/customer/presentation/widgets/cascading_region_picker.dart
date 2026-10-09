import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../config/color.dart';
import '../../../../config/shapes.dart';
import '../../../../config/spacing.dart';
import '../../../../config/text_styles.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../data/models/region_model.dart';

Future<RegionItemModel?> showRegionPickerBottomSheet({
  required BuildContext context,
  required String title,
  required Future<List<RegionItemModel>> Function() loader,
  RegionItemModel? selectedItem,
}) {
  return showModalBottomSheet<RegionItemModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppShapes.dialogRadius)),
    ),
    builder: (context) => _RegionPickerContent(
      title: title,
      loader: loader,
      selectedItem: selectedItem,
    ),
  );
}

class _RegionPickerContent extends StatefulWidget {
  const _RegionPickerContent({
    required this.title,
    required this.loader,
    this.selectedItem,
  });

  final String title;
  final Future<List<RegionItemModel>> Function() loader;
  final RegionItemModel? selectedItem;

  @override
  State<_RegionPickerContent> createState() => _RegionPickerContentState();
}

class _RegionPickerContentState extends State<_RegionPickerContent> {
  final _searchController = TextEditingController();
  List<RegionItemModel> _allItems = [];
  List<RegionItemModel> _filteredItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await widget.loader();
      if (mounted) {
        setState(() {
          _allItems = items;
          _filteredItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data wilayah';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = _allItems;
      } else {
        _filteredItems = _allItems
            .where((item) => item.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          AppGap.sm,
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          AppGap.md,

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTextStyles.titleMedium.copyWith(color: AppColors.primaryDeep),
                  ),
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, color: AppColors.textTertiary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          AppGap.sm,

          // Search Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari ${widget.title.toLowerCase()}...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                prefixIcon: const Icon(LucideIcons.search, size: 20, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceMuted,
                contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppShapes.inputRadius),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          AppGap.sm,
          const Divider(height: 1, color: AppColors.border),

          // Content List
          Expanded(
            child: _buildListContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildListContent() {
    if (_isLoading) {
      return const Center(child: AppLoadingView());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
            AppGap.sm,
            TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.mapPinOff, size: 40.sp, color: AppColors.textTertiary),
              AppGap.sm,
              Text(
                'Tidak ada data ditemukan',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredItems.length,
      separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.border),
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        final isSelected = widget.selectedItem?.id == item.id;

        return ListTile(
          onTap: () => Navigator.pop(context, item),
          title: Text(
            item.name,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: item.type != null
              ? Text(
                  item.type!,
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textTertiary),
                )
              : null,
          trailing: isSelected
              ? const Icon(LucideIcons.check, color: AppColors.primary, size: 20)
              : null,
          contentPadding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
        );
      },
    );
  }
}
