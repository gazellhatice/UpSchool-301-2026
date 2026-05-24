abstract final class AppConstants {
  static const appName = 'Kişisel Harcama Koçu';
  static const supportEmail = 'destek@ornek.com';
  static const privacyPolicyUrl = 'https://ornek.com/gizlilik';
  static const authOnboardingCompletedKey = 'auth_onboarding_completed';

  static const privacyPolicyBody = '''
Kişisel Harcama Koçu Gizlilik Özeti

Bu uygulama, gelir ve gider kayıtlarınızı yönetmeniz için tasarlanmıştır.

Toplanan veriler
• Hesap bilgileri (e-posta, ad — Firebase Authentication)
• Finans kayıtları (işlemler, kategoriler — cihazınızda ve isteğe bağlı olarak Firebase Firestore)

Verilerin kullanımı
• Uygulama işlevlerini sunmak ve cihazlar arası senkronizasyon sağlamak
• Hesabınızla ilişkilendirilmiş verilere yalnızca sizin erişmeniz

Saklama
• Yerel veritabanı cihazınızda kalır
• Bulut senkronu açıkken veriler Firebase altyapısında saklanır

Haklarınız
• Hesabınızdan çıkış yapabilir ve yerel veriyi silebilirsiniz
• Destek: $supportEmail

Bu metin yayın öncesi hukuki danışmanlıkla güncellenmelidir.
''';
}
