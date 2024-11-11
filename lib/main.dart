import 'package:flutter/material.dart';
import 'package:p5/main_screen.dart';
//import 'package:p5/login.dart';
//import 'package:p5/m.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io'; // Import dart:io

void main() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class VerticalNavigationBar extends StatelessWidget {
  final List<Map<String, dynamic>> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  VerticalNavigationBar({
    required this.navItems,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double iconSize = screenHeight * 0.03; // 3% of the screen height
    double textSize = screenHeight * 0.015; // 1.5% of the screen height

    return Container(
      width: 80,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(navItems.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      onItemSelected(index);
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      width: 60, // Fixed width
                      height: 60, // Fixed height
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedIndex == index
                              ? Colors.orange
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius:
                            BorderRadius.circular(4), // Square corners
                      ),
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            navItems[index]['icon'],
                            color: selectedIndex == index
                                ? Colors.orange
                                : Colors.black54,
                            size: iconSize,
                          ),
                          SizedBox(height: 3),
                          Text(
                            navItems[index]['label'],
                            style: TextStyle(
                              color: selectedIndex == index
                                  ? Colors.orange
                                  : Colors.black54,
                              fontWeight: FontWeight.w300,
                              fontSize: textSize,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              // Handle logout action
            },
            child: Container(
              margin: EdgeInsets.all(10),
              width: 60, // Fixed width
              height: 60, // Fixed height
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4), // Square corners
              ),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: iconSize,
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w300,
                      fontSize: textSize,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryRow extends StatefulWidget {
  final List<String> categories;

  CategoryRow({required this.categories});

  @override
  _CategoryRowState createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> {
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5),
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: _selectedCategoryIndex == index
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  widget.categories[index],
                  style: TextStyle(
                    color: _selectedCategoryIndex == index
                        ? Colors.orange
                        : Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OtherContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Other Content'),
    );
  }
}

class OtherSidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Other Sidebar Content'),
    );
  }
}
