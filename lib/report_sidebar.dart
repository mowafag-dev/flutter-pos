// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ReportSidebar extends StatelessWidget {
//   final DateTime selectedDate;
//   final List<DateTime> availableDates;
//   final ValueChanged<DateTime> onDateSelected;

//   ReportSidebar({
//     required this.selectedDate,
//     required this.availableDates,
//     required this.onDateSelected,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: availableDates.length,
//       itemBuilder: (context, index) {
//         final date = availableDates[index];
//         final isSelected = date == selectedDate;
//         final displayDate = DateFormat('yyyy-MM-dd').format(date);
//         final dayLabel = index == 0
//             ? 'Today'
//             : index == 1
//                 ? 'Yesterday'
//                 : displayDate;

//         return GestureDetector(
//           onTap: () => onDateSelected(date),
//           child: Container(
//             color: isSelected ? Colors.orange[100] : Colors.transparent,
//             padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//             child: Text(
//               dayLabel,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 color: isSelected ? Colors.orange : Colors.black,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
