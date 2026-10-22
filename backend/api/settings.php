<?php
// backend/api/settings.php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';

$db = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        $stmt = $db->query("SELECT * FROM settings");
        $rows = $stmt->fetchAll();
        $settings = [];
        foreach ($rows as $r) {
            $settings[$r['key']] = $r['value'];
        }
        echo json_encode(['success' => true, 'data' => $settings], JSON_UNESCAPED_UNICODE);
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data || !is_array($data)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'بيانات الإعدادات غير صالحة'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $stmt = $db->prepare("REPLACE INTO settings (`key`, `value`) VALUES (?, ?)");
        foreach ($data as $key => $val) {
            $stmt->execute([$key, (string)$val]);
        }

        echo json_encode(['success' => true, 'message' => 'تم حفظ الإعدادات بنجاح'], JSON_UNESCAPED_UNICODE);
        break;

    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}
