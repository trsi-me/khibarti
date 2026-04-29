const express = require('express');
const cors = require('cors');
const Database = require('better-sqlite3');
const path = require('path');
const fs = require('fs');

const app = express();
app.use(cors());
app.use(express.json());

const db = new Database(path.join(__dirname, 'khibarti.db'));

// إنشاء الجداول والبيانات الأولية
function initDB() {
  db.exec(`
    CREATE TABLE IF NOT EXISTS roles (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE);
    CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT NOT NULL UNIQUE, password TEXT NOT NULL, role_id INTEGER NOT NULL, name TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS experts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, specialty TEXT NOT NULL, years_experience INTEGER DEFAULT 0, rating REAL DEFAULT 0, sessions_count INTEGER DEFAULT 0, bio TEXT, list_in_student_app INTEGER DEFAULT 1, list_in_company_directory INTEGER DEFAULT 0);
    CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL UNIQUE, university TEXT, major TEXT, graduation_year TEXT);
    CREATE TABLE IF NOT EXISTS companies (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL UNIQUE, company_name TEXT NOT NULL, industry TEXT);
    CREATE TABLE IF NOT EXISTS sessions (id INTEGER PRIMARY KEY AUTOINCREMENT, expert_id INTEGER NOT NULL, student_id INTEGER NOT NULL, scheduled_date TEXT NOT NULL, scheduled_time TEXT NOT NULL, status TEXT DEFAULT 'upcoming', created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS session_attendance (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id INTEGER NOT NULL, user_id INTEGER NOT NULL, joined_at TEXT DEFAULT CURRENT_TIMESTAMP, left_at TEXT, was_recorded INTEGER DEFAULT 0);
    CREATE TABLE IF NOT EXISTS ratings (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id INTEGER NOT NULL, rater_id INTEGER NOT NULL, rated_id INTEGER NOT NULL, score INTEGER NOT NULL, comment TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
    CREATE TABLE IF NOT EXISTS certificates (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id INTEGER NOT NULL, user_id INTEGER NOT NULL, expert_name TEXT NOT NULL, specialty TEXT NOT NULL, session_date TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP, file_path TEXT);
    CREATE TABLE IF NOT EXISTS notifications (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER, title TEXT NOT NULL, body TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP, read INTEGER DEFAULT 0);
    CREATE TABLE IF NOT EXISTS messages (id INTEGER PRIMARY KEY AUTOINCREMENT, sender_id INTEGER NOT NULL, receiver_id INTEGER NOT NULL, body TEXT NOT NULL, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
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
      INSERT INTO students (user_id, university, major, graduation_year) VALUES (1, 'جامعة الملك سعود', 'علوم الحاسب', '2025');
      INSERT INTO experts (user_id, specialty, years_experience, rating, sessions_count, bio, list_in_student_app, list_in_company_directory) VALUES 
        (2, 'تطوير البرمجيات', 12, 0, 42, 'خبير في تطوير التطبيقات', 1, 0),
        (4, 'التسويق الرقمي', 8, 0, 67, 'خبيرة تسويق', 1, 0),
        (5, 'إدارة الأعمال', 15, 0, 28, 'خبير إدارة', 1, 0),
        (6, 'التصميم الجرافيكي', 6, 0, 35, 'مصممة جرافيك', 1, 0),
        (7, 'الذكاء الاصطناعي', 10, 0, 55, 'خبير AI', 1, 0),
        (8, 'المحاسبة', 20, 0, 90, 'محاسب معتمد', 1, 0);
      INSERT INTO companies (user_id, company_name, industry) VALUES (3, 'شركة التقنية', 'التقنية');
      INSERT INTO sessions (expert_id, student_id, scheduled_date, scheduled_time, status) VALUES 
        (1, 1, '2025-02-28', '10:00', 'upcoming'),
        (2, 1, '2025-03-01', '14:00', 'upcoming'),
        (3, 1, '2025-03-05', '09:00', 'upcoming'),
        (4, 1, '2025-03-10', '16:00', 'upcoming'),
        (1, 1, '2025-02-20', '11:00', 'completed'),
        (2, 1, '2025-02-15', '14:00', 'completed'),
        (5, 1, '2025-02-10', '10:30', 'completed');
      INSERT INTO notifications (user_id, title, body) VALUES 
        (NULL, 'مرحباً بك', 'منصة تدريبية تربط الخبراء بالطلاب والشركات'),
        (1, 'جلسة قادمة', 'لديك جلسة مع أحمد محمد غداً الساعة 10:00'),
        (1, 'تذكير', 'أكمل ملفك الشخصي للاستفادة من جميع الميزات'),
        (1, 'ترحيب', 'استكشف الخبراء واحجز جلساتك الأولى'),
        (1, 'جلسة جديدة', 'تم تأكيد حجزك مع سارة علي يوم 1 مارس'),
        (1, 'تقييم', 'قيم جلستك الأخيرة مع خالد حسن لمساعدتنا على التحسن'),
        (2, 'جلسة قادمة', 'لديك جلسة مع طالب تجريبي غداً 10:00'),
        (2, 'تحديث المنصة', 'تم إضافة ميزات جديدة للتطبيق'),
        (2, 'إحصائيات', 'أكملت 42 جلسة هذا الشهر - أحسنت!'),
        (3, 'نظرة عامة', 'لديك 6 خبراء و 15 جلسة نشطة على المنصة'),
        (3, 'ترحيب', 'مرحباً بشركتك — نتمنى لك تجربة مثمرة للتدريب والتطوير'),
        (3, 'تواصل مع الخبراء', 'يمكنك التواصل مع أي خبير عبر زر المحادثة في بطاقة الخبير'),
        (3, 'إشعار إعلان', 'ورشة عمل جديدة في الذكاء الاصطناعي مع خبير عمر يوسف - تواصل معه للمزيد'),
        (3, 'تحديث أسبوعي', 'تم تنفيذ 23 جلسة هذا الأسبوع على المنصة'),
        (3, 'فرص شراكات', 'خبيرة التسويق سارة علي متاحة لشراكات تدريب موظفيك');
    `);
  }
}
initDB();

// إضافة أعمدة جديدة للبيانات الشخصية (الهاتف، الدولة، الصورة)
function migrateUsers() {
  try { db.prepare('ALTER TABLE users ADD COLUMN phone TEXT').run(); } catch (_) { }
  try { db.prepare('ALTER TABLE users ADD COLUMN country TEXT').run(); } catch (_) { }
  try { db.prepare('ALTER TABLE users ADD COLUMN avatar TEXT').run(); } catch (_) { }
  try { db.prepare('ALTER TABLE users ADD COLUMN is_blocked INTEGER DEFAULT 0').run(); } catch (_) { }
}
migrateUsers();

