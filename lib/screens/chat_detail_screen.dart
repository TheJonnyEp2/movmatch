import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../widgets/top_bar.dart';

class ChatDetailScreen extends StatelessWidget {
  final ChatModel chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(43, 43, 43, 1), // Добавляем фон
      body: SafeArea(
        child: Column(
          children: [
            TopBar(activeTab: 'chats'),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color.fromRGBO(210, 112, 255, 1),
                    child: Text(
                      chat.avatar,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    chat.name,
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            const Divider(
              color: Colors.grey,
              height: 1,
              thickness: 0.5,
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  _MessageBubble(
                    text: 'Привет! 👋 Вижу, тебе тоже нравится "Марсианин".',
                    isMe: false,
                  ),
                  _MessageBubble(
                    text: 'Да, сцена с картошкой легендарна 😄',
                    isMe: true,
                  ),
                  _MessageBubble(
                    text: 'Интерстеллар тоже в топе?',
                    isMe: false,
                  ),
                ],
              ),
            ),
            
            _InputField(),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _MessageBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isMe 
            ? const Color.fromRGBO(210, 112, 255, 1) 
            : const Color(0xFF1F1F22),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Напишите сообщение...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1F1F22),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(210, 112, 255, 1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}