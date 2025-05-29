// lib/core/app_constants.dart
class AppConstants {
  // API Base URL
  static const String baseUrl = 'https://your-api-domain.com/api';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String userEndpoint = '/user';
  static const String coursesEndpoint = '/courses';
  static const String examsEndpoint = '/exams';
  static const String homeworkEndpoint = '/homework';
  static const String paymentsEndpoint = '/payments';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // App Settings
  static const String appName = 'PDP Mobile';
  static const String appVersion = '1.0.0';

  // Error Messages (Uzbek)
  static const String networkError = 'Internetga ulanishda xatolik yuz berdi';
  static const String serverError = 'Serverda xatolik yuz berdi';
  static const String validationError = 'Ma\'lumotlarni tekshiring';
  static const String loginRequired = 'Tizimga kirish kerak';
  static const String phoneRequired = 'Telefon raqami kiritish shart';
  static const String passwordRequired = 'Parol kiritish shart';
  static const String invalidPhone = 'Telefon raqami noto\'g\'ri';
  static const String invalidPassword = 'Parol juda qisqa';
  static const String loginFailed = 'Telefon raqami yoki parol noto\'g\'ri';
  static const String registerFailed = 'Ro\'yxatdan o\'tishda xatolik';

  // Success Messages (Uzbek)
  static const String loginSuccess = 'Muvaffaqiyatli kirildi';
  static const String registerSuccess = 'Ro\'yxatdan o\'tish muvaffaqiyatli';
  static const String dataUpdated = 'Ma\'lumotlar yangilandi';
  static const String homeworkSubmitted = 'Vazifa topshirildi';
  static const String paymentSuccess = 'To\'lov muvaffaqiyatli';

  // UI Labels (Uzbek)
  static const String welcome = 'Xush kelibsiz!';
  static const String login = 'Kirish';
  static const String register = 'Ro\'yxatdan o\'tish';
  static const String logout = 'Chiqish';
  static const String profile = 'Profil';
  static const String settings = 'Sozlamalar';
  static const String phoneNumber = 'Telefon raqami';
  static const String password = 'Parol';
  static const String fullName = 'To\'liq ism';
  static const String courses = 'Kurslar';
  static const String exams = 'Imtihonlar';
  static const String homework = 'Uy vazifalari';
  static const String payments = 'To\'lovlar';
  static const String attendance = 'Davomat';
  static const String schedule = 'Dars jadvali';
  static const String notifications = 'Bildirishnomalar';
  static const String dashboard = 'Bosh sahifa';

  // Status Labels (Uzbek)
  static const String pending = 'Kutilmoqda';
  static const String completed = 'Tugallangan';
  static const String upcoming = 'Kelayotgan';
  static const String overdue = 'Muddati o\'tgan';
  static const String paid = 'To\'langan';
  static const String unpaid = 'To\'lanmagan';
  static const String present = 'Bor';
  static const String absent = 'Yo\'q';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;

  // Phone number formatting
  static const String phonePattern = r'^\d{9}$'; // 9 digits for Uzbek numbers
  static const String phoneMask = '##) ###-##-##';
}
