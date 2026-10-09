import '../../../core/network/api_response.dart';
import 'models/add_bank_account_input.dart';
import 'models/create_topup_input.dart';
import 'models/supported_bank_model.dart';
import 'models/wallet_balance_model.dart';
import 'models/wallet_model.dart';
import 'models/wallet_topup_model.dart';
import 'wallet_remote_datasource.dart'; // exports PaginatedTransactionResult

class WalletRepository {
  const WalletRepository(this._remoteDataSource);

  final WalletRemoteDataSource _remoteDataSource;

  Future<ApiResponse<WalletBalanceModel>> getBalance() => _remoteDataSource.getBalance();

  Future<PaginatedTransactionResult> getTransactions({
    int page = 1,
    int limit = 10,
  }) =>
      _remoteDataSource.getTransactions(page: page, limit: limit);

  Future<ApiResponse<List<BankAccountModel>>> getMyBankAccounts() => _remoteDataSource.getMyBankAccounts();

  Future<ApiResponse<BankAccountModel>> addBankAccount(AddBankAccountInput input) => _remoteDataSource.addBankAccount(input);

  Future<ApiResponse<void>> deleteBankAccount(String id) => _remoteDataSource.deleteBankAccount(id);

  Future<ApiResponse<List<SupportedBankModel>>> getSupportedBanks() =>
      _remoteDataSource.getSupportedBanks();

  Future<ApiResponse<BankAccountModel>> setPrimaryBankAccount(String id) =>
      _remoteDataSource.setPrimaryBankAccount(id);

  Future<ApiResponse<WalletTopupModel>> createTopup(CreateTopupInput input) =>
      _remoteDataSource.createTopup(input);

  Future<ApiResponse<WalletTopupModel>> getTopupStatus(String id) =>
      _remoteDataSource.getTopupStatus(id);
}
