import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _items = [
    _OnboardingData(
      title: 'Selamat Datang di Travelindo',
      description: 'Solusi lengkap untuk perjalanan Anda. Sewa kendaraan dengan mudah dan cepat.',
      image: 'assets/images/onboarding_1.png',
      color: AppColors.navy,
    ),
    _OnboardingData(
      title: 'Pilihan Kendaraan Beragam',
      description: 'Dari city car hingga mobil mewah, semua tersedia untuk mendukung mobilitas Anda.',
      image: 'assets/images/onboarding_2.png',
      color: AppColors.teal,
    ),
    _OnboardingData(
      title: 'Travel & Wisata',
      description: 'Temukan jadwal travel antar kota dan paket wisata menarik dengan harga terbaik.',
      image: 'assets/images/onboarding_3.png',
      color: AppColors.orange,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go(AppRoutePaths.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final item = _items[index];
              return Container(
                color: item.color.withValues(alpha: 0.05),
                padding: EdgeInsets.all(AppSpacing.xxl + AppSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder for Image
                    Container(
                      height: 250.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: AppShapes.lg,
                      ),
                      child: Icon(Icons.image, size: 80.sp, color: item.color),
                    ),
                    SizedBox(height: 48.h),
                    Text(
                      item.title,
                      style: AppTextStyles.headlineMedium.copyWith(color: item.color),
                      textAlign: TextAlign.center,
                    ),
                    AppGap.lg,
                    Text(
                      item.description,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xxl),
                child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _items.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      width: _currentPage == index ? 24 : 8,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.orange : AppColors.lightGray,
                        borderRadius: AppShapes.xxs,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text('Lewati'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _items.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: AppSpacing.ctaSpacer, vertical: AppSpacing.md),
                      ),
                      child: Text(_currentPage == _items.length - 1 ? 'Mulai' : 'Lanjut'),
                    ),
                  ],
                ),
              ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String title;
  final String description;
  final String image;
  final Color color;

  _OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}