/** توثيق الخبير (علامة مثل المنصات المعتمدة) — بعض الخبراء موثّقون وبعضهم لا */
function migrateExpertVerified() {
  try {
    db.prepare('ALTER TABLE experts ADD COLUMN is_verified INTEGER DEFAULT 0').run();
  } catch (_) { }
  try {
    const marked = db.prepare('SELECT COUNT(*) as c FROM experts WHERE is_verified = 1').get();
    if (marked.c === 0) {
      db.prepare('UPDATE experts SET is_verified = 1 WHERE id IN (1, 3, 5)').run();
      db.prepare('UPDATE experts SET is_verified = 0 WHERE is_verified IS NULL').run();
    }
  } catch (_) { }
}
migrateExpertVerified();

function ensureUserProfile(userId, roleName) {
  if (roleName === 'student') {
    const x = db.prepare('SELECT id FROM students WHERE user_id = ?').get(userId);
    if (!x) db.prepare('INSERT INTO students (user_id) VALUES (?)').run(userId);
  } else if (roleName === 'expert') {
    const x = db.prepare('SELECT id FROM experts WHERE user_id = ?').get(userId);
    if (!x) {
      try {
        db.prepare('INSERT INTO experts (user_id, specialty, is_verified, list_in_student_app, list_in_company_directory) VALUES (?, ?, 0, 1, 0)').run(userId, 'تخصص افتراضي');
      } catch (_) {
        db.prepare('INSERT INTO experts (user_id, specialty, is_verified) VALUES (?, ?, 0)').run(userId, 'تخصص افتراضي');
      }
    }
  } else if (roleName === 'company' || roleName === 'company_manager' || roleName === 'company_delegate') {
    const x = db.prepare('SELECT id FROM companies WHERE user_id = ?').get(userId);
    if (!x) {
      if (roleName === 'company_delegate') {
        const urow = db.prepare('SELECT parent_company_user_id FROM users WHERE id = ?').get(userId);
        const pid = urow && urow.parent_company_user_id;
        const pc = pid
          ? db.prepare('SELECT company_name, COALESCE(industry, \'\') as industry FROM companies WHERE user_id = ?').get(pid)
          : null;
        if (pc) {
          db.prepare('INSERT INTO companies (user_id, company_name, industry) VALUES (?, ?, ?)').run(
            userId,
            pc.company_name,
            pc.industry || ''
          );
        } else {
          db.prepare('INSERT INTO companies (user_id, company_name) VALUES (?, ?)').run(userId, 'مفوّض شركة');
        }
      } else {
        const cn = roleName === 'company_manager' ? 'مسؤول شراكات' : 'شركة';
        db.prepare('INSERT INTO companies (user_id, company_name) VALUES (?, ?)').run(userId, cn);
      }
    }
  }
}

// إشعار افتراضي عام — يظهر لجميع المستخدمين
function migrateNotifications() {
  const hasGlobal = db.prepare('SELECT 1 FROM notifications WHERE user_id IS NULL LIMIT 1').get();
  if (!hasGlobal) {
    try { db.prepare('INSERT INTO notifications (user_id, title, body) VALUES (NULL, ?, ?)').run('مرحباً بك', 'منصة تدريبية تربط الخبراء بالطلاب والشركات'); } catch (_) { }
  }
}
migrateNotifications();

/** دور المدير وحساب تجريبي — لا يُسمح بالتسجيل كمدير من التطبيق */
function migrateAdminRole() {
  try {
    const has = db.prepare("SELECT id FROM roles WHERE name = 'admin'").get();
    if (!has) db.prepare("INSERT INTO roles (name) VALUES ('admin')").run();
    const adminRole = db.prepare("SELECT id FROM roles WHERE name = 'admin'").get();
    const existing = db.prepare("SELECT id FROM users WHERE email = 'admin@khibarti.com'").get();
    if (!existing && adminRole) {
      db.prepare(
        "INSERT INTO users (email, password, role_id, name) VALUES ('admin@khibarti.com', '123456', ?, 'مدير النظام')"
      ).run(adminRole.id);
    }
  } catch (e) {
    console.error('[migrateAdminRole]', e);
  }
}
migrateAdminRole();

/** لمرة واحدة: تصفير تقييمات الخبراء التجريبية واستبدال 2026 بـ 2025 في التواريخ */
function migrateRatingsZeroYears2025() {
  try {
    db.exec(`CREATE TABLE IF NOT EXISTS app_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);`);
    const done = db.prepare(`SELECT 1 AS ok FROM app_meta WHERE key = 'ratings_zero_years_2025_v1'`).get();
    if (done) return;
    const run = db.transaction(() => {
      db.prepare(`UPDATE experts SET rating = 0`).run();
      db.prepare(`UPDATE students SET graduation_year = '2025' WHERE graduation_year = '2026'`).run();
      db.prepare(
        `UPDATE sessions SET scheduled_date = REPLACE(scheduled_date, '2026', '2025') WHERE instr(scheduled_date, '2026') > 0`
      ).run();
      db.prepare(`INSERT INTO app_meta (key, value) VALUES ('ratings_zero_years_2025_v1', '1')`).run();
    });
    run();
  } catch (e) {
    console.error('[migrateRatingsZeroYears2025]', e);
  }
}
migrateRatingsZeroYears2025();

/** أعمدة ظهور الخبير للطلاب vs للشركات + شركاء بأسماء مختلفة + دور مسؤول الشركة */
function migrateExpertListsCompanyPartnersAndManager() {
  try {
    db.exec(`CREATE TABLE IF NOT EXISTS app_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);`);
    try { db.prepare('ALTER TABLE experts ADD COLUMN list_in_student_app INTEGER DEFAULT 1').run(); } catch (_) { }
    try { db.prepare('ALTER TABLE experts ADD COLUMN list_in_company_directory INTEGER DEFAULT 0').run(); } catch (_) { }
    db.prepare('UPDATE experts SET list_in_student_app = 1 WHERE list_in_student_app IS NULL').run();
    db.prepare('UPDATE experts SET list_in_company_directory = 0 WHERE list_in_company_directory IS NULL').run();

    let mgrRole = db.prepare("SELECT id FROM roles WHERE name = 'company_manager'").get();
    if (!mgrRole) {
      db.prepare("INSERT INTO roles (name) VALUES ('company_manager')").run();
      mgrRole = db.prepare("SELECT id FROM roles WHERE name = 'company_manager'").get();
    }
    if (!db.prepare("SELECT id FROM users WHERE email = 'manager@khibarti.com'").get() && mgrRole) {
      db.prepare(
        "INSERT INTO users (email, password, role_id, name) VALUES ('manager@khibarti.com', '123456', ?, 'مسؤول الشراكة')"
      ).run(mgrRole.id);
      const mu = db.prepare("SELECT id FROM users WHERE email = 'manager@khibarti.com'").get();
      if (mu) db.prepare("INSERT INTO companies (user_id, company_name, industry) VALUES (?, 'قسم الشراكات', 'التدريب')").run(mu.id);
    }

    const done = db.prepare("SELECT 1 FROM app_meta WHERE key = 'partner_experts_v1'").get();
    if (done) return;

    const partners = [
      { email: 'corp.partner1@khibarti.com', name: 'د. هند العتيبي', spec: 'الاستشارات الإدارية', years: 14, bio: 'شريك تدريب — استشارات وإدارة تغيير' },
      { email: 'corp.partner2@khibarti.com', name: 'م. سلطان القحطاني', spec: 'التحول الرقمي', years: 11, bio: 'شريك تدريب — تحول رقمي للمؤسسات' },
      { email: 'corp.partner3@khibarti.com', name: 'أ. لينا الزهراني', spec: 'تطوير الموارد البشرية', years: 9, bio: 'شريك تدريب — تطوير الأداء والمواهب' },
      { email: 'corp.partner4@khibarti.com', name: 'م. ريم الشمري', spec: 'الجودة والامتثال', years: 16, bio: 'شريك تدريب — جودة ومعايير مهنية' },
    ];
    const expertRole = db.prepare("SELECT id FROM roles WHERE name = 'expert'").get();
    if (!expertRole) return;
    const rid = expertRole.id;
    const run = db.transaction(() => {
      for (const p of partners) {
        if (db.prepare('SELECT id FROM users WHERE email = ?').get(p.email)) continue;
        const ins = db.prepare('INSERT INTO users (email, password, role_id, name) VALUES (?, ?, ?, ?)').run(p.email, '123456', rid, p.name);
        const uid = ins.lastInsertRowid;
        db.prepare(
          `INSERT INTO experts (user_id, specialty, years_experience, rating, sessions_count, bio, is_verified, list_in_student_app, list_in_company_directory)
           VALUES (?, ?, ?, 0, 0, ?, 0, 0, 1)`
        ).run(uid, p.spec, p.years, p.bio);
      }
      db.prepare("INSERT INTO app_meta (key, value) VALUES ('partner_experts_v1', '1')").run();
    });
    run();
  } catch (e) {
    console.error('[migrateExpertListsCompanyPartnersAndManager]', e);
  }
}
migrateExpertListsCompanyPartnersAndManager();

