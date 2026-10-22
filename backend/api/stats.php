<?php
// backend/api/stats.php
require_once __DIR__ . '/../config/cors.php';
require_once __DIR__ . '/../config/database.php';

$db = Database::getConnection();

// Total recipes
$totalRecipes = (int)$db->query("SELECT COUNT(*) FROM recipes")->fetchColumn();

// Count by cost tier
$budgetCount = (int)$db->query("SELECT COUNT(*) FROM recipes WHERE costTier = 'budget'")->fetchColumn();
$mediumCount = (int)$db->query("SELECT COUNT(*) FROM recipes WHERE costTier = 'medium'")->fetchColumn();
$deluxeCount = (int)$db->query("SELECT COUNT(*) FROM recipes WHERE costTier = 'deluxe'")->fetchColumn();

// Average cost and calories
$avgCost = (float)$db->query("SELECT AVG(estimatedCost) FROM recipes")->fetchColumn();
$avgCalories = (int)$db->query("SELECT AVG(calories) FROM recipes")->fetchColumn();

// User added recipes
$userAddedCount = (int)$db->query("SELECT COUNT(*) FROM recipes WHERE isUserAdded = 1")->fetchColumn();

// Total Categories
$totalCategories = (int)$db->query("SELECT COUNT(*) FROM categories")->fetchColumn();

// Total Shopping Items
$totalShopping = (int)$db->query("SELECT COUNT(*) FROM shopping_items")->fetchColumn();
$boughtShopping = (int)$db->query("SELECT COUNT(*) FROM shopping_items WHERE isBought = 1")->fetchColumn();

// Category breakdown
$catStmt = $db->query("
    SELECT c.name, c.emoji, COUNT(r.id) as count 
    FROM categories c 
    LEFT JOIN recipes r ON c.id = r.category 
    GROUP BY c.id
");
$categoryBreakdown = $catStmt->fetchAll();

// Top recent recipes
$recentStmt = $db->query("SELECT id, name, category, imageUrl, estimatedCost, costTier, calories, createdAt FROM recipes ORDER BY createdAt DESC LIMIT 5");
$recentRecipes = $recentStmt->fetchAll();

echo json_encode([
    'success' => true,
    'data' => [
        'totalRecipes' => $totalRecipes,
        'costTiers' => [
            'budget' => $budgetCount,
            'medium' => $mediumCount,
            'deluxe' => $deluxeCount,
        ],
        'averageCost' => round($avgCost, 1),
        'averageCalories' => round($avgCalories),
        'userAddedCount' => $userAddedCount,
        'totalCategories' => $totalCategories,
        'shopping' => [
            'total' => $totalShopping,
            'bought' => $boughtShopping
        ],
        'categoryBreakdown' => $categoryBreakdown,
        'recentRecipes' => $recentRecipes,
    ]
], JSON_UNESCAPED_UNICODE);
