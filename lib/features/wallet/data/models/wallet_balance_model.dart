class WalletBalanceModel {
  const WalletBalanceModel({
    required this.balance,
    required this.totalEarned,
    required this.totalWithdrawn,
    this.updatedAt,
  });

  final double balance;
  final double totalEarned;
  final double totalWithdrawn;
  final String? updatedAt;

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (json['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'balance': balance,
    'totalEarned': totalEarned,
    'totalWithdrawn': totalWithdrawn,
    if (updatedAt != null) 'updatedAt': updatedAt,
  };
}
