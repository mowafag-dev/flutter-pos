import 'package:flutter/material.dart';
import 'data_base_helper.dart';

class CustomersContent extends StatelessWidget {
  final List<Map<String, dynamic>> customers;
  final DateTime selectedDate;

  CustomersContent({
    required this.customers,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Customer ${customers[index]['day_id']}'),
          subtitle: Text(customers[index]['date']),
          onTap: () async {
            List<Map<String, dynamic>> invoices =
                await DatabaseHelper().getInvoices();
            List<Map<String, dynamic>> customerInvoices = invoices
                .where((invoice) =>
                    invoice['customerId'] == customers[index]['id'])
                .toList();

            StringBuffer invoice = StringBuffer();
            invoice.writeln('Customer Invoice');
            invoice.writeln('Date: ${customers[index]['date']}');
            invoice.writeln('-----------------');
            invoice.writeln('Client: Customer ${customers[index]['day_id']}');
            invoice.writeln('Items:');
            double totalPrice = 0.0;
            double totalDiscount = 0.0;

            for (var invoiceItem in customerInvoices) {
              var meal =
                  await DatabaseHelper().getMealById(invoiceItem['mealId']);
              double mealPrice = meal['price'] ?? 0.0;
              int quantity = invoiceItem['quantity'] ?? 1;
              double discount = invoiceItem['discount'] ?? 0.0;

              invoice.writeln(
                  '${meal['name']} - $quantity x \$${mealPrice.toStringAsFixed(2)} = \$${(mealPrice * quantity).toStringAsFixed(2)}');
              if (discount > 0) {
                invoice.writeln('Discount: \$${discount.toStringAsFixed(2)}');
              }

              totalPrice += mealPrice * quantity;
              totalDiscount += discount;
            }

            double originalTotalPrice = totalPrice;
            totalPrice -= totalDiscount;

            invoice.writeln('-----------------');
            if (totalPrice != originalTotalPrice) {
              invoice
                  .writeln('Total: \$${originalTotalPrice.toStringAsFixed(2)}');
            }
            invoice.writeln(
                'Total after Discount: \$${totalPrice.toStringAsFixed(2)}');

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                      'Invoices for Customer ${customers[index]['day_id']}'),
                  content: SingleChildScrollView(
                    child: Text(invoice.toString()),
                  ),
                  actions: [
                    TextButton(
                      child: Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}


// class CustomersContent extends StatelessWidget {
//   final List<Map<String, dynamic>> customers;
//   final DateTime selectedDate;

//   CustomersContent({
//     required this.customers,
//     required this.selectedDate,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: customers.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text('Customer ${customers[index]['id']}'),
//           subtitle: Text(customers[index]['date']),
//           onTap: () async {
//             List<Map<String, dynamic>> invoices =
//                 await DatabaseHelper().getInvoices();
//             List<Map<String, dynamic>> customerInvoices = invoices
//                 .where((invoice) =>
//                     invoice['customerId'] == customers[index]['id'])
//                 .toList();

//             StringBuffer invoice = StringBuffer();
//             invoice.writeln('Customer Invoice');
//             invoice.writeln('Date: ${customers[index]['date']}');
//             invoice.writeln('-----------------');
//             invoice.writeln('Client: Customer ${customers[index]['id']}');
//             invoice.writeln('Items:');
//             double totalPrice = 0.0;
//             double totalDiscount = 0.0;

//             for (var invoiceItem in customerInvoices) {
//               var meal =
//                   await DatabaseHelper().getMealById(invoiceItem['mealId']);
//               double mealPrice = meal['price'] ?? 0.0;
//               int quantity = invoiceItem['quantity'] ?? 1;
//               double discount = invoiceItem['discount'] ?? 0.0;

//               invoice.writeln(
//                   '${meal['name']} - $quantity x \$${mealPrice.toStringAsFixed(2)} = \$${(mealPrice * quantity).toStringAsFixed(2)}');
//               if (discount > 0) {
//                 invoice.writeln('Discount: \$${discount.toStringAsFixed(2)}');
//               }

//               totalPrice += mealPrice * quantity;
//               totalDiscount += discount;
//             }

//             double originalTotalPrice = totalPrice;
//             totalPrice -= totalDiscount;

//             invoice.writeln('-----------------');
//             if (totalPrice != originalTotalPrice) {
//               invoice
//                   .writeln('Total: \$${originalTotalPrice.toStringAsFixed(2)}');
//             }
//             invoice.writeln(
//                 'Total after Discount: \$${totalPrice.toStringAsFixed(2)}');

//             showDialog(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title:
//                       Text('Invoices for Customer ${customers[index]['id']}'),
//                   content: SingleChildScrollView(
//                     child: Text(invoice.toString()),
//                   ),
//                   actions: [
//                     TextButton(
//                       child: Text('OK'),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ],
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }
