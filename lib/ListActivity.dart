import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListActivity extends StatefulWidget {
  @override
  _ListActivityState createState() => _ListActivityState();
}

class _ListActivityState extends State<ListActivity> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Listes des activités'),
          backgroundColor: Color.fromARGB(255, 38, 70, 231),
          bottom: TabBar(
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Basket'),
              Tab(text: 'Jeux de société'),
            ],
          ),
        ),
        body: ActivityList(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (_currentIndex == 0) {
              // Navigate to the All tab
              // You can add additional logic here if needed
            } else if (_currentIndex == 1) {
              // Navigate to the Add tab
              Navigator.pushNamed(context, '/addActivity');
            } else if (_currentIndex == 2) {
              // Navigate to the Profile tab
              Navigator.pushNamed(context, '/Profile');
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'ListActivity',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityList extends StatefulWidget {
  @override
  ActivityListState createState() => ActivityListState();
}

class ActivityListState extends State<ActivityList> {
  // Define the selectedCategory variable
  String selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        buildListView('All'),
        buildListView('Basket'),
        buildListView('Jeux de société'),
      ],
    );
  }

  Widget buildListView(String category) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Activity').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        var activities = snapshot.data!.docs;

        // Filter activities based on the selected category
        var filteredActivities = activities.where((activity) {
          var activityData = activity.data() as Map<String, dynamic>;
          if (category.toLowerCase() == 'all') {
            return true;
          } else {
            return activityData['categorie'].toLowerCase() == category.toLowerCase();
          }
        }).toList();

        return ListView.builder(
          itemCount: filteredActivities.length,
          itemBuilder: (context, index) {
            var activity = filteredActivities[index].data() as Map<String, dynamic>;

            return Card(
              elevation: 3.0,
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(activity['titre']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lieu: ${activity['lieu']}'),
                    Text('Price: ${activity['prix']}'), // Added price
                  ],
                ),
                leading: Image.memory(
                  base64Decode(activity['img']), // Assuming 'img' is a base64-encoded string
                  fit: BoxFit.cover,
                  width: 56.0,
                  height: 56.0,
                ),
                onTap: () {
                  showProductDetails(context, activity);
                },
              ),
            );
          },
        );
      },
    );
  }

  void showProductDetails(BuildContext context, Map<String, dynamic> activity) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(activity['titre']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lieu: ${activity['lieu']}'),
              Text('Category: ${activity['categorie']}'),
              Text('Price: ${activity['prix']}'),
              Text('Number of People: ${activity['nbrPersonnes']}'),
              Image.memory(
                base64Decode(activity['img']), // Assuming 'img' is a base64-encoded string
                fit: BoxFit.cover,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Activities'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                children: [
                  Text('Select Category:'),
                  DropdownButton<String>(
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: ['All', 'Basket', 'Jeux de société'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Apply Filter'),
            ),
          ],
        );
      },
    );
  }
}