/**
 * إصلاح لمرة واحدة: بعض قواعد البيانات القديمة جعلت list_in_student_app = 0 لكل الخبراء
 * فيختفون من تطبيق الطالب. نُعيد الظهور للجميع ما عدا شركاء الشركة (corp.partner*).
 */
function migrateRestoreExpertsStudentList() {
  try {
    db.exec(`CREATE TABLE IF NOT EXISTS app_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);`);
    const done = db.prepare(`SELECT 1 FROM app_meta WHERE key = 'restore_experts_student_list_v1'`).get();
    if (done) return;
    db.prepare(`
      UPDATE experts
      SET list_in_student_app = 1
      WHERE COALESCE(list_in_student_app, 1) = 0
        AND user_id IN (
          SELECT id FROM users
          WHERE COALESCE(email, '') NOT LIKE 'corp.partner%@khibarti.com'
        )
    `).run();
    db.prepare(`INSERT INTO app_meta (key, value) VALUES ('restore_experts_student_list_v1', '1')`).run();
  } catch (e) {
    console.error('[migrateRestoreExpertsStudentList]', e);
  }
}
migrateRestoreExpertsStudentList();

/** إزالة عبارة «مرحباً بك في خبرتي» وذِكر «منصة خبرتي» من إشعارات قديمة */
function migrateRemoveWelcomeInKhibartiPhrase() {
  try {
    db.exec(`CREATE TABLE IF NOT EXISTS app_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);`);
    const done = db.prepare(`SELECT 1 FROM app_meta WHERE key = 'remove_welcome_in_khibarti_v1'`).get();
    if (done) return;
    const run = db.transaction(() => {
      db.prepare(`UPDATE notifications SET title = REPLACE(title, 'مرحباً بك في خبرتي', 'مرحباً بك') WHERE title LIKE '%مرحباً بك في خبرتي%'`).run();
      db.prepare(`UPDATE notifications SET body = REPLACE(body, 'مرحباً بك في خبرتي!', 'مرحباً بك. ') WHERE body LIKE '%مرحباً بك في خبرتي!%'`).run();
      db.prepare(`UPDATE notifications SET body = REPLACE(body, 'مرحباً بك في خبرتي', 'مرحباً بك') WHERE body LIKE '%مرحباً بك في خبرتي%'`).run();
      db.prepare(`UPDATE notifications SET body = REPLACE(body, 'منصة خبرتي', 'المنصة') WHERE body LIKE '%منصة خبرتي%'`).run();
      db.prepare(`UPDATE notifications SET body = REPLACE(body, 'عبر منصة خبرتي', 'عبر المنصة') WHERE body LIKE '%عبر منصة خبرتي%'`).run();
      db.prepare(`UPDATE notifications SET body = REPLACE(body, 'في منصة خبرتي', 'في المنصة') WHERE body LIKE '%في منصة خبرتي%'`).run();
      db.prepare(`INSERT INTO app_meta (key, value) VALUES ('remove_welcome_in_khibarti_v1', '1')`).run();
    });
    run();
  } catch (e) {
    console.error('[migrateRemoveWelcomeInKhibartiPhrase]', e);
  }
}
migrateRemoveWelcomeInKhibartiPhrase();

/** عمود ربط المفوّض بحساب الشركة الرئيسي + دور company_delegate */
function migrateCompanyDelegates() {
  try {
    db.exec(`CREATE TABLE IF NOT EXISTS app_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);`);
    const done = db.prepare(`SELECT 1 FROM app_meta WHERE key = 'company_delegates_v1'`).get();
    if (done) return;
    try {
      db.prepare('ALTER TABLE users ADD COLUMN parent_company_user_id INTEGER NULL').run();
    } catch (_) { /* column exists */ }
    let delRole = db.prepare("SELECT id FROM roles WHERE name = 'company_delegate'").get();
    if (!delRole) {
      db.prepare("INSERT INTO roles (name) VALUES ('company_delegate')").run();
      delRole = db.prepare("SELECT id FROM roles WHERE name = 'company_delegate'").get();
    }
    db.prepare(`INSERT INTO app_meta (key, value) VALUES ('company_delegates_v1', '1')`).run();
  } catch (e) {
    console.error('[migrateCompanyDelegates]', e);
  }
}
migrateCompanyDelegates();

/** طلبات الخبراء للظهور في دليل الشركات — موافقة مسؤول الشراكات */
function migrateCompanyPartnerRequests() {
  try {
    db.exec(`CREATE TABLE IF NOT EXISTS app_meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);`);
    db.exec(`
      CREATE TABLE IF NOT EXISTS company_partner_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expert_id INTEGER NOT NULL UNIQUE,
        status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      );
    `);
    const done = db.prepare(`SELECT 1 FROM app_meta WHERE key = 'company_partner_requests_v1'`).get();
    if (done) return;
    const run = db.transaction(() => {
      const candidates = db.prepare(`
        SELECT e.id FROM experts e
        JOIN users u ON u.id = e.user_id
        WHERE COALESCE(e.list_in_company_directory, 0) = 0
          AND COALESCE(u.email, '') NOT LIKE 'corp.partner%@khibarti.com'
        LIMIT 2
      `).all();
      for (const row of candidates) {
        try {
          db.prepare(`INSERT INTO company_partner_requests (expert_id, status) VALUES (?, 'pending')`).run(row.id);
        } catch (_) { /* يوجد صف */ }
      }
      db.prepare(`INSERT INTO app_meta (key, value) VALUES ('company_partner_requests_v1', '1')`).run();
    });
    run();
  } catch (e) {
    console.error('[migrateCompanyPartnerRequests]', e);
  }
}
migrateCompanyPartnerRequests();

