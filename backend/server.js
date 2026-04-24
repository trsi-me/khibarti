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
    CREATE TABLE IF NOT EXISTS experts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, specialty TEXT NOT NULL, years_experience INTEGER DEFAULT 0, rating REAL DEFAULT 0, sessions_count INTEGER DEFAULT 0, bio TEXT);
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
        (3, 1, '2026-03-05', '09:00', 'upcoming'),
        (4, 1, '2026-03-10', '16:00', 'upcoming'),
        (1, 1, '2026-02-20', '11:00', 'completed'),
        (2, 1, '2026-02-15', '14:00', 'completed'),
        (5, 1, '2026-02-10', '10:30', 'completed');
      INSERT INTO notifications (user_id, title, body) VALUES 
        (NULL, 'مرحباً بك في خبرتي', 'منصة تدريبية تربط الخبراء بالطلاب والشركات'),
        (1, 'جلسة قادمة', 'لديك جلسة مع أحمد محمد غداً الساعة 10:00'),
        (1, 'تذكير', 'أكمل ملفك الشخصي للاستفادة من جميع الميزات'),
        (1, 'ترحيب', 'مرحباً بك في خبرتي! استكشف الخبراء واحجز جلساتك الأولى'),
        (1, 'جلسة جديدة', 'تم تأكيد حجزك مع سارة علي يوم 1 مارس'),
        (1, 'تقييم', 'قيم جلستك الأخيرة مع خالد حسن لمساعدتنا على التحسن'),
        (2, 'جلسة قادمة', 'لديك جلسة مع طالب تجريبي غداً 10:00'),
        (2, 'تحديث المنصة', 'تم إضافة ميزات جديدة للتطبيق'),
        (2, 'إحصائيات', 'أكملت 42 جلسة هذا الشهر - أحسنت!'),
        (3, 'نظرة عامة', 'لديك 6 خبراء و 15 جلسة نشطة على المنصة'),
        (3, 'ترحيب', 'مرحباً بشركتك في منصة خبرتي للتدريب والتطوير'),
        (3, 'تواصل مع الخبراء', 'يمكنك التواصل مع أي خبير عبر زر المحادثة في بطاقة الخبير'),
        (3, 'إشعار إعلان', 'ورشة عمل جديدة في الذكاء الاصطناعي مع خبير عمر يوسف - تواصل معه للمزيد'),
        (3, 'تحديث أسبوعي', 'تم تنفيذ 23 جلسة هذا الأسبوع عبر منصة خبرتي'),
        (3, 'فرص شراكات', 'خبير التسويق سارة علي متاحة لشراكات تدريب موظفيك');
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

// إشعار افتراضي عام — يظهر لجميع المستخدمين
function migrateNotifications() {
  const hasGlobal = db.prepare('SELECT 1 FROM notifications WHERE user_id IS NULL LIMIT 1').get();
  if (!hasGlobal) {
    try { db.prepare('INSERT INTO notifications (user_id, title, body) VALUES (NULL, ?, ?)').run('مرحباً بك في خبرتي', 'منصة تدريبية تربط الخبراء بالطلاب والشركات'); } catch (_) { }
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
    const user = db.prepare('SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.email = ? AND u.password = ?').get(email, password);
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
    if (roleRow && roleRow.name === 'admin') {
      return res.status(403).json({ error: 'لا يمكن إنشاء حساب مدير من التطبيق' });
    }
    const exists = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
    if (exists) return res.status(400).json({ error: 'البريد مستخدم مسبقاً' });
    const r = db.prepare('INSERT INTO users (email, password, role_id, name) VALUES (?, ?, ?, ?)').run(email, password, roleId, name);
    const user = db.prepare('SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?').get(r.lastInsertRowid);
    delete user.password;
    if (roleId === 1) db.prepare('INSERT INTO students (user_id) VALUES (?)').run(user.id);
    if (roleId === 2) db.prepare('INSERT INTO experts (user_id, specialty) VALUES (?, ?)').run(user.id, 'تخصص افتراضي');
    if (roleId === 3) db.prepare('INSERT INTO companies (user_id, company_name) VALUES (?, ?)').run(user.id, 'شركة');
    res.json(user);
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
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
  } catch (e) {
    res.status(500).json({ error: e.message });
  }
});

app.get('/api/experts/specialties', (req, res) => {
  try {
    const rows = db.prepare('SELECT DISTINCT specialty FROM experts').all();
    res.json(rows.map(r => r.specialty));
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
    const user = db.prepare('SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?').get(req.params.id);
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
    const user = db.prepare('SELECT u.*, r.name as role_name FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?').get(id);
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
      SELECT u.id, u.email, u.name, u.created_at, u.phone, COALESCE(u.is_blocked, 0) as is_blocked, r.name as role_name
      FROM users u JOIN roles r ON u.role_id = r.id
      ORDER BY u.id DESC
    `).all();
    res.json(rows);
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
        COALESCE(u.is_blocked, 0) as is_blocked, r.name as role_name
      FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?
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
    const { name, email, roleId, password, phone, country, isBlocked } = body;

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

    const row = db.prepare(`
      SELECT u.id, u.email, u.name, u.created_at, u.role_id, u.phone, u.country, u.avatar,
        COALESCE(u.is_blocked, 0) as is_blocked, r.name as role_name
      FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?
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
