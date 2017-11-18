import 'tags.dart';

class Goal{

  // title of the goal
  String title;

  // description of the goal
  String description;

  // location of the goal
  String location;

  // a list of UIDs of the people that have liked the goal
  List<String> likes;

  // a list of Tags that are attached to this goal
  List<Tags> tags;

  // Retrieves a Goal from json storage
  Goal.fromJson(Map value) {
    title = value['title'];
    description = value['description'];
    location = value['location'];
    likes = value['likes'];
    tags = value['tags'];
  }

  // Converts a goal into json format
  /// Converts this profile into json format
  Map toJson() {
    return {
      'title': title,
      'searchName': title.toLowerCase(), // do we need this?
      'description': description,
      'location': location,
      'likes': likes,
      'tags' : tags,
    };
  }
}