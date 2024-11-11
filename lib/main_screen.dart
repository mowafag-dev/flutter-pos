import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'data_base_helper.dart';
import 'report_content.dart';
import 'setting_page.dart';
import 'home_sidebar_page.dart';
import 'customer_content.dart';
import 'home_content_page.dart';
import 'main.dart';

class DigitalClock extends StatefulWidget {
  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  String _timeString = "";
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('d/M/yyyy').format(now);
    final String formattedTime = DateFormat('hh:mm:ss a').format(now);
    if (mounted) {
      setState(() {
        _timeString =
            'make sure the date is correct  $formattedDate - $formattedTime';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _timeString,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isAddClientMode = false;
  List<Map<String, dynamic>> _selectedMeals = [];
  List<Map<String, dynamic>> _meals = [];
  List<Map<String, dynamic>> _customers = [];
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _availableDates = [];
  DateTime _selectedCustomerDate = DateTime.now();
  List<DateTime> _availableCustomerDates = [];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home, 'label': 'Home'},
    {'icon': Icons.person, 'label': 'Custom'},
    {'icon': Icons.table_chart, 'label': 'Tables'},
    {'icon': Icons.payment, 'label': 'Cashier'},
    {'icon': Icons.shopping_cart, 'label': 'Orders'},
    {'icon': Icons.assessment, 'label': 'Report'},
    {'icon': Icons.settings, 'label': 'Settings'},
  ];

  final Map<int, List<String>> _categoryLists = {
    0: ['Starter', 'Breakfast', 'Lunch', 'Supper', 'Dessert', 'Beverage'],
    1: ['New Customer', 'Existing Customer', 'Customer Orders'],
    2: ['All Tables', 'Available', 'Occupied', 'Reserved'],
    3: ['New Payment', 'Pending Payments'],
    4: ['New Order', 'Pending Orders', 'Completed Orders'],
    5: ['Daily Report', 'Monthly Report', 'Yearly Report'],
    6: ['Settings 1', 'Settings 2'],
  };

  @override
  void initState() {
    super.initState();
    _loadMeals();
    _loadAvailableDates();

    _loadAvailableCustomerDates();
  }

  Future<void> _loadAvailableCustomerDates() async {
    print('Loading available customer dates...');
    List<DateTime> dates = await DatabaseHelper().getAvailableDates();
    setState(() {
      _availableCustomerDates = dates;
      if (dates.isNotEmpty) {
        _selectedCustomerDate = dates.first;
        _loadCustomersByDate(_selectedCustomerDate);
      }
    });
    print('Available customer dates loaded: $_availableCustomerDates');
  }

  Future<void> _loadCustomersByDate(DateTime date) async {
    print('Loading customers for date: $date...');
    List<Map<String, dynamic>> customers =
        await DatabaseHelper().getCustomersByDate(date);
    setState(() {
      _customers = customers;
    });
    print('Customers loaded: $_customers');
  }

  Future<void> _loadMeals() async {
    List<Map<String, dynamic>> meals = await DatabaseHelper().getMeals();
    setState(() {
      _meals = meals
          .map((meal) => {
                'id': meal['id'],
                'name': meal['name'] ?? '',
                'price': meal['price'] ?? 0.0,
                'image': meal['image'] ?? '',
              })
          .toList();
    });
  }

  Future<void> _loadCustomers() async {
    List<Map<String, dynamic>> customers =
        await DatabaseHelper().getCustomers();
    setState(() {
      _customers = customers
          .map((customer) => {
                'id': customer['id'],
                'name': customer['name'] ?? '',
                'date': customer['date'] ?? '',
              })
          .toList();
    });
  }

  Future<void> _loadAvailableDates() async {
    List<DateTime> dates = await DatabaseHelper().getAvailableDates();
    setState(() {
      _availableDates = dates;
      if (dates.isNotEmpty) {
        _selectedDate = dates.first;
      }
    });
  }

  Future<void> _addCustomer(Map<String, dynamic> customer) async {
    final db = await DatabaseHelper().database;
    String todayDate = DateTime.now().toIso8601String().split('T').first;

    // Check if a customer entry for today already exists
    final existingEntry = await db.query(
      'customers',
      where: 'date LIKE ?',
      whereArgs: ['%$todayDate%'],
    );

    // Insert only if no entry for today's date exists
    if (existingEntry.isEmpty) {
      await DatabaseHelper().insertCustomer(customer);
    }

    await _loadCustomers();
    await _loadAvailableDates(); // Re-fetch available dates after adding a customer

    await _loadAvailableCustomerDates(); // Re-fetch available customer dates after adding a customer
  }

  void _onMealSelected(Map<String, dynamic> meal) {
    if (_isAddClientMode) {
      setState(() {
        meal['quantity'] = 1;
        meal['discount'] = 0.0;
        meal['expanded'] = false;
        _selectedMeals.add(Map.from(meal));
      });
    }
  }

  void _onRemoveMeal(int index) {
    setState(() {
      _selectedMeals.removeAt(index);
    });
  }

  void _onToggleExpand(int index) {
    setState(() {
      _selectedMeals[index]['expanded'] = !_selectedMeals[index]['expanded'];
    });
  }

  void _onQuantityChanged(int index, String value) {
    setState(() {
      _selectedMeals[index]['quantity'] = int.tryParse(value) ?? 1;
    });
  }

  void _onDiscountChanged(int index, String value) {
    setState(() {
      _selectedMeals[index]['discount'] = double.tryParse(value) ?? 0.0;
    });
  }

  double _calculateTotalPrice() {
    double total = _selectedMeals.fold(0.0, (sum, meal) {
      double price = meal['price'] ?? 0.0;
      int quantity = meal['quantity'];
      return sum + (price * quantity);
    });

    double totalDiscount = _selectedMeals.fold(0.0, (sum, meal) {
      return sum + meal['discount'];
    });

    return total - totalDiscount;
  }

  double _calculateOriginalTotalPrice() {
    return _selectedMeals.fold(0.0, (sum, meal) {
      double price = meal['price'] ?? 0.0;
      int quantity = meal['quantity'];
      return sum + (price * quantity);
    });
  }

  void _onAddMeal(Map<String, dynamic> meal) {
    setState(() {
      _meals.add(meal);
    });
  }

  void _onRemoveSettingsMeal(int index) {
    setState(() {
      _meals.removeAt(index);
    });
  }

  void _exitClientMode() {
    setState(() {
      _isAddClientMode = false;
      _selectedMeals.clear();
    });
  }

  Future<void> _refreshCustomers() async {
    await _loadCustomers();
  }

  Future<void> _confirmAndPrintProcess(BuildContext context) async {
    if (_selectedMeals.isNotEmpty) {
      String todayDate = DateTime.now().toIso8601String().split('T').first;

      // Await the database instance
      final db = await DatabaseHelper().database;

      // Fetch the next `day_id` for today
      final List<Map<String, dynamic>> maxDayIdResult = await db.rawQuery('''
      SELECT MAX(day_id) as max_day_id 
      FROM customers 
      WHERE date = ?
    ''', [todayDate]);

      int nextDayId = (maxDayIdResult.first['max_day_id'] as int? ?? 0) + 1;

      // Insert the new customer with the next `day_id`
      int customerId = await DatabaseHelper().insertCustomer({
        'name': 'Customer $nextDayId',
        'date': todayDate,
        'day_id': nextDayId
      });

      // Insert invoices for the selected meals
      for (var meal in _selectedMeals) {
        await DatabaseHelper().insertInvoice({
          'customerId': customerId,
          'mealId': meal['id'],
          'quantity': meal['quantity'],
          'discount': meal['discount'],
        });
      }

      // Refresh the data
      await _refreshCustomers();
      await _loadAvailableDates();
      await _loadAvailableCustomerDates();

      // Generate and show the invoice
      String invoice = _generateInvoice(nextDayId, todayDate);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Invoice'),
            content: SingleChildScrollView(
              child: Text(invoice),
            ),
            actions: [
              TextButton(
                child: Text('Print'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
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

      _exitClientMode();
    }
  }

  String _generateInvoice(int customerId, String date) {
    StringBuffer invoice = StringBuffer();
    invoice.writeln('Customer Invoice');
    invoice.writeln('Date: $date');
    invoice.writeln('-----------------');
    invoice.writeln('Client: Customer $customerId');
    invoice.writeln('Items:');
    for (var meal in _selectedMeals) {
      invoice.writeln(
          '${meal['name']} - ${meal['quantity']} x \$${meal['price']} = \$${(meal['price'] * meal['quantity']).toStringAsFixed(2)}');
      if (meal['discount'] > 0) {
        invoice.writeln('Discount: \$${meal['discount'].toStringAsFixed(2)}');
      }
    }
    invoice.writeln('-----------------');
    if (_calculateTotalPrice() != _calculateOriginalTotalPrice()) {
      invoice.writeln(
          'Total: \$${_calculateOriginalTotalPrice().toStringAsFixed(2)}');
    }
    invoice.writeln(
        'Total after Discount: \$${_calculateTotalPrice().toStringAsFixed(2)}');
    return invoice.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Row(
          children: [
            Text(
              'POS System',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            Container(
              width: 200,
              height: 35,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                ),
                onSubmitted: (value) {
                  print("Search query: $value");
                },
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DigitalClock(),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          VerticalNavigationBar(
            navItems: _navItems,
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 1) {
                  // If "Customer" is selected, set the date to today and load customers
                  _selectedCustomerDate = DateTime.now();
                  _loadCustomersByDate(_selectedCustomerDate);
                }
                if (_selectedIndex != 0) {
                  _selectedMeals.clear();
                }
              });
            },
          ),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                CategoryRow(categories: _categoryLists[_selectedIndex]!),
                Expanded(
                  child: _selectedIndex == 0
                      ? HomeContent(
                          onMealSelected: _onMealSelected,
                          meals: _meals,
                        )
                      : _selectedIndex == 1
                          ? CustomersContent(
                              customers: _customers,
                              selectedDate: _selectedCustomerDate,
                            )
                          : _selectedIndex == 6
                              ? SettingsContent(
                                  onAddMeal: _onAddMeal,
                                  meals: _meals,
                                  onRemoveMeal: _onRemoveSettingsMeal,
                                )
                              : _selectedIndex == 5
                                  ? DailyReportScreen(
                                      selectedDate: _selectedDate)
                                  : OtherContent(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: _selectedIndex == 0
                ? HomeSidebar(
                    isAddClientMode: _isAddClientMode,
                    selectedMeals: _selectedMeals,
                    totalPrice: _calculateTotalPrice(),
                    originalTotalPrice: _calculateOriginalTotalPrice(),
                    onAddClient: () {
                      setState(() {
                        _isAddClientMode = !_isAddClientMode;
                      });
                    },
                    onRemoveMeal: _onRemoveMeal,
                    onToggleExpand: _onToggleExpand,
                    onQuantityChanged: _onQuantityChanged,
                    onDiscountChanged: _onDiscountChanged,
                    onConfirmAndPrintProcess: _confirmAndPrintProcess,
                    onCancelProcess: _exitClientMode,
                    onExitClientMode: _exitClientMode,
                  )
                : _selectedIndex == 5
                    ? ReportSidebar(
                        selectedDate: _selectedDate,
                        availableDates: _availableDates,
                        onDateSelected: (date) {
                          setState(() {
                            _selectedDate = date;
                          });
                        },
                      )
                    : _selectedIndex == 1
                        ? CustomerSidebar(
                            selectedDate: _selectedCustomerDate,
                            availableDates: _availableCustomerDates,
                            onDateSelected: (date) {
                              setState(() {
                                _selectedCustomerDate = date;
                              });
                              _loadCustomersByDate(date);
                            },
                          )
                        : OtherSidebar(),
          ),
        ],
      ),
    );
  }
}

class CustomerSidebar extends StatelessWidget {
  final DateTime selectedDate;
  final List<DateTime> availableDates;
  final ValueChanged<DateTime> onDateSelected;

  CustomerSidebar({
    required this.selectedDate,
    required this.availableDates,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: availableDates.length,
      itemBuilder: (context, index) {
        final date = availableDates[index];
        final isSelected = date == selectedDate;
        final displayDate = DateFormat('yyyy-MM-dd').format(date);
        final dayLabel = index == 0
            ? 'Today'
            : index == 1
                ? 'Yesterday'
                : displayDate;

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            color: isSelected ? Colors.orange[100] : Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              dayLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.orange : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ReportSidebar extends StatelessWidget {
  final DateTime selectedDate;
  final List<DateTime> availableDates;
  final ValueChanged<DateTime> onDateSelected;

  ReportSidebar({
    required this.selectedDate,
    required this.availableDates,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: availableDates.length,
      itemBuilder: (context, index) {
        final date = availableDates[index];
        final isSelected = date == selectedDate;
        final displayDate = DateFormat('yyyy-MM-dd').format(date);
        final dayLabel = index == 0
            ? 'Today'
            : index == 1
                ? 'Yesterday'
                : displayDate;

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            color: isSelected ? Colors.orange[100] : Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              dayLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.orange : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}
