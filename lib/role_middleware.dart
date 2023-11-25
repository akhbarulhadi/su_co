import 'package:flutter/material.dart';

class RoleMiddleware {
  final List<String> allowedRoles;

  RoleMiddleware({required this.allowedRoles});

  Future<bool> checkRole(String role) async {
    return allowedRoles.contains(role);
  }

  Future<void> handle(BuildContext context, String userRole) async {
    final bool hasPermission = await checkRole(userRole);

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anda tidak memiliki izin untuk mengakses halaman in.'),
        ),
      );
      Navigator.pop(context);
    }
  }
}
