import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class AddActivity extends StatefulWidget {
  @override
  _AddActivityState createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  final TextEditingController titreController = TextEditingController();
  final TextEditingController lieuController = TextEditingController();
  final TextEditingController categorieController = TextEditingController(); // Updated
  final TextEditingController prixController = TextEditingController();
  final TextEditingController nbrPersonnesController = TextEditingController();
  bool isAddingActivity = false; // Track the adding state

  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Activity'),
        backgroundColor: Color.fromARGB(255, 38, 70, 231),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titreController,
              decoration: InputDecoration(labelText: 'Titre'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: lieuController,
              decoration: InputDecoration(labelText: 'Lieu'),
            ),
            SizedBox(height: 16.0),
            Text(
              'Category: ${categorieController.text}', // Display the categorie as text
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: prixController,
              decoration: InputDecoration(labelText: 'Prix'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: nbrPersonnesController,
              decoration: InputDecoration(labelText: 'Number of People'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isAddingActivity ? null : _pickImage,
              child: Text('Pick Image'),
            ),
            if (_image != null)
              Image.file(
                _image!,
                height: 100,
                width: 100,
              ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: isAddingActivity ? null : addActivity,
              child: Text('Add Activity'),
            ),
            if (isAddingActivity) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        identifyImage(_image!); // Identify image when picked
      });
    }
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> identifyImage(File imageFile) async {
    await loadModel();

    final recognition = await Tflite.runModelOnImage(
      path: imageFile.path,
      numResults: 1,
      threshold: 0.2,
    );

    setState(() {
      if (recognition != null) {
        categorieController.text = recognition[0]['label'];
      }
    });
  }

  void addActivity() {
    // Set the state to indicate that activity is being added
    setState(() {
      isAddingActivity = true;
    });

    // Check if an image is selected
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image.'),
        ),
      );
      // Set the state to indicate that activity adding failed
      setState(() {
        isAddingActivity = false;
      });
      return;
    }

    FirebaseFirestore.instance.collection('Activity').add({
      'titre': titreController.text,
      'lieu': lieuController.text,
      'categorie': categorieController.text,
      'prix': prixController.text,
      'nbrPersonnes': int.parse(nbrPersonnesController.text),
      'img': base64Encode(_image!.readAsBytesSync()),
    }).then((value) {
      // Clear the text controllers after adding the activity
      titreController.clear();
      lieuController.clear();
      prixController.clear();
      nbrPersonnesController.clear();

      // Set the state to indicate that activity has been added
      setState(() {
        isAddingActivity = false;
        _image = null; // Clear selected image
      });

      // Show a success message or update the UI as needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Activity added successfully!'),
        ),
      );
    }).catchError((error) {
      // Handle errors if needed
      print('Error adding activity: $error');

      // Set the state to indicate that activity adding failed
      setState(() {
        isAddingActivity = false;
      });

      // Show an error message or update the UI as needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding activity. Please try again.'),
        ),
      );
    });
  }
}
