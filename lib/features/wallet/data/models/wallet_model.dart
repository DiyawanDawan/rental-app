class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
    this.status = 'COMPLETED',
  });

  final String id;
  final double amount;
  final String type;
  final String category;
  final double balanceBefore;
  final double balanceAfter;
  final String description;
  final String createdAt;
  final String status;

  bool get isCredit =>
      type == 'CREDIT' || type == 'TOPUP' || type == 'EARNING' || type == 'REFUND';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      status: json['status']?.toString() ?? 'COMPLETED',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'type': type,
    'category': category,
    'balanceBefore': balanceBefore,
    'balanceAfter': balanceAfter,
    'description': description,
    'createdAt': createdAt,
    'status': status,
  };
}

class BankAccountModel {
  const BankAccountModel({
    required this.id,
    required this.userId,
    required this.bankId,
    required this.accountName,
    required this.accountNumber,
    required this.isMain,
    required this.bankName,
    this.bankCode,
    this.bankLogoUrl,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String bankId;
  final String accountName;
  final String accountNumber;
  final bool isMain;
  final String bankName;
  final String? bankCode;
  final String? bankLogoUrl;
  final String? createdAt;

  // Getter alias untuk backwards compatibility
  String get accountHolder => accountName;
  bool get isPrimary => isMain;

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      bankId: json['bankId']?.toString() ?? '',
      accountName: json['accountName']?.toString() ?? json['accountHolder']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      isMain: json['isMain'] == true || json['isPrimary'] == true,
      bankName: json['bankName']?.toString() ?? '',
      bankCode: json['bankCode']?.toString(),
      bankLogoUrl: json['bankLogoUrl']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'bankId': bankId,
    'accountName': accountName,
    'accountNumber': accountNumber,
    'isMain': isMain,
    'bankName': bankName,
    if (bankCode != null) 'bankCode': bankCode,
    if (bankLogoUrl != null) 'bankLogoUrl': bankLogoUrl,
    if (createdAt != null) 'createdAt': createdAt,
  };
}
