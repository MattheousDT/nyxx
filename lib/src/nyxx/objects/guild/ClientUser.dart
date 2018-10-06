part of nyxx;

/// ClientUser is bot's discord account. Allows to change bot's presence.
class ClientUser extends User {
  /// The client user's email, null if the client user is a bot.
  String email;

  /// Weather or not the client user's account is verified.
  bool verified;

  /// Weather or not the client user has MFA enabled.
  bool mfa;

  ClientUser._new(Map<String, dynamic> data) : super._new(data) {
    this.email = data['email'] as String;
    this.verified = data['verified'] as bool;
    this.mfa = data['mfa_enabled'] as bool;
  }

  /// Updates the client's status.
  ///
  ///```
  ///user.setStatus('dnd');
  ///```
  ClientUser setStatus(String status) => this.setPresence(status: status);

  /// Updates the client's game.
  ///
  ///```
  ///user.setGame(Game.of("<3"))
  ///```
  ClientUser setGame(Presence game) => this.setPresence(game: game);

  /// Updates the client's presence
  ClientUser setPresence({String status, bool afk = false, Presence game}) {
    _client.shards.forEach((int id, Shard shard) {
      shard.setPresence(status: status, afk: afk, game: game);
    });

    return this;
  }

  /// Allows to set status for each shard based on shard state.
  ///
  /// ```
  /// client.setPresenceForShard((shard) {
  ///   shard.setPresence(status: "Shard id: ${shard.id}");
  /// });
  /// ```
  void setPresenceForShard(Function(Shard shard) func) {
    for(var shard in client.shards.values)
      func(shard);
  }

  /// Allows to get [Member] objects for all guilds for bot user.
  Map<Guild, Member> getMembership() {
    var tmp = Map<Guild, Member>();
    for (var guild in client.guilds.values) tmp[guild] = guild.members[this.id];

    return tmp;
  }

  /// Edits current user. This changes user's username - not per guild nickname.
  Future<User> edit({String username, File avatar}) async {
    if (username == null && avatar == null) return null;
    var req = Map<String, dynamic>();

    if (username != null) req['username'] = username;
    if (avatar != null)
      req['avatar'] =
          "data:image/jpeg;base64,${base64Encode(await avatar.readAsBytes())}";

    var res = await _client.http.send("PATCH", "/users/@me", body: req);
    return User._new(res.body as Map<String, dynamic>);
  }
}
