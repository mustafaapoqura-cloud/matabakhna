<?php
// backend/api/recipes.php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';

$db = Database::getConnection();
$method = $_SERVER['REQUEST_METHOD'];

function formatRecipe(array $row): array {
    return [
        'id' => $row['id'],
        'name' => $row['name'],
        'category' => $row['category'],
        'imageUrl' => $row['imageUrl'],
        'description' => $row['description'],
        'prepTimeMinutes' => (int)$row['prepTimeMinutes'],
        'cookTimeMinutes' => (int)$row['cookTimeMinutes'],
        'servings' => (int)$row['servings'],
        'estimatedCost' => (float)$row['estimatedCost'],
        'costTier' => $row['costTier'],
        'calories' => (int)$row['calories'],
        'isUserAdded' => (bool)$row['isUserAdded'],
        'isFeatured' => (bool)($row['isFeatured'] ?? 0),
        'ingredients' => json_decode($row['ingredients'] ?? '[]', true) ?: [],
        'steps' => json_decode($row['steps'] ?? '[]', true) ?: [],
        'tips' => json_decode($row['tips'] ?? '[]', true) ?: [],
        'createdAt' => $row['createdAt'] ?? null,
        'updatedAt' => $row['updatedAt'] ?? null,
    ];
}

switch ($method) {
    case 'GET':
        // Get single recipe by ID
        if (isset($_GET['id']) && !empty($_GET['id'])) {
            $stmt = $db->prepare("SELECT * FROM recipes WHERE id = ?");
            $stmt->execute([$_GET['id']]);
            $recipe = $stmt->fetch();
            if ($recipe) {
                echo json_encode(['success' => true, 'data' => formatRecipe($recipe)], JSON_UNESCAPED_UNICODE);
            } else {
                http_response_code(404);
                echo json_encode(['success' => false, 'message' => 'الوصفة غير موجودة'], JSON_UNESCAPED_UNICODE);
            }
            exit();
        }

        // List recipes with optional filters
        $query = "SELECT * FROM recipes WHERE 1=1";
        $params = [];

        if (!empty($_GET['category'])) {
            $query .= " AND category = ?";
            $params[] = $_GET['category'];
        }

        if (!empty($_GET['costTier'])) {
            $query .= " AND costTier = ?";
            $params[] = $_GET['costTier'];
        }

        if (!empty($_GET['search'])) {
            $searchTerm = '%' . trim($_GET['search']) . '%';
            $query .= " AND (name LIKE ? OR description LIKE ? OR ingredients LIKE ?)";
            $params[] = $searchTerm;
            $params[] = $searchTerm;
            $params[] = $searchTerm;
        }

        $query .= " ORDER BY isFeatured DESC, createdAt DESC";

        $stmt = $db->prepare($query);
        $stmt->execute($params);
        $rows = $stmt->fetchAll();

        $result = array_map('formatRecipe', $rows);
        echo json_encode(['success' => true, 'count' => count($result), 'data' => $result], JSON_UNESCAPED_UNICODE);
        break;

    case 'POST':
        $data = json_decode(file_get_contents('php://input'), true);
        if (!$data || empty($data['name'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'اسم الوصفة مطلوب'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $id = !empty($data['id']) ? $data['id'] : 'recipe_' . time() . '_' . mt_rand(100, 999);
        $name = trim($data['name']);
        $category = $data['category'] ?? 'egyptian';
        $imageUrl = !empty($data['imageUrl']) ? trim($data['imageUrl']) : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80';
        $description = trim($data['description'] ?? '');
        $prepTime = (int)($data['prepTimeMinutes'] ?? 20);
        $cookTime = (int)($data['cookTimeMinutes'] ?? 30);
        $servings = (int)($data['servings'] ?? 4);
        $cost = (float)($data['estimatedCost'] ?? 100.0);
        $costTier = $data['costTier'] ?? 'medium';
        $calories = (int)($data['calories'] ?? 450);
        $isUserAdded = !empty($data['isUserAdded']) ? 1 : 0;
        $isFeatured = !empty($data['isFeatured']) ? 1 : 0;

        $ingredients = is_array($data['ingredients'] ?? null) ? json_encode($data['ingredients'], JSON_UNESCAPED_UNICODE) : '[]';
        $steps = is_array($data['steps'] ?? null) ? json_encode($data['steps'], JSON_UNESCAPED_UNICODE) : '[]';
        $tips = is_array($data['tips'] ?? null) ? json_encode($data['tips'], JSON_UNESCAPED_UNICODE) : '[]';

        $stmt = $db->prepare("
            REPLACE INTO recipes 
            (id, name, category, imageUrl, description, prepTimeMinutes, cookTimeMinutes, servings, estimatedCost, costTier, calories, isUserAdded, isFeatured, ingredients, steps, tips, updatedAt)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        ");

        $stmt->execute([
            $id, $name, $category, $imageUrl, $description,
            $prepTime, $cookTime, $servings, $cost, $costTier, $calories,
            $isUserAdded, $isFeatured, $ingredients, $steps, $tips
        ]);

        http_response_code(201);
        echo json_encode([
            'success' => true,
            'message' => 'تم حفظ الوصفة بنجاح',
            'id' => $id
        ], JSON_UNESCAPED_UNICODE);
        break;

    case 'PUT':
        $id = $_GET['id'] ?? null;
        $data = json_decode(file_get_contents('php://input'), true);

        if (!$id && isset($data['id'])) {
            $id = $data['id'];
        }

        if (!$id) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'معرّف الوصفة مطلوب للتعديل'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        // Fetch existing
        $checkStmt = $db->prepare("SELECT * FROM recipes WHERE id = ?");
        $checkStmt->execute([$id]);
        $existing = $checkStmt->fetch();

        if (!$existing) {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'الوصفة غير موجودة'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $name = trim($data['name'] ?? $existing['name']);
        $category = $data['category'] ?? $existing['category'];
        $imageUrl = trim($data['imageUrl'] ?? $existing['imageUrl']);
        $description = trim($data['description'] ?? $existing['description']);
        $prepTime = isset($data['prepTimeMinutes']) ? (int)$data['prepTimeMinutes'] : (int)$existing['prepTimeMinutes'];
        $cookTime = isset($data['cookTimeMinutes']) ? (int)$data['cookTimeMinutes'] : (int)$existing['cookTimeMinutes'];
        $servings = isset($data['servings']) ? (int)$data['servings'] : (int)$existing['servings'];
        $cost = isset($data['estimatedCost']) ? (float)$data['estimatedCost'] : (float)$existing['estimatedCost'];
        $costTier = $data['costTier'] ?? $existing['costTier'];
        $calories = isset($data['calories']) ? (int)$data['calories'] : (int)$existing['calories'];
        $isFeatured = isset($data['isFeatured']) ? ($data['isFeatured'] ? 1 : 0) : (int)$existing['isFeatured'];

        $ingredients = isset($data['ingredients']) ? json_encode($data['ingredients'], JSON_UNESCAPED_UNICODE) : $existing['ingredients'];
        $steps = isset($data['steps']) ? json_encode($data['steps'], JSON_UNESCAPED_UNICODE) : $existing['steps'];
        $tips = isset($data['tips']) ? json_encode($data['tips'], JSON_UNESCAPED_UNICODE) : $existing['tips'];

        $updateStmt = $db->prepare("
            UPDATE recipes SET 
                name = ?, category = ?, imageUrl = ?, description = ?,
                prepTimeMinutes = ?, cookTimeMinutes = ?, servings = ?, estimatedCost = ?,
                costTier = ?, calories = ?, isFeatured = ?, ingredients = ?, steps = ?, tips = ?,
                updatedAt = CURRENT_TIMESTAMP
            WHERE id = ?
        ");

        $updateStmt->execute([
            $name, $category, $imageUrl, $description,
            $prepTime, $cookTime, $servings, $cost,
            $costTier, $calories, $isFeatured, $ingredients, $steps, $tips,
            $id
        ]);

        echo json_encode(['success' => true, 'message' => 'تم تحديث الوصفة بنجاح'], JSON_UNESCAPED_UNICODE);
        break;

    case 'DELETE':
        $id = $_GET['id'] ?? null;
        if (!$id) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'معرّف الوصفة مطلوب للحذف'], JSON_UNESCAPED_UNICODE);
            exit();
        }

        $stmt = $db->prepare("DELETE FROM recipes WHERE id = ?");
        $stmt->execute([$id]);

        echo json_encode(['success' => true, 'message' => 'تم حذف الوصفة بنجاح'], JSON_UNESCAPED_UNICODE);
        break;

    default:
        http_response_code(405);
        echo json_encode(['error' => 'Method not allowed']);
        break;
}
