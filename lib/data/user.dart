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
  List<Goal> goals;

  // Retrieves a User from json storage
  User.fromMap(Map value) {
    id = value['id'];
    username = value['username'];
    photoUrl = value['photoUrl'];
    location = value['location'];
    bio = value['bio'];
    goals = new List<Goal>(); // place holder: "value" doesn't keep track of goals
  }

  //
  User.fromGoogleSignIn(GoogleSignIn googleSignIn, String uid) {
    id = uid;
    username = googleSignIn.currentUser.displayName;
    photoUrl = googleSignIn.currentUser.photoUrl;
    location = '';
    bio = '';
    goals = new List<Goal>();
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
    };
  }
}