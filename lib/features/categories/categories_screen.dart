import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/errors.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/catalog_service.dart';
import '../products/all_products_screen.dart';
import '../widgets.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _catalog = CatalogService();
  late Future<List<Category>> _future;

  String _gender = 'women';

  @override
  void initState() {
    super.initState();
    _future = _catalog.fetchCategories(gender: _gender);
  }

  void _selectGender(String gender) {
    if (gender == _gender) return;
    setState(() {
      _gender = gender;
      _future = _catalog.fetchCategories(gender: gender);
    });
  }

  void _openSearch(String query) {
    if (query.trim().isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => AllProductsScreen(search: query.trim())),
    );
  }

  void _openCategory(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => AllProductsScreen(
              categoryId: category.id, categoryName: category.name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return Scaffold(
      backgroundColor: AppTheme.shopPageBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: SizedBox(
                width: double.infinity,
                child: const Text(
                  'Shop',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.shopTitle),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 21, 20, 14),
              child: AppSearchField(
                hint: t('search_hint_short'),
                onSubmitted: _openSearch,
                fillColor: AppTheme.searchFillNeutral,
                iconColor: AppTheme.searchGrey,
                hintColor: AppTheme.searchGrey,
                height: 44,
                radius: 12,
                fontSize: 16.5,
                iconSize: 21,
              ),
            ),
            _GenderTabs(
              selected: _gender,
              womenLabel: t('gender_women'),
              menLabel: t('gender_men'),
              onSelect: _selectGender,
            ),
            Expanded(
              child: FutureBuilder<List<Category>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return EmptyState(
                      icon: Icons.error_outline,
                      title: t('error_generic'),
                      subtitle: friendlyError(snapshot.error!),
                    );
                  }
                  final categories = snapshot.data ?? [];
                  if (categories.isEmpty) {
                    return ListView(children: [
                      const SizedBox(height: 100),
                      EmptyState(
                          icon: Icons.grid_view_outlined,
                          title: t('no_results')),
                    ]);
                  }

                  return ListView.separated(
                    cacheExtent: 800,
                    padding: const EdgeInsets.only(
                        top: AppTheme.categorySeparatorHeight),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const _CategorySeparator(),
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _CategoryBand(
                          category: categories[i],
                          onTap: () => _openCategory(categories[i])),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderTabs extends StatelessWidget {
  final String selected;
  final String womenLabel;
  final String menLabel;
  final ValueChanged<String> onSelect;

  const _GenderTabs({
    required this.selected,
    required this.womenLabel,
    required this.menLabel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Row(
        children: [
          Expanded(child: _tab(womenLabel, 'women')),
          Expanded(child: _tab(menLabel, 'men')),
        ],
      ),
    );
  }

  Widget _tab(String label, String value) {
    final active = value == selected;
    return InkWell(
      onTap: () => onSelect(value),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
                color: active ? AppTheme.ink : AppTheme.muted,
              ),
            ),
          ),
          Container(height: 2, color: active ? AppTheme.ink : AppTheme.line),
        ],
      ),
    );
  }
}

class _CategorySeparator extends StatelessWidget {
  const _CategorySeparator();

  @override
  Widget build(BuildContext context) {
    return Container(
        height: AppTheme.categorySeparatorHeight,
        color: AppTheme.categorySeparator);
  }
}

class _CategoryBand extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const _CategoryBand({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bandWidth = MediaQuery.sizeOf(context).width - 32;
    return InkWell(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: kCategoryImageAspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppTheme.categoryBand),
            AppImage(
              url: category.imageUrl,
              fit: BoxFit.cover,
              alignment:
                  Alignment(category.focalX * 2 - 1, category.focalY * 2 - 1),
              zoom: category.zoom,
              height: bandWidth / kCategoryImageAspectRatio,
            ),
            Positioned(
              left: 24,
              top: 0,
              bottom: 0,
              right: 12,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.categoryLabel(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
