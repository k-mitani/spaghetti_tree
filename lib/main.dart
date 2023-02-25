import 'package:flutter/material.dart';
import 'package:libgit2dart/libgit2dart.dart';
import 'package:spaghetti_tree/repositories_view.dart';
import 'package:spaghetti_tree/top_bar.dart';

void main() async {
  var path = "C:\\Users\\lg2023\\Documents\\GitHub\\Town";
  var repo = Repository.open(path);
  runApp(MyApp(repo));
}

class MyApp extends StatelessWidget {
  final Repository repo;
  const MyApp(this.repo, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LayoutBuilder(builder: (context, constraints) {
          return Scaffold(
              body: Column(
            children: [
              const TopBar(),
              Expanded(
                child: Row(
                  children: [
                    const RepositoriesView(),
                    MainView(repo),
                  ],
                ),
              )
            ],
          ));
        }));
  }
}

class MainView extends StatefulWidget {
  final Repository repo;
  const MainView(this.repo, {super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  var _selectedCommitIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(children: [
        RepoSideView(widget.repo),
        Expanded(
            child: Column(
          children: [
            CommitList(widget.repo, _selectedCommitIndex, (int index) {
              setState(() {
                _selectedCommitIndex = index;
              });
            }),
            Expanded(child: CommitView(widget.repo, _selectedCommitIndex)),
          ],
        )),
      ]),
    );
  }
}

class RepoSideView extends StatelessWidget {
  final Repository repo;
  const RepoSideView(this.repo, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      color: Color(0xffcccccc),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("ブランチ", style: TextStyle(fontWeight: FontWeight.bold)),
          for (Branch branch in repo.branches)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(
                branch.name,
                style: TextStyle(
                    fontWeight: branch.isCheckedOut
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
            ),
          SizedBox(height: 20),
          const Text("タグ", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          const Text("スタッシュ", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          const Text("リモート", style: TextStyle(fontWeight: FontWeight.bold)),
          for (var remote in repo.remotes)
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: Text(remote),
            ),
        ]),
      ),
    );
  }
}

class CommitList extends StatelessWidget {
  final Repository repo;
  final int selectedIndex;
  final Function(int) onSelectionChanged;
  const CommitList(this.repo, this.selectedIndex, this.onSelectionChanged,
      {super.key});

  @override
  Widget build(BuildContext context) {
    var logs = repo.log(oid: repo.head.target).asMap();

    return SizedBox(
      height: 300,
      child: ListView(children: [
        for (int index in logs.keys)
          LogListItem(
              index, index == selectedIndex, logs[index]!, onSelectionChanged)
      ]),
    );
  }
}

class LogListItem extends StatelessWidget {
  final int index;
  final bool isSelected;
  final Commit commit;
  final Function(int index) onTap;
  const LogListItem(this.index, this.isSelected, this.commit, this.onTap,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey))),
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
            color: isSelected ? Colors.blue : Colors.white,
            height: 25,
            child: Row(
              children: [
                Container(
                    width: 300,
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(commit.message.trim())),
                SizedBox(
                    width: 120,
                    child: Text(
                        DateTime.fromMillisecondsSinceEpoch(1000 * commit.time)
                            .toString()
                            .substring(0, 16))),
                SizedBox(width: 60, child: Text(commit.author.name)),
                SizedBox(
                    width: 100, child: Text(commit.oid.sha.substring(0, 8))),
              ],
            )),
      ),
    );
  }
}

class CommitView extends StatelessWidget {
  final Repository repo;
  final int selectedCommitIndex;
  const CommitView(this.repo, this.selectedCommitIndex, {super.key});

  @override
  Widget build(BuildContext context) {
    var list = repo.log(oid: repo.head.target);
    var commit = list[selectedCommitIndex];
    print(commit.parents[0]);
    var parentOid = commit.parents[0];
    var commitParent = Commit.lookup(repo: repo, oid: parentOid);

    var diff = Diff.treeToTree(
        repo: repo, oldTree: commitParent.tree, newTree: commit.tree);

    return Row(children: [
      SizedBox(
        width: 400,
        child: Column(
          children: [
            CommitMessageView(repo, commit),
            Expanded(child: CommitFilesView(repo, diff)),
          ],
        ),
      ),
      Expanded(child: CommitDiffsView(repo, diff))
    ]);
  }
}

class CommitMessageView extends StatelessWidget {
  final Repository repo;
  final Commit commit;
  const CommitMessageView(this.repo, this.commit, {super.key});

  @override
  Widget build(BuildContext context) {
    Widget itemOf(String label, String content) {
      return Row(children: [
        Text(label + ": ", style: TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            content,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ]);
    }

    return Container(
      height: 150,
      padding: EdgeInsets.all(3),
      color: Color(0xffffffcc),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        itemOf("OID", commit.oid.sha),
        itemOf("作者", commit.author.name),
        itemOf(
            "作成日時",
            DateTime.fromMillisecondsSinceEpoch(1000 * commit.time)
                .toString()
                .substring(0, 19)),
        SizedBox(height: 12),
        Text(
          commit.message,
          textAlign: TextAlign.start,
        ),
      ]),
    );
  }
}

class CommitFilesView extends StatelessWidget {
  final Repository repo;
  final Diff diff;
  const CommitFilesView(this.repo, this.diff, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      color: Color(0xffaaffcc),
      child: Column(children: [
        for (var d in diff.patches)
          Row(
            children: [
              Text(
                d.delta.newFile.path,
                maxLines: 1,
              ),
            ],
          )
      ]),
    );
  }
}

class CommitDiffsView extends StatelessWidget {
  final Repository repo;
  final Diff diff;
  const CommitDiffsView(this.repo, this.diff, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffaaaaff),
      child: ListView(children: [
        for (var d in diff.patches)
          Container(
            padding: EdgeInsets.all(5),
            decoration: const BoxDecoration(
                border: Border(
                    bottom: BorderSide(width: 1.0, color: Colors.black))),
            child: Text(d.text.trim()),
          )
      ]),
    );
  }
}
