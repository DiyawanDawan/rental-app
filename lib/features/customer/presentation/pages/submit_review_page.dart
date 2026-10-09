import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../config/color.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../application/customer_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubmitReviewPage extends StatefulWidget {
  const SubmitReviewPage({required this.bookingId, required this.vehicleName, super.key});

  final String bookingId;
  final String vehicleName;

  @override
  State<SubmitReviewPage> createState() => _SubmitReviewPageState();
}

class _SubmitReviewPageState extends State<SubmitReviewPage> {
  int _rating = 5;
  int _ratingCleanliness = 5;
  int _ratingService = 5;
  int _ratingCondition = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await context.read<CustomerService>().submitReview(
      bookingId: widget.bookingId,
      rating: _rating,
      comment: _commentController.text.trim(),
      ratingCleanliness: _ratingCleanliness,
      ratingService: _ratingService,
      ratingCondition: _ratingCondition,
    );

    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'Terima kasih atas review Anda!');
      context.pop();
    } else {
      SnackbarUtils.showError(context, 'Gagal mengirim review');
    }
  }

  Widget _buildStarRating(String label, int value, ValueChanged<int> onChanged, {double size = 32}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label, style: AppTextStyles.titleSmall),
          AppGap.xs,
        ],
        Row(
          mainAxisAlignment: label.isEmpty ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: List.generate(5, (index) {
            final starValue = index + 1;
            return GestureDetector(
              onTap: () => onChanged(starValue),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  LucideIcons.star,
                  size: size.sp,
                  color: starValue <= value ? AppColors.warning : AppColors.lightGray,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Beri Review')),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.xl),
        children: [
          Text(
            'Bagaimana pengalaman Anda dengan ${widget.vehicleName}?',
            style: AppTextStyles.titleMedium,
            textAlign: TextAlign.center,
          ),
          AppGap.v(AppSpacing.xl),
          _buildStarRating('', _rating, (v) => setState(() => _rating = v), size: 48),
          
          AppGap.v(AppSpacing.xl),
          Divider(),
          AppGap.v(AppSpacing.xl),
          
          Text(
            'Penilaian Detail',
            style: AppTextStyles.titleMedium,
          ),
          AppGap.v(AppSpacing.md),
          _buildStarRating('Kebersihan', _ratingCleanliness, (v) => setState(() => _ratingCleanliness = v)),
          AppGap.v(AppSpacing.md),
          _buildStarRating('Layanan', _ratingService, (v) => setState(() => _ratingService = v)),
          AppGap.v(AppSpacing.md),
          _buildStarRating('Kondisi Kendaraan', _ratingCondition, (v) => setState(() => _ratingCondition = v)),
          
          AppGap.v(AppSpacing.xl),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Komentar (Opsional)',
              hintText: 'Ceritakan pengalaman Anda...',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 40.h),
          Consumer<CustomerService>(
            builder: (context, service, child) {
              final isLoading = service.status == CustomerStatus.loading;
              return ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Kirim Review'),
              );
            },
          ),
        ],
      ),
    );
  }
}