function isCompanyOfficerUserId(userId) {
  const uid = parseInt(userId, 10);
  if (isNaN(uid) || uid < 1) return false;
  const row = db.prepare(
    `SELECT u.id FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ? AND r.name IN ('company','company_manager','company_delegate')`
  ).get(uid);
  return !!row;
}

function isCompanyPrincipalUserId(userId) {
  const uid = parseInt(userId, 10);
  if (isNaN(uid) || uid < 1) return false;
  const row = db.prepare(
    `SELECT u.id FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ? AND r.name IN ('company','company_manager')`
  ).get(uid);
  return !!row;
}

function requireAdmin(req, res) {
  const raw = req.query.adminUserId ?? req.body?.adminUserId;
  const id = parseInt(raw, 10);
  if (isNaN(id) || id < 1) {
    res.status(400).json({ error: 'معرّف المدير مطلوب' });
    return null;
  }
  const row = db.prepare(
    `SELECT u.id FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ? AND r.name = 'admin'`
  ).get(id);
  if (!row) {
    res.status(403).json({ error: 'غير مصرح' });
    return null;
  }
  return id;
}

// فحص الاتصال — للتأكد من ربط التطبيق بالسيرفر
app.get('/api/health', (req, res) => {
  res.json({ ok: true, message: 'خبرتي متصل' });
});

