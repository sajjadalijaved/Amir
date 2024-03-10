import 'package:intl/intl.dart';
import 'create_note_screen.dart';
import 'package:flutter/material.dart';
import '../JsonModels/note_model.dart';
import 'package:note_app/SQLite/sqlite.dart';
import 'package:note_app/Views/detail_screen.dart';

// ignore_for_file: use_build_context_synchronously

// ignore_for_file: public_member_api_docs, sort_constructors_first, must_be_immutable

class NotesScreen extends StatefulWidget {
  const NotesScreen({
    super.key,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late DatabaseHelper helper;
  late Future<List<NoteModel>> notes;

  late TextEditingController title;
  late TextEditingController content;
  late TextEditingController search;

  @override
  void initState() {
    super.initState();
    title = TextEditingController();
    content = TextEditingController();
    search = TextEditingController();
    helper = DatabaseHelper();
    notes = helper.fetchData();

    // helper.notesDB().whenComplete(() {
    //   notes = getAllNotes();
    // });
  }

  Future<List<NoteModel>> getAllNotes() async {
    return await helper.fetchData();
  }

  Future<void> refresh() async {
    setState(() {
      notes = helper.fetchData();
    });
  }

  Future<List<NoteModel>> searchNote() {
    return helper.searchNotes(search.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: const Color(0xff734a34).withOpacity(.2),
                borderRadius: BorderRadius.circular(8)),
            child: TextFormField(
              controller: search,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    notes = searchNote();
                  });
                } else {
                  setState(() {
                    notes = getAllNotes();
                  });
                }
              },
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                  hintText: "Search"),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: FutureBuilder<List<NoteModel>>(
                future: notes,
                builder: (context, AsyncSnapshot<List<NoteModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Center(child: Text("No Notes Avaible"));
                  } else if (snapshot.hasError) {
                    return Center(child: Text(snapshot.error.toString()));
                  } else {
                    final items = snapshot.data ?? <NoteModel>[];
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            shadowColor: const Color(0xff734a34),
                            elevation: 3,
                            child: ListTile(
                              leading: const Icon(
                                Icons.note,
                                size: 30,
                              ),
                              title: Text(
                                items[index].noteTitle.toString(),
                              ),
                              subtitle: Text(DateFormat("yMd").format(
                                  DateTime.parse(items[index].createdAt))),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailSCreen(
                                        title: items[index].noteTitle,
                                        content: items[index].noteContent,
                                        contentId: items[index].noteId!,
                                      ),
                                    )).then((value) {
                                  if (value) {
                                    refresh();
                                  }
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff734a34),
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CreateNote()))
              .then((value) {
            if (value) {
              refresh();
            }
          });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 35,
        ),
      ),
    );
  }
}
