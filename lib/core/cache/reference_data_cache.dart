import '../../features/customer/data/customer_repository.dart';
import '../../features/customer/data/models/amenity_model.dart';
import '../../features/customer/data/models/payment_channel_model.dart';
import '../../features/customer/data/models/region_model.dart';
import '../../features/wallet/data/models/supported_bank_model.dart';
import '../../features/wallet/data/wallet_repository.dart';

class _CacheEntry<T> {
  _CacheEntry(this.value, this.expiresAt);

  final T value;
  final DateTime expiresAt;

  bool get isValid => DateTime.now().isBefore(expiresAt);
}

/// In-memory TTL cache for stable reference data only.
/// Never cache wallet balance, bookings, prices, or availability.
class ReferenceDataCache {
  ReferenceDataCache(this._walletRepository, this._customerRepository);

  final WalletRepository _walletRepository;
  final CustomerRepository _customerRepository;

  static const banksTtl = Duration(hours: 24);
  static const amenitiesTtl = Duration(hours: 24);
  static const policiesTtl = Duration(hours: 1);
  static const paymentChannelsTtl = Duration(minutes: 10);
  static const regionsTtl = Duration(days: 7);

  final Map<String, _CacheEntry<dynamic>> _store = {};

  Future<List<SupportedBankModel>> getBanks() {
    return _getOrFetch<List<SupportedBankModel>>(
      'banks',
      banksTtl,
      () async {
        final response = await _walletRepository.getSupportedBanks();
        return response.data ?? [];
      },
    );
  }

  Future<List<PaymentChannelModel>> getPaymentChannels() {
    return _getOrFetch<List<PaymentChannelModel>>(
      'payment_channels',
      paymentChannelsTtl,
      () async {
        final response = await _customerRepository.getPaymentChannels();
        return response.data ?? [];
      },
    );
  }

  Future<List<Map<String, dynamic>>> getCancellationPolicies() {
    return _getOrFetch<List<Map<String, dynamic>>>(
      'cancellation_policies',
      policiesTtl,
      () async {
        final response = await _customerRepository.getCancellationPolicies();
        return response.data ?? [];
      },
    );
  }

  Future<List<AmenityModel>> getAmenities() {
    return _getOrFetch<List<AmenityModel>>(
      'amenities',
      amenitiesTtl,
      () async {
        final response = await _customerRepository.getAmenities();
        return response.data ?? [];
      },
    );
  }

  Future<List<RegionItemModel>> getRegions({
    String? countryId,
    String? provinceId,
    String? regencyId,
    String? districtId,
  }) {
    final key = 'regions:${countryId ?? ''}:${provinceId ?? ''}:${regencyId ?? ''}:${districtId ?? ''}';
    return _getOrFetch<List<RegionItemModel>>(
      key,
      regionsTtl,
      () async {
        final response = await _customerRepository.getAddressRegions(
          countryId: countryId,
          provinceId: provinceId,
          regencyId: regencyId,
          districtId: districtId,
        );
        return response.data ?? [];
      },
    );
  }

  Future<T> _getOrFetch<T>(
    String key,
    Duration ttl,
    Future<T> Function() fetch,
  ) async {
    final cached = _store[key];
    if (cached != null && cached.isValid) {
      return cached.value as T;
    }

    final value = await fetch();
    _store[key] = _CacheEntry<T>(value, DateTime.now().add(ttl));
    return value;
  }

  void clearAll() {
    _store.clear();
  }
}
