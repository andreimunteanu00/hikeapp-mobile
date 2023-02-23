import 'package:flutter/cupertino.dart';
import 'package:hikeappmobile/widget/sign_out.widget.dart';

class AccountSuspendedScreen extends StatelessWidget{

  const AccountSuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('This account is suspended!'),
        const Text('For more details contact the support!'),
        SignOutWidget()
      ],
    );
  }
}