import 'package:flutter/material.dart';

class RepositoriesView extends StatelessWidget {
  const RepositoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget itemOf(text, path) {
      return Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),
        child: ListTile(
          onTap: () {},
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
              Text(
                path,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: 200,
      child: ListView(children: [
        itemOf("Town", "C:\\Users\\lg2023\\Documents\\GitHub\\Town"),
        itemOf("TKR5minigames", "C:\\w\\TKR5minigames"),
        itemOf("spaghetti_tree",
            "C:\\Users\\lg2023\\Documents\\GitHub\\spaghetti_tree"),
      ]),
    );
  }
}
