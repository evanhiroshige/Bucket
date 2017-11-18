import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kick_it/data/profile.dart';
import 'package:kick_it/data/relationship.dart';

/// A class that handles the current user information
class Networking {
  // The current GoogleSignIn and Profile being represented
  GoogleSignIn _googleSignIn;
  Profile _profile;

  Profile get profile => _profile;

  // The database where all data is stored
  DatabaseReference _users;
  DatabaseReference _relationships;
  FirebaseAuth _firebaseAuth;
  FirebaseUser _firebaseUser;

  /// Constructor for basic variable initialization
  Networking() {
    _profile = null;
    _googleSignIn = new GoogleSignIn();
    _firebaseAuth = FirebaseAuth.instance;

    // Get database references
    _users = FirebaseDatabase.instance.reference().child('users');
    _relationships =
        FirebaseDatabase.instance.reference().child('relationships');
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
    Profile inProfile = await getProfile();

    // If the profile doesn't exist, save a new one
    if (inProfile == null) {
      _profile = new Profile.fromGoogleSignIn(_googleSignIn, _firebaseUser.uid);
      saveProfile();
    } else {
      _profile = inProfile;
    }
  }

  /// Signs out of the current profile
  Future signOut() async {
    _profile = null;
    _firebaseUser = null;
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Gets the current profile
  Future<Profile> getProfile() async {
    DataSnapshot state = await _users.child(_firebaseUser.uid).once();
    if (state.value == null) return null;
    return new Profile.fromJson(state.value);
  }

  /// Gets a profile by id
  Future<Profile> getProfileById(String id) async {
    DataSnapshot state = await _users.child(id).once();
    if (state.value == null) return null;
    return new Profile.fromJson(state.value);
  }

  /// Saves the current profile to the database
  void saveProfile() {
    _users.child(_firebaseUser.uid).set(profile.toJson());
  }

  /// Deletes the current profile
  void deleteProfile() {
    _users.child(_firebaseUser.uid).remove();
    signOut();
  }

  /// Finds profiles based on the search query
  Future<List<Profile>> searchForProfiles(String query) async {
    List<Profile> results = [];
    Profile newProfile;

    String search = query.toLowerCase();
    DataSnapshot state = await _users.orderByChild('searchName')
        .startAt(search).endAt(search + '\uf8ff').once();

    if (state.value == null || state.value.keys == null) return results;

    for (final key in state.value.keys) {
      newProfile = new Profile.fromJson(state.value[key]);
      if (newProfile.id != profile.id) results.add(newProfile);
    }

    return results;
  }

  /// Gets the friend requests available to the current user
  Future<List<Profile>> getRequests() async {
    List<Profile> requests = [];
    Relationship relationship;

    DataSnapshot state = await _relationships.orderByChild('idOne')
        .equalTo(profile.id).once();
    if (state != null && state.value != null) {
      for (final key in state.value.keys) {
        relationship = new Relationship.fromJson(state.value[key]);
        if (relationship != null
            && relationship.status == 0
            && relationship.lastUser == relationship.idTwo)
          requests.add(await getProfileById(relationship.idTwo));
      }
    }

    state = await _relationships.orderByChild('idTwo')
        .equalTo(profile.id).once();
    if (state != null && state.value != null) {
      for (final key in state.value.keys) {
        relationship = new Relationship.fromJson(state.value[key]);
        if (relationship != null
            && relationship.status == 0
            && relationship.lastUser == relationship.idOne)
          requests.add(await getProfileById(relationship.idOne));
      }
    }

    return requests;
  }

  /// Returns all of the relationships for the current profile
  Future<Map<Profile, bool>> getFriends() async {
    Map<Profile, bool> results = new Map<Profile, bool>();

    if (profile == null) return results;

    DataSnapshot state;
    Relationship relationship;
    Profile newProfile;

    state = await _relationships.orderByChild('idOne')
        .equalTo(profile.id).once();
    if (state.value != null && state.value.keys != null) {
      for (final key in state.value.keys) {
        relationship = new Relationship.fromJson(state.value[key]);
        if (relationship != null) {
          newProfile = await getProfileById(relationship.idTwo);
          if (newProfile != null && relationship.status == 1)
            results.putIfAbsent(newProfile, () => relationship.favTwo);
        }
      }
    }

    state = await _relationships.orderByChild('idTwo')
        .equalTo(profile.id).once();
    if (state.value != null && state.value.keys != null) {
      for (final key in state.value.keys) {
        relationship = new Relationship.fromJson(state.value[key]);
        if (relationship != null) {
          newProfile = await getProfileById(relationship.idOne);
          if (newProfile != null && relationship.status == 1)
            results.putIfAbsent(newProfile, () => relationship.favOne);
        }
      }
    }

    return results;
  }

  /// Makes a relationship with the other profile
  /// Should default to 0 (Pending request)
  Future makeRelationship(Profile other) async {
    Relationship newRelationship = new Relationship(
      idOne: profile.id,
      idTwo: other.id,
      favOne: false,
      favTwo: false,
      status: 0,
      lastUser: profile.id,
    );

    await _relationships.child(newRelationship.getKey())
        .set(newRelationship.toJson());
  }

  /// Returns the relationship between this person and another profile
  Future<Relationship> getRelationship(Profile other) async {
    Relationship relationship;

    DataSnapshot state = await _relationships.orderByChild('idOne')
        .equalTo(profile.id).once();
    if (state != null && state.value != null) {
      for (final key in state.value.keys) {
        relationship = new Relationship.fromJson(state.value[key]);
        if (relationship != null && relationship.idTwo == other.id)
          return relationship;
      }
    }

    state = await _relationships.orderByChild('idTwo')
        .equalTo(profile.id).once();
    if (state != null && state.value != null) {
      for (final key in state.value.keys) {
        relationship = new Relationship.fromJson(state.value[key]);
        if (relationship != null && relationship.idOne == other.id)
          return relationship;
      }
    }

    return new Relationship(
      idOne: profile.id,
      idTwo: other.id,
      favOne: false,
      favTwo: false,
      status: -1,
      lastUser: profile.id,
    );
  }

  /// Returns the relationship between this person and another profile
  Future removeRelationship(Relationship relationship) async {
    if (_relationships.child(relationship.getKey()).once() != null)
      _relationships.child(relationship.getKey()).remove();
  }

  /// Updates the passed relationship in the database
  Future<bool> updateRelationship(Relationship relationship) async {
    if (_relationships.child(relationship.getKey()).once() != null) {
      _relationships.child(relationship.getKey())
          .set(relationship.toJson());
      return true;
    }

    return false;
  }
}