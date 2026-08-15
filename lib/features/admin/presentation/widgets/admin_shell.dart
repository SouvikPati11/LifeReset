import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../home/presentation/widgets/home_style.dart';
import 'admin_style.dart';

/// A single navigable admin section (label, icon, optional subtitle, screen).
class AdminNavItem {
  const AdminNavItem(this.title, this.icon, this.builder, {this.subtitle});

  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget Function() builder;
}

/// A labelled group of sections in the sidebar (e.g. MANAGEMENT, CONTENT).
class AdminNavGroup {
  const AdminNavGroup(this.label, this.items);

  /// `null` renders the group with no header (used for the lone Dashboard row).
  final String? label;
  final List<AdminNavItem> items;
}

/// The full, labelled purple sidebar (desktop + mobile drawer).
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({
    super.key,
    required this.groups,
    required this.selected,
    required this.onSelect,
    required this.email,
    required this.onSignOut,
  });

  final List<AdminNavGroup> groups;
  final int selected;
  final ValueChanged<int> onSelect;
  final String email;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AdminStyle.sidebarWidth,
      decoration: const BoxDecoration(
        color: AdminStyle.sidebarBg,
        border: Border(right: BorderSide(color: HomeStyle.border)),
      ),
      child: Column(
        children: [
          _BrandHeader(email: email),
          const Divider(height: 1, color: HomeStyle.border),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm, vertical: AppSizes.sm),
              children: _navChildren(),
            ),
          ),
          const Divider(height: 1, color: HomeStyle.border),
          _LogoutTile(onSignOut: onSignOut),
        ],
      ),
    );
  }

  List<Widget> _navChildren() {
    final children = <Widget>[];
    var flat = 0;
    for (final g in groups) {
      if (g.label != null) {
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.md, AppSizes.md, AppSizes.md, AppSizes.xs),
          child: Text(
            g.label!,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: HomeStyle.inkSoft,
            ),
          ),
        ));
      }
      for (final item in g.items) {
        final i = flat;
        children.add(_NavTile(
          item: item,
          selected: i == selected,
          onTap: () => onSelect(i),
        ));
        flat++;
      }
    }
    return children;
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile(
      {required this.item, required this.selected, required this.onTap});

  final AdminNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: AppSizes.xs),
      child: Material(
        color: selected ? HomeStyle.lavender : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 12),
            child: Row(
              children: [
                Icon(item.icon,
                    size: 20,
                    color: selected ? HomeStyle.primary : HomeStyle.inkSoft),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? HomeStyle.ink : HomeStyle.inkSoft,
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

/// The collapsed icon-only rail (tablet).
class AdminRail extends StatelessWidget {
  const AdminRail({
    super.key,
    required this.groups,
    required this.selected,
    required this.onSelect,
    required this.onSignOut,
  });

  final List<AdminNavGroup> groups;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final items = <AdminNavItem>[for (final g in groups) ...g.items];
    return Container(
      width: AdminStyle.railWidth,
      decoration: const BoxDecoration(
        color: AdminStyle.sidebarBg,
        border: Border(right: BorderSide(color: HomeStyle.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSizes.md),
          const _BrandMark(),
          const SizedBox(height: AppSizes.sm),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
              children: [
                for (var i = 0; i < items.length; i++)
                  _RailTile(
                    item: items[i],
                    selected: i == selected,
                    onTap: () => onSelect(i),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: onSignOut,
            icon: const Icon(Icons.logout_rounded, color: HomeStyle.inkSoft),
          ),
          const SizedBox(height: AppSizes.sm),
        ],
      ),
    );
  }
}

class _RailTile extends StatelessWidget {
  const _RailTile(
      {required this.item, required this.selected, required this.onTap});

  final AdminNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
      child: Tooltip(
        message: item.title,
        child: Material(
          color: selected ? HomeStyle.lavender : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Icon(item.icon,
                  size: 22,
                  color: selected ? HomeStyle.primary : HomeStyle.inkSoft),
            ),
          ),
        ),
      ),
    );
  }
}

/// The purple gradient app mark (shield) used in the sidebar/rail header.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: HomeStyle.scoreGradient,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Row(
        children: [
          const _BrandMark(),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('LifeReset',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: HomeStyle.ink)),
                Text(
                  email.isEmpty ? 'Administrator' : email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11.5, color: HomeStyle.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.sm),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: onSignOut,
          child: const Padding(
            padding:
                EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.logout_rounded, size: 20, color: HomeStyle.inkSoft),
                SizedBox(width: AppSizes.md),
                Text('Logout',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: HomeStyle.inkSoft)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The content-pane header showing the active section title + subtitle, with an
/// optional menu button that opens the drawer (mobile/tablet).
class AdminTopBar extends StatelessWidget {
  const AdminTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onMenu,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      decoration: const BoxDecoration(
        color: AdminStyle.sidebarBg,
        border: Border(bottom: BorderSide(color: HomeStyle.border)),
      ),
      child: Row(
        children: [
          if (onMenu != null) ...[
            IconButton(
              onPressed: onMenu,
              icon: const Icon(Icons.menu_rounded, color: HomeStyle.ink),
            ),
            const SizedBox(width: AppSizes.xs),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: HomeStyle.ink)),
                if (subtitle != null)
                  Text(subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12.5, color: HomeStyle.inkSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A styled "ships in a later pass" placeholder for modules not yet built,
/// keeping the navigation complete without showing any fabricated data.
class AdminModulePlaceholder extends StatelessWidget {
  const AdminModulePlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: HomeStyle.lavender,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Icon(icon, color: HomeStyle.primary, size: 30),
            ),
            const SizedBox(height: AppSizes.md),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: HomeStyle.ink)),
            const SizedBox(height: AppSizes.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13.5, height: 1.5, color: HomeStyle.inkSoft)),
            ),
          ],
        ),
      ),
    );
  }
}
