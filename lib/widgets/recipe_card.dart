import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteChanged;
  final bool isCompact;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onFavoriteChanged,
    this.isCompact = false,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = StorageService.isFavorite(widget.recipe.id);
  }

  @override
  void didUpdateWidget(covariant RecipeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    isFav = StorageService.isFavorite(widget.recipe.id);
  }

  void _toggleFav() async {
    await StorageService.toggleFavorite(widget.recipe.id);
    setState(() {
      isFav = !isFav;
    });
    widget.onFavoriteChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompactCard();
    }
    return _buildFullCard();
  }

  Widget _buildFullCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Recipe Image Header
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Image.network(
                        widget.recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppTheme.primary.withAlpha(30),
                          child: const Icon(
                            Icons.restaurant_menu_rounded,
                            size: 60,
                            color: AppTheme.primary,
                          ),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Gradient Overlay for readability
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(50),
                            Colors.transparent,
                            Colors.black.withAlpha(120),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Category Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.recipe.category.emoji} ${widget.recipe.category.label}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Material(
                      color: Colors.white.withAlpha(220),
                      shape: const CircleBorder(),
                      child: IconButton(
                        iconSize: 22,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? Colors.red : Colors.grey.shade800,
                        ),
                        onPressed: _toggleFav,
                      ),
                    ),
                  ),
                  // Estimated Cost Badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'حوالي ${widget.recipe.estimatedCost.toInt()} ج',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Content Details
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.recipe.description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: AppTheme.borderLight),
                    const SizedBox(height: 10),
                    // Quick meta: Time, Servings, Tier
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMetaItem(
                          Icons.schedule_rounded,
                          '${widget.recipe.totalTimeMinutes} دقيقة',
                        ),
                        _buildMetaItem(
                          Icons.people_outline_rounded,
                          'تكفي ${widget.recipe.servings} أفراد',
                        ),
                        Row(
                          children: [
                            Text(widget.recipe.costTier.icon, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              widget.recipe.costTier.label.split(' ').first,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard() {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: Image.network(
                    widget.recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.primary.withAlpha(30),
                      child: const Icon(Icons.restaurant_menu_rounded, color: AppTheme.primary),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.recipe.estimatedCost.toInt()} ج',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 14, color: Colors.grey),
                            const SizedBox(width: 3),
                            Text(
                              '${widget.recipe.totalTimeMinutes} د',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
