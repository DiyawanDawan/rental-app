import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/inputs/app_filter_chip.dart';
import '../../../../core/widgets/layout/scroll_safe_padding.dart';
import '../../../../config/theme_context.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../application/customer_service.dart';
import '../../data/models/amenity_model.dart';

typedef VehicleFilterApplyCallback = void Function(
  String? type,
  String? transmission,
  String sort,
  RangeValues priceRange,
  List<String> amenityIds,
  bool minRatingFour,
);

/// Active filter chip shown above vehicle list.
class VehicleFilterChip extends StatelessWidget {
  const VehicleFilterChip({required this.label, required this.onDeleted, super.key});

  final String label;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.sm),
      child: Chip(
        label: Text(label, style: AppTextStyles.bodySmall.copyWith(fontSize: 12.sp)),
        onDeleted: onDeleted,
        deleteIcon: Icon(LucideIcons.x, size: 14.sp),
        backgroundColor: cs.secondaryContainer,
        side: BorderSide(color: cs.secondary, width: 0.5.w),
      ),
    );
  }
}

/// Bottom sheet for vehicle filter and sorting.
class VehicleFilterSheet extends StatefulWidget {
  const VehicleFilterSheet({
    this.initialType,
    this.initialTransmission,
    required this.initialSort,
    required this.initialPriceRange,
    required this.initialAmenityIds,
    this.initialMinRatingFour = false,
    required this.onApply,
    super.key,
  });

  final String? initialType;
  final String? initialTransmission;
  final String initialSort;
  final RangeValues initialPriceRange;
  final List<String> initialAmenityIds;
  final bool initialMinRatingFour;
  final VehicleFilterApplyCallback onApply;

  @override
  State<VehicleFilterSheet> createState() => _VehicleFilterSheetState();
}

class _VehicleFilterSheetState extends State<VehicleFilterSheet> {
  String? _type;
  String? _transmission;
  late String _sort;
  late RangeValues _priceRange;
  late List<String> _amenityIds;
  late bool _minRatingFour;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _transmission = widget.initialTransmission;
    _sort = widget.initialSort;
    _priceRange = widget.initialPriceRange;
    _amenityIds = List.from(widget.initialAmenityIds);
    _minRatingFour = widget.initialMinRatingFour;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.cs;
    return SafeArea(
      child: Padding(
        padding: ScrollSafePadding.sheetPadding(context),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filter & Sorting', style: AppTextStyles.titleLarge),
                  IconButton(onPressed: () => Navigator.pop(context), icon: Icon(LucideIcons.x)),
                ],
              ),
              const Divider(),
              AppGap.md,
              Text('Urutkan', style: AppTextStyles.titleSmall),
              AppGap.sm,
              _buildSortOptions(),
              AppGap.section,
              Text('Jenis Kendaraan', style: AppTextStyles.titleSmall),
              AppGap.sm,
              _buildTypeOptions(),
              AppGap.section,
              Text('Transmisi', style: AppTextStyles.titleSmall),
              AppGap.sm,
              _buildTransmissionOptions(),
              AppGap.section,
              Text('Rating', style: AppTextStyles.titleSmall),
              AppGap.sm,
              AppFilterChip(
                label: const Text('Rating ≥ 4 bintang'),
                selected: _minRatingFour,
                onSelected: (v) => setState(() => _minRatingFour = v),
              ),
              AppGap.section,
              Text('Harga per Hari', style: AppTextStyles.titleSmall),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 5000000,
                divisions: 50,
                activeColor: cs.secondary,
                labels: RangeLabels(
                  MoneyFormatter.rupiah(_priceRange.start),
                  MoneyFormatter.rupiah(_priceRange.end),
                ),
                onChanged: (values) => setState(() => _priceRange = values),
              ),
              AppGap.section,
              Text('Fasilitas', style: AppTextStyles.titleSmall),
              AppGap.sm,
              _buildAmenitiesOptions(),
              AppGap.ctaSpacer,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _type = null;
                          _transmission = null;
                          _sort = 'newest';
                          _priceRange = const RangeValues(0, 5000000);
                          _amenityIds.clear();
                          _minRatingFour = false;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ),
                  AppGap.h(AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(_type, _transmission, _sort, _priceRange, _amenityIds, _minRatingFour);
                        Navigator.pop(context);
                      },
                      child: const Text('Terapkan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: VehicleSortOptions.options.entries.map((e) {
        return ChoiceChip(
          label: Text(e.value),
          selected: _sort == e.key,
          onSelected: (_) => setState(() => _sort = e.key),
        );
      }).toList(),
    );
  }

  Widget _buildTypeOptions() {
    return Wrap(
      spacing: AppSpacing.sm,
      children: VehicleTypeOptions.options.entries.map((e) {
        final isSelected = _type == e.key;
        return ChoiceChip(
          label: Text(e.value),
          selected: isSelected,
          onSelected: (v) => setState(() => _type = v ? e.key : null),
        );
      }).toList(),
    );
  }

  Widget _buildTransmissionOptions() {
    return Wrap(
      spacing: AppSpacing.sm,
      children: TransmissionOptions.options.entries.map((e) {
        final isSelected = _transmission == e.key;
        return ChoiceChip(
          label: Text(e.value),
          selected: isSelected,
          onSelected: (v) => setState(() => _transmission = v ? e.key : null),
        );
      }).toList(),
    );
  }

  Widget _buildAmenitiesOptions() {
    return FutureBuilder<List<AmenityModel>>(
      future: context.read<CustomerService>().getAmenities(),
      builder: (context, snapshot) {
        final options = snapshot.data ?? const <AmenityModel>[];
        if (options.isEmpty) {
          return Text('Fasilitas belum tersedia', style: AppTextStyles.bodySmall);
        }
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: options.map((amenity) {
            final isSelected = _amenityIds.contains(amenity.id);
            return AppFilterChip(
              label: Text(amenity.name),
              selected: isSelected,
              onSelected: (v) {
                setState(() {
                  if (v) {
                    _amenityIds.add(amenity.id);
                  } else {
                    _amenityIds.remove(amenity.id);
                  }
                });
              },
            );
          }).toList(),
        );
      },
    );
  }
}
