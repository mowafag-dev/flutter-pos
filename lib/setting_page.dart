import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'data_base_helper.dart';

class SettingsContent extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddMeal;
  final List<Map<String, dynamic>> meals;
  final Function(int) onRemoveMeal;

  SettingsContent({
    required this.onAddMeal,
    required this.meals,
    required this.onRemoveMeal,
  });

  @override
  _SettingsContentState createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _mealPriceController = TextEditingController();
  final Map<int, bool> _isEditing = {};
  final Map<int, TextEditingController> _nameControllers = {};
  final Map<int, TextEditingController> _priceControllers = {};
  File? _selectedImage;
  bool _isAddingMeal = false;

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final savedImage = await _saveImageToAppDirectory(pickedFile);
        setState(() {
          _selectedImage = savedImage;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<File> _saveImageToAppDirectory(XFile image) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = '${directory.path}/${image.name}';
    return await File(image.path).copy(imagePath);
  }

  Future<void> _addMeal() async {
    final String name = _mealNameController.text;
    final String price = _mealPriceController.text;

    if (name.isEmpty) {
      _showMessage('Please enter a name');
      return;
    }

    if (price.isEmpty) {
      _showMessage('Please enter a price');
      return;
    }

    if (_selectedImage == null) {
      _showMessage('Please select an image');
      return;
    }

    Map<String, dynamic> meal = {
      'name': name,
      'price': double.tryParse(price) ?? 0.0,
      'image': _selectedImage!.path, // Save image path
    };

    int id = await DatabaseHelper().insertMeal(meal);
    meal['id'] = id;
    widget.onAddMeal(meal);
    _mealNameController.clear();
    _mealPriceController.clear();
    setState(() {
      _selectedImage = null;
      _isAddingMeal = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added successfully')),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _updateMeal(int index) async {
    Map<String, dynamic> updatedMeal = {
      'id': widget.meals[index]['id'],
      'name': _nameControllers[index]!.text,
      'price': double.tryParse(_priceControllers[index]!.text) ?? 0.0,
      'image': widget.meals[index]['image'],
    };
    await DatabaseHelper().updateMeal(updatedMeal);
    setState(() {
      widget.meals[index] = updatedMeal;
      _isEditing[index] = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated successfully')),
    );
  }

  Future<void> _deleteMeal(int index) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this meal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DatabaseHelper().deleteMeal(widget.meals[index]['id']);
      widget.onRemoveMeal(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isAddingMeal)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _mealNameController,
                        decoration: InputDecoration(
                          labelText: 'Meal Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _mealPriceController,
                        decoration: InputDecoration(
                          labelText: 'Meal Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Select Image'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addMeal,
                      child: Text('Add'),
                    ),
                  ],
                ),
                if (_selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(_selectedImage!, height: 100),
                  ),
              ],
            ),
          )
        else
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isAddingMeal = true;
              });
            },

            icon: Icon(Icons.add, color: Colors.orange), // Orange icon
            label: Text(
              'Add Meal',
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
                  horizontal: 24.0, vertical: 12.0), // Adjust padding for width
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 0.1, // Adjusted aspect ratio for each item
              crossAxisSpacing: 25, // Increase the spacing between columns
              mainAxisSpacing: 25, // Increase the spacing between rows
            ),
            itemCount: widget.meals.length,
            itemBuilder: (context, index) {
              if (!_nameControllers.containsKey(index)) {
                _nameControllers[index] = TextEditingController(
                    text: widget.meals[index]['name'] ?? '');
              }
              if (!_priceControllers.containsKey(index)) {
                _priceControllers[index] = TextEditingController(
                    text: widget.meals[index]['price']?.toString() ?? '0.0');
              }
              return Stack(
                children: [
                  _isEditing[index] == true
                      ? MealBox(
                          imagePath: widget.meals[index]['image'] ?? '',
                          name: widget.meals[index]['name'] ?? '',
                          price:
                              widget.meals[index]['price']?.toString() ?? '0.0',
                          isEditing: true,
                          nameController: _nameControllers[index]!,
                          priceController: _priceControllers[index]!,
                          onSave: () => _updateMeal(index),
                        )
                      : MealBox(
                          imagePath: widget.meals[index]['image'] ?? '',
                          name: widget.meals[index]['name'] ?? '',
                          price:
                              widget.meals[index]['price']?.toString() ?? '0.0',
                          onEdit: () {
                            setState(() {
                              _isEditing[index] = true;
                            });
                          },
                          onDelete: () {
                            _deleteMeal(index);
                          },
                        ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class MealBox extends StatelessWidget {
  final String imagePath;
  final String name;
  final String price;
  final bool isEditing;
  final TextEditingController? nameController;
  final TextEditingController? priceController;
  final VoidCallback? onSave;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  MealBox({
    required this.imagePath,
    required this.name,
    required this.price,
    this.isEditing = false,
    this.nameController,
    this.priceController,
    this.onSave,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180, // Fixed width
      height: 250, // Fixed height
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
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Distribute space between elements
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: imagePath.isEmpty
                  ? Container(
                      color: Colors.grey[200], // Placeholder for missing images
                      child: Center(child: Text('No Image')),
                    )
                  : Image.file(File(imagePath), fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEditing)
                  Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: onSave,
                        child: Text('Save'),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Center content horizontally
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Adjusted font size
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 20, // Adjusted font size
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
          if (!isEditing)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
