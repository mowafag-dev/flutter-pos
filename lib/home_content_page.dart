import 'package:flutter/material.dart';
import 'dart:io';

class HomeContent extends StatelessWidget {
  final Function(Map<String, dynamic>) onMealSelected;
  final List<Map<String, dynamic>> meals;

  HomeContent({required this.onMealSelected, required this.meals});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8, // Adjusted aspect ratio for each item
        crossAxisSpacing: 20, // Increase the spacing between columns
        mainAxisSpacing: 20, // Increase the spacing between rows
      ),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            onMealSelected(meals[index]);
          },
          child: MealBox(
            imagePath: meals[index]['image'] ?? '',
            name: meals[index]['name'] ?? '',
            price: meals[index]['price']?.toString() ?? '0.0',
          ),
        );
      },
    );
  }
}

class MealBox extends StatelessWidget {
  final String imagePath;
  final String name;
  final String price;

  MealBox({required this.imagePath, required this.name, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: imagePath.isEmpty
                  ? Container(
                      color: Colors.grey[200], // Placeholder for missing images
                      child: Center(child: Text('No Image')),
                    )
                  : Image.file(File(imagePath), fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // Adjusted font size
                    color: Colors.black,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18, // Adjusted font size
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
