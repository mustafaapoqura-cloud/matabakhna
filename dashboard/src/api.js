const API_BASE = (typeof window !== 'undefined' && window.location.port === '8086')
  ? `http://${window.location.hostname}:8085/api`
  : '/api';

export const api = {
  // Stats
  async getStats() {
    const res = await fetch(`${API_BASE}/stats.php`);
    return res.json();
  },

  // Upload Image
  async uploadImage(file) {
    const formData = new FormData();
    formData.append('image', file);
    const res = await fetch(`${API_BASE}/upload.php`, {
      method: 'POST',
      body: formData,
    });
    return res.json();
  },

  // Recipes
  async getRecipes(params = {}) {
    const query = new URLSearchParams(params).toString();
    const res = await fetch(`${API_BASE}/recipes.php${query ? `?${query}` : ''}`);
    return res.json();
  },

  async getRecipe(id) {
    const res = await fetch(`${API_BASE}/recipes.php?id=${encodeURIComponent(id)}`);
    return res.json();
  },

  async createRecipe(recipeData) {
    const res = await fetch(`${API_BASE}/recipes.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: jsonSafeStringify(recipeData),
    });
    return res.json();
  },

  async updateRecipe(id, recipeData) {
    const res = await fetch(`${API_BASE}/recipes.php?id=${encodeURIComponent(id)}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: jsonSafeStringify(recipeData),
    });
    return res.json();
  },

  async deleteRecipe(id) {
    const res = await fetch(`${API_BASE}/recipes.php?id=${encodeURIComponent(id)}`, {
      method: 'DELETE',
    });
    return res.json();
  },

  // Categories
  async getCategories() {
    const res = await fetch(`${API_BASE}/categories.php`);
    return res.json();
  },

  async saveCategory(catData) {
    const res = await fetch(`${API_BASE}/categories.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: jsonSafeStringify(catData),
    });
    return res.json();
  },

  async deleteCategory(id) {
    const res = await fetch(`${API_BASE}/categories.php?id=${encodeURIComponent(id)}`, {
      method: 'DELETE',
    });
    return res.json();
  },

  // Budget
  async getBudget() {
    const res = await fetch(`${API_BASE}/budget.php`);
    return res.json();
  },

  async saveBudget(budgetData) {
    const res = await fetch(`${API_BASE}/budget.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: jsonSafeStringify(budgetData),
    });
    return res.json();
  },

  // Weekly Plan
  async getWeeklyPlan() {
    const res = await fetch(`${API_BASE}/weekly_plan.php`);
    return res.json();
  },

  async setWeeklyMeal(dayKey, recipeId) {
    const res = await fetch(`${API_BASE}/weekly_plan.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: jsonSafeStringify({ dayKey, recipeId }),
    });
    return res.json();
  },

  // Shopping List
  async getShoppingList() {
    const res = await fetch(`${API_BASE}/shopping.php`);
    return res.json();
  },

  async addShoppingItem(item) {
    const res = await fetch(`${API_BASE}/shopping.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: jsonSafeStringify(item),
    });
    return res.json();
  },

  async toggleShoppingItem(id, isBought) {
    const res = await fetch(`${API_BASE}/shopping.php?id=${encodeURIComponent(id)}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: jsonSafeStringify({ isBought }),
    });
    return res.json();
  },

  async deleteShoppingItem(id) {
    const res = await fetch(`${API_BASE}/shopping.php?id=${encodeURIComponent(id)}`, {
      method: 'DELETE',
    });
    return res.json();
  },

  async clearBoughtShoppingItems() {
    const res = await fetch(`${API_BASE}/shopping.php?clearBought=1`, {
      method: 'DELETE',
    });
    return res.json();
  },

  // Settings
  async getSettings() {
    const res = await fetch(`${API_BASE}/settings.php`);
    return res.json();
  },

  async saveSettings(settingsData) {
    const res = await fetch(`${API_BASE}/settings.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: jsonSafeStringify(settingsData),
    });
    return res.json();
  },

  // Health check
  async checkBackend() {
    try {
      const res = await fetch('http://localhost:8000/index.php');
      const data = await res.json();
      return { online: true, data };
    } catch (err) {
      return { online: false, error: err.message };
    }
  }
};

function jsonSafeStringify(obj) {
  return JSON.stringify(obj);
}
