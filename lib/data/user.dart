import 'package:google_sign_in/google_sign_in.dart';
import 'goal.dart';

class User{
  // Database ID for user
  String id;

  // Name of user
  String username;

  // Url for this users photo
  String photoUrl;

  // This users location
  String location;

  // This users bio
  String bio;

  // This users current goals
  List<Goal> currentGoals;

  // This users past goals
  List<Goal> pastGoals;

  // Retrieves a User from json storage
  User.fromMap(Map value) {
    id = value['id'];
    username = value['username'];
    photoUrl = value['photoUrl'];
    location = value['location'];
    bio = value['bio'];
    currentGoals = value['currentGoals'];
    pastGoals = value['pastGoals'];
  }

  //
  User.fromGoogleSignIn(GoogleSignIn googleSignIn, String uid) {
    id = uid;
    username = googleSignIn.currentUser.displayName;
    photoUrl = googleSignIn.currentUser.photoUrl;
    location = '';
    bio = '';
    currentGoals = new List<Goal>();
    pastGoals = new List<Goal>();
  }

  /// Converts this profile into json format
  Map toMap() {
    return {
      'id': id,
      'username': username,
      'searchName': username.toLowerCase(),
      'photoUrl': photoUrl,
      'location': location,
      'bio': bio,
      'currentGoals': currentGoals,
      'pastGoals': pastGoals,
    };
  }
}