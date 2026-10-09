class AddBankAccountInput {
  const AddBankAccountInput({
    required this.bankId,
    required this.accountNumber,
    required this.accountName,
    this.isMain = false,
  });

  final String bankId;
  final String accountNumber;
  final String accountName;
  final bool isMain;

  Map<String, dynamic> toJson() => {
    'bankId': bankId,
    'accountNumber': accountNumber.trim(),
    'accountName': accountName.trim(),
    'isMain': isMain,
  };
}
