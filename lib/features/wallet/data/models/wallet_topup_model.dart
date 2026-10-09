class WalletTopupModel {
  const WalletTopupModel({
    required this.id,
    required this.amount,
    required this.status,
    this.channelCode,
    this.paymentUrl,
    this.createdAt,
  });

  final String id;
  final double amount;
  final String status;
  final String? channelCode;
  final String? paymentUrl;
  final String? createdAt;

  bool get isPending => status.toUpperCase() == 'PENDING';
  bool get isSuccess => status.toUpperCase() == 'SUCCESS';
  bool get isFailed => status.toUpperCase() == 'FAILED';
  bool get isExpired => status.toUpperCase() == 'EXPIRED';
  bool get isCancelled => status.toUpperCase() == 'CANCELLED';

  bool get isTerminal => isSuccess || isFailed || isExpired || isCancelled;

  factory WalletTopupModel.fromJson(Map<String, dynamic> json) {
    return WalletTopupModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'PENDING',
      channelCode: json['channelCode']?.toString(),
      paymentUrl: json['paymentUrl']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'status': status,
    if (channelCode != null) 'channelCode': channelCode,
    if (paymentUrl != null) 'paymentUrl': paymentUrl,
    if (createdAt != null) 'createdAt': createdAt,
  };
}
