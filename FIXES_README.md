# دليل إصلاح مشاكل البناء — Mazen Coach v8.2.0

## ملخص المشاكل والحلول

---

## المشكلة 1: تعارض إصدار `intl` (Failed to install dependencies)

**الخطأ:**
```
mavix_coach depends on intl ^0.20.2, version solving failed
```

**السبب:** Flutter SDK يثبّت `intl` على إصدار محدد بحسب إصدار Flutter المستخدم.

**الحل:** في `pubspec.yaml` تأكد أن:
```yaml
intl: ^0.19.0   # ← يجب أن يبقى هكذا، لا تغيّره إلى ^0.20.2
```

**ملف المصلح:** `pubspec.yaml`

---

## المشكلة 2: خطوط Cairo مفقودة (Failed to bundle asset files)

**الخطأ:**
```
Error: unable to locate asset entry in pubspec.yaml: 'assets/fonts/Cairo-Regular.ttf'
```

**السبب:** ملفات الخطوط غير موجودة في المشروع (لم تُحمَّل من Google Fonts).

**الحل:** استخدام `google_fonts` package بدلاً من الخطوط المحلية — تُحمَّل تلقائياً.

**الخطوات:**
1. استبدل `pubspec.yaml` بالملف المصلح (يضيف `google_fonts: ^6.2.1`)
2. استبدل `lib/core/theme/app_theme.dart` بالملف المصلح
3. شغّل: `flutter pub get`

**ملفات المصلحة:**
- `pubspec.yaml`
- `lib/core/theme/app_theme.dart`

---

## المشكلة 3: `CardThemeData` غير موجودة (Method not found)

**الخطأ:**
```
Error: Method not found: 'CardThemeData'
```

**السبب:** `CardThemeData` أُضيفت في Flutter 3.16، وبعض بيئات Codemagic تستخدم إصداراً أقدم.

**الحل:** استخدام `CardTheme(...)` بدلاً من `CardThemeData(...)` — متوافق مع جميع الإصدارات.

**ملف المصلح:** `lib/core/theme/app_theme.dart`

---

## المشكلة 4: إصدار Kotlin قديم (Unresolved reference في Gradle)

**الخطأ:**
```
Unresolved reference: FilePermissions
Unresolved reference: user, read, write
```

**السبب:** Kotlin 1.9.10 قديم ويتعارض مع إصدارات Flutter الحديثة وAGP 8.x.

**الحل:** ترقية Kotlin من 1.9.10 إلى 1.9.22.

**ملفات المصلحة:**
- `android/build.gradle` (kotlin_version = '1.9.22')
- `android/settings.gradle` (org.jetbrains.kotlin.android version "1.9.22")
- `android/app/build.gradle` (jvmTarget = '11', compileSdk 35)

---

## المشكلة 5: `ic_launcher_round` مفقود (Resource not found)

**الخطأ:**
```
error: resource mipmap/ic_launcher_round not found
```

**السبب:** الـ AndroidManifest يشير إلى `@mipmap/ic_launcher_round` لكن الأيقونة غير موجودة في المشروع.

**الحل:** تغيير `android:roundIcon` ليستخدم نفس `ic_launcher` العادي.

**ملف المصلح:** `android/app/src/main/AndroidManifest.xml`

---

## المشكلة 6: خطأ 303 في الاتصال بالسيرفر (Google Apps Script)

**الخطأ في التطبيق:**
```
خطأ في الاتصال: 303
```

**السبب:** Google Apps Script يعيد redirect بكود 303 عند استقبال POST، وpackage `http` في Flutter لا يتابع هذا الـ redirect تلقائياً.

**الحل:** متابعة الـ redirect يدوياً — نرسل POST، وإذا جاء 302/303 نتابع بـ GET.

**ملف المصلح:** `lib/data/remote/gas_api_service.dart`

---

## خطوات التطبيق الكاملة

### الخطوة 1: استبدال الملفات
انسخ الملفات من مجلد `mavix_fixes/` إلى مشروعك:

```bash
# من داخل مجلد mavix_flutter
cp mavix_fixes/pubspec.yaml .
cp mavix_fixes/android/build.gradle android/
cp mavix_fixes/android/settings.gradle android/
cp mavix_fixes/android/app/build.gradle android/app/
cp mavix_fixes/android/gradle.properties android/
cp mavix_fixes/android/app/proguard-rules.pro android/app/
cp mavix_fixes/android/app/src/main/AndroidManifest.xml android/app/src/main/
cp mavix_fixes/lib/data/remote/gas_api_service.dart lib/data/remote/
cp mavix_fixes/lib/core/theme/app_theme.dart lib/core/theme/
```

### الخطوة 2: إضافة صورة أيقونة مؤقتة
```bash
# أضف أي صورة PNG بحجم 512x512 في:
assets/images/launcher_icon.png
```

### الخطوة 3: إضافة ملف `codemagic.yaml`
انسخ `mavix_fixes/codemagic.yaml` إلى جذر المشروع وعدّل الإيميل.

### الخطوة 4: تحديث المكتبات وبناء
```bash
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

### الخطوة 5: رفع التغييرات على GitHub
```bash
git add -A
git commit -m "fix: resolve build errors and GAS 303 redirect"
git push
```
ثم شغّل build جديد على Codemagic.

---

## ملاحظة مهمة بشأن Google Apps Script

تأكد أن سكريبت GAS يستقبل كلاً من `doGet` و`doPost`:

```javascript
function doGet(e) {
  return doPost(e); // أعد التوجيه إلى doPost
}

function doPost(e) {
  const data = JSON.parse(e.parameter.data || '{}');
  // ... باقي الكود
}
```
