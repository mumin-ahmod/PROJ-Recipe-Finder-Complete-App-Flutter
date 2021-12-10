import 'package:json_annotation/json_annotation.dart';
import 'package:recipes/data/models/ingredient.dart';

part 'recipe_model.g.dart';

@JsonSerializable()
class APIRecipeQuery {
  // Add APIRecipeQuery.fromJson


  factory APIRecipeQuery.fromJson(Map<String, dynamic> json) =>
      _$APIRecipeQueryFromJson(json);

  Map<String, dynamic> toJson() => _$APIRecipeQueryToJson(this);

  @JsonKey(name: 'q')
  String query;
  int from;
  int to;
  bool more;
  int count;
  List<APIHits> hits;

  APIRecipeQuery({
    required this.query,
    required this.from,
    required this.to,
    required this.more,
    required this.count,
    required this.hits,
  });





}

// Add @JsonSerializable() class APIHits
@JsonSerializable()
class APIHits{
  APIRecipe recipe;

  APIHits({required this.recipe});

  factory APIHits.fromJson(Map<String, dynamic> json) =>
      _$APIHitsFromJson(json);

  Map<String, dynamic> toJson() => _$APIHitsToJson(this);

}

// Add @JsonSerializable() class APIRecipe

@JsonSerializable()
class APIRecipe {
  // 1
  String label;
  String image;
  String url;
  // 2
  List<APIIngredients> ingredients;

  double calories;
  double totalWeight;
  double totalTime;

  APIRecipe({
    required this.label,
    required this.image,
    required this.url,
    required this.ingredients,
    required this.calories,
    required this.totalWeight,
    required this.totalTime,
  });

  // 3
  factory APIRecipe.fromJson(Map<String, dynamic> json) =>
      _$APIRecipeFromJson(json);
  Map<String, dynamic> toJson() => _$APIRecipeToJson(this);
}

// Add global Helper Functions


// expl: we are converting double value of calorie and weight into a string

String getCalories(double? calories){
  if(calories == null){
    return '0 KCAL';
  }
  return calories.floor().toString()+'KCAL';
}

String getWeight(double? weight){
  if(weight == null){
    return '0g';
  }

  return weight.floor().toString() +'g';
}






//Add @JsonSerializable() class APIIngredients

@JsonSerializable()
class APIIngredients {
  // 1
  @JsonKey(name: 'text')
  String name;
  double weight;

  APIIngredients({
    required this.name,
    required this.weight,
  });

  // 2
  factory APIIngredients.fromJson(Map<String, dynamic> json) =>
      _$APIIngredientsFromJson(json);
  Map<String, dynamic> toJson() => _$APIIngredientsToJson(this);
}

// convert ingredients

List<Ingredient> convertIngredients(List<APIIngredients> apiIngredients){
  final ingredients = <Ingredient> [];

  apiIngredients.forEach((ingredient) {
    ingredients.add(
        Ingredient(name: ingredient.name, weight: ingredient.weight));
  });

  return ingredients;

}
