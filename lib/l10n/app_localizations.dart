import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get isAr => locale.languageCode == 'ar';

  // Welcome
  String get welcomeTitle =>
      isAr ? 'اختر نوع الحساب' : 'Choose your account type';
  String get student => isAr ? 'طالب' : 'Student';
  String get expert => isAr ? 'خبير' : 'Expert';
  String get company => isAr ? 'شركة' : 'Company';
  String get companyManager => isAr ? 'مسؤول' : 'Manager';
  String get companyDelegate => isAr ? 'مفوّض شركة' : 'Company delegate';
  String get companyTeamSectionTitle =>
      isAr ? 'حسابات فرعية (مفوّضون)' : 'Sub-accounts (delegates)';
  String get companyTeamSectionSubtitle => isAr
      ? 'يستطيع المفوّض استخدام التطبيق بنفس صلاحيات الشركة (الخبراء، الرسائل، الإعدادات) بالنيابة عن الحساب الرئيسي.'
      : 'A delegate can use the app with the same company powers (experts, messages, settings) on behalf of the main account.';
  String get companyTeamReadOnlyHint => isAr
      ? 'المفوّضون يُدارون من حساب الشركة أو مسؤول الشراكات.'
      : 'Delegates are managed from the main company or partnerships officer account.';
  String get companyTeamAdd => isAr ? 'إضافة مفوّض' : 'Add delegate';
  String get companyTeamEmpty => isAr ? 'لا يوجد مفوّضون بعد' : 'No delegates yet';
  String get companyTeamDialogTitle => isAr ? 'مفوّض جديد' : 'New delegate';
  String get companyTeamDeleteTitle => isAr ? 'حذف المفوّض؟' : 'Remove delegate?';
  String get companyTeamDeleteBody => isAr
      ? 'سيتم حذف الحساب ولن يستطيع الدخول بعد الآن.'
      : 'This account will be deleted and can no longer sign in.';
  String get companyTeamAdded => isAr ? 'تم إنشاء المفوّض' : 'Delegate created';
  String get companyTeamValidationError => isAr
      ? 'أدخل الاسم والبريد وكلمة مرور لا تقل عن ٦ أحرف'
      : 'Enter name, email, and a password of at least 6 characters';
  String get actionDelete => isAr ? 'حذف' : 'Delete';
  String get errorGeneric => isAr ? 'تعذّر إتمام الطلب' : 'Something went wrong';
  String get companyOfficerHubTitle => isAr ? 'مسؤول الشراكات' : 'Partnerships officer';
  String get companyOfficerHubSubtitle =>
      isAr ? 'متابعة الشركاء المعتمدين والتنسيق معهم' : 'Track and coordinate approved partners';
  String get companyOfficerBullet1 =>
      isAr ? 'عرض قائمة الشركاء المعتمدين للشركة' : 'View the company partner directory';
  String get companyOfficerBullet2 =>
      isAr ? 'مراجعة الإشعارات والتحديثات' : 'Review notifications and updates';
  String get companyOfficerBullet3 =>
      isAr ? 'التنسيق مع الفريق داخل نفس حساب الشركة' : 'Coordinate with your team under one company login';
  String get partnerRequestsSectionTitle =>
      isAr ? 'طلبات الظهور في دليل الشركات' : 'Partner directory requests';
  String get partnerRequestsSectionHint => isAr
      ? 'الخبراء الذين طلبوا الظهور كشركاء — وافق أو ارفض.'
      : 'Experts who asked to appear as partners — approve or reject.';
  String get partnerRequestsEmpty =>
      isAr ? 'لا توجد طلبات قيد المراجعة' : 'No pending requests';
  String get partnerRequestApprove => isAr ? 'موافقة' : 'Approve';
  String get partnerRequestReject => isAr ? 'رفض' : 'Reject';
  String get partnerRequestProcessed => isAr ? 'تم تحديث الطلب' : 'Request updated';
  String get expertPartnerDirCardTitle =>
      isAr ? 'دليل شركات المنصة' : 'Company partner directory';
  String get expertPartnerDirListed =>
      isAr ? 'أنت مُدرّج في دليل الشركات' : 'You are listed for companies';
  String get expertPartnerDirPending =>
      isAr ? 'طلبك قيد مراجعة مسؤول الشراكات' : 'Your request is under review';
  String get expertPartnerDirRejected =>
      isAr ? 'تم رفض طلبك — يمكنك إعادة الإرسال' : 'Request was declined — you can send again';
  String get expertPartnerDirRequestCta =>
      isAr ? 'طلب الظهور في دليل الشركات' : 'Request listing in company directory';
  String get expertPartnerDirIntro => isAr
      ? 'للظهور كشريك تدريبي لدى شركات المنصة.'
      : 'To appear as a training partner for companies on the platform.';
  String get expertPartnerDirRequestSent =>
      isAr ? 'تم إرسال الطلب' : 'Request submitted';
  String get login => isAr ? 'تسجيل الدخول' : 'LOGIN';
  String get signUp => isAr ? 'إنشاء حساب' : 'SIGN UP';

  // Login
  String get loginTitle => isAr ? 'تسجيل الدخول' : 'Login';
  String get signUpTitle => isAr ? 'التسجيل' : 'Sign Up';
  String get email => isAr ? 'البريد الإلكتروني' : 'Email';
  String get password => isAr ? 'كلمة المرور' : 'Password';
  String get confirmPassword => isAr ? 'تأكيد كلمة المرور' : 'Confirm Password';
  String get createAccount => isAr ? 'إنشاء الحساب' : 'Create Account';
  String get enter => isAr ? 'دخول' : 'Enter';
  String get backToHome => isAr ? 'العودة للرئيسية' : 'Back to Home';

  // Main Nav
  String get navHome => isAr ? 'الرئيسية' : 'Home';
  String get navExplore => isAr ? 'استكشف الخبراء' : 'Explore Experts';
  String get navSessions => isAr ? 'جلساتي' : 'My Sessions';
  String get navProfile => isAr ? 'الملف الشخصي' : 'Profile';
  String get navSettings => isAr ? 'الإعدادات' : 'Settings';

  /// شريط التنقل السفلي — كلمة واحدة فقط تحت الأيقونة (بدون سطر ثانٍ)
  String get navBarHome => isAr ? 'الرئيسية' : 'Home';
  String get navBarExplore => isAr ? 'الخبراء' : 'Explore';
  String get navBarSessions => isAr ? 'جلساتي' : 'Sessions';
  String get navBarProfile => isAr ? 'الملف' : 'Profile';
  String get navBarSettings => isAr ? 'إعدادات' : 'Settings';
  String get navBarAdminDash => isAr ? 'لوحة' : 'Dash';
  String get navBarAdminUsers => isAr ? 'مستخدمون' : 'Users';
  String get navBarAdminSessions => isAr ? 'جلسات' : 'Sessions';
  String get navBarExpertSessions => isAr ? 'جلسات' : 'Sessions';
  String get navBarCompanyExperts => isAr ? 'خبراء' : 'Experts';
  String get navBarCompanyOfficer => isAr ? 'مسؤول' : 'Officer';

  // Home
  String get homeTitle => isAr ? 'خبرتي' : 'Khibarti';
  String get welcome => isAr ? 'مرحباً بك' : 'Welcome';
  String get searchPlaceholder =>
      isAr ? 'ابحث عن خبير...' : 'Search for an expert...';
  String get suggestedExperts => isAr ? 'خبراء مقترحون' : 'Suggested Experts';
  String get upcomingSessions => isAr ? 'جلسات قادمة' : 'Upcoming Sessions';
  String get notifications => isAr ? 'الإشعارات' : 'Notifications';
  String get noSessions =>
      isAr ? 'لا توجد جلسات قادمة' : 'No upcoming sessions';
  String get noNotifications => isAr ? 'لا إشعارات' : 'No notifications';
  String get viewAll => isAr ? 'عرض الكل' : 'View all';
  String get join => isAr ? 'انضم' : 'Join';

  // Categories
  String get all => isAr ? 'الكل' : 'All';
  String get dev => isAr ? 'تطوير' : 'Development';
  String get marketing => isAr ? 'تسويق' : 'Marketing';
  String get design => isAr ? 'تصميم' : 'Design';
  String get management => isAr ? 'إدارة' : 'Management';

  // Explore
  String get exploreTitle => isAr ? 'استكشف الخبراء' : 'Explore Experts';
  String get searchExpertHint => isAr
      ? 'ابحث عن خبير بالاسم أو التخصص...'
      : 'Search by name or specialty...';
  String get filterCategory => isAr ? 'التصنيف' : 'Category';
  String get filterRating => isAr ? 'التقييم' : 'Rating';
  String get filterPrice => isAr ? 'السعر' : 'Price';
  String get book => isAr ? 'احجز' : 'Book';

  // Sessions
  String get sessionsTitle => isAr ? 'جلساتي' : 'My Sessions';
  String get tabUpcoming => isAr ? 'القادمة' : 'Upcoming';
  String get tabCompleted => isAr ? 'المنتهية' : 'Completed';
  String get noUpcoming =>
      isAr ? 'لا توجد جلسات قادمة' : 'No upcoming sessions';
  String get noCompleted =>
      isAr ? 'لا توجد جلسات منتهية' : 'No completed sessions';
  String get cancel => isAr ? 'إلغاء' : 'Cancel';

  // Profile
  String get profileTitle => isAr ? 'الملف الشخصي' : 'Profile';
  String get demoUser => isAr ? 'مستخدم تجريبي' : 'Demo User';
  String get name => isAr ? 'الاسم' : 'Name';
  String get phone => isAr ? 'رقم الهاتف' : 'Phone';
  String get country => isAr ? 'الدولة' : 'Country';
  String get saudiArabia => isAr ? 'المملكة العربية السعودية' : 'Saudi Arabia';
  String get editProfile => isAr ? 'تعديل الملف الشخصي' : 'Edit Profile';

  // Settings
  String get settingsTitle => isAr ? 'الإعدادات' : 'Settings';
  String get language => isAr ? 'اللغة' : 'Language';
  String get arabic => isAr ? 'العربية' : 'Arabic';
  String get english => 'English';
  String get notificationsSettings => isAr ? 'الإشعارات' : 'Notifications';
  String get notificationsOn => isAr ? 'مفعّلة' : 'On';
  String get help => isAr ? 'المساعدة' : 'Help';
  String get about => isAr ? 'حول التطبيق' : 'About';
  String get version => isAr ? 'الإصدار 1.0.0' : 'Version 1.0.0';
  String get accessibility =>
      isAr ? 'وضع ذوي الاحتياجات الخاصة' : 'Accessibility Mode';
  String get accessibilityDesc =>
      isAr ? 'تكبير الخط والعناصر' : 'Enlarge text and elements';

  // Join Session
  String sessionWith(String expert) =>
      isAr ? 'جلسة مع $expert' : 'Session with $expert';
  String get mockVideo => isAr ? 'محاكاة الفيديو' : 'Mock Video';
  String get chat => isAr ? 'الشات' : 'Chat';
  String get welcomeToSession =>
      isAr ? 'الجلسة التدريبية' : 'Training session';
  String get expertGreeting => isAr
      ? 'أهلاً، كيف يمكنني مساعدتك اليوم؟'
      : 'Hello, how can I help you today?';
  String get readyToStart => isAr ? 'أنا جاهز للبدء' : 'I am ready to start';
  String get typeMessage => isAr ? 'اكتب رسالة...' : 'Type a message...';
  String get mic => isAr ? 'ميكروفون' : 'Microphone';
  String get camera => isAr ? 'كاميرا' : 'Camera';
  String get shareScreen => isAr ? 'مشاركة' : 'Share';

  String get filterSpecialty => isAr ? 'التخصص' : 'Specialty';
  String get filterYears => isAr ? 'سنوات الخبرة' : 'Years of Experience';
  String get bookSession => isAr ? 'احجز جلسة' : 'Book Session';
  String get tabCancelled => isAr ? 'ملغاة' : 'Cancelled';
  String get rateSession => isAr ? 'قيّم الجلسة' : 'Rate Session';
  String get downloadCertificate =>
      isAr ? 'تحميل الشهادة' : 'Download Certificate';
  String get changePassword => isAr ? 'تغيير كلمة المرور' : 'Change Password';
  String get personalBio => isAr ? 'نبذة شخصية' : 'Personal Bio';
  String get profilePhoto => isAr ? 'الصورة الشخصية' : 'Profile Photo';
  String get tapToUploadPhoto =>
      isAr ? 'اضغط لرفع صورة' : 'Tap to upload photo';
  String get privacyPolicy => isAr ? 'سياسة الخصوصية' : 'Privacy Policy';
  String get termsConditions =>
      isAr ? 'الشروط والأحكام' : 'Terms and Conditions';
  String get privacyAndTerms =>
      isAr ? 'الخصوصية والشروط' : 'Privacy & Terms';
  String get agreeToTerms =>
      isAr
          ? 'أوافق على سياسة الخصوصية والشروط والأحكام'
          : 'I agree to the Privacy Policy and Terms';
  String get agreeToTermsError =>
      isAr ? 'يجب الموافقة للمتابعة' : 'You must accept to continue';
  String get agreeToDataRecording =>
      isAr
          ? 'أوافق على تسجيل بياناتي داخل النظام وفقاً للسياسة المعتمدة'
          : 'I consent to my data being stored in the system as per the policy';
  String get agreeToDataRecordingError =>
      isAr ? 'يجب الموافقة على تسجيل البيانات للمتابعة' : 'You must consent to data recording to continue';
  String get selectSessionDateTime =>
      isAr ? 'اختر تاريخ ووقت الجلسة' : 'Pick session date and time';
  String get companyExpertDisclaimer => isAr
      ? 'الخبير يقدّم خدماته بشكل مستقل. التواصل المباشر يكون خارج وساطة الشركة ومسؤولية الأطراف.'
      : 'Experts provide services independently. Direct contact is outside the company’s mediation.';
  String get logout => isAr ? 'تسجيل الخروج' : 'Logout';
  String get deleteAccount => isAr ? 'حذف الحساب' : 'Delete Account';
  String get endSession => isAr ? 'إنهاء الجلسة' : 'End Session';
  String get recordSession => isAr ? 'تسجيل الجلسة' : 'Record Session';
  String get sessionRecorded => isAr ? 'تم تسجيل الجلسة' : 'Session recorded';
  String get certificateGenerated =>
      isAr ? 'تم توليد الشهادة' : 'Certificate generated';

  // Expert
  String get expertDashboard => isAr ? 'لوحة الخبير' : 'Expert Dashboard';
  String get mySessionsAsExpert =>
      isAr ? 'جلساتي القادمة' : 'My Upcoming Sessions';
  String get myStats => isAr ? 'إحصائياتي' : 'My Stats';
  String get totalSessions => isAr ? 'إجمالي الجلسات' : 'Total Sessions';
  String get myRating => isAr ? 'تقييمي' : 'My Rating';
  String get navExpertSessions => isAr ? 'جلساتي' : 'My Sessions';
  String get noExpertSessions =>
      isAr ? 'لا توجد جلسات قادمة' : 'No upcoming sessions';
  String get withStudent => isAr ? 'مع طالب' : 'with student';
  String get myConversations => isAr ? 'محادثاتي' : 'My Conversations';
  String get noConversations =>
      isAr ? 'لا توجد محادثات بعد' : 'No conversations yet';
  String get tapToReply => isAr ? 'اضغط للرد' : 'Tap to reply';

  // Company
  String get companyDashboard => isAr ? 'لوحة الشركة' : 'Company Dashboard';
  String get platformOverview =>
      isAr ? 'نظرة عامة على المنصة' : 'Platform Overview';
  String get navPartners => isAr ? 'الخبراء' : 'Experts';
  String get browseExperts => isAr ? 'استعراض الخبراء' : 'Browse Experts';
  String get expertsCount => isAr ? 'عدد الخبراء' : 'Experts Count';
  String get sessionsCount => isAr ? 'عدد الجلسات' : 'Sessions Count';
  String get viewOnly => isAr ? 'للشراكات والتعاون' : 'For partnerships';
  String get contactExpert => isAr ? 'تواصل مع الخبير' : 'Contact Expert';
  String get contact => isAr ? 'تواصل' : 'Contact';
  String chatWith(String name) => isAr ? 'محادثة مع $name' : 'Chat with $name';
  String get typeMessageHere =>
      isAr ? 'اكتب رسالتك...' : 'Type your message...';
  String get send => isAr ? 'إرسال' : 'Send';

  // Admin
  String get adminLoginLink => isAr ? 'تسجيل دخول الإدارة' : 'Admin sign in';
  String get navAdminDashboard => isAr ? 'لوحة التحكم' : 'Dashboard';
  String get navAdminUsers => isAr ? 'المستخدمون' : 'Users';
  String get navAdminSessions => isAr ? 'كل الجلسات' : 'All sessions';
  String get adminPanelTitle => isAr ? 'لوحة الإدارة' : 'Admin panel';
  String get adminOverview =>
      isAr ? 'نظرة على المنصة والمستخدمين والجلسات' : 'Platform overview';
  String get adminUsersTitle => isAr ? 'المستخدمون' : 'Users';
  String get adminSessionsTitle => isAr ? 'جميع الجلسات' : 'All sessions';
  String get adminSendNotification =>
      isAr ? 'إرسال إشعار' : 'Send notification';
  String get adminNotificationTitle =>
      isAr ? 'عنوان الإشعار' : 'Notification title';
  String get adminNotificationBody =>
      isAr ? 'نص الإشعار (اختياري)' : 'Body (optional)';
  String get adminNotifyAll =>
      isAr ? 'إشعار عام لجميع المستخدمين' : 'Notify all users';
  String get adminServerError =>
      isAr ? 'تعذر تحميل البيانات — تأكد من السيرفر' : 'Could not load data';
  String get roleAdmin => isAr ? 'مدير' : 'Admin';
  String get adminUserDetail => isAr ? 'بيانات المستخدم' : 'User details';
  String get adminUserRestricted =>
      isAr ? 'حساب مقيّد' : 'Restricted';
  String get adminUserActive => isAr ? 'نشط' : 'Active';
  String get adminRestrictAccount =>
      isAr ? 'تقييد الحساب (منع الدخول)' : 'Restrict account (block login)';
  String get adminSaveChanges => isAr ? 'حفظ التعديلات' : 'Save changes';
  String get adminDeleteUserConfirm =>
      isAr ? 'حذف هذا الحساب نهائياً؟ لا يمكن التراجع.' : 'Delete this account permanently?';
  String get adminCannotDeleteSelf =>
      isAr ? 'لا يمكن حذف حسابك من هنا' : 'You cannot delete your own account here';
  String get adminUserDeleted => isAr ? 'تم حذف المستخدم' : 'User deleted';
  String get adminUserSaved => isAr ? 'تم حفظ التعديلات' : 'Saved';
  String get adminRoleChangeHint =>
      isAr ? 'تغيير الدور (طالب / خبير / شركة)' : 'Change role (student / expert / company)';
  String get createdAt => isAr ? 'تاريخ التسجيل' : 'Registered';
  String get adminAddUser => isAr ? 'إضافة مستخدم' : 'Add user';
  String get adminAddUserHint =>
      isAr ? 'أي نص كمعرّف دخول (ليس شرطاً بريداً إلكترونياً)' : 'Any login identifier (not required to be an email)';
  String get adminCreateUserSubmit => isAr ? 'إنشاء الحساب' : 'Create account';
  String get expertVerifiedBadge =>
      isAr ? 'خبير موثّق' : 'Verified expert';
  String get expertVerifiedToggle =>
      isAr ? 'تصريح / توثيق الخبير' : 'Expert verification badge';
  String get expertVerifiedDesc => isAr
      ? 'يظهر للجميع بجانب اسم الخبير كعلامة توثيق'
      : 'Shows a verification badge next to the expert’s name';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
