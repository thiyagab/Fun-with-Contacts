
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
  final List<String> phones;
  final String id;
  final Uint8List avatar;
  final List<String> emails;

  Profile({this.name,this.phones, this.id,this.emails,this.avatar});

  @override
  bool operator ==(covariant Profile other) => other.id == id;

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
      emails:map["emails"]!=null? (map["emails"] as String).split(","):List(),
      phones:map["phones"]!=null? (map["phones"] as String).split(","):List(),
    );
  }
}
