abstract final class AppRoutes {
  static const home = '/';
  static const about = '/hakkimizda';
  static const contact = '/iletisim';
  static const download = '/indir';
  static const privacy = '/gizlilik';
  static const auth = '/giris';
  static const app = '/uygulama';

  static const appOzet = '/uygulama/ozet';
  static const appAnaliz = '/uygulama/analiz';
  static const appTakvim = '/uygulama/takvim';
  static const appProfil = '/uygulama/profil';

  static const authRegisterQuery = 'kayit';

  static const List<String> appTabPaths = [
    appOzet,
    appAnaliz,
    appTakvim,
    appProfil,
  ];

  static const List<String> appTabLabels = [
    'Özet',
    'Analiz',
    'Takvim',
    'Profil',
  ];

  static String tabPath(int index) {
    if (index < 0 || index >= appTabPaths.length) return appOzet;
    return appTabPaths[index];
  }

  static int? tabIndexFromLocation(String location) {
    final index = appTabPaths.indexOf(location);
    if (index >= 0) return index;
    if (location == app || location.startsWith('$app/')) {
      return 0;
    }
    return null;
  }

  static bool isAppLocation(String location) {
    return location == app || location.startsWith('$app/');
  }
}
