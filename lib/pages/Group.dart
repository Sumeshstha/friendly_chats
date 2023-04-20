import 'package:flutter/material.dart';

class GroupsPage extends StatefulWidget {
  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final List<String> groups = [    'Group A',    'Group B',    'Group C',    'Group D',    'Group E', "Group f", 
  "Group G", "Group H", "Group I", "Group J", "Group K", "Group L"  ];

  final TextEditingController _newGroupController = TextEditingController();

  void _showNewGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create new group'),
          content: TextField(
            controller: _newGroupController,
            decoration: InputDecoration(hintText: 'Enter group name'),
          ),
          actions: [
              TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                setState(() {
                  groups.add(_newGroupController.text);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Groups'),
      ),
      body: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              child: Text(groups[index][0]),
            ),
            title: Text(groups[index]),
            subtitle: Text('5 members'),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                // Show options for this group
              },
            ),
            onTap: () {
              // Navigate to the chat page for this group
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _newGroupController.clear();
          _showNewGroupDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
