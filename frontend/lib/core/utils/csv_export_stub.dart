/// Mobil / masaüstü: CSV indirme web'de kullanılır.
bool get csvExportSupported => false;

void downloadCsvFile({
  required String filename,
  required String content,
}) {
  throw UnsupportedError('CSV indirme yalnızca web sürümünde kullanılabilir.');
}
