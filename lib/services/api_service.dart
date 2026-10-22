import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import 'storage_service.dart';

class ApiService {
  // Default base URL depending on platform
  static String get defaultBaseUrl {
    // Points directly to the live Contabo VPS server
    return 'http://80.241.218.23:8085/api';
  }

  static String baseUrl = defaultBaseUrl;

  /// Helper to convert relative or localhost URLs to platform-appropriate URLs
  static String resolveImageUrl(String url) {
    if (url.isEmpty) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80';
    }
    if (url.startsWith('/')) {
      return 'http://80.241.218.23:8085$url';
    }
    if (url.contains('localhost:8000') || url.contains('10.0.2.2:8000')) {
      return url.replaceAll('localhost:8000', '80.241.218.23:8085')
                .replaceAll('10.0.2.2:8000', '80.241.218.23:8085');
    }
    return url;
  }

  /// Fetch all recipes from the PHP Backend
  static Future<List<Recipe>> fetchRecipes() async {
    try {
      final uri = Uri.parse('$baseUrl/recipes.php');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded['success'] == true && decoded['data'] is List) {
          final List<Recipe> recipes = (decoded['data'] as List)
              .map((item) {
                final map = Map<String, dynamic>.from(item as Map);
                map['imageUrl'] = resolveImageUrl(map['imageUrl'] as String? ?? '');
                return Recipe.fromJson(map);
              })
              .toList();

          // Save backend recipes locally in cache
          await StorageService.cacheRemoteRecipes(recipes);
          return StorageService.getAllRecipes();
        }
      }
    } catch (e) {
      debugPrint('ApiService.fetchRecipes error (using local cache): $e');
    }

    // Return cached/local recipes on failure
    return StorageService.getAllRecipes();
  }

  /// Create a new recipe on the PHP backend
  static Future<bool> createRecipe(Recipe recipe) async {
    // Always save locally first
    await StorageService.saveCustomRecipe(recipe);

    try {
      final uri = Uri.parse('$baseUrl/recipes.php');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(recipe.toJson()),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('ApiService.createRecipe error: $e');
    }
    return false;
  }

  /// Delete a recipe on the PHP backend
  static Future<bool> deleteRecipe(String recipeId) async {
    await StorageService.deleteCustomRecipe(recipeId);

    try {
      final uri = Uri.parse('$baseUrl/recipes.php?id=$recipeId');
      final response = await http.delete(uri).timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('ApiService.deleteRecipe error: $e');
      return false;
    }
  }

  /// Check backend health
  static Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse(baseUrl.replaceAll('/api', '/index.php'));
      final response = await http.get(uri).timeout(const Duration(seconds: 2));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
