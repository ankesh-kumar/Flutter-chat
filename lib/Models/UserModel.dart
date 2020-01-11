class UserModel{


 String photoUrl;
 String nickname;
 String id;

 UserModel(id,nickname,photoUrl);

 String get getphotoUrl{
   return photoUrl;
 }

 String get getnickname{
   return nickname;
 }

 String get getid{
   return id;
 }

 void set setphotoUrl(String photoUrl){
   this.photoUrl=photoUrl;
 }
 void set setnickname(String nickname){
   this.nickname=nickname;
 }
 void set setid(String id){
   this.id=id;
 }

}