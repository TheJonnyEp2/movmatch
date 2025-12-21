import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final String activeTab;

  const TopBar({
    super.key,
    required this.activeTab,
  });

  @override
  Widget build(BuildContext context) {
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
            onTap: () => Navigator.pushNamed(context, '/chats'),
          ),
          _NavItem(
            text: 'Карточки',
            active: activeTab == 'cards',
            onTap: () => Navigator.pushNamed(context, '/cards'),
          ),
          _NavItem(
            text: 'Профиль',
            active: activeTab == 'profile',
            onTap: () => Navigator.pushNamed(context, '/profile'),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/profile'),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/Profile.png'),
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
          ),
        ),
      ),
    );
  }
}