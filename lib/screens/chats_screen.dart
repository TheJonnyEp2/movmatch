import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import 'chat_detail_screen.dart';
import '../widgets/top_bar.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  static final List<ChatModel> chats = [
    ChatModel(
      name: 'Джессика',
      lastMessage: 'Ты уже видела трейлер…',
      time: '10:42',
      isNew: true,
      avatar: '👩',
    ),
    ChatModel(
      name: 'Мэтт',
      lastMessage: 'Согласен, концовка была…',
      time: 'Вчера',
      avatar: '👨',
    ),
    ChatModel(
      name: 'Александр',
      lastMessage: 'Давай на выходных…',
      time: 'Вчера',
      avatar: '🧑',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(43, 43, 43, 1),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(activeTab: 'chats'),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Сообщения',
                      style: TextStyle(
                        fontSize: 32, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Expanded(
                      child: GridView.builder(
                        itemCount: chats.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          childAspectRatio: 2.6,
                        ),
                        itemBuilder: (context, index) {
                          final chat = chats[index];
                          return _ChatCard(
                            chat: chat,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatDetailScreen(chat: chat),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatCard extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const _ChatCard({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF18181B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color.fromRGBO(210, 112, 255, 1),
              child: Text(
                chat.avatar,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    chat.name,
                    style: const TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat.time,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                if (chat.isNew)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(210, 112, 255, 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'НОВОЕ', 
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}