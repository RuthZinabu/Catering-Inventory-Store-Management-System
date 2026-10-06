@echo off
echo Installing flutter_launcher_icons package...
call flutter pub get

echo.
echo Generating app icons for Android and iOS...
call dart run flutter_launcher_icons

echo.
echo Icon generation complete!
echo.
echo Next steps:
echo 1. For Android: Icons are ready to use
echo 2. For iOS: You may need to run 'flutter clean' and rebuild
echo.
pause
