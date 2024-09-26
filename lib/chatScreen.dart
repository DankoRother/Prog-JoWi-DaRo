import 'package:flutter/material.dart';
import 'chatBot_service.dart'; // Import the service for interacting with the AI chatbot
import 'appBar.dart'; // Import the custom AppBar

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState(); // Create the state for ChatScreen
}

class _ChatScreenState extends State<ChatScreen> {
  final OpenAIService _openAIService = OpenAIService(); // Instance of OpenAIService to handle API calls
  final TextEditingController _controller = TextEditingController(); // Controller for the text input field
  List<Map<String, String>> _messages = []; // List to store chat messages

  // Function to send a message to the AI
  void _sendMessage() async {
    String userMessage = _controller.text; // Get the user's message from the input field
    setState(() {
      _messages.add({'role': 'user', 'content': userMessage}); // Add user's message to the message list
    });
    _controller.clear(); // Clear the input field

    // Get the AI's response based on the user's message
    String botResponse = await _openAIService.sendMessage(userMessage);
    setState(() {
      _messages.add({'role': 'assistant', 'content': botResponse}); // Add the bot's response to the message list
    });
  }

  // Widget to build individual message bubbles
  Widget _buildMessage(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft, // Align based on user or bot
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Margin around the message bubble
        padding: EdgeInsets.all(12), // Padding inside the message bubble
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300], // Color based on who sent the message
          borderRadius: BorderRadius.circular(10), // Rounded corners for the message bubble
        ),
        child: Text(
          message, // Display the message text
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black, // Text color based on sender
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        loggedInTitle: 'Ask AI for Inspiration', // Title when logged in
        loggedOutTitle: 'Ask AI for Inspiration', // Title when not logged in
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length, // Number of messages in the list
              itemBuilder: (context, index) {
                var message = _messages[index]; // Get the message at the current index
                return _buildMessage(message['content']!, message['role'] == 'user'); // Build the message bubble
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0), // Padding around the input field
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller, // Connect the controller to the text field
                    decoration: InputDecoration(hintText: "Type in a message..."), // Hint text for the input field
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send), // Send button icon
                  onPressed: _sendMessage, // Trigger sending the message when pressed
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
