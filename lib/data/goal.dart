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

  Goal(){
    title = null;
    description = null;
    location = null;
    likes = null;
    tags = null;
  }

  // Retrieves a Goal from json storage
  Goal.fromMap(Map value) {
    title = value['title'];
    description = value['description'];
    location = value['location'];
    likes = value['likes'];
    tags = value['tags'];
  }

  // Converts a goal into json format
  Map toMap() {
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