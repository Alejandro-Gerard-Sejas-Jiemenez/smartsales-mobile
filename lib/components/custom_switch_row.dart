import 'package:flutter/material.dart';

class CustomSwitchRow extends StatelessWidget {
  final bool isActive;
  final bool isStaff;
  final ValueChanged<bool> onActiveChanged;
  final ValueChanged<bool> onStaffChanged;

  const CustomSwitchRow({
    Key? key,
    required this.isActive,
    required this.isStaff,
    required this.onActiveChanged,
    required this.onStaffChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.indigo[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Switch(
                  value: isActive,
                  onChanged: onActiveChanged,
                  activeColor: Color(0xFF283593),
                ),
                SizedBox(width: 4),
                Text('Activo', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              children: [
                Switch(
                  value: isStaff,
                  onChanged: onStaffChanged,
                  activeColor: Colors.indigo,
                ),
                SizedBox(width: 4),
                Text('Staff', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
