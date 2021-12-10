import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlbrite/sqlbrite.dart';
import 'package:synchronized/synchronized.dart';
import '../models/models.dart';

class DatabaseHelper {
  static const _databaseName = 'MyRecipes.db';
  static const _databaseVersion = 1;

  static const recipeTable = 'Recipe';
  static const ingredientTable = 'Ingredient';
  static const recipeId = 'recipeId';
  static const ingredientId = 'static const';

  static late BriteDatabase _streamDatabase;

  // make this a singleton class

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static var lock = Lock();

// only have a single app wide reference to the database

  static Database? _database;

// add create database code here

  Future _onCreate(Database db, int version) async {
    await db.execute('''CREATE TABLE $recipeTable(
    $recipeId INTEGER PRIMARY KEY,
    label TEXT,
    image TEXT,
    url TEXT,
    calories REAL,
    totalWeight REAL,
    totalTime REAL
    
    
    )''');

    await db.execute('''CREATE TABLE $ingredientTable(
    $ingredientId INTEGER PRIMARY KEY,
    $recipeId INTEGER,
    name TEXT,
    WEIGHT REAL
    
    )''');
  }

  /// this opens the database (and creates it if it doesn't exist)

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();

    final path = join(documentsDirectory.path, _databaseName);

    // remember to turn off debugging before deploying app

    Sqflite.setDebugModeOn(true);

    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // add initialize getter here

  Future<Database> get database async{
    if(_database != null) return _database!;

    await lock.synchronized(() async {
      if(_database == null){
        _database = await _initDatabase();

        _streamDatabase = BriteDatabase(_database!);
      }
    }

    );

    return _database!;
  }

  // getter for stream databse

  Future<BriteDatabase> get streamDatabase async{
    await database;
    return _streamDatabase;
  }

  // add perseRecipes here

  List<Recipe> parseRecipes(List<Map<String, dynamic>> recipeList){
    final recipes = <Recipe> [];

    recipeList.forEach((recipeMap) {
      final recipe = Recipe.fromJson(recipeMap);

      recipes.add(recipe);
    });

    return recipes;
  }

  List<Ingredient> parseIngredients(List<Map<String, dynamic>> ingredientList) {
    final ingredients = <Ingredient>[];
    ingredientList.forEach((ingredientMap) {
      // 5
      final ingredient = Ingredient.fromJson(ingredientMap);
      ingredients.add(ingredient);
    });
    return ingredients;
  }

//Add findAppRecipes here


  Future<List<Recipe>> findAllRecipes() async {
    final db = await instance.streamDatabase;

    final recipeList = await db.query(recipeTable);

    final recipes = parseRecipes(recipeList);
    //^^ gave me a list / converted to a list

    return recipes;
  }

  // add watch all recipes here

  Stream<List<Recipe>> watchAllRecipes() async* {
    final db = await instance.streamDatabase;

    yield* db.createQuery(recipeTable).mapToList((row) => Recipe.fromJson(row));
  }

  // watch all ingredients
  Stream<List<Ingredient>> watchAllIngredients() async* {
    final db = await instance.streamDatabase;
    yield* db
        .createQuery(ingredientTable)
        .mapToList((row) => Ingredient.fromJson(row));
  }

// findRecipeByID() here

  Future<Recipe> findRecipeById(int id) async {
    final db = await instance.streamDatabase;

    final recipeList = await db.query(recipeTable, where: 'id=$id');

    final recipes = parseRecipes(recipeList);

    return recipes.first;
}

// find all recipe ingredients


  Future<List<Ingredient>> findAllIngredients() async {
    final db = await instance.streamDatabase;
    final ingredientList = await db.query(ingredientTable);
    final ingredients = parseIngredients(ingredientList);
    return ingredients;
  }

// findRecipeIngredients() goes here

  Future<List<Ingredient>> findRecipeIngredients(int recipeId) async {
    final db = await instance.streamDatabase;
    final ingredientList =
    await db.query(ingredientTable, where: 'recipeId = $recipeId');
    final ingredients = parseIngredients(ingredientList);
    return ingredients;
  }



  Future<int> insert(String table, Map<String, dynamic> row) async{
    final db = await instance.streamDatabase;

    return db.insert(table, row);
  }

  Future<int> insertRecipe(Recipe recipe){
    return insert(recipeTable, recipe.toJson());
  }

  Future<int> insertIngredient(Ingredient ingredient){
    return insert(ingredientTable, ingredient.toJson());
  }

  // delete methods



  Future<int> _delete(String table, String columnId, int id) async{

    final db = await instance.streamDatabase;

    return db.delete(table, where: '$columnId =?', whereArgs: [id]);
  }

  Future<int> deleteRecipe(Recipe recipe) async{
    if(recipe.id != null){
      return _delete(recipeTable, recipeId, recipe.id!);
    }
    else{
      return Future.value(-1);
    }
  }


  Future<int> deleteIngredient(Ingredient ingredient) async {
    if (ingredient.id != null) {
      return _delete(ingredientTable, ingredientId, ingredient.id!);
    } else {
      return Future.value(-1);
    }
  }

  Future<void> deleteIngredients(List<Ingredient> ingredients) {
    // 4
    ingredients.forEach((ingredient) {
      if (ingredient.id != null) {
        _delete(ingredientTable, ingredientId, ingredient.id!);
      }
    });
    return Future.value();
  }

  Future<int> deleteRecipeIngredients(int id) async {
    final db = await instance.streamDatabase;
    // 5
    return db
        .delete(ingredientTable, where: '$recipeId = ?', whereArgs: [id]);
  }


  void close(){
    _streamDatabase.close();
  }









}
