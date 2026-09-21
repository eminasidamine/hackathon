import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../core/settings_controller.dart';
import '../core/theme.dart';
import '../services/cart_controller.dart';
import 'cart/cart_screen.dart';
import 'categories/categories_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import '../services/role_controller.dart';
import 'vendor/vendor_categories_screen.dart';

class Shell extends StatefulWidget {
  Shell({Key? key}) : super(key: key ?? navKey);

  static final GlobalKey<ShellState> navKey = GlobalKey<ShellState>();

  @override
  State<Shell> createState() => ShellState();
}

class ShellState extends State<Shell> {
  int _index = 0;

  void goToBag() => setState(() => _index = 2);

  static const _screens = [
    HomeScreen(),
    CategoriesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  Future<void> _startSell(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VendorCategoriesScreen()),
    );

    if (mounted) await context.read<RoleController>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<SettingsController>().t;
    final cartCount = context.watch<CartController>().itemCount;

    final tabs = [
      _TabSpec(_TabKind.home, t('tab_home'), active: _index == 0),
      _TabSpec(_TabKind.categories, t('tab_categories'), active: _index == 1),
      _TabSpec(_TabKind.create, t('tab_create'), active: false),
      _TabSpec(_TabKind.cart, t('tab_cart'),
          badge: cartCount, active: _index == 2),
      _TabSpec(_TabKind.account, t('tab_profile'), active: _index == 3),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _AppTabBar(
        tabs: tabs,
        onTap: (kind) {
          switch (kind) {
            case _TabKind.home:
              setState(() => _index = 0);
              break;
            case _TabKind.categories:
              setState(() => _index = 1);
              break;
            case _TabKind.create:
              _startSell(context);
              break;
            case _TabKind.cart:
              setState(() => _index = 2);
              break;
            case _TabKind.account:
              setState(() => _index = 3);
              break;
          }
        },
      ),
    );
  }
}

enum _TabKind { home, categories, create, cart, account }

class _TabSpec {
  final _TabKind kind;
  final String label;
  final int badge;
  final bool active;

  _TabSpec(this.kind, this.label, {this.badge = 0, this.active = false});
}

class _AppTabBar extends StatelessWidget {
  final List<_TabSpec> tabs;
  final ValueChanged<_TabKind> onTap;

  const _AppTabBar({required this.tabs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppTheme.panel,
        border: Border(top: BorderSide(color: AppTheme.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 9, 2, 0),
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                for (final tab in tabs)
                  Expanded(
                    child: InkWell(
                      onTap: () => onTap(tab.kind),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _AppTabIcon(
                                kind: tab.kind,
                                color: tab.kind == _TabKind.create
                                    ? AppTheme.ink
                                    : (tab.active
                                        ? AppTheme.ink
                                        : AppTheme.mutedDark),
                              ),
                              if (tab.badge > 0)
                                Positioned(
                                  top: -4,
                                  right: -9,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    height: 17,
                                    constraints:
                                        const BoxConstraints(minWidth: 17),
                                    decoration: const BoxDecoration(
                                      color: AppTheme.ink,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(9)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${tab.badge}',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tab.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: tab.active
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: tab.kind == _TabKind.create
                                  ? AppTheme.ink
                                  : (tab.active
                                      ? AppTheme.ink
                                      : AppTheme.mutedDark),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppTabIcon extends StatelessWidget {
  final _TabKind kind;
  final Color color;

  const _AppTabIcon({required this.kind, required this.color});

  static String _hex(Color c) => '#${c.value.toRadixString(16).substring(2)}';

  String _svg(String hex, String barBgHex) {
    switch (kind) {
      case _TabKind.home:
        return '<svg viewBox="0 0 24 24" fill="none" stroke="$hex" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">'
            '<path d="M4 11.5 12 4l8 7.5"/>'
            '<path d="M6 10.3V19a1 1 0 0 0 1 1h3v-5.4h4V20h3a1 1 0 0 0 1-1v-8.7"/></svg>';
      case _TabKind.cart:
        return '<svg viewBox="0 0 24 24" fill="none" stroke="$hex" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">'
            '<path d="M7 8.5V6.8a5 5 0 0 1 10 0V8.5"/>'
            '<rect x="4" y="8.5" width="16" height="11.5" rx="2.2"/></svg>';
      case _TabKind.create:
        return '<svg viewBox="0 0 24 24" fill="none" stroke="$hex" stroke-width="1.6" stroke-linecap="round">'
            '<circle cx="12" cy="12" r="9.2"/>'
            '<path d="M12 7.7v8.6M7.7 12h8.6"/></svg>';
      case _TabKind.categories:
        return '<svg viewBox="0 0 24 24" fill="none" stroke="$hex" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">'
            '<line x1="2.6" y1="6.3" x2="7.4" y2="6.3"/>'
            '<line x1="2.6" y1="11.6" x2="7.4" y2="11.6"/>'
            '<line x1="2.6" y1="16.9" x2="7.4" y2="16.9"/>'
            '<circle cx="14.6" cy="11.4" r="5.1"/>'
            '<line x1="18.3" y1="15.1" x2="21.6" y2="18.4"/></svg>';
      case _TabKind.account:
        return '<svg viewBox="0 0 24 24">'
            '<circle cx="5" cy="12" r="2.1" fill="$hex"/>'
            '<circle cx="12" cy="12" r="2.1" fill="$hex"/>'
            '<circle cx="19" cy="12" r="2.1" fill="$hex"/></svg>';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_svg(_hex(color), _hex(AppTheme.panel)),
        width: 24, height: 24);
  }
}
