import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/components/Lyrics/SyncedLyrics.dart';

class LyricDelayAdjustDialog extends HookConsumerWidget {
  const LyricDelayAdjustDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useTextEditingController(
      text: ref.read(lyricDelayState).inMilliseconds.toString(),
    );

    double getValue() =>
        double.tryParse(controller.text.replaceAll("ms", "")) ?? 0;

    return AlertDialog(
      title: const Center(child: Text("Adjust Lyrics Delay")),
      actions: [
        ElevatedButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text("Done"),
          onPressed: () {
            Navigator.of(context).pop(
              Duration(
                milliseconds: getValue().toInt(),
              ),
            );
          },
        )
      ],
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_rounded),
            onPressed: () {
              controller.text = "${getValue() - 25}ms";
            },
          ),
          Flexible(
            child: TextField(
              keyboardType: TextInputType.number,
              controller: controller,
              decoration: const InputDecoration(
                isDense: true,
                hintText: "Delay in milliseconds",
              ),
              onSubmitted: (_) {
                Navigator.of(context).pop(
                  Duration(
                    milliseconds: getValue().toInt(),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              controller.text = "${getValue() + 25}ms";
            },
          ),
        ],
      ),
    );
  }
}
