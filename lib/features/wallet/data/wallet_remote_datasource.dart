import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import 'models/add_bank_account_input.dart';
import 'models/create_topup_input.dart';
import 'models/supported_bank_model.dart';
import 'models/wallet_balance_model.dart';
import 'models/wallet_model.dart';
import 'models/wallet_topup_model.dart';

/// C1 FIX: Carry pagination metadata alongside transaction data.
/// Backend `paginatedResponse` emits `{ meta, data, pagination: { page, limit, total, totalPages } }`.
/// The plain `ApiResponse<List<T>>` only captures `data`; we need `pagination.totalPages`
/// to correctly drive infinite scroll instead of using a fragile `count == limit` heuristic.
class PaginatedTransactionResult {
  const PaginatedTransactionResult({
    required this.transactions,
    required this.totalPages,
    required this.currentPage,
  });
  final List<TransactionModel> transactions;
  final int totalPages;
  final int currentPage;

  bool get hasMore => currentPage < totalPages;
}

class WalletRemoteDataSource {
  const WalletRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<ApiResponse<WalletBalanceModel>> getBalance() async {
    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.walletBalance);
    return ApiResponse<WalletBalanceModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => WalletBalanceModel.fromJson(
        json is Map<String, dynamic> ? json : <String, dynamic>{},
      ),
    );
  }

  Future<PaginatedTransactionResult> getTransactions({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.walletTransactions,
      queryParameters: {'page': page, 'limit': limit},
    );
    final raw = response.data ?? <String, dynamic>{};

    // C1 FIX: Read `pagination` block from paginatedResponse format.
    final paginationJson = raw['pagination'] as Map<String, dynamic>?;
    final totalPages = (paginationJson?['totalPages'] as num?)?.toInt() ?? 1;
    final currentPage = (paginationJson?['page'] as num?)?.toInt() ?? page;

    final dataJson = raw['data'];
    final transactions = dataJson is List
        ? dataJson.whereType<Map<String, dynamic>>().map(TransactionModel.fromJson).toList()
        : <TransactionModel>[];

    return PaginatedTransactionResult(
      transactions: transactions,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }

  Future<ApiResponse<List<BankAccountModel>>> getMyBankAccounts() async {
    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.bankAccounts);
    return ApiResponse<List<BankAccountModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json.whereType<Map<String, dynamic>>().map(BankAccountModel.fromJson).toList()
          : <BankAccountModel>[],
    );
  }

  Future<ApiResponse<BankAccountModel>> addBankAccount(AddBankAccountInput input) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.bankAccounts,
      data: input.toJson(),
    );
    return ApiResponse<BankAccountModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => BankAccountModel.fromJson(json is Map<String, dynamic> ? json : <String, dynamic>{}),
    );
  }

  Future<ApiResponse<void>> deleteBankAccount(String id) async {
    final response = await _apiClient.delete<Map<String, dynamic>>(ApiEndpoints.bankAccountById(id));
    return ApiResponse<void>.fromJson(response.data ?? <String, dynamic>{}, (_) {});
  }

  Future<ApiResponse<List<SupportedBankModel>>> getSupportedBanks() async {
    final response = await _apiClient.get<Map<String, dynamic>>(ApiEndpoints.banksSupported);
    return ApiResponse<List<SupportedBankModel>>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => json is List
          ? json.whereType<Map<String, dynamic>>().map(SupportedBankModel.fromJson).toList()
          : <SupportedBankModel>[],
    );
  }

  Future<ApiResponse<WalletTopupModel>> createTopup(CreateTopupInput input) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiEndpoints.walletTopup,
      data: input.toJson(),
    );
    return ApiResponse<WalletTopupModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => WalletTopupModel.fromJson(
        json is Map<String, dynamic> ? json : <String, dynamic>{},
      ),
    );
  }

  Future<ApiResponse<WalletTopupModel>> getTopupStatus(String id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiEndpoints.walletTopupStatus(id),
    );
    return ApiResponse<WalletTopupModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => WalletTopupModel.fromJson(
        json is Map<String, dynamic> ? json : <String, dynamic>{},
      ),
    );
  }

  Future<ApiResponse<BankAccountModel>> setPrimaryBankAccount(String id) async {
    final response = await _apiClient.patch<Map<String, dynamic>>(
      ApiEndpoints.bankAccountPrimary(id),
    );
    return ApiResponse<BankAccountModel>.fromJson(
      response.data ?? <String, dynamic>{},
      (json) => BankAccountModel.fromJson(json is Map<String, dynamic> ? json : <String, dynamic>{}),
    );
  }
}
