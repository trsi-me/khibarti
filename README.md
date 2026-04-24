# خبرتي | Khibarti

دليل شامل ومتكامل لتطبيق خبرتي — مشروع جامعي يربط الطلاب بالخبراء عبر جلسات تدريب افتراضية.

---

## الفهرس

1. [نظرة عامة](#1-نظرة-عامة)
2. [المصطلحات التقنية](#2-المصطلحات-التقنية)
3. [الميزات التفصيلية](#3-الميزات-التفصيلية)
4. [مسار المستخدم](#4-مسار-المستخدم)
5. [هيكل المشروع الكامل](#5-هيكل-المشروع-الكامل)
6. [قاعدة البيانات (Schema)](#6-قاعدة-البيانات-schema)
7. [API المرجع الكامل](#7-api-المرجع-الكامل)
8. [مكتبات التطبيق (pubspec)](#8-مكتبات-التطبيق-pubspec)
9. [مكتبات السيرفر (package.json)](#9-مكتبات-السيرفر-packagejson)
10. [المتطلبات والتثبيت](#10-المتطلبات-والتثبيت)
11. [التشغيل خطوة بخطوة](#11-التشغيل-خطوة-بخطوة)
12. [الأكواد المهمة والشرح](#12-الأكواد-المهمة-والشرح)
13. [إعدادات التشغيل حسب الجهاز](#13-إعدادات-التشغيل-حسب-الجهاز)
14. [بناء التطبيق للنشر](#14-بناء-التطبيق-للنشر)
15. [حل المشاكل الشائعة](#15-حل-المشاكل-الشائعة)
16. [روابط رسمية](#16-روابط-رسمية)
17. [شرح المشروع بشكل كامل](#17-شرح-المشروع-بشكل-كامل)
18. [لوحة الإدارة (Admin)](#18-لوحة-الإدارة-admin)

---

## 1. نظرة عامة

### فكرة التطبيق

**خبرتي** تطبيق جامعي يربط بين ثلاثة أنواع من المستخدمين:

| النوع | الوصف |
|-------|-------|
| **طالب** | يبحث عن خبراء، يحجز جلسات، receives شهادات خبرة |
| **خبير** | يقدم جلسات تدريب وإرشاد في تخصصه |
| **شركة** | تدعم المنصة وتتواصل مع الخبراء والطلاب |
| **مدير (Admin)** | يطلع على إحصائيات المنصة، قائمة المستخدمين، كل الجلسات، ويرسل إشعارات عامة أو لمستخدم محدد — نفس تصميم التطبيق |

### الهدف الرئيسي

تحويل الخبرة العملية من عائق وظيفي إلى فرصة تدريب قبل دخول سوق العمل، من خلال جلسات موثقة داخل التطبيق.

### نظرة معماريّة سريعة

```
[تطبيق Flutter]  ←──HTTP──→  [سيرفر Node.js]
       │                            │
       │                            └──→ SQLite (قاعدة البيانات)
       └──→ توليد PDF للشهادات محلياً
```

---

## 2. المصطلحات التقنية

| المصطلح | الشرح |
|---------|-------|
| **Flutter** | إطار عمل من جوجل لبناء تطبيقات لأجهزة متعددة (أندرويد، iOS، ويب، Windows) من كود واحد. |
| **Dart** | لغة البرمجة التي يُكتب فيها تطبيق Flutter. |
| **Widget** | اللبنة الأساسية لواجهة Flutter — كل عنصر على الشاشة (زر، نص، صورة) هو Widget. |
| **Backend (الباك اند)** | السيرفر الذي يعالج طلبات التطبيق، يخزن البيانات، وينفذ منطق الأعمال. |
| **API** | واجهة برمجة التطبيقات — طريقة تسمح للتطبيق بالتواصل مع السيرفر (إرسال واستقبال بيانات). |
| **REST API** | أسلوب لتصميم الـ API: طلبات HTTP (GET للحصول، POST للإضافة، PATCH للتعديل، DELETE للحذف). |
| **HTTP** | بروتوكول نقل البيانات على الويب. التطبيق يرسل طلب (مثلاً POST لتفاصيل تسجيل الدخول) ويستقبل رد. |
| **JSON** | صيغة لتبادل البيانات بصورة نصية، مثل `{"name": "أحمد", "email": "a@b.com"}`. |
| **SQLite** | قاعدة بيانات خفيفة — كل البيانات في ملف واحد، لا يحتاج سيرفر قاعدة بيانات منفصل. |
| **محاكي (Emulator)** | برنامج يحاكي جهاز أندرويد على الكمبيوتر لتجربة التطبيق دون جهاز حقيقي. |
| **Package / مكتبة** | كود جاهز يُضاف للمشروع لتوفير وظيفة معينة (مثل HTTP أو PDF). |
| **Pub** | أداة إدارة مكتبات Dart و Flutter (مثل `pub get`). |
| **npm** | أداة إدارة مكتبات JavaScript لـ Node.js (مثل `npm install`). |
| **CORS** | آلية تسمح للتطبيق (من نطاق مختلف) بالاتصال بالسيرفر. |
| **State (الحالة)** | البيانات التي تتغير أثناء تشغيل التطبيق (مثل المستخدم الحالي، قائمة الجلسات). |
| **Async / Await** | أسلوب لتنفيذ عمليات تحتاج وقت (مثل طلب شبكة) دون تجميد الواجهة. |

---

## 3. الميزات التفصيلية

### شاشة البداية (Splash)
- عرض شعار التطبيق
- أنيميشن بسيط (Fade + Scale)
- الانتقال التلقائي لشاشة الترحيب

### شاشة الترحيب (Welcome)
- رسالة ترحيب
- اختيار نوع المستخدم: طالب / خبير / شركة
- أزرار: تسجيل الدخول / إنشاء حساب
- تبديل اللغة (عربي / إنجليزي)  
- **لوحة الإدارة** لا تظهر من هذا التطبيق — تُشغَّل منفصلة عبر `lib/main_admin.dart` (انظر §18)

### شاشة تسجيل الدخول (Login)
- حقول: البريد الإلكتروني، كلمة المرور
- عند التسجيل: الاسم، تأكيد كلمة المرور
- التحقق من السيرفر
- الانتقال للواجهة الرئيسية عند النجاح

### الواجهة الرئيسية (Bottom Navigation)
- **للطالب (5 تبويبات):** الرئيسية، استكشف الخبراء، جلساتي، الملف الشخصي، الإعدادات
- **للخبير / الشركة:** لوحة خاصة بالدور + جلسات أو شركاء + ملف + إعدادات
- **للمدير (Admin — 5 تبويبات):** لوحة التحكم (إحصائيات + إرسال إشعارات)، المستخدمون، كل الجلسات، الملف الشخصي، الإعدادات — **بدون** حذف الحساب من واجهة الإعدادات

**الرئيسية (طالب):** ترحيب، بحث، تصنيفات، خبراء مقترحون، جلسات قادمة، إشعارات  
**استكشف الخبراء:** بحث وفلترة، بطاقات خبراء، صفحة تفاصيل، حجز جلسة  
**جلساتي:** تبويبات (القادمة / المنتهية / الملغاة)، انضم، إلغاء، تقييم، تحميل شهادة  
**الملف الشخصي:** بيانات، تعديل، تغيير كلمة المرور، نبذة شخصية  
**الإعدادات:** اللغة، الإشعارات، سياسة الخصوصية، الشروط، تسجيل الخروج، حذف الحساب (غير متاح لحساب المدير)، وضع ذوي الاحتياجات

### شاشة الجلسة الافتراضية (Join Session)
- محاكاة منطقة فيديو
- شات جانبي
- أزرار: ميكروفون، كاميرا، مشاركة الشاشة، تسجيل الجلسة
- تسجيل حضور على السيرفر
- إنهاء الجلسة وتحديث الحالة وإنشاء الشهادة

### نظام الشهادات
- توليد PDF بعد إكمال الجلسة
- تخزين الملف محلياً
- إمكانية التحميل من تبويب «المنتهية»

---

## 4. مسار المستخدم

```
بدء التطبيق
    ↓
شاشة البداية (Splash)
    ↓
شاشة الترحيب (Welcome)
    ↓
اختيار النوع + تسجيل دخول أو إنشاء حساب
    ↓
الواجهة الرئيسية (5 تبويبات)
    ↓
من «استكشف الخبراء» → تفاصيل خبير → حجز جلسة
من «جلساتي» → انضم للجلسة → شاشة الجلسة → إنهاء → شهادة
من «الملف الشخصي» → تعديل / تغيير كلمة المرور
من «الإعدادات» → اللغة / الخروج / حذف الحساب
```

---

## 5. هيكل المشروع الكامل

```
khibarti/
├── lib/                           ← كود التطبيق (Flutter/Dart)
│   ├── main.dart                  ← نقطة البدء (runApp)
│   ├── app.dart                   ← إعداد التطبيق (MaterialApp، الثيم، اللغة)
│   ├── app_state.dart             ← حالة عامة (المستخدم الحالي، اللغة، وضع الإعاقة)
│   ├── main_app.dart              ← الشاشة الرئيسية ذات الـ 5 تبويبات
│   │
│   ├── config/
│   │   └── api_config.dart        ← عنوان السيرفر (baseUrl)
│   │
│   ├── l10n/
│   │   └── app_localizations.dart ← ترجمة النصوص (عربي/إنجليزي)
│   │
│   ├── services/
│   │   ├── api_service.dart       ← كل طلبات HTTP للسيرفر
│   │   └── certificate_service.dart ← توليد ملف PDF للشهادة
│   │
│   ├── screens/                   ← الشاشات
│   │   ├── admin/                 ← لوحة الإدارة (لوحة التحكم، المستخدمون، الجلسات)
│   │   ├── splash_screen.dart
│   │   ├── welcome_screen.dart
│   │   ├── login_screen.dart
│   │   ├── home_screen.dart
│   │   ├── explore_screen.dart
│   │   ├── expert_detail_screen.dart
│   │   ├── sessions_screen.dart
│   │   ├── join_session_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   └── settings_screen.dart
│   │
│   ├── theme/
│   │   └── app_theme.dart         ← الألوان، الخطوط، شكل الأزرار
│   │
│   ├── widgets/
│   │   └── khibarti_logo.dart     ← مكوّن الشعار
│   │
│   └── database/
│       └── database_helper.dart  ← (غير مستخدم حالياً — التطبيق يعتمد على API)
│
├── backend/                       ← السيرفر (Node.js)
│   ├── server.js                 ← الملف الرئيسي — كل مسارات الـ API
│   ├── package.json              ← قائمة مكتبات السيرفر
│   └── khibarti.db               ← ملف SQLite (يُنشأ عند أول تشغيل)
│
├── assets/
│   └── images/
│       └── Logo.jpg              ← شعار التطبيق (إن وُجد)
│
├── pubspec.yaml                  ← قائمة مكتبات Flutter
├── android/                      ← إعدادات أندرويد
├── ios/                          ← إعدادات iOS
└── README.md                     ← هذا الملف
```

---

## 6. قاعدة البيانات (Schema)

الجداول في السيرفر (ملف `khibarti.db`):

| الجدول | الوصف | أعمدة رئيسية |
|--------|-------|-------------|
| **roles** | أدوار المستخدمين | id, name (student, expert, company) |
| **users** | المستخدمون | id, email, password, role_id, name |
| **experts** | بيانات الخبراء | id, user_id, specialty, years_experience, rating, sessions_count, bio |
| **students** | بيانات الطلاب | id, user_id, university, major, graduation_year |
| **companies** | بيانات الشركات | id, user_id, company_name, industry |
| **sessions** | الجلسات | id, expert_id, student_id, scheduled_date, scheduled_time, status |
| **session_attendance** | حضور الجلسات | id, session_id, user_id, joined_at |
| **ratings** | تقييمات الجلسات | id, session_id, rater_id, rated_id, score |
| **certificates** | الشهادات | id, session_id, user_id, expert_name, specialty, session_date |
| **notifications** | الإشعارات | id, user_id, title, body |

**حالات الجلسة (status):** `upcoming` | `completed` | `cancelled`

---

## 7. API المرجع الكامل

الـ Base URL الافتراضي: `http://10.0.2.2:3000`

### المصادقة (Auth)

| Method | المسار | الوصف | Body / Query |
|--------|--------|-------|--------------|
| GET | `/api/auth/check-email?email=...` | التحقق من وجود البريد | Query: email |
| POST | `/api/auth/login` | تسجيل الدخول | `{ email, password }` |
| POST | `/api/auth/register` | إنشاء حساب | `{ email, password, roleId, name }` — **لا يُقبل التسجيل بدور مدير** (يُرفض من السيرفر إن كان `role_id` لدور `admin`) |

### لوحة الإدارة (Admin) — تتطلب `adminUserId` لمستخدم فعلي بدور `admin`

| Method | المسار | الوصف | Query / Body |
|--------|--------|-------|----------------|
| GET | `/api/admin/stats` | إحصائيات (مستخدمون، جلسات، رسائل، إشعارات، تفصيل حسب الدور والحالة) | Query: `adminUserId` |
| GET | `/api/admin/users` | قائمة كل المستخدمين مع الدور | Query: `adminUserId` |
| GET | `/api/admin/sessions` | كل الجلسات (خبير، طالب، تاريخ، حالة) | Query: `adminUserId` |
| POST | `/api/admin/notifications` | إشعار عام أو لمستخدم | Body: `{ adminUserId, title, body?, userId? }` — إذا لم يُمرَّر `userId` يُعتبر إشعاراً عاماً (`user_id` فارغ في قاعدة البيانات) |

### الخبراء (Experts)

| Method | المسار | الوصف | Body / Query |
|--------|--------|-------|--------------|
| GET | `/api/experts` | قائمة الخبراء | Query: search, specialty, minYears, minRating |
| GET | `/api/experts/specialties` | قائمة التخصصات | — |
| GET | `/api/experts/:id` | تفاصيل خبير | — |
| GET | `/api/experts/:id/user` | user_id للخبير | — |

### الجلسات (Sessions)

| Method | المسار | الوصف | Body |
|--------|--------|-------|------|
| POST | `/api/sessions/book` | حجز جلسة | `{ expertId, studentId, date, time }` |
| GET | `/api/sessions/user/:userId` | جلسات المستخدم | Query: status |
| PATCH | `/api/sessions/:id/status` | تغيير حالة الجلسة | `{ status }` |
| POST | `/api/sessions/:id/rate` | تقييم الجلسة | `{ raterId, ratedId, score }` |
| POST | `/api/sessions/:id/attendance` | تسجيل حضور | `{ userId }` |

### الشهادات والإشعارات والمستخدمون

| Method | المسار | الوصف | Body |
|--------|--------|-------|------|
| POST | `/api/certificates` | إنشاء شهادة | `{ sessionId, userId, expertName, specialty, sessionDate }` |
| GET | `/api/notifications/:userId` | إشعارات المستخدم | — |
| GET | `/api/users/:id` | بيانات مستخدم | — |
| PATCH | `/api/users/:id` | تعديل مستخدم | `{ name?, password? }` |
| DELETE | `/api/users/:id` | حذف مستخدم | — |
| GET | `/api/students/by-user/:userId` | student_id من user_id | — |

---

## 8. مكتبات التطبيق (pubspec)

الملف: `pubspec.yaml`

| المكتبة | الوظيفة |
|---------|----------|
| **flutter** | إطار التطبيق |
| **flutter_localizations** | دعم اللغات (عربي، إنجليزي) |
| **cupertino_icons** | أيقونات واجهة iOS |
| **google_fonts** | خطوط مثل IBM Plex Arabic |
| **http** | إرسال طلبات HTTP للسيرفر |
| **path** | التعامل مع المسارات |
| **path_provider** | مسارات مجلدات التطبيق (للشهادات) |
| **pdf** | توليد ملفات PDF |
| **sqflite** | (موجود في المشروع لكن غير مستخدم — البديل API) |

---

## 9. مكتبات السيرفر (package.json)

الملف: `backend/package.json`

| المكتبة | الوظيفة |
|---------|----------|
| **express** | إطار سيرفر الويب — استقبال الطلبات وتوجيهها |
| **cors** | السماح للتطبيق من نطاق مختلف بالاتصال |
| **better-sqlite3** | التعامل مع قاعدة SQLite |

---

## 10. المتطلبات والتثبيت

### ما تحتاجه

| الأداة | الاستخدام |
|--------|-----------|
| **Flutter** | بناء وتشغيل التطبيق |
| **Node.js** | تشغيل السيرفر |
| **محاكي أندرويد** أو **جهاز أندرويد** أو **Chrome** | تجربة التطبيق |

### تثبيت Flutter

1. ادخل إلى [flutter.dev](https://flutter.dev)
2. حمّل Flutter SDK
3. فك الضغط وضع الملفات في مجلد مثل `C:\flutter`
4. أضف `C:\flutter\bin` إلى متغير البيئة **PATH**
5. افتح طرفية جديدة ونفّذ: `flutter doctor`

### تثبيت Node.js

1. ادخل إلى [nodejs.org](https://nodejs.org)
2. حمّل الإصدار LTS
3. نفّذ التثبيت
4. تحقق: `node -v` و `npm -v`

### محاكي أندرويد

- حمّل **Android Studio** من [developer.android.com](https://developer.android.com/studio)
- أثناء التثبيت اختر Android Virtual Device
- بعد التثبيت: **Tools → Device Manager → Create Device** لإنشاء محاكي

---

## 11. التشغيل خطوة بخطوة

### 1) تشغيل السيرفر

افتح طرفية ونفّذ:

```bash
cd D:\VSCode\Projects\flutterprojects\khibarti\backend
npm install
npm start
```

**شرح:**
- `cd` — الانتقال لمجلد السيرفر
- `npm install` — تحميل المكتبات (مرة واحدة)
- `npm start` — تشغيل السيرفر

يجب أن تظهر: `Khibarti API يعمل على http://localhost:3000`

**اترك هذه الطرفية مفتوحة.**

---

### 2) تشغيل التطبيق

افتح طرفية **جديدة** ونفّذ:

```bash
cd D:\VSCode\Projects\flutterprojects\khibarti
flutter pub get
flutter run
```

اختر الجهاز عند السؤال (مثلاً المحاكي الأندرويد).

---

### 3) تسجيل الدخول

استخدم:

| النوع | البريد | كلمة المرور |
|-------|--------|-------------|
| طالب | student@khibarti.com | 123456 |
| خبير | expert@khibarti.com | 123456 |
| شركة | company@khibarti.com | 123456 |
| **مدير** | **admin@khibarti.com** | **123456** |

يُنشأ حساب المدير تلقائياً عند تشغيل السيرفر (دالة `migrateAdminRole` في `server.js`) إذا لم يكن موجوداً. **غيّر كلمة المرور في الإنتاج.**

---

## 12. الأكواد المهمة — الشرح وكيف تعمل معاً

### 12.1 نظرة عامة: كيف تتصل الأجزاء

```
main.dart  →  app.dart  →  SplashScreen  →  WelcomeScreen  →  LoginScreen
                                                                    ↓
                                                              MainApp (5 تبويبات)
                                                                    ↓
                        ┌─────────────────────────────────────────────────────┐
                        │  HomeScreen, ExploreScreen, SessionsScreen,         │
                        │  ProfileScreen, SettingsScreen                      │
                        │  كلها تستخدم: ApiService + AppState                │
                        └─────────────────────────────────────────────────────┘
                                            ↓ HTTP
                                    backend/server.js
                                            ↓
                                      SQLite (khibarti.db)
```

**الفكرة:** التطبيق يبدأ من `main`، يعرض شاشات البداية حتى تسجيل الدخول، ثم ينتقل لواجهة رئيسية فيها 5 تبويبات. كل شاشة تحتاج بيانات فتستدعي `ApiService`، الذي يرسل طلب HTTP للسيرفر، والسيرفر يقرأ/يكتب من SQLite.

---

### 12.2 مسار الشاشات (من البداية للنهاية)

| الترتيب | الشاشة | الملف | ماذا يحدث |
|---------|--------|-------|------------|
| 1 | نقطة البداية | `main.dart` | يستدعي `runApp(KhibartiApp())` |
| 2 | إعداد التطبيق | `app.dart` | يحدد الشاشة الأولى: `SplashScreen` أو `MainApp` (إذا skipWelcome) |
| 3 | شاشة البداية | `splash_screen.dart` | يعرض الشعار 1.5 ثانية ثم `pushReplacement` لـ WelcomeScreen |
| 4 | شاشة الترحيب | `welcome_screen.dart` | يختار المستخدم النوع (طالب/خبير/شركة) ويضغط تسجيل الدخول أو إنشاء حساب |
| 5 | شاشة تسجيل الدخول | `login_screen.dart` | يُدخل البريد وكلمة المرور، يضغط دخول → استدعاء API → حفظ المستخدم في AppState → الانتقال لـ MainApp |
| 6 | الواجهة الرئيسية | `main_app.dart` | يعرض 5 تبويبات (IndexedStack) و BottomNavigationBar للتنقل بينها |
| 7 | الشاشات الداخلية | home, explore, sessions, profile, settings | كل واحدة تظهر حسب التبويب المختار، وتحمّل بياناتها من API عند الفتح |

---

### 12.3 تدفق البيانات: من الواجهة للسيرفر والعكس

```
[المستخدم يضغط "دخول"]  ←  LoginScreen
         ↓
   _api.login(email, password)  ←  ApiService
         ↓
   http.post(baseUrl + '/api/auth/login', body: JSON)
         ↓
   [السيرفر يفحص users في SQLite]
         ↓
   يرجع JSON مثل: { id: 1, email: "...", name: "...", role_name: "student" }
         ↓
   ApiService ترجع Map للمستدعي
         ↓
   LoginScreen يحفظ: AppState.currentUser = user
         ↓
   Navigator.pushReplacement(MainApp)
         ↓
   MainApp وكل الشاشات يمكنها قراءة AppState.currentUser
```

**الفكرة:** الشاشة تستدعي الدالة في ApiService، ApiService يرسل طلب للسيرفر، السيرفر يعالج ويرجع JSON، ApiService تحوّل JSON لـ Map وترجعها، الشاشة تحفظ في AppState أو تعرض البيانات.

---

### 12.4 سيناريو كامل: تسجيل الدخول خطوة بخطوة

**1) المستخدم يضغط زر "دخول"** في `LoginScreen`:

```dart
ElevatedButton(
  onPressed: _loading ? null : _submit,  // يستدعي _submit
  ...
)
```

**2) دالة `_submit` تُنفّذ:**

```dart
Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;  // تأكد أن الحقول صحيحة
  setState(() => _loading = true);                  // أظهر مؤشر التحميل
  
  final user = await _api.login(                   // استدعاء API
    _emailController.text.trim(),
    _passwordController.text,
  );
  
  if (user != null) {
    AppState.currentUser = user;                    // حفظ المستخدم في الذاكرة
    _navigateToMainApp();                           // الانتقال للواجهة الرئيسية
  } else {
    _showSnack('...');                              // رسالة خطأ
  }
  setState(() => _loading = false);
}
```

**3) داخل `ApiService.login`:**

```dart
Future<Map<String, dynamic>?> login(String email, String password) async {
  final r = await http.post(
    Uri.parse('$_base/api/auth/login'),             // العنوان الكامل
    headers: {'Content-Type': 'application/json'},   // نوع المحتوى
    body: jsonEncode({'email': email, 'password': password}),  // البيانات بصيغة JSON
  ).timeout(const Duration(seconds: 5));
  
  if (r.statusCode == 200)                          // إذا نجح الطلب
    return jsonDecode(r.body) as Map<String, dynamic>;  // حول JSON لـ Map
  return null;                                      // وإلا null
}
```

**4) السيرفر (backend/server.js):**

```javascript
app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;            // يستقبل البريد وكلمة المرور
  const user = db.prepare(
    'SELECT u.*, r.name as role_name FROM users u JOIN roles r ...'
  ).get(email, password);                          // يبحث في SQLite
  
  if (!user) return res.status(401).json({ error: '...' });
  res.json(user);                                  // يرسل بيانات المستخدم
});
```

**5) النتيجة:** `LoginScreen` تستلم `user` (Map فيه id, name, email, role_name)، تحفظه في `AppState.currentUser`، وتنتقل لـ `MainApp`. أي شاشة أخرى يمكنها قراءة `AppState.currentUser?['name']` أو `AppState.currentUser?['id']`.

---

### 12.5 سيناريو كامل: تحميل البيانات في الصفحة الرئيسية

**1) عند فتح HomeScreen** يُستدعى `initState`:

```dart
@override
void initState() {
  super.initState();
  _loadData();   // يحمّل البيانات فوراً
}
```

**2) دالة `_loadData`:**

```dart
Future<void> _loadData() async {
  final userId = AppState.currentUser?['id'] as int?;   // من من؟ من المستخدم المسجل
  if (userId == null) return;
  
  final experts = await _api.getExperts();              // طلب 1: قائمة الخبراء
  final sessions = await _api.getSessionsForUser(userId, status: 'upcoming');  // طلب 2
  final notifications = await _api.getNotificationsForUser(userId);            // طلب 3
  
  if (mounted) {
    setState(() {
      _experts = experts;
      _sessions = sessions;
      _notifications = notifications;
    });
  }
}
```

**3) العلاقة:** `AppState.currentUser` يُملأ عند تسجيل الدخول. الشاشات تحتاج `userId` لطلب الجلسات والإشعارات، فتقرأه من `AppState.currentUser?['id']`.

---

### 12.6 سيناريو كامل: حجز جلسة

| الخطوة | أين | ماذا يحدث |
|--------|-----|------------|
| 1 | ExpertDetailScreen | المستخدم يضغط "احجز جلسة" |
| 2 | `_bookSession()` | تقرأ `AppState.currentUser` و `getStudentIdByUserId` من API |
| 3 | ApiService.bookSession | طلب POST لـ `/api/sessions/book` مع expertId, studentId, date, time |
| 4 | السيرفر | `INSERT INTO sessions ...` ثم يرجع `{ id: ... }` |
| 5 | ExpertDetailScreen | يعرض رسالة نجاح وينتقل للخلف |

---

### 12.7 الملفات الأساسية ودور كل واحد

| الملف | الدور |
|-------|-------|
| `main.dart` | نقطة الدخول — يستدعي `runApp(KhibartiApp())` |
| `app.dart` | إعداد التطبيق: الثيم، اللغة، والشاشة الأولى (Splash أو MainApp) |
| `app_state.dart` | تخزين حالة عامة: المستخدم الحالي، اللغة، وضع التكبير — يُستخدم من أي شاشة |
| `api_config.dart` | عنوان السيرفر — يستخدمه ApiService في كل الطلبات |
| `api_service.dart` | وسيط بين التطبيق والسيرفر — كل استدعاء API يمر من هنا |
| `main_app.dart` | القالب الرئيسي: 5 تبويبات + شريط سفلي للتنقل |
| `database_helper.dart` | غير مستخدم حالياً — التطبيق يعتمد على API بدلاً من SQLite المحلي |

---

### 12.8 أكواد مهمة بالتفصيل

#### تغيير عنوان السيرفر

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3000';
}
```

`ApiService` يقرأ `ApiConfig.baseUrl` ويضيفه لأول كل مسار (مثل `/api/auth/login`).

---

#### نقطة البداية

```dart
// lib/main.dart
void main() {
  runApp(const KhibartiApp());
}
```

`runApp` يبدأ عرض التطبيق. `KhibartiApp` (في app.dart) يحدد الشاشة الأولى.

---

#### كيف يختار app.dart الشاشة الأولى

```dart
// lib/app.dart
home: skipWelcome ? const MainApp() : const SplashScreen(),
```

- أول تشغيل: `skipWelcome = false` → يعرض SplashScreen
- بعد تغيير اللغة من الإعدادات: يعيد بناء التطبيق مع `skipWelcome = true` → يعرض MainApp مباشرة دون العودة للترحيب.

---

#### IndexedStack — إبقاء الشاشات في الذاكرة

```dart
// lib/main_app.dart
body: IndexedStack(
  index: _currentIndex,
  children: _screens,
),
```

`IndexedStack` يعرض شاشة واحدة حسب `_currentIndex` لكن يبقي كل الشاشات محمّلة. عند التنقل بين التبويبات لا تُعاد تحميل البيانات من الصفر (إلا لو الشاشة تستدعي `_loadData` عند كل ظهور).

---

#### طلب GET مع معاملات (مثل فلترة الخبراء)

```dart
// في api_service.dart — getExperts
final q = <String>[];
if (search != null && search.isNotEmpty) q.add('search=$search');
if (specialty != null && specialty != 'الكل') q.add('specialty=$specialty');
// ...
final query = q.isEmpty ? '' : '?${q.join('&')}';
final url = Uri.parse('$_base/api/experts$query');
```

يبني عنوان مثل: `http://10.0.2.2:3000/api/experts?search=أحمد&specialty=تطوير`

---

#### حفظ المستخدم بعد الدخول

```dart
// في login_screen.dart
AppState.currentUser = user;
```

بعدها أي شاشة تقرأ `AppState.currentUser?['name']` أو `['id']` أو `['role_name']` لمعرفة من المستخدم الحالي.

---

## 13. إعدادات التشغيل حسب الجهاز

| البيئة | العنوان في `api_config.dart` |
|--------|------------------------------|
| محاكي أندرويد | `http://10.0.2.2:3000` |
| Chrome / Windows | `http://localhost:3000` |
| جهاز أندرويد حقيقي | `http://192.168.1.5:3000` (استبدل بـ IP اللابتوب) |

**ملاحظة:** الجهاز والكمبيوتر يجب أن يكونا على نفس شبكة الـ Wi-Fi.

---

## 14. بناء التطبيق للنشر

### APK للأندرويد

```bash
flutter build apk --release
```

الملف الناتج: `build/app/outputs/flutter-apk/app-release.apk`

### تطبيق ويب

```bash
flutter build web
```

الملف الناتج في مجلد `build/web/` — يمكن رفعه على استضافة ويب.

---

## 15. حل المشاكل الشائعة

| المشكلة | السبب المحتمل | الحل |
|---------|----------------|------|
| `flutter: command not found` | Flutter غير مضاف لـ PATH | أضف مسار `flutter/bin` إلى PATH |
| تسجيل الدخول يفشل مع رسالة «تأكد من تشغيل السيرفر» | السيرفر غير مشغّل | شغّل `npm start` في مجلد backend |
| المحاكي لا يظهر | المحاكي غير مشغّل | شغّله من Android Studio → Device Manager |
| خطأ الاتصال بالسيرفر | العنوان خاطئ | تحقق من `api_config.dart` وحالة السيرفر |
| خطأ Gradle | ملفات بناء قديمة | `flutter clean` ثم `flutter pub get` |
| الشعار لا يظهر | ملف Logo.jpg غير موجود | ضع الملف في `assets/images/Logo.jpg` |
| `No devices found` | لا محاكي ولا جهاز متصل | شغّل المحاكي أو وصّل جهاز أندرويد |
| خطأ NDK | إصدار NDK غير متوافق | راجع `android/app/build.gradle.kts` و`ndkVersion` |
| لوحة الإدارة لا تعرض إحصائيات أو «تعذر تحميل البيانات» | السيرفر متوقف أو عنوان `api_config` خاطئ | شغّل `npm start` في `backend` وتأكد من `baseUrl` حسب الجهاز (محاكي: `10.0.2.2`) |

---

## 16. روابط رسمية

| المورد | الرابط |
|--------|--------|
| Flutter | https://flutter.dev |
| Dart | https://dart.dev |
| تثبيت Flutter | https://docs.flutter.dev/get-started/install |
| Node.js | https://nodejs.org |
| Android Studio | https://developer.android.com/studio |
| VS Code | https://code.visualstudio.com |

---

## 17. شرح المشروع بشكل كامل — كل الأكواد مع الشرح

هذا القسم يحتوي على **الكود الكامل** لكل ملف مع شرح وظيفته وعلاقته بباقي المشروع.

---

### 17.1 main.dart — نقطة البداية

**الشرح:** أول ملف يُنفّذ عند تشغيل التطبيق. يستدعي `runApp()` لبدء عرض واجهة Flutter. كل شيء يبدأ من هنا.

```dart
import 'package:flutter/material.dart';
import 'package:khibarti/app.dart';

void main() {
  runApp(const KhibartiApp());
}
```

- `main()`: الدالة الافتراضية التي يبحث عنها Flutter عند التشغيل.
- `runApp(KhibartiApp())`: يُمرّر الـ Widget الجذري (KhibartiApp) لمحرك العرض ليعرض الشاشة الأولى.

---

### 17.2 app.dart — إعداد التطبيق الكامل

**الشرح:** يبني `MaterialApp` — الثيم، اللغة، المترجمين، والشاشة الأولى. يقرأ من `AppState` للغة ووضع الإعاقة.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:khibarti/app_state.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/main_app.dart';
import 'package:khibarti/screens/splash_screen.dart';
import 'package:khibarti/theme/app_theme.dart';

class KhibartiApp extends StatelessWidget {
  final bool skipWelcome;

  const KhibartiApp({super.key, this.skipWelcome = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'خبرتي | Khibarti',
      theme: AppTheme.lightTheme(
        accessibilityMode: AppState.accessibilityMode,
      ),
      locale: AppState.locale,
      localeResolutionCallback: (_, supported) => AppState.locale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: skipWelcome ? const MainApp() : const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

- `skipWelcome`: إن كان `true` يذهب مباشرة لـ MainApp (بعد تغيير اللغة من الإعدادات).
- `theme`: من AppTheme مع دعم وضع التكبير.
- `locale`: من AppState — عربي أو إنجليزي.
- `home`: إما SplashScreen أو MainApp حسب skipWelcome.

---

### 17.3 app_state.dart — حالة التطبيق المشتركة

**الشرح:** يخزّن بيانات تُستخدم من أي شاشة: المستخدم الحالي، اللغة، وضع ذوي الاحتياجات. لا يحتاج state management معقّد لصغر المشروع.

```dart
import 'package:flutter/material.dart';

/// حالة التطبيق - المستخدم الحالي والتصميم
class AppState {
  static bool accessibilityMode = false;
  static Locale locale = const Locale('ar');
  static Map<String, dynamic>? currentUser;
}
```

- `accessibilityMode`: تكبير الخط والعناصر.
- `locale`: اللغة الحالية.
- `currentUser`: بيانات المستخدم بعد تسجيل الدخول (id, name, email, role_name).

---

### 17.4 main_app.dart — الواجهة الرئيسية ذات 5 تبويبات

**الشرح:** الوعاء بعد تسجيل الدخول. يستخدم `IndexedStack` لعرض الشاشات الخمس دون إعادة بنائها عند التنقل.

```dart
import 'package:flutter/material.dart';
import 'package:khibarti/l10n/app_localizations.dart';
import 'package:khibarti/screens/home_screen.dart';
import 'package:khibarti/screens/explore_screen.dart';
import 'package:khibarti/screens/sessions_screen.dart';
import 'package:khibarti/screens/profile_screen.dart';
import 'package:khibarti/screens/settings_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    SessionsScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1B5E57),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.navHome),
          BottomNavigationBarItem(icon: const Icon(Icons.search), label: l10n.navExplore),
          BottomNavigationBarItem(icon: const Icon(Icons.calendar_today), label: l10n.navSessions),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: l10n.navProfile),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: l10n.navSettings),
        ],
      ),
    );
  }
}
```

- `IndexedStack`: يعرض شاشة واحدة لكن يبقي الباقي في الذاكرة.
- `onTap`: يغيّر `_currentIndex` ويحدّث `setState` لعرض التبويب الجديد.

---

### 17.5 api_config.dart — عنوان السيرفر

**الشرح:** يحدد `baseUrl` — يستخدمه ApiService في كل الطلبات. غيّره حسب الجهاز (محاكي: 10.0.2.2، جهاز حقيقي: IP اللابتوب، Chrome: localhost).

```dart
/// إعدادات الـ API - غيّر العنوان حسب الجهاز
/// محاكي أندرويد: 10.0.2.2
/// جهاز حقيقي: عنوان IP للكمبيوتر (مثل 192.168.1.5)
/// Chrome/Windows: localhost
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3000';
}
```

---

### 17.6 api_service.dart — كل طلبات HTTP (كامل)

**الشرح:** Singleton وسيط بين التطبيق والسيرفر. كل دالة ترسل طلب HTTP وتُرجع النتيجة. تستخدم `ApiConfig.baseUrl` و `http` package.

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:khibarti/config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._();
  static ApiService get instance => _instance;
  final String _base = ApiConfig.baseUrl;

  ApiService._();

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final r = await http.post(
        Uri.parse('$_base/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
      return null;
    } catch (_) { return null; }
  }

  Future<Map<String, dynamic>?> register({required String email, required String password, required int roleId, required String name}) async {
    try {
      final r = await http.post(
        Uri.parse('$_base/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'roleId': roleId, 'name': name}),
      ).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
      return null;
    } catch (_) { return null; }
  }

  Future<bool> emailExists(String email) async {
    try {
      final r = await http.get(Uri.parse('$_base/api/auth/check-email?email=${Uri.encodeComponent(email)}')).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return (jsonDecode(r.body) as Map)['exists'] == true;
      return false;
    } catch (_) { return false; }
  }

  Future<List<Map<String, dynamic>>> getExperts({String? search, String? specialty, int? minYears, double? minRating}) async {
    try {
      final q = <String>[];
      if (search != null && search.isNotEmpty) q.add('search=$search');
      if (specialty != null && specialty != 'الكل') q.add('specialty=$specialty');
      if (minYears != null && minYears > 0) q.add('minYears=$minYears');
      if (minRating != null && minRating > 0) q.add('minRating=$minRating');
      final query = q.isEmpty ? '' : '?${q.join('&')}';
      final r = await http.get(Uri.parse('$_base/api/experts$query')).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(r.body));
      return [];
    } catch (_) { return []; }
  }

  Future<List<String>> getSpecialties() async {
    try {
      final r = await http.get(Uri.parse('$_base/api/experts/specialties')).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return List<String>.from(jsonDecode(r.body));
      return [];
    } catch (_) { return []; }
  }

  Future<Map<String, dynamic>?> getExpertById(int id) async {
    try {
      final r = await http.get(Uri.parse('$_base/api/experts/$id')).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
      return null;
    } catch (_) { return null; }
  }

  Future<int?> bookSession(int expertId, int studentId, String date, String time) async {
    try {
      final resp = await http.post(
        Uri.parse('$_base/api/sessions/book'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'expertId': expertId, 'studentId': studentId, 'date': date, 'time': time}),
      ).timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) return (jsonDecode(resp.body) as Map)['id'] as int?;
      return null;
    } catch (_) { return null; }
  }

  Future<List<Map<String, dynamic>>> getSessionsForUser(int userId, {String? status}) async {
    try {
      final url = status != null && status.isNotEmpty ? '$_base/api/sessions/user/$userId?status=$status' : '$_base/api/sessions/user/$userId';
      final r = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(r.body));
      return [];
    } catch (_) { return []; }
  }

  Future<void> updateSessionStatus(int sessionId, String status) async {
    try {
      await http.patch(
        Uri.parse('$_base/api/sessions/$sessionId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<void> cancelSession(int sessionId) async => updateSessionStatus(sessionId, 'cancelled');
  Future<void> completeSession(int sessionId) async => updateSessionStatus(sessionId, 'completed');

  Future<void> addRating(int sessionId, int raterId, int ratedId, int score) async {
    try {
      await http.post(
        Uri.parse('$_base/api/sessions/$sessionId/rate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'raterId': raterId, 'ratedId': ratedId, 'score': score}),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<void> recordAttendance(int sessionId, int userId) async {
    try {
      await http.post(
        Uri.parse('$_base/api/sessions/$sessionId/attendance'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<void> createCertificate({required int sessionId, required int userId, required String expertName, required String specialty, required String sessionDate}) async {
    try {
      await http.post(
        Uri.parse('$_base/api/certificates'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionId': sessionId, 'userId': userId, 'expertName': expertName, 'specialty': specialty, 'sessionDate': sessionDate}),
      ).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> getNotificationsForUser(int userId) async {
    try {
      final r = await http.get(Uri.parse('$_base/api/notifications/$userId')).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return List<Map<String, dynamic>>.from(jsonDecode(r.body));
      return [];
    } catch (_) { return []; }
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    try {
      final r = await http.get(Uri.parse('$_base/api/users/$id')).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
      return null;
    } catch (_) { return null; }
  }

  Future<int?> getStudentIdByUserId(int userId) async {
    try {
      final r = await http.get(Uri.parse('$_base/api/students/by-user/$userId')).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) {
        final data = jsonDecode(r.body);
        return data != null ? (data as Map)['id'] as int? : null;
      }
      return null;
    } catch (_) { return null; }
  }

  Future<int?> getExpertUserIdByExpertId(int expertId) async {
    try {
      final r = await http.get(Uri.parse('$_base/api/experts/$expertId/user')).timeout(const Duration(seconds: 5));
      if (r.statusCode == 200) return (jsonDecode(r.body) as Map)['userId'] as int?;
      return null;
    } catch (_) { return null; }
  }

  Future<void> updateUser(int id, {String? name, String? password}) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (password != null && password.isNotEmpty) body['password'] = password;
      if (body.isNotEmpty) {
        await http.patch(
          Uri.parse('$_base/api/users/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 5));
      }
    } catch (_) {}
  }

  Future<void> deleteUser(int id) async {
    try {
      await http.delete(Uri.parse('$_base/api/users/$id')).timeout(const Duration(seconds: 5));
    } catch (_) {}
  }

  Future<bool> checkConnection() async {
    try {
      final r = await http.get(Uri.parse('$_base/api/experts')).timeout(const Duration(seconds: 3));
      return r.statusCode == 200;
    } catch (_) { return false; }
  }
}
```

- **login/register:** POST للـ Auth.
- **getExperts:** GET مع query params للفلترة.
- **bookSession/getSessionsForUser:** حجز وجلب الجلسات.
- **recordAttendance/completeSession/addRating:** إدارة الجلسة.
- **createCertificate:** إنشاء سجل شهادة في السيرفر.

---

### 17.7 certificate_service.dart — توليد PDF للشهادة

**الشرح:** ينشئ ملف PDF للشهادة محلياً باستخدام مكتبة `pdf` ويحفظه في مجلد التطبيق عبر `path_provider`. يُستدعى بعد إنهاء الجلسة.

```dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// توليد وحفظ شهادات الخبرة محلياً
class CertificateService {
  static Future<String?> generateAndSave({
    required String expertName,
    required String specialty,
    required String sessionDate,
    required String userName,
  }) async {
    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('شهادة خبرة', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 24),
              pw.Text('تُمنح هذه الشهادة إلى', style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 8),
              pw.Text(userName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('لإكمال جلسة تدريب مع الخبير', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 8),
              pw.Text(expertName, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text('في تخصص: $specialty', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 16),
              pw.Text('تاريخ الجلسة: $sessionDate', style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 32),
              pw.Text('تطبيق خبرتي - Khibarti', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ),
      );
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'certificate_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      return file.path;
    } catch (_) { return null; }
  }
}
```

- `pdf.addPage`: يضيف صفحة A4 بالنص.
- `getApplicationDocumentsDirectory()`: مسار مجلد المستندات.
- يرجع مسار الملف أو `null` عند الفشل.

---

### 17.8 app_theme.dart — الألوان والثيم

**الشرح:** يحدد ألوان التطبيق (primary أخضر داكن) وبناء ThemeData مع خط IBM Plex Arabic. لو `accessibilityMode` يكبّر الحجم (scale 1.2).

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF1B5E57);
  static const Color primaryDark = Color(0xFF0D3D38);
  static const Color accent = Color(0xFF2E7D6E);
  static const Color darkBlue = Color(0xFF1565C0);
  static const Color cardBg = Color(0xFFF5F7F6);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
}

class AppTheme {
  static ThemeData lightTheme({bool accessibilityMode = false}) {
    final scale = accessibilityMode ? 1.2 : 1.0;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
      cardTheme: CardThemeData(color: AppColors.cardBg, elevation: 1, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 16 * scale)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 16 * scale), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
      textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(TextTheme(
        bodyLarge: TextStyle(fontSize: (16 * scale).clamp(14.0, 24.0), color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: (14 * scale).clamp(12.0, 20.0), color: AppColors.textSecondary),
        titleLarge: TextStyle(fontSize: (20 * scale).clamp(18.0, 28.0), fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontSize: (18 * scale).clamp(16.0, 24.0), fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      )),
    );
  }
}
```

---

### 17.9 khibarti_logo.dart — شعار التطبيق

**الشرح:** يعرض `Logo.jpg` من assets، أو شعار نصي "خبرتي / Khibarti" مع تدرج لوني عند فشل التحميل.

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KhibartiLogo extends StatelessWidget {
  final double size;

  const KhibartiLogo({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.asset(
        'assets/images/Logo.jpg',
        width: size, height: size, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildTextLogo(size),
      ),
    );
  }

  static Widget _buildTextLogo(double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1B5E57), Color(0xFF1565C0)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF1B5E57).withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('خبرتي', style: GoogleFonts.ibmPlexSansArabic(fontSize: size * 0.38, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 6),
          Text('Khibarti', style: GoogleFonts.ibmPlexSansArabic(fontSize: size * 0.2, fontWeight: FontWeight.w500, color: Colors.white70)),
        ],
      ),
    );
  }
}
```

---

### 17.10 app_localizations.dart — الترجمة (عربي/إنجليزي)

**الشرح:** يوفّر نصوص التطبيق حسب `locale`. كل getter يعيد النص العربي أو الإنجليزي. `AppLocalizations.of(context)` يُستدعى من أي شاشة.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) => Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  bool get isAr => locale.languageCode == 'ar';

  // أمثلة: welcomeTitle, student, expert, company, login, signUp, email, password, navHome, navExplore, navSessions, navProfile, navSettings, ...
  String get welcomeTitle => isAr ? 'مرحباً بك في خبرتي' : 'Welcome to Khibarti';
  String get login => isAr ? 'تسجيل الدخول' : 'LOGIN';
  String get navHome => isAr ? 'الرئيسية' : 'Home';
  String get navExplore => isAr ? 'استكشف الخبراء' : 'Explore Experts';
  String get bookSession => isAr ? 'احجز جلسة' : 'Book Session';
  String get join => isAr ? 'انضم' : 'Join';
  // ... باقي النصوص (~50 getter)
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async => SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
```

---

### 17.11 backend/server.js — السيرفر (كامل)

**الشرح:** سيرفر Node.js + Express يستقبل طلبات التطبيق، يقرأ/يكتب SQLite عبر better-sqlite3. `initDB()` تنشئ الجداول والبيانات التجريبية. CORS للسماح للطلبات من التطبيق.

```javascript
const express = require('express');
const cors = require('cors');
const Database = require('better-sqlite3');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());

const db = new Database(path.join(__dirname, 'khibarti.db'));

function initDB() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS roles (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE);
    CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT NOT NULL UNIQUE, password TEXT NOT NULL, role_id INTEGER NOT NULL, name TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS experts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, specialty TEXT NOT NULL, years_experience INTEGER DEFAULT 0, rating REAL DEFAULT 0, sessions_count INTEGER DEFAULT 0, bio TEXT);
    CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL UNIQUE, university TEXT, major TEXT, graduation_year TEXT);
    CREATE TABLE IF NOT EXISTS companies (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL UNIQUE, company_name TEXT NOT NULL, industry TEXT);
    CREATE TABLE IF NOT EXISTS sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, expert_id INTEGER NOT NULL, student_id INTEGER NOT NULL, scheduled_date TEXT NOT NULL, scheduled_time TEXT NOT NULL, status TEXT DEFAULT 'upcoming', created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS session_attendance (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id INTEGER NOT NULL, user_id INTEGER NOT NULL, joined_at TEXT DEFAULT CURRENT_TIMESTAMP, left_at TEXT, was_recorded INTEGER DEFAULT 0);
    CREATE TABLE IF NOT EXISTS ratings (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id INTEGER NOT NULL, rater_id INTEGER NOT NULL, rated_id INTEGER NOT NULL, score INTEGER NOT NULL, comment TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS certificates (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id INTEGER NOT NULL, user_id INTEGER NOT NULL, expert_name TEXT NOT NULL, specialty TEXT NOT NULL, session_date TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP, file_path TEXT);
    CREATE TABLE IF NOT EXISTS notifications (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, title TEXT NOT NULL, body TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP, read INTEGER DEFAULT 0);
  `);
  const roles = db.prepare('SELECT COUNT(*) as c FROM roles').get();
  if (roles.c === 0) {
    db.exec(`
      INSERT INTO roles (name) VALUES ('student'), ('expert'), ('company');
      INSERT INTO users (email, password, role_id, name) VALUES 
        ('student@khibarti.com', '123456', 1, 'طالب تجريبي'),
        ('expert@khibarti.com', '123456', 2, 'أحمد محمد'),
        ('company@khibarti.com', '123456', 3, 'شركة داعمة'),
        ('expert2@khibarti.com', '123456', 2, 'سارة علي'),
        ('expert3@khibarti.com', '123456', 2, 'خالد حسن'),
        ('expert4@khibarti.com', '123456', 2, 'فاطمة عمر'),
        ('expert5@khibarti.com', '123456', 2, 'عمر يوسف'),
        ('expert6@khibarti.com', '123456', 2, 'نورة أحمد');
      INSERT INTO students (user_id, university, major, graduation_year) VALUES (1, 'جامعة الملك سعود', 'علوم الحاسب', '2026');
      INSERT INTO experts (user_id, specialty, years_experience, rating, sessions_count, bio) VALUES 
        (2, 'تطوير البرمجيات', 12, 4.8, 42, 'خبير في تطوير التطبيقات'),
        (4, 'التسويق الرقمي', 8, 4.9, 67, 'خبيرة تسويق'),
        (5, 'إدارة الأعمال', 15, 4.6, 28, 'خبير إدارة'),
        (6, 'التصميم الجرافيكي', 6, 4.7, 35, 'مصممة جرافيك'),
        (7, 'الذكاء الاصطناعي', 10, 4.9, 55, 'خبير AI'),
        (8, 'المحاسبة', 20, 4.8, 90, 'محاسب معتمد');
      INSERT INTO companies (user_id, company_name, industry) VALUES (3, 'شركة التقنية', 'التقنية');
      INSERT INTO sessions (expert_id, student_id, scheduled_date, scheduled_time, status) VALUES 
        (1, 1, '2026-02-28', '10:00', 'upcoming'),
        (2, 1, '2026-03-01', '14:00', 'upcoming'),
        (1, 1, '2026-02-20', '11:00', 'completed');
      INSERT INTO notifications (user_id, title, body) VALUES 
        (1, 'جلسة قادمة', 'لديك جلسة مع أحمد محمد غداً'),
        (1, 'تذكير', 'أكمل ملفك الشخصي');
    `);
  }
}
initDB();

// ============ Auth ============
app.get('/api/auth/check-email', (req, res) => {
  try {
    const { email } = req.query;
    const exists = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
    res.json({ exists: !!exists });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/auth/login', (req, res) => {
  try {
    const { email, password } = req.body;
    const user = db.prepare('SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.email = ? AND u.password = ?').get(email, password);
    if (!user) return res.status(401).json({ error: 'البريد أو كلمة المرور غير صحيحة' });
    res.json(user);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/auth/register', (req, res) => {
  try {
    const { email, password, roleId, name } = req.body;
    const exists = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
    if (exists) return res.status(400).json({ error: 'البريد مستخدم مسبقاً' });
    const r = db.prepare('INSERT INTO users (email, password, role_id, name) VALUES (?, ?, ?, ?)').run(email, password, roleId, name);
    const user = db.prepare('SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?').get(r.lastInsertRowid);
    if (roleId === 1) db.prepare('INSERT INTO students (user_id) VALUES (?)').run(user.id);
    if (roleId === 2) db.prepare('INSERT INTO experts (user_id, specialty) VALUES (?, ?)').run(user.id, 'تخصص افتراضي');
    if (roleId === 3) db.prepare('INSERT INTO companies (user_id, company_name) VALUES (?, ?)').run(user.id, 'شركة');
    res.json(user);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ============ Experts ============
app.get('/api/experts', (req, res) => {
  try {
    const { search, specialty, minYears, minRating } = req.query;
    let sql = 'SELECT e.*, u.name FROM experts e JOIN users u ON e.user_id = u.id WHERE 1=1';
    const params = [];
    if (search) { sql += ' AND (u.name LIKE ? OR e.specialty LIKE ?)'; params.push(`%${search}%`, `%${search}%`); }
    if (specialty && specialty !== 'الكل') { sql += ' AND e.specialty = ?'; params.push(specialty); }
    if (minYears) { sql += ' AND e.years_experience >= ?'; params.push(minYears); }
    if (minRating) { sql += ' AND e.rating >= ?'; params.push(minRating); }
    sql += ' ORDER BY e.rating DESC';
    const rows = db.prepare(sql).all(...params);
    res.json(rows);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/experts/specialties', (req, res) => {
  try {
    const rows = db.prepare('SELECT DISTINCT specialty FROM experts').all();
    res.json(rows.map(r => r.specialty));
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/experts/:id', (req, res) => {
  try {
    const row = db.prepare('SELECT e.*, u.name FROM experts e JOIN users u ON e.user_id = u.id WHERE e.id = ?').get(req.params.id);
    if (!row) return res.status(404).json({ error: 'غير موجود' });
    res.json(row);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ============ Sessions ============
app.post('/api/sessions/book', (req, res) => {
  try {
    const { expertId, studentId, date, time } = req.body;
    const r = db.prepare('INSERT INTO sessions (expert_id, student_id, scheduled_date, scheduled_time) VALUES (?, ?, ?, ?)').run(expertId, studentId, date, time);
    res.json({ id: r.lastInsertRowid });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/sessions/user/:userId', (req, res) => {
  try {
    const { status } = req.query;
    const userId = req.params.userId;
    const student = db.prepare('SELECT id FROM students WHERE user_id = ?').get(userId);
    const expert = db.prepare('SELECT id FROM experts WHERE user_id = ?').get(userId);
    let sql = `SELECT s.*, u.name as expert_name, e.specialty FROM sessions s JOIN experts e ON s.expert_id = e.id JOIN users u ON e.user_id = u.id WHERE s.student_id = ? OR s.expert_id = ?`;
    const params = [student?.id ?? -1, expert?.id ?? -1];
    if (status) { sql += ' AND s.status = ?'; params.push(status); }
    sql += ' ORDER BY s.scheduled_date DESC, s.scheduled_time DESC';
    const rows = db.prepare(sql).all(...params);
    res.json(rows);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.patch('/api/sessions/:id/status', (req, res) => {
  try {
    const { status } = req.body;
    db.prepare('UPDATE sessions SET status = ? WHERE id = ?').run(status, req.params.id);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/sessions/:id/rate', (req, res) => {
  try {
    const { raterId, ratedId, score } = req.body;
    db.prepare('INSERT INTO ratings (session_id, rater_id, rated_id, score) VALUES (?, ?, ?, ?)').run(req.params.id, raterId, ratedId, score);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.post('/api/sessions/:id/attendance', (req, res) => {
  try {
    const { userId } = req.body;
    const r = db.prepare('INSERT INTO session_attendance (session_id, user_id) VALUES (?, ?)').run(req.params.id, userId);
    res.json({ id: r.lastInsertRowid });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

// ============ Certificates, Notifications, Users, Students ============
app.post('/api/certificates', (req, res) => {
  try {
    const { sessionId, userId, expertName, specialty, sessionDate } = req.body;
    const r = db.prepare('INSERT INTO certificates (session_id, user_id, expert_name, specialty, session_date) VALUES (?, ?, ?, ?, ?)').run(sessionId, userId, expertName, specialty, sessionDate);
    res.json({ id: r.lastInsertRowid });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/notifications/:userId', (req, res) => {
  try {
    const rows = db.prepare('SELECT * FROM notifications WHERE user_id IS NULL OR user_id = ? ORDER BY created_at DESC').all(req.params.userId);
    res.json(rows);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/users/:id', (req, res) => {
  try {
    const user = db.prepare('SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?').get(req.params.id);
    if (!user) return res.status(404).json({ error: 'غير موجود' });
    res.json(user);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.patch('/api/users/:id', (req, res) => {
  try {
    const { name, password } = req.body;
    if (name) db.prepare('UPDATE users SET name = ? WHERE id = ?').run(name, req.params.id);
    if (password) db.prepare('UPDATE users SET password = ? WHERE id = ?').run(password, req.params.id);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.delete('/api/users/:id', (req, res) => {
  try {
    db.prepare('DELETE FROM users WHERE id = ?').run(req.params.id);
    res.json({ ok: true });
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/students/by-user/:userId', (req, res) => {
  try {
    const row = db.prepare('SELECT id FROM students WHERE user_id = ?').get(req.params.userId);
    res.json(row ? { id: row.id } : null);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

app.get('/api/experts/:id/user', (req, res) => {
  try {
    const row = db.prepare('SELECT user_id FROM experts WHERE id = ?').get(req.params.id);
    res.json(row ? { userId: row.user_id } : null);
  } catch (e) { res.status(500).json({ error: e.message }); }
});

const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Khibarti API يعمل على http://localhost:${PORT}`);
  console.log('للأندرويد استخدم: http://10.0.2.2:3000');
});
```

---

### 17.12 الشاشات — الأكواد الرئيسية مع الشرح

**splash_screen.dart:** يعرض الشعار مع Fade+Scale أنيميشن. بعد 1.5 ثانية → `pushReplacement(WelcomeScreen)`.

```dart
// initState
_controller = AnimationController(duration: Duration(milliseconds: 800), vsync: this);
_fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
_scaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
_controller.forward();
Future.delayed(Duration(milliseconds: 1500), () {
  if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const WelcomeScreen()));
});
```

**login_screen.dart — _submit (القلب الرئيسي):**

```dart
Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _loading = true);
  if (widget.isSignUp) {
    if (await _api.emailExists(email)) { _showSnack('البريد مستخدم'); return; }
    final user = await _api.register(email: email, password: password, roleId: widget.roleId, name: name);
    if (user != null) { AppState.currentUser = user; _navigateToMainApp(); }
  } else {
    final user = await _api.login(email, password);
    if (user != null) { AppState.currentUser = user; _navigateToMainApp(); }
    else _showSnack('البريد أو كلمة المرور غير صحيحة - تأكد من تشغيل السيرفر');
  }
  if (mounted) setState(() => _loading = false);
}
```

**home_screen.dart — _loadData:**

```dart
Future<void> _loadData() async {
  final userId = AppState.currentUser?['id'] as int?;
  if (userId == null) return;
  final experts = await _api.getExperts();
  final sessions = await _api.getSessionsForUser(userId, status: 'upcoming');
  final notifications = await _api.getNotificationsForUser(userId);
  if (mounted) setState(() { _experts = experts; _sessions = sessions; _notifications = notifications; });
}
```

**explore_screen.dart — _loadExperts مع الفلاتر:**

```dart
Future<void> _loadExperts() async {
  final experts = await _api.getExperts(
    search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
    specialty: _selectedSpecialty == 'الكل' ? null : _selectedSpecialty,
    minYears: _minYears > 0 ? _minYears : null,
    minRating: _minRating > 0 ? _minRating : null,
  );
  setState(() => _experts = experts);
}
```

**expert_detail_screen.dart — _bookSession:**

```dart
Future<void> _bookSession() async {
  final user = AppState.currentUser;
  if (user == null) return;
  final studentId = await _api.getStudentIdByUserId(user['id'] as int);
  if (studentId == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('يجب أن تكون طالباً لحجز جلسة')));
    return;
  }
  final now = DateTime.now();
  final date = '${now.year}-${now.month.toString().padLeft(2,'0')}-${(now.day+3).toString().padLeft(2,'0')}';
  await _api.bookSession(widget.expertId, studentId, date, '10:00');
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حجز الجلسة بنجاح')));
  Navigator.pop(context);
}
```

**sessions_screen.dart:** تبويبات (القادمة، المنتهية، الملغاة). القادمة: زر انضم → JoinSessionScreen، زر إلغاء → cancelSession. المنتهية: زر قيّم → addRating، زر تحميل شهادة → createCertificate + CertificateService.generateAndSave.

**join_session_screen.dart — _endSession:**

```dart
Future<void> _endSession() async {
  final confirm = await showDialog<bool>(...);
  if (confirm != true) return;
  if (widget.sessionId != null) {
    await _api.completeSession(widget.sessionId!);
    await _api.createCertificate(sessionId: ..., userId: ..., expertName: ..., specialty: ..., sessionDate: ...);
    await CertificateService.generateAndSave(expertName: ..., specialty: ..., sessionDate: ..., userName: ...);
  }
  Navigator.pop(context);
}
```

**profile_screen.dart:** يعرض AppState.currentUser. تعديل → EditProfileScreen. تغيير كلمة المرور → نافذة + updateUser.

**edit_profile_screen.dart — _save:**

```dart
await _api.updateUser(userId, name: _nameController.text.trim());
AppState.currentUser?['name'] = _nameController.text.trim();
Navigator.pop(context);
```

**settings_screen.dart:** اللغة → AppState.locale + runApp. وضع الإعاقة → AppState.accessibilityMode + runApp. تسجيل الخروج → AppState.currentUser = null + pushAndRemoveUntil(WelcomeScreen). حذف الحساب → deleteUser + نفس مسار الخروج.

---

### 17.13 تدفق العمليات

**من فتح التطبيق حتى الرئيسية:** main → runApp → SplashScreen → (1.5 ثانية) → WelcomeScreen → LoginScreen → login API → AppState.currentUser → MainApp → HomeScreen._loadData.

**من البحث حتى حجز جلسة:** ExploreScreen._loadExperts → ExpertDetailScreen → getStudentIdByUserId → bookSession → POST /api/sessions/book.

**من انضم حتى الشهادة:** JoinSessionScreen → recordAttendance → إنهاء → completeSession → createCertificate → CertificateService.generateAndSave → pop.

---

## 18. لوحة الإدارة (Admin)

### الفكرة

دور **admin** يربط واجهة إدارية داخل **نفس تطبيق Flutter** بنفس الثيم (ألوان خبرتي، خط IBM Plex Arabic، بطاقات `KhibartiCard`). البيانات تأتي من السيرفر عبر `ApiService`: دوال `getAdminStats`، `getAdminUsers`، `getAdminSessions`، `sendAdminNotification`. التحقق من أن الطلب من مدير يتم في السيرفر بمطابقة `adminUserId` مع مستخدم له `role_name = 'admin'`.

### نقطة الدخول (منفصلة عن التطبيق العام)

- شغّل التطبيق على **ملف الدخول الخاص بالإدارة** (نفس المشروع، نقطة تنفيذ مختلفة):

```bash
flutter run -t lib/main_admin.dart
```

- أو من VS Code / Cursor: اختر الإعداد **khibarti admin** في Run and Debug (ملف `.vscode/launch.json`).

ما يحدث: `AppState.adminFlavor = true` → بعد الـ Splash تفتح مباشرة شاشة **تسجيل دخول المدير** (بدون شاشة ترحيب وبدون رابط في التطبيق العام). إن وُجدت جلسة لمستخدم ليس `admin` تُمسح وتُطلب بيانات المدير.

### الدخول بالبيانات

1. شغّل السيرفر (`backend`: `npm start`).
2. شغّل التطبيق كما في «نقطة الدخول» أعلاه.
3. الحساب التجريبي الافتراضي:

| البريد | كلمة المرور |
|--------|-------------|
| admin@khibarti.com | 123456 |

يُضاف الحساب تلقائياً عند أول تشغيل للسيرفر بعد إضافة دور `admin` في جدول `roles` (انظر `migrateAdminRole` في `server.js`).

### التبويبات (5)

| التبويب | الملف | الوظيفة |
|---------|--------|----------|
| لوحة التحكم | `lib/screens/admin/admin_dashboard_screen.dart` | إحصائيات، تفصيل المستخدمين حسب الدور، الجلسات حسب الحالة، زر **إرسال إشعار** (عام أو لمستخدم برقمه `#` من قائمة المستخدمين) |
| المستخدمون | `lib/screens/admin/admin_users_screen.dart` | قائمة بكل الحسابات (اسم، بريد، دور، رقم المعرف) |
| كل الجلسات | `lib/screens/admin/admin_sessions_screen.dart` | كل الجلسات مع الخبير والطالب؛ قائمة لتغيير الحالة (تستدعي `PATCH /api/sessions/:id/status`) |
| الملف الشخصي | `profile_screen.dart` | مثل بقية الأدوار؛ يظهر دور **مدير** في الشارة |
| الإعدادات | `settings_screen.dart` | مثل العادة؛ **لا يظهر زر حذف الحساب** لحساب المدير |

التنقل يُضبط في `main_app.dart`: عندما `role_name == 'admin'` تُعرض الشاشات الخمس أعلاه بدل مسار الطالب/الخبير/الشركة.

### الأمان (مهم للإنتاج)

الوضع الحالي مناسب للتطوير والتجربة: التحقق من المدير يعتمد على تمرير `adminUserId` في الطلب. **للإنتاج** يُنصح باعتماد جلسات خادم أو JWT وعدم الاعتماد على معرّف فقط يُرسل من التطبيق.

### الملفات ذات الصلة

| الملف | الدور |
|--------|--------|
| `backend/server.js` | أدوار `admin`، مسارات `/api/admin/*`، منع التسجيل كمدير من `/api/auth/register` |
| `lib/services/api_service.dart` | دوال الـ Admin أعلاه |
| `lib/main_admin.dart` | نقطة دخول الإدارة فقط (`flutter run -t lib/main_admin.dart`) |
| `lib/l10n/app_localizations.dart` | نصوص لوحة الإدارة (`navAdminDashboard`، إلخ.) |
