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
}

void processFile(File file) {
  var content = file.readAsStringSync();
  var originalContent = content;

  content = content.replaceAll('const TextStyle', 'TextStyle');
  content = content.replaceAll('const Text(', 'Text(');
  content = content.replaceAll('const Padding(', 'Padding(');
  content = content.replaceAll('const Icon(', 'Icon(');
  content = content.replaceAll('const SizedBox(', 'SizedBox(');
  content = content.replaceAll('const EdgeInsets', 'EdgeInsets');
  content = content.replaceAll('const BorderRadius', 'BorderRadius');
  content = content.replaceAll('const Column(', 'Column(');
  content = content.replaceAll('const Row(', 'Row(');
  content = content.replaceAll('const Center(', 'Center(');
  content = content.replaceAll('const Align(', 'Align(');
  content = content.replaceAll('const Expanded(', 'Expanded(');
  content = content.replaceAll('const Spacer(', 'Spacer(');
  content = content.replaceAll('const SliverToBoxAdapter(', 'SliverToBoxAdapter(');
  content = content.replaceAll('const SliverPadding(', 'SliverPadding(');
  content = content.replaceAll('const InputDecoration(', 'InputDecoration(');
  content = content.replaceAll('const BoxConstraints(', 'BoxConstraints(');
  content = content.replaceAll('const OutlineInputBorder(', 'OutlineInputBorder(');
  content = content.replaceAll('const RoundedRectangleBorder(', 'RoundedRectangleBorder(');
  content = content.replaceAll('const CircleBorder(', 'CircleBorder(');
  content = content.replaceAll('const EdgeInsets.zero', 'EdgeInsets.zero');
  content = content.replaceAll('const SizedBox.shrink()', 'SizedBox.shrink()');
  
  if (content != originalContent) {
    file.writeAsStringSync(content);
    print('Updated ${file.path}');
  }
}