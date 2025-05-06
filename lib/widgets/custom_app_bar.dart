import 'package:flutter/material.dart';

import '../app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showSearchIcon;
  final List<Widget>? actions;
  final VoidCallback? onSearchPressed;
  
  const CustomAppBar({
    Key? key,
    required this.title,
    this.showBackButton = true,
    this.showSearchIcon = false,
    this.actions,
    this.onSearchPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : null,
      actions: [
        if (showSearchIcon)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearchPressed,
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
