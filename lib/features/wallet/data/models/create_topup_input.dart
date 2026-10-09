class CreateTopupInput {
  const CreateTopupInput({
    required this.amount,
    required this.channelCode,
    this.channelProperties,
  });

  final double amount;
  final String channelCode;
  final Map<String, dynamic>? channelProperties;

  Map<String, dynamic> toJson() => {
    'amount': amount.toInt(),
    'channelCode': channelCode,
    if (channelProperties != null && channelProperties!.isNotEmpty)
      'channelProperties': channelProperties,
  };
}
