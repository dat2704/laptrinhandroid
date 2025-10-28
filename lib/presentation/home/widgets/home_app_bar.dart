
import 'package:cua_hang_thoi_trang/presentation/admin/admin_page.dart';
import 'package:cua_hang_thoi_trang/presentation/auth/bloc/auth_bloc.dart';
import 'package:cua_hang_thoi_trang/presentation/cart/widgets/cart_side_panel.dart';
import 'package:cua_hang_thoi_trang/presentation/home/home_page.dart';
import 'package:cua_hang_thoi_trang/presentation/profile/profile_page.dart';
import 'package:cua_hang_thoi_trang/presentation/widgets/product_search_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: InkWell(
        onTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomePage()),
            (Route<dynamic> route) => false,
          );
        },
        child: const Text(
          'DStore',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.search_outlined),
          onPressed: () {
            showSearch(context: context, delegate: ProductSearchDelegate());
          },
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () => showCartSidePanel(context),
        ),
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return IconButton(
                icon: const Icon(Icons.person_outline_rounded),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        // Only show admin button if user is admin
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthenticatedAdmin) {
              return IconButton(
                icon: const Icon(Icons.admin_panel_settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminPage()),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
