
import 'dart:typed_data';

final List<Profile> demoProfiles = [
  new Profile(

    name: "Gross person",

  ),
  new Profile(

    name: "Someone Special",

  ),
];

class Profile {
  final String name;
  Set<String> phones;
  final String id;
  final Uint8List avatar;
   Set<String> emails;

  Profile({this.name,this.phones, this.id,this.emails,this.avatar});

  bool operator ==(o) => o is Profile && id == o.id;
  int get hashCode => id.hashCode;

  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map["_id"]=id;
    map["name"]=name;
    map["phones"]=phones!=null?phones.join(","):"";
    map["emails"]=emails!=null? emails.join(","):"";
    return map;
  }

  Profile fromMap(Map<String,dynamic> map){
    return Profile(
      name : map["name"],
      id:map["_id"],
      emails:map["emails"]!=null? (map["emails"] as String).split(",").toSet():Set(),
      phones:map["phones"]!=null? (map["phones"] as String).split(",").toSet():Set(),
    );
  }
}