// ============ Auth ============
app.get('/api/auth/check-email', (req, res) => {
  try {
    const { email } = req.query;
    const exists = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
    res.json({ exists: !!exists });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/auth/login', (req, res) => {
  try {
    const { email, password } = req.body;
    const user = db.prepare(`
      SELECT u.*, r.name as role_name, COALESCE(e.is_verified, 0) as expert_verified
      FROM users u
      JOIN roles r ON u.role_id = r.id
      LEFT JOIN experts e ON e.user_id = u.id
      WHERE u.email = ? AND u.password = ?
    `).get(email, password);
    if (!user) return res.status(401).json({ error: 'البريد أو كلمة المرور غير صحيحة' });
    if (user.is_blocked === 1) return res.status(403).json({ error: 'تم تقييد هذا الحساب. تواصل مع الإدارة.' });
    delete user.password;
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/auth/register', (req, res) => {
  try {
    const { email, password, roleId, name } = req.body;
    const roleRow = db.prepare('SELECT name FROM roles WHERE id = ?').get(roleId);
    if (!roleRow) return res.status(400).json({ error: 'دور غير صالح' });
    if (roleRow.name === 'admin') {
      return res.status(403).json({ error: 'لا يمكن إنشاء حساب مدير من التطبيق' });
    }
    if (roleRow.name === 'company_delegate') {
      return res.status(403).json({ error: 'أضف المفوّضين من لوحة «مسؤول الشراكات» داخل حساب الشركة' });
    }
    const exists = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
    if (exists) return res.status(400).json({ error: 'البريد مستخدم مسبقاً' });
    const r = db.prepare('INSERT INTO users (email, password, role_id, name) VALUES (?, ?, ?, ?)').run(email, password, roleId, name);
    const user = db.prepare('SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?').get(r.lastInsertRowid);
    delete user.password;
    if (roleRow.name === 'student') db.prepare('INSERT INTO students (user_id) VALUES (?)').run(user.id);
    if (roleRow.name === 'expert') {
      try {
        db.prepare('INSERT INTO experts (user_id, specialty, is_verified, list_in_student_app, list_in_company_directory) VALUES (?, ?, 0, 1, 0)').run(user.id, 'تخصص افتراضي');
      } catch (_) {
        db.prepare('INSERT INTO experts (user_id, specialty, is_verified) VALUES (?, ?, 0)').run(user.id, 'تخصص افتراضي');
      }
    }
    if (roleRow.name === 'company' || roleRow.name === 'company_manager') {
      const cn = roleRow.name === 'company_manager' ? 'مسؤول شراكات' : 'شركة';
      db.prepare('INSERT INTO companies (user_id, company_name) VALUES (?, ?)').run(user.id, cn);
    }
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ============ حسابات الشركة الفرعية (مفوّضون) ============
app.get('/api/company/delegates', (req, res) => {
  try {
    const ownerUserId = parseInt(req.query.ownerUserId, 10);
    if (isNaN(ownerUserId) || ownerUserId < 1) return res.status(400).json({ error: 'ownerUserId مطلوب' });
    if (!isCompanyPrincipalUserId(ownerUserId)) return res.status(403).json({ error: 'غير مصرّح' });
    const rows = db.prepare(
      `SELECT u.id, u.email, u.name, u.created_at FROM users u
       JOIN roles r ON u.role_id = r.id
       WHERE u.parent_company_user_id = ? AND r.name = 'company_delegate'
       ORDER BY u.id ASC`
    ).all(ownerUserId);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/company/delegates', (req, res) => {
  try {
    const body = req.body || {};
    const ownerUserId = parseInt(body.ownerUserId, 10);
    const email = typeof body.email === 'string' ? body.email.trim() : '';
    const password = typeof body.password === 'string' ? body.password : '';
    const name = typeof body.name === 'string' ? body.name.trim() : '';
    if (isNaN(ownerUserId) || ownerUserId < 1) return res.status(400).json({ error: 'ownerUserId غير صالح' });
    if (!isCompanyPrincipalUserId(ownerUserId)) return res.status(403).json({ error: 'فقط حساب الشركة أو مسؤول الشراكات يضيف مفوّضين' });
    if (!email || !name) return res.status(400).json({ error: 'البريد والاسم مطلوبان' });
    if (password.length < 6) return res.status(400).json({ error: 'كلمة المرور 6 أحرف على الأقل' });
    const exists = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
    if (exists) return res.status(400).json({ error: 'البريد مستخدم مسبقاً' });
    const parentCo = db.prepare('SELECT company_name, COALESCE(industry, \'\') as industry FROM companies WHERE user_id = ?').get(ownerUserId);
    if (!parentCo) return res.status(400).json({ error: 'لا يوجد ملف شركة للمالك' });
    const delRole = db.prepare("SELECT id FROM roles WHERE name = 'company_delegate'").get();
    if (!delRole) return res.status(500).json({ error: 'دور المفوّض غير مهيأ' });
    const ins = db.prepare(
      'INSERT INTO users (email, password, role_id, name, parent_company_user_id) VALUES (?, ?, ?, ?, ?)'
    ).run(email, password, delRole.id, name, ownerUserId);
    const newId = ins.lastInsertRowid;
    db.prepare('INSERT INTO companies (user_id, company_name, industry) VALUES (?, ?, ?)').run(
      newId,
      parentCo.company_name,
      parentCo.industry || ''
    );
    const user = db.prepare(
      'SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?'
    ).get(newId);
    delete user.password;
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/company/delegates/:delegateId', (req, res) => {
  try {
    const delegateId = parseInt(req.params.delegateId, 10);
    const ownerUserId = parseInt((req.query.ownerUserId ?? req.body?.ownerUserId), 10);
    if (isNaN(delegateId) || delegateId < 1 || isNaN(ownerUserId) || ownerUserId < 1) {
      return res.status(400).json({ error: 'معرّفات غير صالحة' });
    }
    if (!isCompanyPrincipalUserId(ownerUserId)) return res.status(403).json({ error: 'غير مصرّح' });
    const row = db.prepare(
      `SELECT u.id FROM users u JOIN roles r ON u.role_id = r.id
       WHERE u.id = ? AND u.parent_company_user_id = ? AND r.name = 'company_delegate'`
    ).get(delegateId, ownerUserId);
    if (!row) return res.status(404).json({ error: 'غير موجود' });
    db.prepare('DELETE FROM companies WHERE user_id = ?').run(delegateId);
    db.prepare('DELETE FROM users WHERE id = ?').run(delegateId);
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ============ طلبات دليل الشركات (موافقة / رفض — مسؤول الشراكات) ============
app.get('/api/company/partner-requests', (req, res) => {
  try {
    const officerUserId = parseInt(req.query.officerUserId, 10);
    const status = typeof req.query.status === 'string' ? req.query.status : 'pending';
    if (isNaN(officerUserId) || officerUserId < 1) return res.status(400).json({ error: 'officerUserId مطلوب' });
    if (!isCompanyOfficerUserId(officerUserId)) return res.status(403).json({ error: 'غير مصرّح' });
    if (!['pending', 'approved', 'rejected'].includes(status)) {
      return res.status(400).json({ error: 'حالة غير صالحة' });
    }
    const rows = db.prepare(`
      SELECT r.id, r.expert_id, r.status, r.created_at, e.specialty, u.name as expert_name, e.user_id as expert_user_id
      FROM company_partner_requests r
      JOIN experts e ON e.id = r.expert_id
      JOIN users u ON u.id = e.user_id
      WHERE r.status = ?
      ORDER BY datetime(r.created_at) DESC
    `).all(status);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.patch('/api/company/partner-requests/:id', (req, res) => {
  try {
    const requestId = parseInt(req.params.id, 10);
    const officerUserId = parseInt(req.body?.officerUserId, 10);
    const decision = req.body?.decision;
    if (isNaN(requestId) || requestId < 1) return res.status(400).json({ error: 'معرّف غير صالح' });
    if (isNaN(officerUserId) || officerUserId < 1) return res.status(400).json({ error: 'officerUserId مطلوب' });
    if (!isCompanyOfficerUserId(officerUserId)) return res.status(403).json({ error: 'غير مصرّح' });
    if (decision !== 'approve' && decision !== 'reject') {
      return res.status(400).json({ error: 'decision يجب أن يكون approve أو reject' });
    }
    const row = db.prepare('SELECT * FROM company_partner_requests WHERE id = ?').get(requestId);
    if (!row) return res.status(404).json({ error: 'غير موجود' });
    if (row.status !== 'pending') return res.status(400).json({ error: 'تمت معالجة هذا الطلب مسبقاً' });
    if (decision === 'approve') {
      const run = db.transaction(() => {
        db.prepare(`UPDATE company_partner_requests SET status = 'approved' WHERE id = ?`).run(requestId);
        db.prepare(`UPDATE experts SET list_in_company_directory = 1 WHERE id = ?`).run(row.expert_id);
      });
      run();
    } else {
      db.prepare(`UPDATE company_partner_requests SET status = 'rejected' WHERE id = ?`).run(requestId);
    }
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/experts/partner-directory-request/me', (req, res) => {
  try {
    const expertUserId = parseInt(req.query.expertUserId, 10);
    if (isNaN(expertUserId) || expertUserId < 1) return res.status(400).json({ error: 'expertUserId مطلوب' });
    const role = db.prepare(`SELECT r.name FROM users u JOIN roles r ON r.id = u.role_id WHERE u.id = ?`).get(expertUserId);
    if (!role || role.name !== 'expert') return res.status(403).json({ error: 'محجوز للخبراء' });
    const ex = db.prepare(
      'SELECT id, COALESCE(list_in_company_directory, 0) as in_directory FROM experts WHERE user_id = ?'
    ).get(expertUserId);
    if (!ex) return res.json({ inDirectory: false, requestStatus: null });
    const reqRow = db.prepare('SELECT status FROM company_partner_requests WHERE expert_id = ?').get(ex.id);
    res.json({
      inDirectory: !!ex.in_directory,
      requestStatus: reqRow ? reqRow.status : null,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/experts/partner-directory-request', (req, res) => {
  try {
    const expertUserId = parseInt(req.body?.expertUserId, 10);
    if (isNaN(expertUserId) || expertUserId < 1) return res.status(400).json({ error: 'expertUserId مطلوب' });
    const user = db.prepare(`SELECT u.id, u.email FROM users u JOIN roles r ON r.id = u.role_id WHERE u.id = ? AND r.name = 'expert'`).get(expertUserId);
    if (!user) return res.status(403).json({ error: 'محجوز للخبراء' });
    const em = String(user.email || '');
    if (em.includes('corp.partner')) return res.status(400).json({ error: 'لا يلزم طلب لهذا الحساب' });
    const ex = db.prepare('SELECT id, COALESCE(list_in_company_directory, 0) as lcd FROM experts WHERE user_id = ?').get(expertUserId);
    if (!ex) return res.status(400).json({ error: 'لا ملف خبير' });
    if (ex.lcd === 1) return res.status(400).json({ error: 'أنت مُدرج بالفعل في دليل الشركات' });
    const existing = db.prepare('SELECT id, status FROM company_partner_requests WHERE expert_id = ?').get(ex.id);
    if (existing) {
      if (existing.status === 'pending') return res.status(400).json({ error: 'طلبك قيد المراجعة' });
      if (existing.status === 'approved') return res.status(400).json({ error: 'تمت الموافقة مسبقاً' });
      db.prepare(`UPDATE company_partner_requests SET status = 'pending', created_at = CURRENT_TIMESTAMP WHERE expert_id = ?`).run(ex.id);
    } else {
      db.prepare(`INSERT INTO company_partner_requests (expert_id, status) VALUES (?, 'pending')`).run(ex.id);
    }
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ============ Experts ============
app.get('/api/experts', (req, res) => {
  try {
    const { search, specialty, minYears, minRating, audience } = req.query;
    let sql = 'SELECT e.*, u.name FROM experts e JOIN users u ON e.user_id = u.id WHERE 1=1';
    const params = [];
    if (audience === 'company') {
      sql += ' AND COALESCE(e.list_in_company_directory, 0) = 1';
    } else {
      sql += ' AND COALESCE(e.list_in_student_app, 1) = 1';
    }
    if (search) { sql += ' AND (u.name LIKE ? OR e.specialty LIKE ?)'; params.push(`%${search}%`, `%${search}%`); }
    if (specialty && specialty !== 'الكل') { sql += ' AND e.specialty = ?'; params.push(specialty); }
    if (minYears) { sql += ' AND e.years_experience >= ?'; params.push(minYears); }
    if (minRating) { sql += ' AND e.rating >= ?'; params.push(minRating); }
    sql += ' ORDER BY e.rating DESC';
    const rows = db.prepare(sql).all(...params);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/experts/specialties', (req, res) => {
  try {
    const { audience } = req.query;
    let sql = 'SELECT DISTINCT e.specialty FROM experts e WHERE 1=1';
    if (audience === 'company') {
      sql += ' AND COALESCE(e.list_in_company_directory, 0) = 1';
    } else {
      sql += ' AND COALESCE(e.list_in_student_app, 1) = 1';
    }
    const rows = db.prepare(sql).all();
    res.json(rows.map(r => r.specialty));
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/experts/by-user/:userId', (req, res) => {
  try {
    const uid = parseInt(req.params.userId, 10);
    if (isNaN(uid) || uid < 1) return res.status(400).json({ error: 'معرّف غير صالح' });
    const row = db.prepare('SELECT e.*, u.name FROM experts e JOIN users u ON e.user_id = u.id WHERE e.user_id = ?').get(uid);
    res.json(row || null);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/experts/:id', (req, res) => {
  try {
    const row = db.prepare('SELECT e.*, u.name FROM experts e JOIN users u ON e.user_id = u.id WHERE e.id = ?').get(req.params.id);
    if (!row) return res.status(404).json({ error: 'غير موجود' });
    res.json(row);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ============ Sessions ============
app.post('/api/sessions/book', (req, res) => {
  try {
    const { expertId, studentId, date, time } = req.body;
    const r = db.prepare('INSERT INTO sessions (expert_id, student_id, scheduled_date, scheduled_time) VALUES (?, ?, ?, ?)').run(expertId, studentId, date, time);
    res.json({ id: r.lastInsertRowid });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
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
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.patch('/api/sessions/:id/status', (req, res) => {
  try {
    const { status } = req.body;
    db.prepare('UPDATE sessions SET status = ? WHERE id = ?').run(status, req.params.id);
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/sessions/:id/rate', (req, res) => {
  try {
    const { raterId, ratedId, score } = req.body;
    db.prepare('INSERT INTO ratings (session_id, rater_id, rated_id, score) VALUES (?, ?, ?, ?)').run(req.params.id, raterId, ratedId, score);
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/sessions/:id/attendance', (req, res) => {
  try {
    const { userId } = req.body;
    const r = db.prepare('INSERT INTO session_attendance (session_id, user_id) VALUES (?, ?)').run(req.params.id, userId);
    res.json({ id: r.lastInsertRowid });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ============ Certificates ============
app.post('/api/certificates', (req, res) => {
  try {
    const { sessionId, userId, expertName, specialty, sessionDate } = req.body;
    const r = db.prepare('INSERT INTO certificates (session_id, user_id, expert_name, specialty, session_date) VALUES (?, ?, ?, ?, ?)').run(sessionId, userId, expertName, specialty, sessionDate);
    res.json({ id: r.lastInsertRowid });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ============ Notifications ============
app.get('/api/notifications/:userId', (req, res) => {
  try {
    const rows = db.prepare('SELECT * FROM notifications WHERE user_id IS NULL OR user_id = ? ORDER BY created_at DESC').all(req.params.userId);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ============ User ============
app.get('/api/users/:id', (req, res) => {
  try {
    const user = db.prepare(`
      SELECT u.*, r.name as role_name, COALESCE(e.is_verified, 0) as expert_verified
      FROM users u
      JOIN roles r ON u.role_id = r.id
      LEFT JOIN experts e ON e.user_id = u.id
      WHERE u.id = ?
    `).get(req.params.id);
    if (!user) return res.status(404).json({ error: 'غير موجود' });
    delete user.password;
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.patch('/api/users/:id', (req, res) => {
  try {
    const { name, password, phone, country, avatar } = req.body || {};
    const id = parseInt(req.params.id, 10);
    if (isNaN(id) || id < 1) return res.status(400).json({ error: 'معرّف غير صالح' });
    if (name) db.prepare('UPDATE users SET name = ? WHERE id = ?').run(name, id);
    if (password && String(password).length > 0) db.prepare('UPDATE users SET password = ? WHERE id = ?').run(password, id);
    if (phone !== undefined) db.prepare('UPDATE users SET phone = ? WHERE id = ?').run(phone == null ? null : String(phone), id);
    if (country !== undefined) db.prepare('UPDATE users SET country = ? WHERE id = ?').run(country == null ? null : String(country), id);
    if (avatar !== undefined) db.prepare('UPDATE users SET avatar = ? WHERE id = ?').run(avatar == null ? null : String(avatar), id);
    const user = db.prepare(`
      SELECT u.*, r.name as role_name, COALESCE(e.is_verified, 0) as expert_verified
      FROM users u
      JOIN roles r ON u.role_id = r.id
      LEFT JOIN experts e ON e.user_id = u.id
      WHERE u.id = ?
    `).get(id);
    if (user) delete user.password;
    res.json(user || { ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/users/:id', (req, res) => {
  try {
    db.prepare('DELETE FROM users WHERE id = ?').run(req.params.id);
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// مساعد: student_id من user_id
app.get('/api/students/by-user/:userId', (req, res) => {
  try {
    const row = db.prepare('SELECT id FROM students WHERE user_id = ?').get(req.params.userId);
    res.json(row ? { id: row.id } : null);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ============ Messages (التواصل مع الخبراء) ============
app.get('/api/messages/conversations/:userId', (req, res) => {
  try {
    const uid = parseInt(req.params.userId, 10);
    if (isNaN(uid) || uid < 1) return res.status(400).json({ error: 'معرّف غير صالح' });
    const rows = db.prepare(`
      SELECT u.id as other_user_id, u.name as other_user_name, MAX(m.created_at) as last_at
      FROM messages m
      JOIN users u ON u.id = CASE WHEN m.sender_id = ? THEN m.receiver_id ELSE m.sender_id END
      WHERE m.sender_id = ? OR m.receiver_id = ?
      GROUP BY u.id, u.name
      ORDER BY last_at DESC
    `).all(uid, uid, uid);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/messages/:userId/:otherUserId', (req, res) => {
  try {
    const uid = parseInt(req.params.userId, 10);
    const oid = parseInt(req.params.otherUserId, 10);
    if (isNaN(uid) || isNaN(oid) || uid < 1 || oid < 1) {
      return res.status(400).json({ error: 'معرّفات غير صالحة' });
    }
    const rows = db.prepare(`
      SELECT m.*, u.name as sender_name FROM messages m
      JOIN users u ON m.sender_id = u.id
      WHERE (m.sender_id = ? AND m.receiver_id = ?) OR (m.sender_id = ? AND m.receiver_id = ?)
      ORDER BY m.created_at ASC
    `).all(uid, oid, oid, uid);
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/messages', (req, res) => {
  try {
    const { senderId, receiverId, body } = req.body || {};
    const sid = senderId != null ? parseInt(senderId, 10) : NaN;
    const rid = receiverId != null ? parseInt(receiverId, 10) : NaN;
    const msgBody = typeof body === 'string' ? body.trim() : '';

    if (isNaN(sid) || sid < 1) {
      return res.status(400).json({ error: 'معرّف المرسِل غير صالح' });
    }
    if (isNaN(rid) || rid < 1) {
      return res.status(400).json({ error: 'معرّف المستلم غير صالح' });
    }
    if (msgBody.length === 0) {
      return res.status(400).json({ error: 'نص الرسالة فارغ' });
    }

    const r = db.prepare('INSERT INTO messages (sender_id, receiver_id, body) VALUES (?, ?, ?)').run(sid, rid, msgBody);
    const row = db.prepare('SELECT m.*, u.name as sender_name FROM messages m JOIN users u ON m.sender_id = u.id WHERE m.id = ?').get(r.lastInsertRowid);
    res.json(row || {});
  } catch (e) {
    console.error('[POST /api/messages] send error:', e);
    res.status(500).json({ error: e.message || 'خطأ في الخادم' });
  }
});

// مساعد: expert user_id من expert_id
app.get('/api/experts/:id/user', (req, res) => {
  try {
    const row = db.prepare('SELECT user_id FROM experts WHERE id = ?').get(req.params.id);
    res.json(row ? { userId: row.user_id } : null);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// ============ Admin (لوحة التحكم — يتطلب adminUserId لمستخدم بدور admin) ============
app.get('/api/admin/stats', (req, res) => {
  try {
    if (requireAdmin(req, res) == null) return;
    const totalUsers = db.prepare('SELECT COUNT(*) as c FROM users').get().c;
    const byRole = db.prepare(`
      SELECT r.name as role, COUNT(*) as c FROM users u JOIN roles r ON u.role_id = r.id GROUP BY r.name
    `).all();
    const totalSessions = db.prepare('SELECT COUNT(*) as c FROM sessions').get().c;
    const sessionsByStatus = db.prepare('SELECT status, COUNT(*) as c FROM sessions GROUP BY status').all();
    const totalMessages = db.prepare('SELECT COUNT(*) as c FROM messages').get().c;
    const totalNotifications = db.prepare('SELECT COUNT(*) as c FROM notifications').get().c;
    res.json({
      totalUsers,
      byRole,
      totalSessions,
      sessionsByStatus,
      totalMessages,
      totalNotifications,
    });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/admin/users', (req, res) => {
  try {
    if (requireAdmin(req, res) == null) return;
    const rows = db.prepare(`
      SELECT u.id, u.email, u.name, u.created_at, u.phone, COALESCE(u.is_blocked, 0) as is_blocked, r.name as role_name,
        COALESCE(e.is_verified, 0) as expert_verified
      FROM users u JOIN roles r ON u.role_id = r.id
      LEFT JOIN experts e ON e.user_id = u.id
      ORDER BY u.id DESC
    `).all();
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

/** إنشاء مستخدم من لوحة الإدارة — أي نص كبريد (بدون قيود شكل البريد) */
app.post('/api/admin/users', (req, res) => {
  try {
    if (requireAdmin(req, res) == null) return;
    const body = req.body || {};
    const email = typeof body.email === 'string' ? body.email.trim() : '';
    const password = typeof body.password === 'string' ? body.password : '';
    const name = typeof body.name === 'string' ? body.name.trim() : '';
    const roleId = parseInt(body.roleId, 10);
    if (!email) return res.status(400).json({ error: 'البريد أو المعرف مطلوب' });
    if (!name) return res.status(400).json({ error: 'الاسم مطلوب' });
    if (password.length < 6) return res.status(400).json({ error: 'كلمة المرور 6 أحرف على الأقل' });
    if (isNaN(roleId) || roleId < 1) return res.status(400).json({ error: 'دور غير صالح' });
    const roleRow = db.prepare('SELECT name FROM roles WHERE id = ?').get(roleId);
    if (!roleRow) return res.status(400).json({ error: 'دور غير موجود' });
    if (roleRow.name === 'admin') return res.status(403).json({ error: 'لا يمكن إنشاء حساب مدير من هنا' });
    if (roleRow.name === 'company_delegate') {
      return res.status(403).json({ error: 'أنشئ المفوّضين من تطبيق الشركة — لوحة مسؤول الشراكات' });
    }
    const exists = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
    if (exists) return res.status(400).json({ error: 'هذا المعرف مستخدم مسبقاً' });
    const r = db.prepare('INSERT INTO users (email, password, role_id, name) VALUES (?, ?, ?, ?)').run(email, password, roleId, name);
    const user = db.prepare('SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?').get(r.lastInsertRowid);
    delete user.password;
    if (roleRow.name === 'student') db.prepare('INSERT INTO students (user_id) VALUES (?)').run(user.id);
    if (roleRow.name === 'expert') {
      try {
        db.prepare('INSERT INTO experts (user_id, specialty, is_verified, list_in_student_app, list_in_company_directory) VALUES (?, ?, 0, 1, 0)').run(user.id, 'تخصص افتراضي');
      } catch (_) {
        db.prepare('INSERT INTO experts (user_id, specialty, is_verified) VALUES (?, ?, 0)').run(user.id, 'تخصص افتراضي');
      }
    }
    if (roleRow.name === 'company' || roleRow.name === 'company_manager') {
      const cn = roleRow.name === 'company_manager' ? 'مسؤول شراكات' : 'شركة';
      db.prepare('INSERT INTO companies (user_id, company_name) VALUES (?, ?)').run(user.id, cn);
    }
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/admin/user/:userId', (req, res) => {
  try {
    if (requireAdmin(req, res) == null) return;
    const uid = parseInt(req.params.userId, 10);
    if (isNaN(uid) || uid < 1) return res.status(400).json({ error: 'معرّف غير صالح' });
    const row = db.prepare(`
      SELECT u.id, u.email, u.name, u.created_at, u.role_id, u.phone, u.country, u.avatar,
        COALESCE(u.is_blocked, 0) as is_blocked, r.name as role_name,
        COALESCE(e.is_verified, 0) as expert_verified
      FROM users u JOIN roles r ON u.role_id = r.id
      LEFT JOIN experts e ON e.user_id = u.id
      WHERE u.id = ?
    `).get(uid);
    if (!row) return res.status(404).json({ error: 'غير موجود' });
    res.json(row);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.patch('/api/admin/user/:userId', (req, res) => {
  try {
    const adminId = requireAdmin(req, res);
    if (adminId == null) return;
    const targetId = parseInt(req.params.userId, 10);
    if (isNaN(targetId) || targetId < 1) return res.status(400).json({ error: 'معرّف غير صالح' });
    const body = req.body || {};
    const { name, email, roleId, password, phone, country, isBlocked, expertVerified } = body;

    if (targetId === adminId && (isBlocked === true || isBlocked === 1)) {
      return res.status(400).json({ error: 'لا يمكنك تقييد حسابك' });
    }

    const target = db.prepare(`SELECT u.id, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?`).get(targetId);
    if (!target) return res.status(404).json({ error: 'غير موجود' });

    if (roleId !== undefined && roleId !== null) {
      const rid = parseInt(roleId, 10);
      if (isNaN(rid) || rid < 1) return res.status(400).json({ error: 'دور غير صالح' });
      const roleRow = db.prepare('SELECT name FROM roles WHERE id = ?').get(rid);
      if (!roleRow) return res.status(400).json({ error: 'دور غير موجود' });
      if (roleRow.name === 'admin') return res.status(403).json({ error: 'لا يمكن تعيين دور مدير من التطبيق' });
      if (target.role_name === 'admin') {
        const adminCount = db.prepare(`SELECT COUNT(*) as c FROM users u JOIN roles r ON u.role_id = r.id WHERE r.name = 'admin'`).get().c;
        if (adminCount <= 1) return res.status(400).json({ error: 'لا يمكن تغيير دور آخر مدير' });
      }
      db.prepare('UPDATE users SET role_id = ? WHERE id = ?').run(rid, targetId);
      ensureUserProfile(targetId, roleRow.name);
    }

    if (name !== undefined) db.prepare('UPDATE users SET name = ? WHERE id = ?').run(String(name).trim(), targetId);
    if (email !== undefined) {
      const em = String(email).trim();
      const dup = db.prepare('SELECT id FROM users WHERE email = ? AND id != ?').get(em, targetId);
      if (dup) return res.status(400).json({ error: 'البريد مستخدم مسبقاً' });
      db.prepare('UPDATE users SET email = ? WHERE id = ?').run(em, targetId);
    }
    if (password !== undefined && String(password).length > 0) {
      db.prepare('UPDATE users SET password = ? WHERE id = ?').run(String(password), targetId);
    }
    if (phone !== undefined) db.prepare('UPDATE users SET phone = ? WHERE id = ?').run(phone == null ? null : String(phone), targetId);
    if (country !== undefined) db.prepare('UPDATE users SET country = ? WHERE id = ?').run(country == null ? null : String(country), targetId);
    if (isBlocked !== undefined) {
      const b = isBlocked === true || isBlocked === 1 || isBlocked === '1';
      db.prepare('UPDATE users SET is_blocked = ? WHERE id = ?').run(b ? 1 : 0, targetId);
    }

    if (expertVerified !== undefined) {
      const exp = db.prepare('SELECT id FROM experts WHERE user_id = ?').get(targetId);
      if (exp) {
        const v = expertVerified === true || expertVerified === 1 || expertVerified === '1';
        db.prepare('UPDATE experts SET is_verified = ? WHERE user_id = ?').run(v ? 1 : 0, targetId);
      }
    }

    const row = db.prepare(`
      SELECT u.id, u.email, u.name, u.created_at, u.role_id, u.phone, u.country, u.avatar,
        COALESCE(u.is_blocked, 0) as is_blocked, r.name as role_name,
        COALESCE(e.is_verified, 0) as expert_verified
      FROM users u JOIN roles r ON u.role_id = r.id
      LEFT JOIN experts e ON e.user_id = u.id
      WHERE u.id = ?
    `).get(targetId);
    res.json(row);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.delete('/api/admin/user/:userId', (req, res) => {
  try {
    const adminId = requireAdmin(req, res);
    if (adminId == null) return;
    const targetId = parseInt(req.params.userId, 10);
    if (isNaN(targetId) || targetId < 1) return res.status(400).json({ error: 'معرّف غير صالح' });
    if (targetId === adminId) return res.status(400).json({ error: 'لا يمكن حذف حسابك' });
    const target = db.prepare(`SELECT r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?`).get(targetId);
    if (!target) return res.status(404).json({ error: 'غير موجود' });
    if (target.role_name === 'admin') {
      const adminCount = db.prepare(`SELECT COUNT(*) as c FROM users u JOIN roles r ON u.role_id = r.id WHERE r.name = 'admin'`).get().c;
      if (adminCount <= 1) return res.status(400).json({ error: 'لا يمكن حذف آخر مدير' });
    }
    db.prepare('DELETE FROM users WHERE id = ?').run(targetId);
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/admin/sessions', (req, res) => {
  try {
    if (requireAdmin(req, res) == null) return;
    const rows = db.prepare(`
      SELECT s.*,
        eu.name as expert_name,
        e.specialty,
        su.name as student_name
      FROM sessions s
      JOIN experts e ON s.expert_id = e.id
      JOIN users eu ON e.user_id = eu.id
      JOIN students st ON s.student_id = st.id
      JOIN users su ON st.user_id = su.id
      ORDER BY s.scheduled_date DESC, s.scheduled_time DESC
    `).all();
    res.json(rows);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.post('/api/admin/notifications', (req, res) => {
  try {
    if (requireAdmin(req, res) == null) return;
    const { title, body, userId } = req.body || {};
    const t = typeof title === 'string' ? title.trim() : '';
    if (!t) return res.status(400).json({ error: 'عنوان الإشعار مطلوب' });
    const b = body == null ? null : String(body);
    if (userId == null || userId === '') {
      db.prepare('INSERT INTO notifications (user_id, title, body) VALUES (NULL, ?, ?)').run(t, b);
    } else {
      const uid = parseInt(userId, 10);
      if (isNaN(uid) || uid < 1) return res.status(400).json({ error: 'معرّف المستخدم غير صالح' });
      db.prepare('INSERT INTO notifications (user_id, title, body) VALUES (?, ?, ?)').run(uid, t, b);
    }
    res.json({ ok: true });
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

// Flutter Web: نفس النطاق = رابط واحد (API + واجهة) — مجلد web من `flutter build web` أو Docker
const webRoot = path.join(__dirname, 'web');
if (fs.existsSync(path.join(webRoot, 'index.html'))) {
  app.use(
    express.static(webRoot, {
      maxAge: '1d',
      index: false,
    })
  );
  app.use((req, res, next) => {
    if (req.method !== 'GET' && req.method !== 'HEAD') return next();
    if (req.path.startsWith('/api')) {
      return res.status(404).json({ error: 'not found' });
    }
    if (path.extname(req.path) !== '' && !req.path.endsWith('/')) {
      return res.status(404).send('Not found');
    }
    return res.sendFile(path.join(webRoot, 'index.html'));
  });
}

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Khibarti listening on port ${PORT}`);
  if (fs.existsSync(path.join(webRoot, 'index.html'))) {
    console.log('Serving Flutter web from', webRoot);
  }
  console.log('API: /api/...  |  Android emulator API base: http://10.0.2.2:' + PORT);
});
