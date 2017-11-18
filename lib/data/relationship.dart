class Relationship {
  // The user ids in the relationship
  String idOne, idTwo;

  /// The relationship status of this relationship
  /// - -1 means there is no relationship
  /// - 0 means there is a pending request
  /// - 1 means there is a friend relationship
  int status;

  // The last user to perform an action in this relationship
  String lastUser;

  // Gets the relationship's key (first user id + second user id)
  String getKey() { return idOne + '+' + idTwo; }

  /// Default constructor
  Relationship({
    this.idOne,
    this.idTwo,
    this.status,
    this.lastUser,
  });

  /// Loads a relationship from a stored json
  Relationship.fromMap(Map value) {
    idOne = value['idOne'];
    idTwo = value['idTwo'];
    status = value['status'];
    lastUser = value['lastUser'];
  }

  /// Converts this relationship into a map to be stored in json format
  Map toMap() {
    return {
      'idOne': idOne,
      'idTwo': idTwo,
      'status': status,
      'lastUser': lastUser,
    };
  }
}