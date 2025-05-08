import 'package:flutter/material.dart';

class ChatUi extends StatefulWidget {
  const ChatUi({super.key});

  @override
  State<ChatUi> createState() => _ChatUiState();
}

class _ChatUiState extends State<ChatUi> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ChatItem extends StatelessWidget {
  final ChatType chatType;
  const ChatItem({super.key, required this.chatType});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}


enum ChatType { text, recipe, image, audio }


