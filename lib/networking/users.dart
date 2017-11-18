import 'dart:async';

import 'package:bucket_list/data/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A class that handles the user information
class Users {
  // The current GoogleSignIn and Profile being represented
  GoogleSignIn _googleSignIn;
  User _user;
  User get currentUser => _user;

  // The database where all data is stored
  FirebaseAuth _firebaseAuth;
  FirebaseUser _firebaseUser;
  Firestore _firestore;
  CollectionReference _users;

  /// Constructor for basic variable initialization
  Users() {
    _googleSignIn = new GoogleSignIn();
    _firebaseAuth = FirebaseAuth.instance;
    _firestore = Firestore.instance;

    // Get database references
    _users = _firestore.collection('users');
  }

  /// Signs in the user
  /// This should be called from the loading screen
  Future signIn() async {
    // Perform a Google sign in
    GoogleSignInAccount user = _googleSignIn.currentUser;

    if (user == null)
      user = await _googleSignIn.signInSilently();
    // If the silent sign in failed, force another sign in
    while (user == null)
      user = await _googleSignIn.signIn();

    // Authenticate with Firebase
    _firebaseUser = await _firebaseAuth.currentUser();
    if (_firebaseUser == null) {
      GoogleSignInAuthentication credentials =
      await _googleSignIn.currentUser.authentication;

      _firebaseUser = await _firebaseAuth.signInWithGoogle(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
    }

    // Try to get a profile
    User inUser = await getUser();

    // If the profile doesn't exist, save a new one
    if (inUser == null) {
      _user = new User.fromGoogleSignIn(_googleSignIn, _firebaseUser.uid);
      saveUser();
    } else {
      _user = inUser;
    }
  }

  /// Signs out of the current profile
  Future signOut() async {
    _user = null;
    _firebaseUser = null;
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Gets the current profile
  Future<User> getUser() async {
    return await this.getUserById(_firebaseUser.uid);
  }

  /// Gets a profile by id
  Future<User> getUserById(String id) async {
    User user;
    DocumentReference shot = _users.document(id.toString());
    if(shot != null) {
      DocumentSnapshot snap = await shot.snapshots.single;
      user = new User.fromMap(snap.data);
    }
    return user;
  }

  /// Saves the current profile to the database
  void saveUser() {
    _users.document(_firebaseUser.uid).setData(_user.toMap());
  }

  /// Deletes the current profile
  void deleteUser() {
    _users.document(_firebaseUser.uid).delete();
    signOut();
  }
}