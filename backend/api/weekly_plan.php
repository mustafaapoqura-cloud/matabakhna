<?php
// backend/api/weekly_plan.php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';

$db = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        $stmt = $db->query("
            SELECT w.dayKey, w.recipeId, r.name as recipeName, r.imageUrl, r.estimatedCost, r.costTier, r.calories
            FROM weekly_plan w
            LEFT JOIN recipes r ON w.recipeId = r.id
        ");
        $rows = $stmt->fetchAll();
        $plan = [];
        foreach ($rows as $row) {
            $plan[$row['dayKey']] = [
                'recipeId' => $row['recipeId'],
                'recipeName' => $row['recipeName'],
                'imageUrl' => $row['imageUrl'],
                'estimatedCost' => (float)$row['estimatedCost'],
                'costTier' => $row['costTier'],
                'calories' => (int)$row['calories']
            ];
        }
        echo json_encode(['success' => true, 'data' => $plan], JSON_UNESCAPED_UNICODE);
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data || empty($data['dayKey'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'اليوم مطلوب'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $dayKey = trim($data['dayKey']);
        $recipeId = !empty($data['recipeId']) ? trim($data['recipeId']) : null;

        $stmt = $db->prepare("REPLACE INTO weekly_plan (dayKey, recipeId, updatedAt) VALUES (?, ?, CURRENT_TIMESTAMP)");
        $stmt->execute([$dayKey, $recipeId]);

        echo json_encode(['success' => true, 'message' => 'تم تحديث جدول الوجبات'], JSON_UNESCAPED_UNICODE);
        break;

    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}
