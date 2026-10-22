<?php
// backend/config/database.php

class Database {
    private static ?PDO $instance = null;

    public static function getConnection(): PDO {
        if (self::$instance === null) {
            // Determine driver: use MySQL on Linux server, SQLite on local Windows
            $driver = (PHP_OS_FAMILY !== 'Windows' && extension_loaded('pdo_mysql')) ? 'mysql' : 'sqlite';

            try {
                if ($driver === 'mysql') {
                    $host = '127.0.0.1';
                    $dbname = 'matabakhna_db';
                    $user = 'matabakhna_user';
                    $pass = 'Matabakhna@2026';
                    self::$instance = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $user, $pass);
                } else {
                    $dbDir = __DIR__ . '/../database';
                    if (!is_dir($dbDir)) {
                        mkdir($dbDir, 0777, true);
                    }
                    $dbPath = $dbDir . '/matabakhna.db';
                    self::$instance = new PDO("sqlite:" . $dbPath);
                }

                self::$instance->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
                self::$instance->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

                self::initSchema(self::$instance, $driver);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
                exit();
            }
        }
        return self::$instance;
    }

    private static function initSchema(PDO $db, string $driver): void {
        if ($driver === 'mysql') {
            $db->exec("
                CREATE TABLE IF NOT EXISTS categories (
                    id VARCHAR(50) PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    emoji VARCHAR(20) NOT NULL,
                    description TEXT
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

                CREATE TABLE IF NOT EXISTS recipes (
                    id VARCHAR(100) PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    category VARCHAR(50) NOT NULL,
                    imageUrl TEXT NOT NULL,
                    description TEXT NOT NULL,
                    prepTimeMinutes INT DEFAULT 20,
                    cookTimeMinutes INT DEFAULT 30,
                    servings INT DEFAULT 4,
                    estimatedCost DECIMAL(10, 2) DEFAULT 100.0,
                    costTier VARCHAR(50) DEFAULT 'medium',
                    calories INT DEFAULT 450,
                    isUserAdded TINYINT DEFAULT 0,
                    isFeatured TINYINT DEFAULT 0,
                    ingredients LONGTEXT NOT NULL,
                    steps LONGTEXT NOT NULL,
                    tips LONGTEXT NOT NULL,
                    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

                CREATE TABLE IF NOT EXISTS shopping_items (
                    id VARCHAR(100) PRIMARY KEY,
                    title VARCHAR(255) NOT NULL,
                    quantity VARCHAR(100) NOT NULL,
                    category VARCHAR(100),
                    isBought TINYINT DEFAULT 0,
                    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

                CREATE TABLE IF NOT EXISTS budget_plans (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    period VARCHAR(50) NOT NULL,
                    totalBudget DECIMAL(10, 2) NOT NULL,
                    familyMembers INT NOT NULL,
                    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

                CREATE TABLE IF NOT EXISTS weekly_plan (
                    dayKey VARCHAR(50) PRIMARY KEY,
                    recipeId VARCHAR(100),
                    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

                CREATE TABLE IF NOT EXISTS settings (
                    `key` VARCHAR(100) PRIMARY KEY,
                    `value` TEXT NOT NULL
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
            ");
        } else {
            // SQLite schema
            $db->exec("
                CREATE TABLE IF NOT EXISTS categories (
                    id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    emoji TEXT NOT NULL,
                    description TEXT
                );

                CREATE TABLE IF NOT EXISTS recipes (
                    id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    category TEXT NOT NULL,
                    imageUrl TEXT NOT NULL,
                    description TEXT NOT NULL,
                    prepTimeMinutes INTEGER DEFAULT 20,
                    cookTimeMinutes INTEGER DEFAULT 30,
                    servings INTEGER DEFAULT 4,
                    estimatedCost REAL DEFAULT 100.0,
                    costTier TEXT DEFAULT 'medium',
                    calories INTEGER DEFAULT 450,
                    isUserAdded INTEGER DEFAULT 0,
                    isFeatured INTEGER DEFAULT 0,
                    ingredients TEXT NOT NULL,
                    steps TEXT NOT NULL,
                    tips TEXT NOT NULL,
                    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
                    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
                );

                CREATE TABLE IF NOT EXISTS shopping_items (
                    id TEXT PRIMARY KEY,
                    title TEXT NOT NULL,
                    quantity TEXT NOT NULL,
                    category TEXT,
                    isBought INTEGER DEFAULT 0,
                    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
                );

                CREATE TABLE IF NOT EXISTS budget_plans (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    period TEXT NOT NULL,
                    totalBudget REAL NOT NULL,
                    familyMembers INTEGER NOT NULL,
                    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
                );

                CREATE TABLE IF NOT EXISTS weekly_plan (
                    dayKey TEXT PRIMARY KEY,
                    recipeId TEXT,
                    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
                );

                CREATE TABLE IF NOT EXISTS settings (
                    `key` TEXT PRIMARY KEY,
                    `value` TEXT NOT NULL
                );
            ");
        }

        self::seedCategoriesAndSettings($db, $driver);
    }

    private static function seedCategoriesAndSettings(PDO $db, string $driver): void {
        // Seed default categories
        $categories = [
            ['id' => 'egyptian', 'name' => 'أكل مصري أصيل', 'emoji' => '🍲', 'description' => 'أطباق المطبخ المصري التراثية الفاخرة والطواجن المحمرة'],
            ['id' => 'popular', 'name' => 'أكل شعبي', 'emoji' => '🥙', 'description' => 'أكلات الشارع المصري المحبوبة كشري وحواوشي وكبدة'],
            ['id' => 'western', 'name' => 'أكل غربي وسريع', 'emoji' => '🍔', 'description' => 'الباستا، البيتزا، البرجر، والوجبات السريعة المعاصرة'],
            ['id' => 'budgetFriendly', 'name' => 'أكلات اقتصادية', 'emoji' => '🪙', 'description' => 'وجبات شهية ومغذية على قد الإيد بتكلفة موفرة'],
            ['id' => 'desserts', 'name' => 'حلويات', 'emoji' => '🍰', 'description' => 'الحلويات الشرقية والغربية وأطباق التحلية اللذيذة'],
            ['id' => 'healthy', 'name' => 'دايت وصحي', 'emoji' => '🥗', 'description' => 'وجبات خفيفة قليلة السعرات ومشبعة للرشاقة']
        ];

        $catSql = ($driver === 'mysql') 
            ? "INSERT IGNORE INTO categories (id, name, emoji, description) VALUES (?, ?, ?, ?)"
            : "INSERT OR IGNORE INTO categories (id, name, emoji, description) VALUES (?, ?, ?, ?)";
        
        $catStmt = $db->prepare($catSql);
        foreach ($categories as $cat) {
            $catStmt->execute([$cat['id'], $cat['name'], $cat['emoji'], $cat['description']]);
        }

        // Seed default settings
        $settings = [
            ['appName', 'طبختنا - مطبخ الهنا'],
            ['appMotto', 'ميزانية ووصفات أكل لكل بيت'],
            ['tipOfTheDay', 'أهلاً بك في تطبيق طبختنا! أضف أكلتك المفضلة من لوحة التحكم.'],
            ['announcement', 'لوحة التحكم متصلة بالتطبيق مباشرة.'],
            ['currency', 'ج.م'],
            ['dailyBudgetSuggestion', '150'],
            ['weeklyBudgetSuggestion', '1000'],
            ['monthlyBudgetSuggestion', '4000']
        ];

        $setSql = ($driver === 'mysql')
            ? "INSERT IGNORE INTO settings (`key`, `value`) VALUES (?, ?)"
            : "INSERT OR IGNORE INTO settings (`key`, `value`) VALUES (?, ?)";

        $setStmt = $db->prepare($setSql);
        foreach ($settings as $s) {
            $setStmt->execute([$s[0], $s[1]]);
        }
    }
}
