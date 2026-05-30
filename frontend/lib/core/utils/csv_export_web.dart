import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

bool get csvExportSupported => true;

void downloadCsvFile({
  required String filename,
  required String content,
}) {
  final bytes = utf8.encode('\uFEFF$content');
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
