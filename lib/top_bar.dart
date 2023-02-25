import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    Container buttonOf(IconData icon, String text, onPressed) {
      return Container(
        margin: const EdgeInsets.all(5),
        child: ElevatedButton(
            onPressed: onPressed,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon),
              Text(
                text,
                textAlign: TextAlign.center,
              )
            ])),
      );
    }

    return Container(
      height: 65,
      color: const Color(0xff334455),
      child: Row(
        children: [
          buttonOf(Icons.add, "New", () {}),
          buttonOf(Icons.new_label, "Commit", () {}),
          buttonOf(Icons.download, "Fetch", () {}),
          buttonOf(Icons.upload, "Push", () {}),
          buttonOf(Icons.terminal, "Terminal", () {}),
          buttonOf(Icons.settings, "Settings", () {}),
        ],
      ),
    );
  }
}
