import 'dart:io';

void main() {
  final dir = Directory('lib/features');
  if (dir.existsSync()) {
    for (var entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart') && entity.path.contains('presentation')) {
        processFile(entity);
      }
    }
  }
  
  final coreWidgetsDir = Directory('lib/core/widgets');
  if (coreWidgetsDir.existsSync()) {
    for (var entity in coreWidgetsDir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        processFile(entity);
      }
    }
  }
}

void processFile(File file) {
  var content = file.readAsStringSync();
  var originalContent = content;

  if (!content.contains("import 'package:flutter_screenutil/flutter_screenutil.dart';")) {
    final importMatch = RegExp(r'^import .*;$', multiLine: true).allMatches(content);
    if (importMatch.isNotEmpty) {
      final insertPos = importMatch.last.end;
      content = content.substring(0, insertPos) + '\nimport \'package:flutter_screenutil/flutter_screenutil.dart\';' + content.substring(insertPos);
    } else {
      content = 'import \'package:flutter_screenutil/flutter_screenutil.dart\';\n' + content;
    }
  }

  content = content.replaceAllMapped(RegExp(r'SizedBox\(\s*height:\s*(\d+(?:\.\d+)?)\s*\)'), (m) => 'SizedBox(height: ${m[1]}.h)');
  content = content.replaceAllMapped(RegExp(r'SizedBox\(\s*width:\s*(\d+(?:\.\d+)?)\s*\)'), (m) => 'SizedBox(width: ${m[1]}.w)');
  content = content.replaceAllMapped(RegExp(r'EdgeInsets\.all\(\s*(\d+(?:\.\d+)?)\s*\)'), (m) => 'EdgeInsets.all(${m[1]}.w)');
  content = content.replaceAllMapped(RegExp(r'EdgeInsets\.symmetric\(\s*horizontal:\s*(\d+(?:\.\d+)?)\s*,\s*vertical:\s*(\d+(?:\.\d+)?)\s*\)'), (m) => 'EdgeInsets.symmetric(horizontal: ${m[1]}.w, vertical: ${m[2]}.h)');
  content = content.replaceAllMapped(RegExp(r'EdgeInsets\.symmetric\(\s*vertical:\s*(\d+(?:\.\d+)?)\s*,\s*horizontal:\s*(\d+(?:\.\d+)?)\s*\)'), (m) => 'EdgeInsets.symmetric(vertical: ${m[1]}.h, horizontal: ${m[2]}.w)');
  content = content.replaceAllMapped(RegExp(r'EdgeInsets\.symmetric\(\s*horizontal:\s*(\d+(?:\.\d+)?)\s*\)'), (m) => 'EdgeInsets.symmetric(horizontal: ${m[1]}.w)');
  content = content.replaceAllMapped(RegExp(r'EdgeInsets\.symmetric\(\s*vertical:\s*(\d+(?:\.\d+)?)\s*\)'), (m) => 'EdgeInsets.symmetric(vertical: ${m[1]}.h)');
  
  content = content.replaceAllMapped(RegExp(r'EdgeInsets\.only\(([^)]+)\)'), (m) {
    var inner = m[1]!;
    inner = inner.replaceAllMapped(RegExp(r'left:\s*(\d+(?:\.\d+)?)'), (im) => 'left: ${im[1]}.w');
    inner = inner.replaceAllMapped(RegExp(r'right:\s*(\d+(?:\.\d+)?)'), (im) => 'right: ${im[1]}.w');
    inner = inner.replaceAllMapped(RegExp(r'top:\s*(\d+(?:\.\d+)?)'), (im) => 'top: ${im[1]}.h');
    inner = inner.replaceAllMapped(RegExp(r'bottom:\s*(\d+(?:\.\d+)?)'), (im) => 'bottom: ${im[1]}.h');
    return 'EdgeInsets.only($inner)';
  });
  
  content = content.replaceAllMapped(RegExp(r'EdgeInsets\.fromLTRB\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*\)'), (m) => 'EdgeInsets.fromLTRB(${m[1]}.w, ${m[2]}.h, ${m[3]}.w, ${m[4]}.h)');
  content = content.replaceAllMapped(RegExp(r'BorderRadius\.circular\(\s*(\d+(?:\.\d+)?)\s*\)'), (m) => 'BorderRadius.circular(${m[1]}.r)');
  
  content = content.replaceAllMapped(RegExp(r'(size|iconSize):\s*(\d+(?:\.\d+)?)\b'), (m) => '${m[1]}: ${m[2]}.sp');
  content = content.replaceAllMapped(RegExp(r'fontSize:\s*(\d+(?:\.\d+)?)\b'), (m) => 'fontSize: ${m[1]}.sp');
  content = content.replaceAllMapped(RegExp(r'(?<!BorderSide\()(?<!\.)\bwidth:\s*(\d+(?:\.\d+)?)\b'), (m) => 'width: ${m[1]}.w');
  content = content.replaceAllMapped(RegExp(r'(?<!\.)\bheight:\s*(\d+(?:\.\d+)?)\b'), (m) => 'height: ${m[1]}.h');
  content = content.replaceAllMapped(RegExp(r'\bradius:\s*(\d+(?:\.\d+)?)\b'), (m) => 'radius: ${m[1]}.r');
  
  content = content.replaceAllMapped(RegExp(r'const\s+(SizedBox|EdgeInsets|Icon|BorderRadius|Padding|CircleAvatar)'), (m) => m[1]!);
  
  content = content.replaceAll('SizedBox()', 'const SizedBox()');
  content = content.replaceAll('SizedBox.shrink()', 'const SizedBox.shrink()');
  content = content.replaceAll('EdgeInsets.zero', 'const EdgeInsets.zero');
  
  if (content != originalContent) {
    file.writeAsStringSync(content);
    print('Updated ${file.path}');
  }
}
