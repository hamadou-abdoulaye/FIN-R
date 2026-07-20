@echo off
echo 🚀 Construction du frontend pour InfinityFree
echo ==============================================
echo.

cd finr-app

echo 📦 Installation des dependances...
call npm install --legacy-peer-deps

echo.
echo 🔨 Construction de l'application React...
call npm run build

echo.
echo 📤 Copie du build vers le backend Laravel...
cd ..
xcopy /E /I /Y finr-app\build\* finr-api\public\

echo.
echo ✅ Frontend copie dans finr-api/public/
echo.
echo 🎉 Termine ! Le frontend sera accessible via le backend Laravel
echo.
pause