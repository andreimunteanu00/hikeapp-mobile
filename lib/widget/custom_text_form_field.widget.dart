import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {

  final double? labelWidth;
  final String? initialValue;
  final String? labelText;
  final TextInputType? keyboardType;
  final Function? onChange;
  final bool? enabled;
  final String? Function(String?)? validator;

  const CustomTextFormField({super.key,
    this.labelWidth,
    this.initialValue,
    this.labelText,
    this.keyboardType,
    this.onChange,
    this.enabled,
    this.validator
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: labelWidth,
      child: TextFormField(
        enabled: enabled,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.blue.shade300),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
        ),
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        keyboardType: keyboardType,
        validator: validator,
            /*(value) {
          if (value!.isEmpty) {
            return validatorText;
          }
          return null;
        },*/
        onSaved: (value) => onChange!(value),
      ),
    );
  }
}