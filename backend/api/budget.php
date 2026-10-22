<?php
// backend/api/budget.php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';

$db = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        $stmt = $db->query("SELECT * FROM budget_plans ORDER BY id DESC LIMIT 1");
        $plan = $stmt->fetch();
        if (!$plan) {
            $plan = [
                'period' => 'daily',
                'totalBudget' => 150.0,
                'familyMembers' => 4
            ];
        } else {
            $plan['totalBudget'] = (float)$plan['totalBudget'];
            $plan['familyMembers'] = (int)$plan['familyMembers'];
        }
        echo json_encode(['success' => true, 'data' => $plan], JSON_UNESCAPED_UNICODE);
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data || !isset($data['totalBudget'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'بيانات الميزانية مطلوبة'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $period = $data['period'] ?? 'daily';
        $totalBudget = (float)$data['totalBudget'];
        $familyMembers = (int)($data['familyMembers'] ?? 4);

        $stmt = $db->prepare("INSERT INTO budget_plans (period, totalBudget, familyMembers) VALUES (?, ?, ?)");
        $stmt->execute([$period, $totalBudget, $familyMembers]);

        echo json_encode(['success' => true, 'message' => 'تم حفظ الميزانية بنجاح'], JSON_UNESCAPED_UNICODE);
        break;

    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}
