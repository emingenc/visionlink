import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

import 'package:url_launcher/url_launcher_string.dart';

void showCustomAboutDialog(BuildContext context) async {
  var version = "unknown";
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
  } catch (_) {}
  if (context.mounted) {
    showAboutDialog(
      context: context,
      applicationName: "visionlink",
      applicationVersion: version,
      applicationIcon: Image.asset(
        'assets/icons/visionlink.png',
        width: 56,
        height: 56,
      ),
      children: [
        OutlinedButton(
          onPressed: () => launchUrlString(
            "https://github.com/emingenc/visionlink",
            mode: LaunchMode.externalApplication,
          ),
          child: Row(
            children: [
              Icon(Icons.code),
              const SizedBox(width: 10),
              Text("Source Code"),
            ],
          ),
        ),
        const SizedBox(height: 2),
        
      ],
    );
  }
}
