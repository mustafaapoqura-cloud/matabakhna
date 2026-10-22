@echo off
title تشغيل منصة طبختنا (PHP Backend + React Dashboard)
echo ===================================================================
echo             تشغيل منصة طبختنا (الباك إند والداشبورد)
echo ===================================================================
echo.
echo [1/2] جاري تشغيل الباك إند PHP على http://localhost:8000 ...
start "Matabakhna PHP Backend" cmd /k "cd /d "%~dp0backend" && php -S 0.0.0.0:8000"

echo [2/2] جاري تشغيل داشبورد React على http://localhost:5173 ...
start "Matabakhna React Dashboard" cmd /k "cd /d "%~dp0dashboard" && npm run dev"

echo.
echo ===================================================================
echo تم تشغيل جميع الخدمات بنجاح!
echo - رابط لوحة التحكم (الداشبورد): http://localhost:5173
echo - رابط الباك إند (REST API):     http://localhost:8000
echo - تطبيق الموبايل (Flutter): جاهز ومتصل تلقائياً بالباك إند.
echo ===================================================================
pause
