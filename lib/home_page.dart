import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> cuisines = [];
  List<String> recipeNames = [];
  List<String> recipes = [];
  List<String> totalTimeInMins = [];
  List<String> urls = [];
  TextEditingController ingredientsController = TextEditingController();

  Future<void> _getRecipes() async {
    String url = 'https://api-srgwic.onrender.com/RecipeGen';
    Map<String, String> headers = {"Content-type": "application/json"};
    String ingredients = ingredientsController.text;
    String jsonBody = json.encode({"inputIngredients": ingredients.split(',')});

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: jsonBody);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          cuisines = List<String>.from(data['Cuisines']);
          recipeNames = List<String>.from(data['RecipeName']);
          // Update to format the recipe details
          List<dynamic> rawRecipes = data['Recipes'];
          recipes = rawRecipes.map((recipe) => _formatRecipe(recipe)).toList();
          totalTimeInMins = List<String>.from(data['TotalTimeInMins']);
          urls = List<String>.from(data['URLs']);
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      print(e);
    }
  }

  // Helper function to format the recipe
  String _formatRecipe(List<dynamic> recipe) {
    String ingredients = recipe[1].replaceAllMapped(
      RegExp(r'(\d+)\s(\w+)\s(\w+)'),
          (match) => '${match[1]} ${match[2]} ${match[3]}',
    );

    String instructions = recipe[2].replaceAll('\n', '\n\n');

    return "Ingredients:\n$ingredients\n\nInstructions:\n$instructions";
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Roboto',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Recipe Generator'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: ingredientsController,
                decoration: InputDecoration(
                  labelText: 'Enter Ingredients (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getRecipes,
                child: Text('Get Recipes'),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: recipeNames.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          urls[index],
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        title: Text(
                          recipeNames[index],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(cuisines[index]),
                        onTap: () {
                          // Display recipe details in a dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(recipeNames[index]),
                                content: SingleChildScrollView(
                                  child: Text(
                                    recipes[index],
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}