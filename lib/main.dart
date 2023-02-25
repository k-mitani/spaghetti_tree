import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:git/git.dart';
import 'package:path/path.dart' as p;

void main() async {
  var path = "C:\\Users\\lg2023\\Documents\\GitHub\\Town";
  if (!await GitDir.isGitDir(path)) {
    throw Exception("Not a git repository");
  }
  var repo = await GitDir.fromExisting(path);
  final commitCount = await repo.commitCount();
  var commits = await repo.commits();

  runApp(MyApp(repo, commits));
}

class MyApp extends StatelessWidget {
  const MyApp(GitDir this.repo, Map<String, Commit> this.commits, {super.key});
  final GitDir repo;
  final Map<String, Commit> commits;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LayoutBuilder(builder: (context, constraints) {
          return Scaffold(
            body: CommitList(
              commits: commits,
            ),
          );
        }));
  }
}

class CommitList extends StatefulWidget {
  const CommitList({
    required Map<String, Commit> this.commits,
  });
  final Map<String, Commit> commits;

  @override
  State<CommitList> createState() => _CommitListState();
}

class _CommitListState extends State<CommitList> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var fontSize = 20.0;
    var items = widget.commits.values.toList().asMap().entries;
    return ListView(children: [
      for (var kv in items)
        Container(
          padding: const EdgeInsets.all(0.0),
          decoration: new BoxDecoration(
              border: new Border(
                  bottom: BorderSide(width: 1.0, color: Colors.grey))),
          child: ListTile(
              tileColor:
                  kv.key == _selectedIndex ? Colors.cyanAccent : Colors.white,
              onTap: () => {
                    setState(() {
                      _selectedIndex = kv.key;
                    })
                  },
              title: SizedBox(
                width: 100,
                child: Row(children: [
                  SizedBox(
                      width: 400,
                      child: Text(kv.value.message,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold))),
                  Text(kv.value.author, style: TextStyle(fontSize: fontSize)),
                ]),
              )),
        )
    ]);
  }
}


// class CommitList extends StatelessWidget {
//   const CommitList({
//     required Map<String, Commit> this.commits,
//   });
//   final Map<String, Commit> commits;

//   @override
//   Widget build(BuildContext context) {
//     // take first 5 commits
//     var fontSize = 20.0;
//     return ListView(children: [
//       for (var commit in commits.values)
//         Padding(
//             padding: const EdgeInsets.all(3.0),
//             child: SizedBox(
//               width: 1000,
//               child: Row(children: [
//                 SizedBox(
//                     width: 400,
//                     child: Text(commit.message,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                             fontSize: fontSize, fontWeight: FontWeight.bold))),
//                 Text(commit.author, style: TextStyle(fontSize: fontSize)),
//               ]),
//             ))
//     ]);
//   }
// }
