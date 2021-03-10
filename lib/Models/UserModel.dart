class UserModel {
  final String photoUrl;
  final String nickname;
  final String id;

  @override
  String toString() =>
      'UserModel{photoUrl: $photoUrl, nickname: $nickname, id: $id}';

  UserModel({this.id, this.nickname, this.photoUrl});
}
