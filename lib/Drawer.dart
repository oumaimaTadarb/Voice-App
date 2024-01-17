// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class Drawerr extends StatefulWidget {
  late String language;
  String selectLange = "fr";
  final Function(String) onLanguageChanged; // Add this line

  Drawerr({required this.language, required this.onLanguageChanged});

  @override
  State<Drawerr> createState() => _DrawerrState();
}

class _DrawerrState extends State<Drawerr> {
  void change(String lang) {
    setState(() {
      widget.language = lang;
    });
  }

  @override
  void initState() {
    super.initState();
    change(widget.selectLange); // Use widget.selectLange
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue, // Set a background color for the header
            ),
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white, // Set text color for the header
                fontSize: 24,
              ),
            ),
          ),
          ExpansionTile(
            title: Text("Choose language"),
            children: [
              ListTile(
                title: Text("French"),
                onTap: () {
                  setState(() {
                    change("French");
                  });
                  widget.onLanguageChanged("French");
                },
              ),
              ListTile(
                title: Text("English"),
                onTap: () {
                  setState(() {
                    change("English");
                  });
                  widget.onLanguageChanged("English");
                },
              )
            ],
          ),
          ExpansionTile(
            title: Text("Choose Voice"),
            children: [
              ListTile(title: Text("Man")),
              ListTile(title: Text("Woman"))
            ],
          ),
        ],
      ),
    );
  }
}
