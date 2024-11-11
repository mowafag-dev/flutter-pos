import 'package:flutter/material.dart';
//import 'data_base_helper.dart';

class HomeSidebar extends StatelessWidget {
  final bool isAddClientMode;
  final List<Map<String, dynamic>> selectedMeals;
  final double totalPrice;
  final double originalTotalPrice;
  final VoidCallback onAddClient;
  final Function(int) onRemoveMeal;
  final Function(int) onToggleExpand;
  final Function(int, String) onQuantityChanged;
  final Function(int, String) onDiscountChanged;
  final VoidCallback onExitClientMode;
  final Function(BuildContext) onConfirmAndPrintProcess;
  final VoidCallback onCancelProcess;

  HomeSidebar({
    required this.isAddClientMode,
    required this.selectedMeals,
    required this.totalPrice,
    required this.originalTotalPrice,
    required this.onAddClient,
    required this.onRemoveMeal,
    required this.onToggleExpand,
    required this.onQuantityChanged,
    required this.onDiscountChanged,
    required this.onExitClientMode,
    required this.onConfirmAndPrintProcess,
    required this.onCancelProcess,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 16.0), // Add space between the app bar and the button
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Center the button horizontally
          children: [
            ElevatedButton.icon(
              onPressed: onAddClient,
              icon: Icon(Icons.add, color: Colors.orange), // Orange icon
              label: Text(
                'Add Client',
                style: TextStyle(color: Colors.orange), // Orange text
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White background
                side: BorderSide(color: Colors.orange), // Orange border
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Slightly curved edges
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0), // Adjust padding for width
              ),
            ),
          ],
        ),
        if (isAddClientMode)
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: selectedMeals.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(selectedMeals[index]
                                              ['expanded']
                                          ? Icons.keyboard_arrow_left
                                          : Icons.keyboard_arrow_down),
                                      onPressed: () {
                                        onToggleExpand(index);
                                      },
                                    ),
                                    Text(selectedMeals[index]['name'] ?? ''),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '\$${(selectedMeals[index]['price'] * selectedMeals[index]['quantity']).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        decoration:
                                            selectedMeals[index]['discount'] > 0
                                                ? TextDecoration.lineThrough
                                                : TextDecoration.none,
                                        color:
                                            selectedMeals[index]['discount'] > 0
                                                ? Colors.grey
                                                : Colors.black,
                                      ),
                                    ),
                                    if (selectedMeals[index]['discount'] > 0)
                                      Text(
                                        '\$${(selectedMeals[index]['price'] * selectedMeals[index]['quantity'] - selectedMeals[index]['discount']).toStringAsFixed(2)}',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    Text(
                                      'Qty: ${selectedMeals[index]['quantity']}, Disc: ${selectedMeals[index]['discount']}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    onRemoveMeal(index);
                                  },
                                ),
                              ],
                            ),
                            subtitle: selectedMeals[index]['expanded']
                                ? Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                labelText: 'Quantity',
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                onQuantityChanged(index, value);
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                labelText: 'Discount',
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                onDiscountChanged(index, value);
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          'Discounted Price: \$${(selectedMeals[index]['price'] * selectedMeals[index]['quantity'] - selectedMeals[index]['discount']).toStringAsFixed(2)}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                          Divider(),
                        ],
                      );
                    },
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (totalPrice != originalTotalPrice)
                        Text(
                          'Total: \$${originalTotalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            fontSize: 14,
                          ),
                        ),
                      Text(
                        'Total after Discount: \$${totalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        onConfirmAndPrintProcess(context);
                      },
                      child: Text('Confirm & Print'),
                    ),
                    ElevatedButton(
                      onPressed: onCancelProcess,
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        if (!isAddClientMode) Spacer(),
      ],
    );
  }
}
