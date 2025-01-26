import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/views/chat_page.dart';
import 'package:chat_app/views/login_page.dart';
import 'package:chat_app/widgets/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //logout function
  void logout(BuildContext context) async {
    AuthService auth = AuthService();
    try {
      await auth.signOut();
    } catch (e) {
      CustomToast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthService auth = AuthService();
    ChatService chat = ChatService();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home Page',
          style: TextStyle(color: Colors.blue),
        ),
        actions: [
          IconButton(
            onPressed: () {
              logout(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ));
            }, // Pass context here
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chat.fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CupertinoActivityIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          List<Map<String, dynamic>> users = snapshot.data!;
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              if (users[index]['email'] != auth.getCurrentUser()!.email) {
                return ListTile(
                  title: Text(users[index]['name'] ?? 'No Name'),
                  subtitle: Text(users[index]['email'] ?? 'No Email'),
                  leading: Icon(Icons.person),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                              name: users[index]['name'],
                              receiver: users[index]['uid']),
                        ));
                  },
                );
              } else {
                return Container();
              }
            },
          );
        },
      ),
    );
  }
}
