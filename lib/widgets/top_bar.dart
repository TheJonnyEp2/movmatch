import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class TopBar extends StatelessWidget {
  final String activeTab;

  const TopBar({
    super.key,
    required this.activeTab,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    void navigateAndSave(String route) {
      if (ModalRoute.of(context)?.settings.name != route) {
        authProvider.saveCurrentRoute(route);
        Navigator.pushNamed(context, route);
      }
    }

    void _showLogoutDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
          title: const Text(
            'Выход из аккаунта',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Onest',
            ),
          ),
          content: const Text(
            'Вы уверены, что хотите выйти из аккаунта?',
            style: TextStyle(
              color: Colors.grey,
              fontFamily: 'Onest',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Отмена',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Onest',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await authProvider.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/login', 
                  (route) => false
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(210, 112, 255, 1),
              ),
              child: const Text(
                'Выйти',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Onest',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 72,
      color: const Color(0xFF141416),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          const Text(
            'MovMatch',
            style: TextStyle(
              fontFamily: 'CyGrotesk',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(221, 255, 255, 255),
            ),
          ),
          const Spacer(),
          _NavItem(
            text: 'Чаты',
            active: activeTab == 'chats',
            onTap: () => navigateAndSave('/chats'),
          ),
          _NavItem(
            text: 'Карточки',
            active: activeTab == 'cards',
            onTap: () => navigateAndSave('/cards'),
          ),
          _NavItem(
            text: 'Профиль',
            active: activeTab == 'profile',
            onTap: () => navigateAndSave('/profile'),
          ),
          const SizedBox(width: 16),
           GestureDetector(
            onTap: () => navigateAndSave('/profile'),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/Profile.png'),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _showLogoutDialog,
              icon: const Icon(
                Icons.exit_to_app,
                size: 20,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          text,
          style: TextStyle(
            color: active ? const Color.fromRGBO(210, 112, 255, 1) : Colors.grey,
            fontWeight: FontWeight.w600,
            fontFamily: 'Onest',
          ),
        ),
      ),
    );
  }
}