import 'package:flutter/material.dart';
import '/services/database_helper.dart';

class SqlitePage extends StatefulWidget {
  const SqlitePage({super.key});

  @override
  State<SqlitePage> createState() => _SqlitePageState();
}

class _SqlitePageState extends State<SqlitePage> {
  DatabaseHelper dbHelper = DatabaseHelper();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  List<Map<String, dynamic>> users = [];

  Future<void> _addUser() async {
    await dbHelper.insertUser({
      'name': _nameController.text,
      'email': _emailController.text,
    });
    _nameController.clear();
    _emailController.clear();
  }

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  Future<void> _refreshUsers() async {
    final data = await dbHelper.getUsers();
    setState(() {
      users = data;
    });
  }

  void _showForm(int? id) {
    if (id != null) {
      final existingUser = users.firstWhere((element) => element['id'] == id);
      _nameController.text = existingUser['name'];
      _emailController.text = existingUser['email'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'ชื่อ'),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'อีเมล'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (id == null) {
                      _addUser();
                    } else {
                      _updateUser(id);
                    }
                    Navigator.of(context).pop(); // ปิด bottom sheet
                  },
                  child: Text(id == null ? 'เพิ่มข้อมูล' : 'แก้ไขข้อมูล'),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateUser(int id) async {
    await dbHelper.updateUser({
      'id': id,
      'name': _nameController.text,
      'email': _emailController.text,
    });
    _nameController.clear();
    _emailController.clear();
    _refreshUsers();
  }

  Future<void> _deleteUser(int id) async {
    await dbHelper.deleteUser(id);
    _refreshUsers(); // อัปเดตรายการข้อมูล

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('รายการข้อมูล'),
      ),
      body: users.isEmpty
          ? Center(
              child: Text(
                  'ไม่มีข้อมูล กรุณาเพิ่มข้อมูลใหม่'), // ข้อความแสดงที่กลางหน้าจอเมื่อไม่มีข้อมูล
            )
          : ListView.builder(
              itemCount: users.length, // จํานวนข้อมูลในรายการ
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(users[index]['name']),
                  subtitle: Text(users[index]['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                  onPressed: () => _showForm(users[index]['id']),
                ),
                IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _deleteUser(users[index]['id']),
                ),
                    ],

                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
