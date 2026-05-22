import admin from 'firebase-admin';

let initialized = false;

function isPlaceholder(value) {
  if (!value) return true;
  const v = value.trim().toLowerCase();
  return v.startsWith('your-') || v.includes('ornek') || v === 'changeme';
}

function canVerifyTokens() {
  const projectId = process.env.FIREBASE_PROJECT_ID?.trim();
  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT?.trim();
  return Boolean(projectId && !isPlaceholder(projectId) && serviceAccount);
}

function initFirebaseAdmin() {
  if (initialized) return true;
  if (!canVerifyTokens()) return false;

  const projectId = process.env.FIREBASE_PROJECT_ID.trim();
  const serviceAccountJson = process.env.FIREBASE_SERVICE_ACCOUNT.trim();

  try {
    const cred =
      serviceAccountJson.startsWith('{')
        ? JSON.parse(serviceAccountJson)
        : JSON.parse(Buffer.from(serviceAccountJson, 'base64').toString('utf8'));

    admin.initializeApp({
      credential: admin.credential.cert(cred),
      projectId,
    });
    initialized = true;
    return true;
  } catch (err) {
    console.warn('Firebase Admin başlatılamadı:', err.message);
    return false;
  }
}

export async function verifyFirebaseToken(req, res, next) {
  const authHeader = req.headers.authorization;
  const isProduction = process.env.NODE_ENV === 'production';

  // Geliştirme: service account yoksa token doğrulama atlanır
  if (!isProduction && !canVerifyTokens()) {
    req.user = { uid: 'dev-user' };
    return next();
  }

  if (!authHeader?.startsWith('Bearer ')) {
    if (isProduction) {
      return res.status(401).json({ error: 'Yetkilendirme gerekli' });
    }
    req.user = { uid: 'dev-user' };
    return next();
  }

  const token = authHeader.slice(7);

  if (!initFirebaseAdmin()) {
    if (isProduction) {
      return res.status(503).json({
        error: 'Kimlik doğrulama servisi yapılandırılmamış',
      });
    }
    req.user = { uid: 'dev-user' };
    return next();
  }

  try {
    const decoded = await admin.auth().verifyIdToken(token);
    req.user = { uid: decoded.uid, email: decoded.email };
    next();
  } catch (err) {
    console.warn('Token doğrulama hatası:', err.message);
    if (isProduction) {
      return res.status(401).json({ error: 'Geçersiz veya süresi dolmuş oturum' });
    }
    // Dev + doğrulama başarısız: yine de devam et (local test)
    req.user = { uid: 'dev-user' };
    next();
  }
}
