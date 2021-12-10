import 'dart:async';
import '../models/models.dart';

import '../repository.dart';
import 'moor_db.dart';


class MoorRepository extends Repository{

  late RecipeDatabase recipeDatabase;

  late RecipeDao _recipeDao;

  late IngredientDao _ingredientDao;

  Stream<List<Ingredient>>? ingredientStream;

  Stream<List<Recipe>>? recipeStream;


  @override
  Future init() async{
    recipeDatabase = RecipeDatabase();

    _recipeDao = recipeDatabase.recipeDao;

    _ingredientDao = recipeDatabase.ingredientDao;


  }



  @override
  void close() {
   recipeDatabase.close();
  }
  @override
  Future<void> deleteRecipe(Recipe recipe) {
    if (recipe.id != null) {
      _recipeDao.deleteRecipe(recipe.id!);
    }
    return Future.value();
  }

  @override
  Future<void> deleteIngredient(Ingredient ingredient) {
    if (ingredient.id != null) {
      return _ingredientDao.deleteIngredient(ingredient.id!);
    } else {
      return Future.value();
    }
  }

  @override
  Future<void> deleteIngredients(List<Ingredient> ingredients) {
    ingredients.forEach((ingredient) {
      if (ingredient.id != null) {
        _ingredientDao.deleteIngredient(ingredient.id!);
      }
    });
    return Future.value();
  }

  @override
  Future<void> deleteRecipeIngredients(int recipeId) async {
    // 1
    final ingredients = await findRecipeIngredients(recipeId);
    // 2
    return deleteIngredients(ingredients);
  }

  @override
  Future<List<Ingredient>> findAllIngredients() {
    return _ingredientDao.findAllIngredients().then<List<Ingredient>>(
          (List<MoorIngredientData> moorIngredients) {
        final ingredients = <Ingredient>[];
        moorIngredients.forEach(
              (ingredient) {
            ingredients.add(moorIngredientToIngredient(ingredient));
          },
        );
        return ingredients;
      },
    );
  }


  @override
  Future<List<Recipe>> findAllRecipes() {
   return _recipeDao.findAllRecipes().
   then<List<Recipe>>((List<MoorRecipeData> moorRecipe) {
     final recipes = <Recipe> [];

     moorRecipe.forEach((moorRecipe)async {
       final recipe = moorRecipeToRecipe(moorRecipe);

       if(recipe.id != null){
         recipe.ingredients = await findRecipeIngredients(recipe.id !);
       }
       recipes.add(recipe);
     });
     return recipes;
   });
  }

  @override
  Future<Recipe> findRecipeById(int id) {
    return _recipeDao
        .findRecipeById(id)
        .then((listOfRecipes) => moorRecipeToRecipe(listOfRecipes.first));
  }

  @override
  Future<List<Ingredient>> findRecipeIngredients(int recipeId) {
    return _ingredientDao.findRecipeIngredients(recipeId).then(
          (listOfIngredients) {
        final ingredients = <Ingredient>[];
        listOfIngredients.forEach(
              (ingredient) {
            ingredients.add(moorIngredientToIngredient(ingredient));
          },
        );
        return ingredients;
      },
    );
  }


  @override
  Future<List<int>> insertIngredients(List<Ingredient> ingredients) {
    return Future(() {
      // 1
      if (ingredients.length == 0) {
        return <int>[];
      }
      final resultIds = <int>[];
      ingredients.forEach((ingredient) {
        // 2
        final moorIngredient = ingredientToInsertableMoorIngredient(ingredient);
        // 3
        _ingredientDao
            .insertIngredient(moorIngredient)
            .then((int id) => resultIds.add(id));
      },);
      return resultIds;
    },);
  }

  @override
  Future<int> insertRecipe(Recipe recipe) {
    return Future(() async {
      // 1
      final id =
      await _recipeDao.insertRecipe(recipeToInsertableMoorRecipe(recipe));
      if (recipe.ingredients != null) {
        // 2
        recipe.ingredients!.forEach((ingredient) {
          ingredient.recipeId = id;
        },);
        // 3
        insertIngredients(recipe.ingredients!);
      }
      return id;
    },);
  }

  @override
  Stream<List<Ingredient>> watchAllIngredients() {
    if (ingredientStream == null) {
    // 1
    final stream = _ingredientDao.watchAllIngredients();
    // 2
    ingredientStream = stream.map((moorIngredients) {
    final ingredients = <Ingredient>[];
    // 3
    moorIngredients.forEach((moorIngredient) {
    ingredients.add(moorIngredientToIngredient(moorIngredient));
    },);
    return ingredients;
    },);
    }
    return ingredientStream!;
  }

  @override
  Stream<List<Recipe>> watchAllRecipes() {
    if(recipeStream == null){
      recipeStream = _recipeDao.watchAllRecipes();
    }
    return recipeStream!;
  }


}