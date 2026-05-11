#Requires -Version 5.1
# ينسخ مخرجات `flutter build web` إلى backend/web (نفس مكان الـ API = رابط واحد محلياً وعند النشر)
# الاستخدام: من جذر المشروع:  .\publish_flutter_web.ps1
#   اختياري:  .\publish_flutter_web.ps1 -WebDebug  (بناء ديبغ بدل release)
#   تخطي pub get:  -SkipPubGet
#   ملاحظة: لا نستخدم اسم -Debug لأنه محجوز في PowerShell

[CmdletBinding()]
param(
  [switch]$WebDebug,
  [switch]$SkipPubGet
)

$ErrorActionPreference = 'Stop'
$Root = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
Set-Location -LiteralPath $Root

$src = Join-Path $Root 'build\web'
$dst = Join-Path $Root 'backend\web'

Write-Host "[khibarti] Project: $Root" -ForegroundColor Cyan
Write-Host "[khibarti] Target:  $dst" -ForegroundColor Cyan

if (-not $SkipPubGet) {
  Write-Host ">> flutter pub get" -ForegroundColor Yellow
  flutter pub get
}

# تشكيل العربية في PDF (حزمة pdf): https://pub.dev/packages/pdf — use_arabic
$PdfArabicDefine = '--dart-define=use_arabic=true'

if ($WebDebug) {
  Write-Host ">> flutter build web (debug, canvas kit)" -ForegroundColor Yellow
  flutter build web $PdfArabicDefine
} else {
  Write-Host ">> flutter build web --release" -ForegroundColor Yellow
  flutter build web --release $PdfArabicDefine
}

$index = Join-Path $src 'index.html'
if (-not (Test-Path -LiteralPath $index)) {
  throw "Build failed: missing $index"
}

# استبدال كامل: حذف النسخة السابقة ثم نسخ الجديد
if (Test-Path -LiteralPath $dst) {
  Write-Host ">> Removing old backend\web" -ForegroundColor DarkGray
  Remove-Item -LiteralPath $dst -Recurse -Force
}
New-Item -ItemType Directory -Path $dst -Force | Out-Null
Copy-Item -Path (Join-Path $src '*') -Destination $dst -Recurse -Force

Write-Host '>> OK - Flutter web copied to backend\web' -ForegroundColor Green
Write-Host '   Test:  cd backend; npm start  |  http://localhost:3000' -ForegroundColor Gray
Write-Host '   API:   http://localhost:3000/api/health' -ForegroundColor Gray
Write-Host '   Render: commit folder backend\web (git add backend\web) then push - no build on server' -ForegroundColor DarkYellow
