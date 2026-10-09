import 'package:flutter/foundation.dart';

import '../../../core/cache/reference_data_cache.dart';
import '../../../core/utils/error_message_util.dart';
import '../data/models/add_bank_account_input.dart';
import '../data/models/create_topup_input.dart';
import '../data/models/supported_bank_model.dart';
import '../data/models/wallet_balance_model.dart';
import '../data/models/wallet_model.dart';
import '../data/models/wallet_topup_model.dart';
import '../data/wallet_remote_datasource.dart'; // exports PaginatedTransactionResult
import '../data/wallet_repository.dart';

enum WalletStatus { initial, loading, loaded, failure }

class WalletService extends ChangeNotifier {
  WalletService(this._repository, this._referenceCache);

  final WalletRepository _repository;
  final ReferenceDataCache _referenceCache;

  WalletStatus _status = WalletStatus.initial;
  WalletBalanceModel? _walletBalance;
  List<TransactionModel> _transactions = [];
  List<BankAccountModel> _bankAccounts = [];
  String? _message;

  int _currentPage = 1;
  bool _hasMoreTransactions = true;
  bool _isLoadingMore = false;

  bool _isBankLoading = false;
  bool _isBankActionLoading = false;
  String? _bankErrorMessage;

  WalletStatus get status => _status;
  WalletBalanceModel? get walletBalance => _walletBalance;
  double get balance => _walletBalance?.balance ?? 0.0;
  double get totalEarned => _walletBalance?.totalEarned ?? 0.0;
  double get totalWithdrawn => _walletBalance?.totalWithdrawn ?? 0.0;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<BankAccountModel> get bankAccounts => List.unmodifiable(_bankAccounts);
  String? get errorMessage => _message;
  bool get hasMoreTransactions => _hasMoreTransactions;
  bool get isLoadingMore => _isLoadingMore;

  bool get isBankLoading => _isBankLoading;
  bool get isBankActionLoading => _isBankActionLoading;
  String? get bankErrorMessage => _bankErrorMessage;

  Future<void> loadWalletData() async {
    _status = WalletStatus.loading;
    _currentPage = 1;
    _hasMoreTransactions = true;
    notifyListeners();

    try {
      final balanceResp = await _repository.getBalance();
      // C1 FIX: Use server-authoritative pagination instead of count == limit heuristic.
      final transResult = await _repository.getTransactions(page: 1, limit: 10);
      _walletBalance = balanceResp.data;
      _transactions = transResult.transactions;
      _hasMoreTransactions = transResult.hasMore;
      _status = WalletStatus.loaded;
    } catch (error) {
      _message = userFacingError(error);
      _status = WalletStatus.failure;
    }
    notifyListeners();
  }

  Future<void> loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMoreTransactions) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      // C1 FIX: Use server-authoritative hasMore from pagination metadata.
      final result = await _repository.getTransactions(page: _currentPage, limit: 10);
      final newTransactions = result.transactions;

      if (newTransactions.isEmpty) {
        _hasMoreTransactions = false;
      } else {
        _transactions.addAll(newTransactions);
        _hasMoreTransactions = result.hasMore;
      }
    } catch (error) {
      _message = userFacingError(error);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadBankAccounts() async {
    _isBankLoading = true;
    _bankErrorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getMyBankAccounts();
      _bankAccounts = response.data ?? [];
    } catch (e) {
      _bankErrorMessage = userFacingError(e);
    } finally {
      _isBankLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addBankAccount(AddBankAccountInput input) async {
    _isBankActionLoading = true;
    _bankErrorMessage = null;
    notifyListeners();

    try {
      // Auto main if it's the first account
      final shouldBeMain = input.isMain || _bankAccounts.isEmpty;
      final payload = AddBankAccountInput(
        bankId: input.bankId,
        accountNumber: input.accountNumber,
        accountName: input.accountName,
        isMain: shouldBeMain,
      );

      await _repository.addBankAccount(payload);
      await loadBankAccounts();
      return true;
    } catch (e) {
      _bankErrorMessage = userFacingError(e);
      return false;
    } finally {
      _isBankActionLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBankAccount(String id) async {
    _isBankActionLoading = true;
    _bankErrorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteBankAccount(id);
      await loadBankAccounts();
      return true;
    } catch (e) {
      _bankErrorMessage = userFacingError(e);
      return false;
    } finally {
      _isBankActionLoading = false;
      notifyListeners();
    }
  }

  Future<List<SupportedBankModel>> getSupportedBanks() async {
    try {
      return await _referenceCache.getBanks();
    } catch (_) {
      return [];
    }
  }

  Future<bool> setPrimaryBankAccount(String id) async {
    _isBankActionLoading = true;
    _bankErrorMessage = null;
    notifyListeners();

    try {
      await _repository.setPrimaryBankAccount(id);
      await loadBankAccounts();
      return true;
    } catch (e) {
      _bankErrorMessage = userFacingError(e);
      return false;
    } finally {
      _isBankActionLoading = false;
      notifyListeners();
    }
  }

  Future<WalletTopupModel?> createTopup(CreateTopupInput input) async {
    try {
      final response = await _repository.createTopup(input);
      return response.data;
    } catch (error) {
      _message = userFacingError(error);
      notifyListeners();
      return null;
    }
  }

  Future<WalletTopupModel?> checkTopupStatus(String topupId) async {
    try {
      final response = await _repository.getTopupStatus(topupId);
      return response.data;
    } catch (_) {
      return null;
    }
  }
}
