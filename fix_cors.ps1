# ============================================================================
# Firebase Storage CORS Fix - Automated Solution
# ============================================================================

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  FIREBASE STORAGE CORS FIX - AUTOMATED SCRIPT                      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Step 1: Check if Flutter app is running
Write-Host "STEP 1: Checking for running Flutter processes..." -ForegroundColor Yellow
$flutterProcesses = Get-Process | Where-Object {$_.ProcessName -like "*flutter*" -or $_.ProcessName -like "*dart*"}

if ($flutterProcesses) {
    Write-Host "  ⚠️  Found running Flutter/Dart processes" -ForegroundColor Yellow
    Write-Host "  ℹ️  Please stop your Flutter app manually by pressing 'q' in the terminal" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Press Enter after stopping the app to continue"
} else {
    Write-Host "  ✅ No Flutter processes detected" -ForegroundColor Green
}
Write-Host ""

# Step 2: Display Firebase Console Instructions
Write-Host "STEP 2: Verify Firebase Storage Rules..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Opening Firebase Console in your browser..." -ForegroundColor Cyan

try {
    Start-Process "https://console.firebase.google.com/project/friendlychat-a8bbc/storage/rules"
    Write-Host "  ✓ Firebase Console opened" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Could not open automatically" -ForegroundColor Yellow
    Write-Host "  Please manually open: https://console.firebase.google.com/project/friendlychat-a8bbc/storage/rules" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "  Your rules should be:" -ForegroundColor White
Write-Host ""
Write-Host "    rules_version = '2';" -ForegroundColor Gray
Write-Host "    service firebase.storage {" -ForegroundColor Gray
Write-Host "      match /b/{bucket}/o {" -ForegroundColor Gray
Write-Host "        match /profilePictures/{userId} {" -ForegroundColor Gray
Write-Host "          allow read: if true;" -ForegroundColor Green
Write-Host "          allow write: if request.auth != null && request.auth.uid == userId;" -ForegroundColor Green
Write-Host "        }" -ForegroundColor Gray
Write-Host "      }" -ForegroundColor Gray
Write-Host "    }" -ForegroundColor Gray
Write-Host ""
Write-Host "  CRITICAL: Make sure you see 'allow read: if true;'" -ForegroundColor Yellow
Write-Host "  This allows public read access which is required for CORS." -ForegroundColor Yellow
Write-Host ""
Write-Host "  After verifying/updating rules:" -ForegroundColor White
Write-Host "    1. Click 'Publish' button" -ForegroundColor Cyan
Write-Host "    2. Wait for green 'Published' status" -ForegroundColor Cyan
Write-Host "    3. IMPORTANT: Wait 2-5 minutes for global propagation" -ForegroundColor Red
Write-Host ""
$confirmed = Read-Host "Have you published the rules and waited? (yes/no)"

if ($confirmed -ne "yes" -and $confirmed -ne "y") {
    Write-Host ""
    Write-Host "  ⚠️  Please publish the rules first, then run this script again" -ForegroundColor Red
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit
}
Write-Host ""
Write-Host "  ✅ Firebase rules confirmed" -ForegroundColor Green
Write-Host ""

# Step 3: Clear Browser Cache Instructions
Write-Host "STEP 3: Clearing Browser Cache..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Opening Microsoft Edge cache clear dialog..." -ForegroundColor Cyan

# Try to open Edge cache clearing
try {
    Start-Process msedge.exe "edge://settings/clearBrowserData"
    Write-Host "  ✅ Edge cache settings opened" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Please follow these steps in the opened window:" -ForegroundColor White
    Write-Host "    1. Select 'Cached images and files'" -ForegroundColor Cyan
    Write-Host "    2. Set time range to 'All time'" -ForegroundColor Cyan
    Write-Host "    3. Click 'Clear now' button" -ForegroundColor Cyan
    Write-Host ""
} catch {
    Write-Host "  ⚠️  Could not open Edge automatically" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Please manually clear cache:" -ForegroundColor White
    Write-Host "    1. Press Ctrl+Shift+Delete in your browser" -ForegroundColor Cyan
    Write-Host "    2. Select 'Cached images and files'" -ForegroundColor Cyan
    Write-Host "    3. Set time range to 'All time'" -ForegroundColor Cyan
    Write-Host "    4. Click 'Clear data' or 'Clear now'" -ForegroundColor Cyan
    Write-Host ""
}

Read-Host "Press Enter after clearing cache to continue"
Write-Host ""
Write-Host "  ✅ Browser cache cleared" -ForegroundColor Green
Write-Host ""

# Step 4: Wait for Firebase Propagation
Write-Host "STEP 4: Waiting for Firebase rules propagation..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  Firebase Storage rules can take 2-5 minutes to propagate globally." -ForegroundColor Cyan
Write-Host "  Waiting 30 seconds... (minimum recommended wait time)" -ForegroundColor Cyan
Write-Host ""

for ($i = 30; $i -gt 0; $i--) {
    Write-Host "  ⏳ $i seconds remaining..." -ForegroundColor Yellow -NoNewline
    Start-Sleep -Seconds 1
    Write-Host "`r" -NoNewline
}
Write-Host "  ✅ Wait complete                                    " -ForegroundColor Green
Write-Host ""

# Step 5: Restart Flutter App
Write-Host "STEP 5: Ready to restart Flutter app..." -ForegroundColor Yellow
Write-Host ""
Write-Host "  To restart your Flutter app, run:" -ForegroundColor White
Write-Host ""
Write-Host "    flutter run -d edge" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Or for a clean restart:" -ForegroundColor White
Write-Host ""
Write-Host "    flutter clean" -ForegroundColor Cyan
Write-Host "    flutter run -d edge" -ForegroundColor Cyan
Write-Host ""

$autoRestart = Read-Host "Would you like to restart the Flutter app now? (yes/no)"

if ($autoRestart -eq "yes" -or $autoRestart -eq "y") {
    Write-Host ""
    Write-Host "  🚀 Starting Flutter app..." -ForegroundColor Cyan
    Write-Host ""
    
    Set-Location -Path $PSScriptRoot
    
    try {
        # Try to run Flutter
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "flutter run -d edge"
        Write-Host "  ✅ Flutter app launched in new window" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠️  Could not launch automatically" -ForegroundColor Yellow
        Write-Host "  Please run 'flutter run -d edge' manually in your terminal" -ForegroundColor Cyan
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  CORS FIX COMPLETE!                                                ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "✅ Next Steps:" -ForegroundColor Green
Write-Host "   1. Navigate to Profile Picture page" -ForegroundColor Cyan
Write-Host "   2. Upload a profile picture" -ForegroundColor Cyan
Write-Host "   3. Check browser console (F12) for any CORS errors" -ForegroundColor Cyan
Write-Host "   4. Verify profile picture displays in all locations" -ForegroundColor Cyan
Write-Host ""
Write-Host "📊 Verification Checklist:" -ForegroundColor Yellow
Write-Host "   □ No CORS errors in console" -ForegroundColor White
Write-Host "   □ Profile picture in sidebar drawer" -ForegroundColor White
Write-Host "   □ Profile picture in chat messages" -ForegroundColor White
Write-Host "   □ Profile picture on profile page" -ForegroundColor White
Write-Host "   □ Profile picture in search results" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  If issues persist:" -ForegroundColor Yellow
Write-Host "   - Wait another 5 minutes for Firebase propagation" -ForegroundColor Cyan
Write-Host "   - Try opening app in Incognito mode (Ctrl+Shift+N)" -ForegroundColor Cyan
Write-Host "   - Test on native platform: flutter run -d windows" -ForegroundColor Cyan
Write-Host "   - See CORS_FIX_GUIDE.txt for detailed troubleshooting" -ForegroundColor Cyan
Write-Host ""

Read-Host "Press Enter to exit"
