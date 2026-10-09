import '../../data/models/travel_model.dart';

/// Builds seat list + optional row layout when API `seatMap` is missing.
class TravelSeatUtils {
  const TravelSeatUtils._();

  static List<SeatModel> resolveSeats(TravelSeatAvailabilityModel availability) {
    if (availability.seats.isNotEmpty) return availability.seats;

    final fromMap = availability.seatMap?.allSeats ?? [];
    if (fromMap.isNotEmpty) return fromMap;

    return generateFallbackSeats(
      capacity: availability.seatingCapacity,
      occupied: availability.occupiedSeats.toSet(),
      defaultPrice: availability.pricePerSeat,
    );
  }

  static BusSeatMapModel resolveSeatMap(TravelSeatAvailabilityModel availability) {
    if (availability.seatMap != null && availability.seatMap!.rows.isNotEmpty) {
      return availability.seatMap!;
    }

    final seats = resolveSeats(availability);
    if (seats.isEmpty) return const BusSeatMapModel(rows: []);

    return _layoutFallbackGrid(seats);
  }

  static List<SeatModel> generateFallbackSeats({
    required int capacity,
    required Set<String> occupied,
    required double defaultPrice,
  }) {
    if (capacity <= 0) return [];

    const letters = ['A', 'B', 'C', 'D'];
    final seatsPerRow = 4;
    final rows = (capacity / seatsPerRow).ceil();
    final result = <SeatModel>[];

    var index = 0;
    for (var row = 1; row <= rows; row++) {
      for (var col = 0; col < seatsPerRow && index < capacity; col++) {
        final code = '$row${letters[col]}';
        result.add(SeatModel.fromCode(code, occupied: occupied, defaultPrice: defaultPrice));
        index++;
      }
    }
    return result;
  }

  static BusSeatMapModel _layoutFallbackGrid(List<SeatModel> seats) {
    const seatsPerRow = 4;
    final rows = <BusSeatMapRowModel>[];

    for (var i = 0; i < seats.length; i += seatsPerRow) {
      final end = (i + seatsPerRow) > seats.length ? seats.length : i + seatsPerRow;
      final chunk = seats.sublist(i, end);
      final rowNum = (i ~/ seatsPerRow) + 1;
      rows.add(BusSeatMapRowModel(label: rowNum.toString(), seats: chunk));
    }

    // Ensure labels match generated codes when possible
    if (rows.isEmpty && seats.isNotEmpty) {
      rows.add(BusSeatMapRowModel(label: '1', seats: seats));
    }

    return BusSeatMapModel(rows: rows);
  }

  static double totalPrice(List<SeatModel> selected, double fallbackPrice) {
    return selected.fold(0, (sum, s) => sum + s.effectivePrice(fallbackPrice));
  }
}
