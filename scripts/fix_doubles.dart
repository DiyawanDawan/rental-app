import 'dart:io';

void main() {
  final dirs = [Directory('lib/features'), Directory('lib/core')];
  for (final dir in dirs) {
    if (dir.existsSync()) {
      for (var entity in dir.listSync(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          processFile(entity);
        }
      }
    }
  }
}

void processFile(File file) {
  var content = file.readAsStringSync();
  var originalContent = content;

  // Fix double extensions: .h.h -> .h, .w.w -> .w, .r.r -> .r, .sp.sp -> .sp
  content = content.replaceAll('.h.h', '.h');
  content = content.replaceAll('.w.w', '.w');
  content = content.replaceAll('.r.r', '.r');
  content = content.replaceAll('.sp.sp', '.sp');

  // Fix const TextStyle with .sp (const can't use extension methods)
  // Match patterns like: const TextStyle(fontSize: 12.sp)
  content = content.replaceAll(RegExp(r"const TextStyle\("), "TextStyle(");
  
  // Fix const Divider(height: X.h) -> Divider(height: X.h) 
  content = content.replaceAll(RegExp(r"const Divider\(height: (\d+(?:\.\d+)?)\.h\)"), "Divider(height: \$1.h)");

  if (content != originalContent) {
    file.writeAsStringSync(content);
    print('Fixed ${file.path}');
  }
}
