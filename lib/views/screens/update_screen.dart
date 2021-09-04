import 'package:flutter/material.dart';
import 'package:gallery/core/models/models.dart';
import 'package:gallery/views/widgets/form/update_wallet_form.dart';

class UpdateScreen extends StatefulWidget {
  final int index;
  final Wallet wallet;

  const UpdateScreen({
    required this.index,
    required this.wallet,
  });

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Update Info'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: UpdateWalletForm(
          index: widget.index,
          wallet: widget.wallet,
        ),
      ),
    );
  }
}