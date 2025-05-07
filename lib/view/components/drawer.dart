import 'package:dolphin/core/image/app_Image.dart';
import 'package:dolphin/view/components/my_list_tile.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onProfileTap;
  final void Function()? onSignOut;
  const MyDrawer({super.key, this.onProfileTap, this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF0F2027),
      child: Column(
        children: [
          DrawerHeader(child: Image.asset(AppImage.logo, scale: 5)),

          MyListTile(
            icon: Icons.person,
            text: "DOLPHIN PROFILE",
            onTap: onProfileTap,
          ),
        ],
      ),
    );
  }
}
