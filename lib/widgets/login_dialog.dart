import 'dart:math';

import 'package:appwrite/appwrite.dart';
import 'package:chicken_thoughts_notifications/data/user.dart';
import 'package:chicken_thoughts_notifications/net/database_manager.dart';
import 'package:chicken_thoughts_notifications/pages/settings_user.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:progress_indicator_m3e/progress_indicator_m3e.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController nameController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  LoginState state = LoginState.name;
  Widget? content;
  List<Widget>? actions;
  List<ChickenThoughtsUser>? matchedUsers;

  Future<void> createNewUser() async {
    Box settings = Hive.box("settings");
    // Seed random based on inputted name (for funsies!)
    Random random = Random(nameController.text.codeUnits.fold(0, (hash, char) => (hash! * 31 + char) & 0xFFFFFFFF));
    String id = ID.unique();
    int emoji = random.nextInt(userEmojis.length);
    int color = random.nextInt(userColors.length);
    settings.put("user.id", id);
    settings.put("user.name", nameController.text);
    settings.put("user.emoji", emoji);
    settings.put("user.color", color);

    // Push to database
    await DatabaseManager.createUser(id, nameController.text, emoji, color);

    if (mounted) Navigator.pushReplacementNamed(context, "/settings/user");
  }

  Future<void> submitName() async {
    setState(() {
      state = LoginState.loading;
    });

    matchedUsers = await DatabaseManager.getUsersMatchingName(nameController.text);

    if (matchedUsers == null || matchedUsers!.isEmpty) {
      await createNewUser();
    } else {
      setState(() {
        state = LoginState.matching;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state == LoginState.name) {
      content = Form(
        key: formKey,
        child: TextFormField(
          autofocus: true,
          onFieldSubmitted: (value) {
            submitName();
          },
          controller: nameController,
          decoration: InputDecoration(
            label: Text("Name")
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter your name";
            }
            return null;
          },
        ),
      );
      actions = [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel")
        ),
        TextButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              submitName();
            }
          },
          child: Text("OK")
        ),
      ];
    } else if (state == LoginState.loading) {
      content = LinearProgressIndicatorM3E();
      actions = null;
    } else {
      content = ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: double.maxFinite,
          minWidth: double.maxFinite,
          maxHeight: 600
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8.0,
          children: [
            Text("The following users were found with the same name. Log into one of these existing accounts?"),
            ListView.builder(
              shrinkWrap: true,
              itemCount: matchedUsers!.length + 1,
              itemBuilder: (context, index) {
                if (index == matchedUsers!.length) {
                  return ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minTileHeight: 72,
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                      child: Icon(Icons.create),
                    ),
                    title: Text("Create new user"),
                    onTap: () async {
                      setState(() {
                        state = LoginState.loading;
                      });
                      await createNewUser();
                    },
                  );
                }

                ChickenThoughtsUser user = matchedUsers![index];
            
                return ListTile(
                  minTileHeight: 72,
                  title: Text(user.name),
                  leading: CircleAvatar(
                    backgroundColor: userColors[user.iconBg],
                    child: Text(userEmojis[user.iconFg]),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    Box settings = Hive.box("settings");
                    settings.put("user.id", user.id);
                    settings.put("user.name", user.name);
                    settings.put("user.emoji", user.iconFg);
                    settings.put("user.color", user.iconBg);
                    Navigator.pushReplacementNamed(context, "/settings/user");
                  },
                );
              }
            ),
          ],
        ),
      );
      actions = [
        TextButton(
          onPressed: () {
            setState(() {
              state = LoginState.name;
            });
          },
          child: Text("Back")
        ),
      ];
    }

    return PopScope(
      canPop: state != LoginState.loading,
      child: AlertDialog(
        title: Text("Login"),
        content: AnimatedSize(
          duration: Durations.short2,
          child: content
        ),
        actions: actions
      ),
    );
  }
}

enum LoginState {
  name,
  matching,
  loading
}