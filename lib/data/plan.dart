import 'package:intl/intl.dart';
import 'goal.dart';

class Plan extends Goal {
  // Start time
  DateTime start;

  // End time
  DateTime end;

  // Owner represented as a UID
  String owner;

  // Participants represented as a list of UIDs
  List<String> participants;

  // Retrieves a Plan from json storage
  Plan.fromMap(Map value) {
    super.title = value[title];
    super.description = value[description];
    super.location = value[location];
    super.likes = value[likes];
    super.tags = value[tags];

    start = value['start'];
    end = value ['end'];
    owner = value ['owner'];
    participants = value['participants'];
  }

  // Converts a Plan into json format
  Map toMap() {
    return {
      'title': title,
      'searchName': title.toLowerCase(), // do we need this?
      'description': description,
      'location': location,
      'likes': likes,
      'tags': tags,

      'start': start,
      'end': end,
      'owner': owner,
      'participants': participants,
    };
  }
}