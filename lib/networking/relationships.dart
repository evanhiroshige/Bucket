import 'dart:async';

import 'package:bucket_list/data/relationship.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A class that handles the user information
class Relationships {
  // The current uid that we need to access
  String _id;

  // The database where all data is stored
  CollectionReference _relationships;

  /// Constructor for basic variable initialization
  Relationships(String id, CollectionReference rel) {
    this._id = id;
    this._relationships = rel;
  }

  /// Gets all requests that this user is involved in
  Future<List<Relationship>> getRequests() async {
    List<Relationship> requests = new List<Relationship>();

    QuerySnapshot idOne = await this
        ._relationships
        .where(
          "idOne",
          isEqualTo: this._id,
        )
        .where(
          "status",
          isEqualTo: 0,
        )
        .snapshots
        .single;
    QuerySnapshot idTwo = await this
        ._relationships
        .where(
          "idTwo",
          isEqualTo: this._id,
        )
        .where(
          "status",
          isEqualTo: 0,
        )
        .snapshots
        .single;

    for (DocumentSnapshot snap in idOne.documents) {
      requests.add(new Relationship.fromMap(snap.data));
    }
    for (DocumentSnapshot snap in idTwo.documents) {
      requests.add(new Relationship.fromMap(snap.data));
    }

    return requests;
  }

  /// Gets all friendships that this user is involved in
  Future<List<Relationship>> getFriends() async {
    List<Relationship> friends = new List<Relationship>();

    QuerySnapshot idOne = await this
        ._relationships
        .where(
          "idOne",
          isEqualTo: this._id,
        )
        .where(
          "status",
          isEqualTo: 1,
        )
        .snapshots
        .single;

    QuerySnapshot idTwo = await this
        ._relationships
        .where(
          "idTwo",
          isEqualTo: this._id,
        )
        .where(
          "status",
          isEqualTo: 1,
        )
        .snapshots
        .single;

    for (DocumentSnapshot snap in idOne.documents) {
      friends.add(new Relationship.fromMap(snap.data));
    }
    for (DocumentSnapshot snap in idTwo.documents) {
      friends.add(new Relationship.fromMap(snap.data));
    }

    return friends;
  }

  /// Gets this user's relationship with the user who's id is passed
  Future<Relationship> getRelationship(String other) async {
    QuerySnapshot one = await this
        ._relationships
        .where(
          "idOne",
          isEqualTo: this._id,
        )
        .where(
          "idTwo",
          isEqualTo: other,
        )
        .snapshots
        .single;

    if (one.documents.isNotEmpty) {
      return new Relationship.fromMap(one.documents.first.data);
    }

    QuerySnapshot two = await this
        ._relationships
        .where(
          "idOne",
          isEqualTo: this._id,
        )
        .where(
          "idTwo",
          isEqualTo: other,
        )
        .snapshots
        .single;

    if (two.documents.isNotEmpty) {
      return new Relationship.fromMap(two.documents.first.data);
    }

    return new Relationship(
      idOne: this._id,
      idTwo: other,
      status: -1,
      lastUser: this._id,
    );
  }

  /// Saves the passed relationship
  void setRelationship(Relationship rel) {
    this._relationships.document(rel.getKey()).setData(rel.toMap());
  }
}
