// ignore_for_file: avoid_print
import 'dart:io';

typedef FixRule = String Function(String content);

final fixRules = <FixRule>[
  (c) => c.replaceAllMapped(
        RegExp(r'OVERDUE .+? seharusnya kembali'),
        (_) => 'OVERDUE \u2014 seharusnya kembali',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r'handover .+? lokasi dari HP penyewa'),
        (_) => 'handover \u2014 lokasi dari HP penyewa',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r'\$\{widget\.origin\} .+? \$\{widget\.destination\}'),
        (_) => r'${widget.origin} \u2192 ${widget.destination}',
      ),
  (c) => c.replaceAllMapped(
        RegExp(
          r'\$\{schedule\.route!\.origin\} .+? \$\{schedule\.route!\.destination\}',
        ),
        (_) => r'${schedule.route!.origin} \u2192 ${schedule.route!.destination}',
      ),
  (c) => c.replaceAllMapped(
        RegExp(
          r'\$\{booking\.schedule!\.route!\.origin\} .+? \$\{booking\.schedule!\.route!\.destination\}',
        ),
        (_) =>
            r'${booking.schedule!.route!.origin} \u2192 ${booking.schedule!.route!.destination}',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r'\$\{r\.origin\} .+? \$\{r\.destination\}'),
        (_) => r'${r.origin} \u2192 ${r.destination}',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"\$\{v\.brand \?\? '-'\} .+? \$\{MoneyFormatter"),
        (_) => r"${v.brand ?? '-'} \u00b7 ${MoneyFormatter",
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"\$\{t\.location \?\? '-'\} .+? \$\{MoneyFormatter"),
        (_) => r"${t.location ?? '-'} \u00b7 ${MoneyFormatter",
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"\$\{vehicle\.brand \?\? '-'\} .+? \$\{MoneyFormatter"),
        (_) => r"${vehicle.brand ?? '-'} \u00b7 ${MoneyFormatter",
      ),
  (c) => c.replaceAllMapped(
        RegExp(r'Rating .+? 4 bintang'),
        (_) => 'Rating \u2265 4 bintang',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"label: 'Rating .+? 4'"),
        (_) => "label: 'Rating \u2265 4'",
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"label: '.+? \$\{_radiusKm\.toInt\(\)\} km'"),
        (_) => r"label: '\u2264 ${_radiusKm.toInt()} km'",
      ),
  (c) => c.replaceAllMapped(
        RegExp(
          r'\$\{MoneyFormatter\.rupiah\(_priceRange\.start\)\} .+? \$\{MoneyFormatter\.rupiah\(_priceRange\.end\)\}',
        ),
        (_) =>
            r'${MoneyFormatter.rupiah(_priceRange.start)} \u2013 ${MoneyFormatter.rupiah(_priceRange.end)}',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"_SortChip\(label: 'A.+?Z'"),
        (_) => "_SortChip(label: 'A\u2013Z'",
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"_SortChip\(label: 'Harga .+?', value: 'price_asc'"),
        (_) => "_SortChip(label: 'Harga \u2191', value: 'price_asc'",
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"_SortChip\(label: 'Harga .+?', value: 'price_desc'"),
        (_) => "_SortChip(label: 'Harga \u2193', value: 'price_desc'",
      ),
  (c) => c.replaceAllMapped(
        RegExp(
          r"label: Text\(_maxPrice == null \? 'Harga max' : '.+? \$\{MoneyFormatter\.rupiah\(_maxPrice!\)\}\)",
        ),
        (_) =>
            r"label: Text(_maxPrice == null ? 'Harga max' : '\u2264 ${MoneyFormatter.rupiah(_maxPrice!)})",
      ),
  (c) => c.replaceAllMapped(
        RegExp(
          r"label: Text\(_maxDurationDays == null \? 'Durasi max' : '.+? \$_maxDurationDays hari'\)",
        ),
        (_) =>
            r"label: Text(_maxDurationDays == null ? 'Durasi max' : '\u2264 $_maxDurationDays hari')",
      ),
  (c) => c.replaceAllMapped(
        RegExp(r'populer .+? destinasi, durasi'),
        (_) => 'populer \u2014 destinasi, durasi',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r'Foto Kendaraan \(1.+?8\)'),
        (_) => 'Foto Kendaraan (1\u20138)',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r'pelanggan .+? foto, video'),
        (_) => 'pelanggan \u2014 foto, video',
      ),
  (c) => c.replaceAllMapped(
        RegExp(
          r'\$\{vehicle\.brand\} .+? \$\{MoneyFormatter\.rupiah\(vehicle\.pricePerDay\)\}',
        ),
        (_) =>
            r'${vehicle.brand} \u00b7 ${MoneyFormatter.rupiah(vehicle.pricePerDay)}',
      ),
  (c) => c.replaceAllMapped(
        RegExp(
          r'\$\{schedule\.departureTime\} .+? \$\{schedule\.arrivalTime\}',
        ),
        (_) => r'${schedule.departureTime} \u2013 ${schedule.arrivalTime}',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r'Mitra PRO aktif .+? termasuk GPS IoT'),
        (_) => 'Mitra PRO aktif \u2014 termasuk GPS IoT',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r'\$start  .+?  \$end'),
        (_) => r'$start  \u2192  $end',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"pengikut .+? \$\{profile\['vehicleCount'\]"),
        (_) => r"pengikut \u00b7 ${profile['vehicleCount']",
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"Geofence .+? \$\{vehicle\?\.name"),
        (_) => r"Geofence \u2014 ${vehicle?.name",
      ),
  (c) => c.replaceAllMapped(
        RegExp(r'card list .+? promo, geo, trust'),
        (_) => 'card list \u2014 promo, geo, trust',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"preview\['rows'\]\.length\} baris .+? per baris"),
        (_) => r"${preview['rows'].length} baris \u00b7 $_leftSeats+$_rightSeats per baris",
      ),
  (c) => c.replaceAllMapped(
        RegExp(r'\$\{channel\.method\} .+? \$\{channel\.code\}'),
        (_) => r'${channel.method} \u00b7 ${channel.code}',
      ),
  (c) => c.replaceAllMapped(
        RegExp(
          r"\$\{MoneyFormatter\.rupiah\(\(pkg\['basePrice'\] as num\?\)\?\.toDouble\(\) \?\? 0\)\} .+? \$status",
        ),
        (_) =>
            r"${MoneyFormatter.rupiah((pkg['basePrice'] as num?)?.toDouble() ?? 0)} \u00b7 $status",
      ),
  (c) => c.replaceAllMapped(
        RegExp(r": '.+?',", multiLine: true),
        (m) {
          final value = m.group(0)!;
          if (!value.contains('Ã') && !value.contains('â')) return value;
          if (value.contains('subtitle: Text(')) return value;
          return ": '\u2014',";
        },
      ),
  (c) => c.replaceAll(
        RegExp(r"subtitle: Text\('\$\{schedule\['departureTime'\] \?\? '-'\} .+? \$\{schedule\['status'\]"),
        "subtitle: Text('\${schedule['departureTime'] ?? '-'} \u00b7 \${schedule['status']",
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"/// .+ orange, full-width"),
        (_) => '/// Primary CTA \u2014 orange, full-width default, loading state bawaan.',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"/// Secondary .+ outline orange"),
        (_) => '/// Secondary \u2014 outline orange.',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"/// Icon button konsisten .+ back overlay"),
        (_) => '/// Icon button konsisten \u2014 favorite, share, back overlay.',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"/// Kolom pencarian modern .+ radius 12"),
        (_) => '/// Kolom pencarian modern \u2014 filled, tanpa border kaku, radius 12.',
      ),
  (c) => c.replaceAllMapped(
        RegExp(r"distanceKm != null \? ' .+? km'"),
        (_) => r"distanceKm != null ? ' \u00b7 ${vehicle.distanceKm!.toStringAsFixed(1)} km'",
      ),
];

String fixContent(String content) {
  var updated = content;
  for (final rule in fixRules) {
    updated = rule(updated);
  }
  return updated;
}

void main() {
  final libDir = Directory('lib');
  final changed = <File>[];
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final original = entity.readAsStringSync();
    final updated = fixContent(original);
    if (updated != original) {
      entity.writeAsStringSync(updated);
      changed.add(entity);
    }
  }

  print('Fixed ${changed.length} file(s):');
  for (final file in changed) {
    print('  - ${file.path.replaceAll(r'\', '/')}');
  }
}
