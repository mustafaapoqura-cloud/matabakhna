<?php
// backend/api/shopping.php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';

$db = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        $stmt = $db->query("SELECT * FROM shopping_items ORDER BY isBought ASC, createdAt DESC");
        $items = $stmt->fetchAll();
        $formatted = array_map(function($i) {
            return [
                'id' => $i['id'],
                'title' => $i['title'],
                'quantity' => $i['quantity'],
                'category' => $i['category'],
                'isBought' => (bool)$i['isBought'],
                'createdAt' => $i['createdAt']
            ];
        }, $items);
        echo json_encode(['success' => true, 'data' => $formatted], JSON_UNESCAPED_UNICODE);
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data || empty($data['title'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'اسم العنصر مطلوب'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $id = !empty($data['id']) ? $data['id'] : 'shop_' . time() . '_' . mt_rand(10, 99);
        $title = trim($data['title']);
        $quantity = trim($data['quantity'] ?? '1');
        $category = trim($data['category'] ?? 'عام');
        $isBought = !empty($data['isBought']) ? 1 : 0;

        $stmt = $db->prepare("REPLACE INTO shopping_items (id, title, quantity, category, isBought) VALUES (?, ?, ?, ?, ?)");
        $stmt->execute([$id, $title, $quantity, $category, $isBought]);

        http_response_code(201);
        echo json_encode(['success' => true, 'message' => 'تمت إضافة العنصر لقائمة المشتريات', 'id' => $id], JSON_UNESCAPED_UNICODE);
        break;

    case 'PUT':
        $data = json_decode(file_get_contents('php://input'), true);
        $id = $_GET['id'] ?? ($data['id'] ?? null);
        if (!$id) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'معرّف العنصر مطلوب'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $isBought = isset($data['isBought']) ? ($data['isBought'] ? 1 : 0) : null;
        if ($isBought !== null) {
            $stmt = $db->prepare("UPDATE shopping_items SET isBought = ? WHERE id = ?");
            $stmt->execute([$isBought, $id]);
        } else {
            // Toggle
            $stmt = $db->prepare("UPDATE shopping_items SET isBought = CASE WHEN isBought = 1 THEN 0 ELSE 1 END WHERE id = ?");
            $stmt->execute([$id]);
        }

        echo json_encode(['success' => true, 'message' => 'تم تحديث حالة الشراء'], JSON_UNESCAPED_UNICODE);
        break;

    case 'DELETE':
        if (isset($_GET['clearBought']) && $_GET['clearBought'] === '1') {
            $db->exec("DELETE FROM shopping_items WHERE isBought = 1");
            echo json_encode(['success' => true, 'message' => 'تم مسح العناصر المشتراة'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $id = $_GET['id'] ?? null;
        if (!$id) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'معرّف العنصر مطلوب'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $stmt = $db->prepare("DELETE FROM shopping_items WHERE id = ?");
        $stmt->execute([$id]);
        echo json_encode(['success' => true, 'message' => 'تم حذف العنصر'], JSON_UNESCAPED_UNICODE);
        break;

    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}
