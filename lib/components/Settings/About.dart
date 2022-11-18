import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:spotube/components/Shared/Hyperlink.dart';
import 'package:spotube/hooks/usePackageInfo.dart';

const licenseText = """
BSD-4-Clause License

Copyright (c) 2022 Jay Barot. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. All advertising materials mentioning features or use of this software must display the following acknowledgement:
This product includes software developed by Jay Barot.
4. Neither the name of the Software nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY JAY BAROT AND CONTRIBUTORS  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JAY BAROT AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
""";

class About extends HookWidget {
  const About({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = usePackageInfo(
      appName: "Spotube",
      packageName: "oss.krtirtho.Spotube",
      version: "2.5.0",
    );

    return ListTile(
      leading: const Icon(Icons.info_outline_rounded),
      title: const Text("About Spotube"),
      onTap: () {
        showAboutDialog(
            context: context,
            applicationIcon:
                CircleAvatar(child: Image.asset("assets/spotube-logo.png")),
            applicationName: "Spotube",
            applicationVersion: info.version,
            applicationLegalese: licenseText,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Author: "),
                  Hyperlink(
                    "JAY BAROT",
                    "https://linktr.ee/Jay_barot",
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                children: const [
                  Hyperlink(
                    "💚 Sponsor/Donate 💚",
                    "https://checkout.stripe.com/c/pay/cs_live_a1kUjcaQ9jqT4PjGo6PqMSXtPVeav22sQ2I16L1WdlRXRVMNveQ6pyWdGy#fidkdWxOYHwnPyd1blppbHNgWjA0Tk1HN0JWQG58c1wzfTBmdEd3V0RdQnIwTE5gUG4wNW5pcXF3dzdJc0tpfWd1XFBxSmJhTVJdUFxfS0YzTExuajNJfDBSYmNHbDVfS30xQ3xBbzU0UkIwNTVwak52SGltdicpJ3VpbGtuQH11anZgYUxhJz8nYFNkZlRMYjN8NmZ9NzVANz1kJyknd2BjYHd3YHdKd2xibGsnPydtcXF1dj8qKmZtYGZuanBxK3Zxd2x1YCtmamgqJ3gl",
                  ),
                  Text(" • "),
                  Hyperlink(
                    "BSD-4-Clause LICENSE",
                    "https://github.com/KRTirtho/spotube/blob/master/LICENSE",
                  ),
                  Text(" • "),
                  Hyperlink(
                    "Bug Report",
                    "https://github.com/KRTirtho/spotube/issues/new?assignees=&labels=bug&template=bug_report.md&title=",
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Center(child: Text("© Spotube 2022. All rights reserved"))
            ]);
      },
    );
  }
}
