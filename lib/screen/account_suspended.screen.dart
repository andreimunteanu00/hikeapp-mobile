import 'package:flutter/cupertino.dart';

class AccountSuspendedScreen extends StatelessWidget{

  const AccountSuspendedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text('This account is suspended!'),
        Text('For more details contact the support!')
      ],
    );
  }
}