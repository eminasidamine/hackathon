import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/settings_controller.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/catalog_service.dart';
import 'vendor_gate_screen.dart';

class VendorCategoriesScreen extends StatefulWidget {
  const VendorCategoriesScreen({super.key});

  @override
  State<VendorCategoriesScreen> createState() => _VendorCategoriesScreenState();
}

class _VendorCategoriesScreenState extends State<VendorCategoriesScreen> {
  late final Future<List<Category>> _future;
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _future = CatalogService().fetchCategories();
  }

  Future<void> _continue() async {
    await openMyShop(
      context,
      initialCategoryId: _selected.isEmpty ? null : _selected.first,
      categoryIds: _selected.toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        surfaceTintColor: AppTheme.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.ink),
        title: Text(t('categories_title'),
            style: const TextStyle(
                color: AppTheme.ink,
                fontWeight: FontWeight.w600,
                fontSize: 17)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Category>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final categories = snapshot.data ?? [];
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    children: [
                      Text(
                        t('which_categories_intro'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15.5,
                            color: AppTheme.muted,
                            height: 1.35),
                      ),
                      const SizedBox(height: 26),
                      if (categories.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            t('no_category_available'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.muted),
                          ),
                        )
                      else
                        for (final category in categories) ...[
                          InkWell(
                            onTap: () => setState(() {
                              if (_selected.contains(category.id)) {
                                _selected.remove(category.id);
                              } else {
                                _selected.add(category.id);
                              }
                            }),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      category.name,
                                      style: TextStyle(
                                        fontSize: 15.5,
                                        color: AppTheme.ink,
                                        fontWeight:
                                            _selected.contains(category.id)
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _selected.contains(category.id)
                                        ? Icons.check
                                        : Icons.chevron_right,
                                    size: 22,
                                    color: AppTheme.ink,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1, color: AppTheme.line),
                        ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selected.isEmpty ? null : _continue,
                      child: Text(t('continue_caps')),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
