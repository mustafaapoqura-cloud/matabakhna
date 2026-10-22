<?php
// backend/api/categories.php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';

$db = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        $stmt = $db->query("
            SELECT c.*, COUNT(r.id) as recipeCount 
            FROM categories c
            LEFT JOIN recipes r ON c.id = r.category
            GROUP BY c.id
            ORDER BY c.id ASC
        ");
        $categories = $stmt->fetchAll();
        echo json_encode(['success' => true, 'data' => $categories], JSON_UNESCAPED_UNICODE);
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data || empty($data['name'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'اسم التصنيف مطلوب'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $name = trim($data['name']);
        $id = !empty($data['id']) ? trim($data['id']) : 'cat_' . time() . '_' . mt_rand(10, 99);
        $emoji = trim($data['emoji'] ?? '🍲');
        $desc = trim($data['description'] ?? '');

        try {
            $stmt = $db->prepare("REPLACE INTO categories (id, name, emoji, description) VALUES (?, ?, ?, ?)");
            $stmt->execute([$id, $name, $emoji, $desc]);
            echo json_encode(['success' => true, 'message' => 'تم حفظ التصنيف بنجاح', 'id' => $id], JSON_UNESCAPED_UNICODE);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'فشل حفظ التصنيف: ' . $e->getMessage()], JSON_UNESCAPED_UNICODE);
        }
        break;

    case 'DELETE':
        $id = $_GET['id'] ?? null;
        if (!$id) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'معرّف التصنيف مطلوب'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        try {
            // Unlink any recipes tied to this category so foreign keys or filters don't break
            $updateStmt = $db->prepare("UPDATE recipes SET category = 'other' WHERE category = ?");
            $updateStmt->execute([$id]);

            $stmt = $db->prepare("DELETE FROM categories WHERE id = ?");
            $stmt->execute([$id]);

            echo json_encode(['success' => true, 'message' => 'تم حذف التصنيف بنجاح'], JSON_UNESCAPED_UNICODE);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'فشل حذف التصنيف: ' . $e->getMessage()], JSON_UNESCAPED_UNICODE);
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}
