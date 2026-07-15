import 'package:flutter/material.dart';

class SettingsUserDialog extends StatelessWidget {
  SettingsUserDialog({super.key});

  final TextEditingController controller = TextEditingController(text: "Maddie");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
              child: TextField(
                controller: controller,
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: OutlineInputBorder()
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 48, 8, 24),
                  child: InkWell(
                    customBorder: CircleBorder(),
                    onTap: () {},
                    child: CircleAvatar(
                      backgroundColor: Color(0xFFC2B7F0),
                      radius: 72,
                      child: Text(
                        "🪨",
                        style: TextStyle(
                          fontSize: 66
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 32.0,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SizedBox(
                        width: 96,
                        height: 96,
                        child: Center(
                          child: Text(
                            "🪨",
                            style: TextStyle(
                              fontSize: 48
                            )
                          )
                        )
                      ),
                    ),
                    Text("Foreground")
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Color(0xFFC2B7F0),
                        ),
                      ),
                    ),
                    Text("Background")
                  ],
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ListTile(
                leading: Icon(Icons.logout_outlined),
                title: Text("Log out"),
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {},
              ),
            )
          ],
        ),
      ),
    );
  }
}