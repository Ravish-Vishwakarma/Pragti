import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'package:pragti/Data/urls.dart';
import 'package:pragti/Widgets/style.dart';

class AskAiPage extends StatefulWidget {
  const AskAiPage({super.key});

  @override
  State<AskAiPage> createState() => _AskAiPageState();
}

class _AskAiPageState extends State<AskAiPage> {
  final TextEditingController _searchcontroller = TextEditingController();
  var mddata = "";
  bool isDrawerExpanded = false; // Left drawer (already in your app)
  bool isRightPanelExpanded = false; // For saved chats sidebar
  bool _isloading = false;
  Future<void> sendAIPrompt() async {
    setState(() {
      _isloading = true;
    });
    final url = Uri.parse(Urls.sendaiprompt);
    var body = json.encode({"prompt": _searchcontroller.text});
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode == 200) {
      setState(() {
        mddata =
            json.decode(
              response.body,
            )["candidates"][0]['content']["parts"][0]["text"];
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.forestgreen,
      // appBar: MyAppbar(title: "ASK AI"),
      body: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(0),
          bottomLeft: Radius.circular(1),
        ),
        child: Container(
          color: Colors.white,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main content area
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: SearchBar(
                              onSubmitted: (value) {
                                sendAIPrompt();
                                _searchcontroller.clear();
                              },
                              controller: _searchcontroller,
                              leading: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.add),
                              ),
                              hintText: "Ask",
                              hintStyle: WidgetStateProperty.all(
                                TextStyle(color: Colors.black.withOpacity(0.5)),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              trailing: [
                                IconButton(
                                  onPressed: () {
                                    sendAIPrompt();
                                    _searchcontroller.clear();
                                  },
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isRightPanelExpanded = !isRightPanelExpanded;
                              });
                            },
                            icon: Icon(
                              isRightPanelExpanded
                                  ? Icons.close
                                  : Icons.bookmark_border,
                              color: Colors.black,
                            ),
                            tooltip: "Toggle Saved Chats",
                          ),
                        ],
                      ),
                    ),

                    _isloading
                        ? const Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              child: MarkdownBody(
                                data: mddata,
                                softLineBreak: true,
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(color: Colors.black),
                                  listBullet: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),

              // Right side saved chats panel (animated)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250), // fast animation
                curve: Curves.easeInOut,
                width: isRightPanelExpanded ? 220 : 0,
                color: const Color.fromARGB(255, 226, 226, 226),
                child:
                    isRightPanelExpanded
                        ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                "Saved Chats",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: 6,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                      "Chat ${index + 1}",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    onTap: () {
                                      // Later: load chat from saved data
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
