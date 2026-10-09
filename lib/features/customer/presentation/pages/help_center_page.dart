import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/color.dart';
import '../../../../config/routes.dart';
import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../config/shapes.dart';
import '../../../../core/widgets/feedback/app_loading_view.dart';
import '../../application/customer_service.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  late Future<Map<String, dynamic>?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<CustomerService>().getHelpCenter();
  }

  Future<void> _launchWhatsApp(String number) async {
    final url = Uri.parse('https://wa.me/$number');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Bantuan')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingView();
          }

          final data = snapshot.data ?? {};
          final whatsapp = data['whatsapp']?.toString() ?? '6281234567890';
          final email = data['email']?.toString() ?? 'support@travelindo.com';
          final hours = data['hours']?.toString();
          final faq = (data['faq'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? [];

          return ListView(
            padding: AppPadding.screen,
            children: [
              Icon(LucideIcons.headset, size: 64.sp, color: AppColors.orange),
              AppGap.lg,
              Text(
                'Ada kendala dengan pesanan Anda?',
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              AppGap.sm,
              Text(
                'Tim bantuan kami siap membantu Anda menyelesaikan masalah yang terjadi selama perjalanan.',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (hours != null) ...[
                AppGap.sm,
                Text(hours, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
              ],
              AppGap.ctaSpacer,
              _HelpCard(
                title: 'Hubungi via WhatsApp',
                subtitle: 'Respon cepat melalui chat WhatsApp resmi.',
                icon: LucideIcons.messageCircle,
                color: AppColors.success,
                onTap: () => _launchWhatsApp(whatsapp),
              ),
              AppGap.lg,
              _HelpCard(
                title: 'Kirim Email',
                subtitle: 'Kirimkan detail keluhan Anda ke $email',
                icon: LucideIcons.mail,
                color: AppColors.navy,
                onTap: () async {
                  final url = Uri.parse('mailto:$email');
                  await launchUrl(url);
                },
              ),
              AppGap.lg,
              _HelpCard(
                title: 'Kebijakan Pembatalan',
                subtitle: 'Pelajari syarat refund dan pembatalan pesanan.',
                icon: LucideIcons.fileText,
                color: AppColors.orange,
                onTap: () => context.push(AppRoutePaths.cancellationPolicy),
              ),
              AppGap.ctaSpacer,
              Text('FAQ (Pertanyaan Populer)', style: AppTextStyles.titleMedium),
              AppGap.md,
              if (faq.isEmpty)
                const _FaqItem(
                  question: 'Bagaimana cara membatalkan pesanan?',
                  answer: 'Anda dapat membatalkan pesanan melalui halaman Pesanan Saya sebelum status berubah menjadi Selesai.',
                )
              else
                ...faq.map(
                  (item) => _FaqItem(
                    question: item['q']?.toString() ?? '-',
                    answer: item['a']?.toString() ?? '-',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: AppPadding.list,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: AppShapes.md,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            AppGap.h(AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleSmall),
                  AppGap.xxs,
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, size: 16.sp),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({required this.question, required this.answer});
  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.page),
          child: Text(answer, style: AppTextStyles.bodySmall),
        ),
      ],
    );
  }
}
