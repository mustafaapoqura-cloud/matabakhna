<?php
// backend/database/clear_db.php
require_once __DIR__ . '/../config/database.php';

$db = Database::getConnection();
$db->exec("DELETE FROM recipes;");
$db->exec("DELETE FROM shopping_items;");
$db->exec("UPDATE weekly_plan SET recipeId = NULL;");

echo json_encode([
    'success' => true,
    'message' => 'تم مسح جميع الوصفات والعناصر التجريبية بنجاح. قاعدة البيانات جاهزة الآن وخالية تماماً لتقوم أنت بإضافة أكلاتك وصورك الخاصة!'
], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
