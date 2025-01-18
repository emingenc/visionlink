import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'constants.dart';

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    void navigateHome(AuthResponse response) {
      Navigator.of(context).pushReplacementNamed('/home');
    }

    return Scaffold(
      appBar: appBar('Sign In'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SupaEmailAuth(
                  redirectTo: kIsWeb ? null : 'dev.visionlink.coreos://',
                  onSignInComplete: navigateHome,
                  onSignUpComplete: (AuthResponse response) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please check your email to confirm your account.'),
                          ),
                        );
                      },
                  metadataFields: [
                    MetaDataField(
                      prefixIcon: const Icon(Icons.person),
                      label: 'Username',
                      key: 'username',
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter something';
                        }
                        return null;
                      },
                    ),
                    BooleanMetaDataField(
                      label: 'Keep me up to date with the latest news and updates.',
                      key: 'marketing_consent',
                      checkboxPosition: ListTileControlAffinity.leading,
                    ),
                    BooleanMetaDataField(
                      key: 'terms_agreement',
                      isRequired: true,
                      checkboxPosition: ListTileControlAffinity.leading,
                      richLabelSpans: [
                        const TextSpan(text: 'I have read and agree to the '),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: const TextStyle(
                            color: Color.fromARGB(255, 12, 142, 112),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Handle tap on Terms and Conditions
                            },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
