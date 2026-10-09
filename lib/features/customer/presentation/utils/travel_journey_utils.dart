import '../../data/models/travel_model.dart';

enum TravelJourneyPhase { waiting, onTheWay, arrived, cancelled }

class TravelJourneyUtils {
  const TravelJourneyUtils._();

  static TravelJourneyPhase resolvePhase({
    String? scheduleStatus,
    DateTime? departureAt,
    DateTime? arrivalAt,
  }) {
    switch (scheduleStatus?.toUpperCase()) {
      case 'CANCELLED':
        return TravelJourneyPhase.cancelled;
      case 'ARRIVED':
        return TravelJourneyPhase.arrived;
      case 'ON_THE_WAY':
        return TravelJourneyPhase.onTheWay;
    }

    final now = DateTime.now();
    if (departureAt != null && now.isBefore(departureAt)) {
      return TravelJourneyPhase.waiting;
    }
    if (arrivalAt != null && now.isAfter(arrivalAt)) {
      return TravelJourneyPhase.arrived;
    }
    if (departureAt != null && now.isAfter(departureAt)) {
      return TravelJourneyPhase.onTheWay;
    }
    return TravelJourneyPhase.waiting;
  }

  static String phaseLabel(TravelJourneyPhase phase) {
    switch (phase) {
      case TravelJourneyPhase.waiting:
        return 'Menunggu keberangkatan';
      case TravelJourneyPhase.onTheWay:
        return 'Bus dalam perjalanan';
      case TravelJourneyPhase.arrived:
        return 'Sudah tiba di tujuan';
      case TravelJourneyPhase.cancelled:
        return 'Perjalanan dibatalkan';
    }
  }

  static int phaseIndex(TravelJourneyPhase phase) {
    switch (phase) {
      case TravelJourneyPhase.waiting:
        return 0;
      case TravelJourneyPhase.onTheWay:
        return 1;
      case TravelJourneyPhase.arrived:
        return 2;
      case TravelJourneyPhase.cancelled:
        return -1;
    }
  }
}
