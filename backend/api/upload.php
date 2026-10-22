<?php
// backend/api/upload.php
require_once __DIR__ . '/../config/cors.php';

// Ensure uploads folder exists
$uploadDir = __DIR__ . '/../uploads';
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'طريقة الطلب غير مسموح بها']);
    exit();
}

if (!isset($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) {
    $errorMsg = 'لم يتم تحديد أي ملف للرفع أو حدث خطأ أثناء الرفع';
    if (isset($_FILES['image']['error'])) {
        switch ($_FILES['image']['error']) {
            case UPLOAD_ERR_INI_SIZE:
            case UPLOAD_ERR_FORM_SIZE:
                $errorMsg = 'حجم الصورة كبير جداً، الحد الأقصى 15 ميجابايت';
                break;
            case UPLOAD_ERR_NO_FILE:
                $errorMsg = 'لم يتم اختيار ملف';
                break;
        }
    }
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => $errorMsg], JSON_UNESCAPED_UNICODE);
    exit();
}

$file = $_FILES['image'];
$allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'image/jpg'];

// Validate MIME type
$finfo = new finfo(FILEINFO_MIME_TYPE);
$mime = $finfo->file($file['tmp_name']);

if (!in_array($mime, $allowedTypes)) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'نوع الملف غير مدعوم، يرجى رفع صورة (JPG, PNG, WEBP)'], JSON_UNESCAPED_UNICODE);
    exit();
}

// Generate safe unique filename
$ext = pathinfo($file['name'], PATHINFO_EXTENSION);
if (empty($ext)) {
    $ext = ($mime === 'image/png') ? 'png' : (($mime === 'image/webp') ? 'webp' : 'jpg');
}
$newFilename = 'recipe_' . time() . '_' . bin2hex(random_bytes(4)) . '.' . strtolower($ext);
$targetPath = $uploadDir . '/' . $newFilename;

if (move_uploaded_file($file['tmp_name'], $targetPath)) {
    // Determine public URL
    $host = $_SERVER['HTTP_HOST'] ?? 'localhost:8000';
    $protocol = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off') ? "https" : "http";
    $fullUrl = $protocol . "://" . $host . "/uploads/" . $newFilename;
    $relativeUrl = "/uploads/" . $newFilename;

    echo json_encode([
        'success' => true,
        'message' => 'تم رفع الصورة بنجاح',
        'filename' => $newFilename,
        'url' => $fullUrl,
        'path' => $relativeUrl
    ], JSON_UNESCAPED_UNICODE);
} else {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'فشل حفظ الملف على الخادم'], JSON_UNESCAPED_UNICODE);
}
