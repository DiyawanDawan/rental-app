import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:travelindo/config/color.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/text_styles.dart';
import '../../../../config/spacing.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../features/customer/application/customer_service.dart';
import '../../../../features/customer/data/models/payment_channel_model.dart';
import '../../data/models/create_topup_input.dart';
import '../../application/wallet_service.dart';

class WalletTopupPage extends StatefulWidget {
  const WalletTopupPage({super.key});

  @override
  State<WalletTopupPage> createState() => _WalletTopupPageState();
}

class _WalletTopupPageState extends State<WalletTopupPage> {
  final _amountController = TextEditingController(text: '50000');
  PaymentChannelModel? _selectedChannel;
  bool _submitting = false;

  final List<int> _quickAmounts = [20000, 50000, 100000, 200000, 500000, 1000000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;
    final channel = _selectedChannel;
    
    if (channel == null) {
      SnackbarUtils.showInfo(context, 'Pilih metode pembayaran');
      return;
    }
    if (amount < 10000) {
      SnackbarUtils.showError(context, 'Nominal top-up minimal Rp 10.000');
      return;
    }
    if (amount > 10000000) {
      SnackbarUtils.showError(context, 'Nominal top-up maksimal Rp 10.000.000');
      return;
    }

    setState(() => _submitting = true);
    final input = CreateTopupInput(
      amount: amount,
      channelCode: channel.code,
    );
    
    final result = await context.read<WalletService>().createTopup(input);
    setState(() => _submitting = false);

    if (result == null) {
      SnackbarUtils.showError(context, context.read<WalletService>().errorMessage ?? 'Gagal membuat top-up');
      return;
    }

    if (!mounted) return;
    _showPollingBottomSheet(result.id, result.paymentUrl);
  }

  void _showPollingBottomSheet(String topupId, String? paymentUrl) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) {
        return _PollingSheet(topupId: topupId, paymentUrl: paymentUrl);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Up Dompet')),
      body: ListView(
        padding: AppPadding.screen,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nominal (Rp)',
              hintText: '50000',
              prefixText: 'Rp ',
            ),
          ),
          AppGap.md,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickAmounts.map((amount) {
              return ActionChip(
                label: Text(MoneyFormatter.rupiah(amount.toDouble())),
                onPressed: () {
                  _amountController.text = amount.toString();
                },
              );
            }).toList(),
          ),
          AppGap.v(AppSpacing.xxl),
          Text('Metode Pembayaran', style: AppTextStyles.titleMedium),
          AppGap.sm,
          FutureBuilder<List<PaymentChannelModel>>(
            future: context.read<CustomerService>().getPaymentChannels(),
            builder: (context, snapshot) {
              final channels = snapshot.data ?? [];
              if (channels.isEmpty) {
                return const Text('Memuat kanal pembayaran...');
              }
              return Column(
                children: channels
                    .map(
                      (c) => RadioListTile<PaymentChannelModel>(
                        title: Text(c.name),
                        subtitle: Text(c.code),
                        value: c,
                        groupValue: _selectedChannel,
                        onChanged: (val) => setState(() => _selectedChannel = val),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          AppGap.v(AppSpacing.xxl),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Top Up Sekarang'),
          ),
        ],
      ),
    );
  }
}

class _PollingSheet extends StatefulWidget {
  const _PollingSheet({required this.topupId, this.paymentUrl});
  final String topupId;
  final String? paymentUrl;

  @override
  State<_PollingSheet> createState() => _PollingSheetState();
}

class _PollingSheetState extends State<_PollingSheet> {
  Timer? _pollTimer;
  int _pollCount = 0;
  String _status = 'PENDING';

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      _pollCount++;
      if (_pollCount > 45) { // 3 minutes timeout
        timer.cancel();
        if (mounted) setState(() => _status = 'TIMEOUT');
        return;
      }
      
      final topup = await context.read<WalletService>().checkTopupStatus(widget.topupId);
      if (topup != null && mounted) {
        if (topup.isTerminal) {
          timer.cancel();
          setState(() => _status = topup.status);
          
          if (topup.isSuccess) {
            await context.read<WalletService>().loadWalletData();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.screen,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Status Pembayaran', style: AppTextStyles.titleMedium, textAlign: TextAlign.center),
          AppGap.lg,
          if (_status == 'PENDING') ...[
            const Center(child: CircularProgressIndicator()),
            AppGap.lg,
            const Text('Menunggu pembayaran Anda...', textAlign: TextAlign.center),
            if (widget.paymentUrl != null) ...[
              AppGap.md,
              ElevatedButton(
                onPressed: () async {
                  final uri = Uri.parse(widget.paymentUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: const Text('Buka Aplikasi Pembayaran'),
              ),
            ],
           ] else if (_status == 'SUCCESS') ...[
             Icon(LucideIcons.circleCheck, color: AppColors.success, size: 48),
            AppGap.md,
            Text('Top Up Berhasil!', textAlign: TextAlign.center, style: AppTextStyles.titleMedium.copyWith(color: AppColors.success)),
            AppGap.lg,
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close sheet
                Navigator.pop(context); // back to wallet
              },
              child: const Text('Selesai'),
            ),
           ] else ...[
             Icon(LucideIcons.circleX, color: AppColors.error, size: 48),
            AppGap.md,
            Text('Top Up $_status', textAlign: TextAlign.center, style: AppTextStyles.titleMedium.copyWith(color: AppColors.error)),
            AppGap.lg,
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
          AppGap.md,
          if (_status == 'PENDING')
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batalkan'),
            ),
        ],
      ),
    );
  }
}
