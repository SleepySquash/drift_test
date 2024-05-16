import 'package:flutter/material.dart';

class SingleFieldWidget extends StatefulWidget {
  const SingleFieldWidget({super.key});

  @override
  State<SingleFieldWidget> createState() => _SingleFieldWidgetState();
}

class _SingleFieldWidgetState extends State<SingleFieldWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        child: Container(
          width: 300,
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                decoration: const InputDecoration(label: Text('URL')),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_controller.text),
                child: const Text('Ok'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
