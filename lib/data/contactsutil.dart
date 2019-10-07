import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinder/data/profiles.dart';
import 'package:contacts_service/contacts_service.dart';
import 'contactsdb.dart';
class ContactsUtil{
  static int _totalLikes,_totalSuperLikes,_totalDislikes,_totalContacts,_yettoswipelength;
  static int get totalLikes => _totalLikes;
  static int get totalSuperLikes => _totalSuperLikes;
  static int get totalDislikes => _totalDislikes;
  static int get totalContacts => _totalContacts;
  static int get yettoswipelength=>_yettoswipelength;




  static Future<List<Profile>> loadYetoSwipeContacts() async{
    int rowCount = await DatabaseHelper.queryRowCount();

    if(rowCount==0){
        await syncDBContacts();
    }else{
      var prefs=await SharedPreferences.getInstance();
      totalContacts=prefs.getInt("totalcontacts");
      syncDBContacts();
    }
    List<Map<String,dynamic>> profiles=await DatabaseHelper.queryYetToSwiped();
    _yettoswipelength=profiles.length;
    _totalSuperLikes=await DatabaseHelper.queryRowCountFor(ContactState.superliked);
    _totalLikes=await DatabaseHelper.queryRowCountFor(ContactState.liked);
    _totalDislikes=await DatabaseHelper.queryRowCountFor(ContactState.disliked);
    return shuffle(profiles.map((map)=>Profile().fromMap(map)).toList());

  }


  static set totalContacts(int count){
     _totalContacts=count;
  }


  static  set yettoswipelength (int count){
     _yettoswipelength=count;
  }

  static void updateTotalContactsLength(int length) async{
     _totalContacts=length;
     final prefs = await SharedPreferences.getInstance();
     prefs.setInt("totalcontacts", _totalContacts);
  }

  //TODO Optimize this. For instance we dont need to do update every time, lets check timetaken and spend extra effort
  static void syncDBContacts () async{

    Iterable<Contact> contacts=await ContactsService.getContacts(withThumbnails: false);
    updateTotalContactsLength(contacts.length);

    int rowCount = await DatabaseHelper.queryRowCount();
    Set<Profile> profilesToInsert=Set();
    Set<Profile> profilesToUpdate = Set();
    Set<Profile> profilesToDelete=Set();
    if(rowCount==0){
      profilesToInsert=contacts.map(fromContact).toSet();

    }else{
      Set<Profile> dbProfiles = Set();
      List<Map<String,dynamic>> rows= await DatabaseHelper.queryAllRows();
      rows.forEach((map)=>dbProfiles.add(new Profile().fromMap(map)));

      for(Contact contact in contacts){
        Profile profile = fromContact(contact);
        if(dbProfiles.remove(profile)){
          profilesToUpdate.add(profile);
        }else{
          profilesToInsert.add(profile);
        }
      }
      profilesToDelete=dbProfiles;
    }
    if(profilesToInsert.length>0)
      DatabaseHelper.insertAllProfiles(profilesToInsert);
    if(profilesToUpdate.length>0)
      DatabaseHelper.updateAllProfiles(profilesToUpdate);
    if(profilesToDelete.length>0){
      DatabaseHelper.deleteAllProfiles(profilesToDelete);
    }

    DatabaseHelper.queryRowCountFor(ContactState.yettoswipe);

  }



  static List shuffle(List items) {
    var random = new Random();

    // Go through all elements.
    for (var i = items.length - 1; i > 0; i--) {

      // Pick a pseudorandom number according to the list length
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }

  static Profile fromContact(Contact contact){
    Profile profile =
    new Profile(
      name: contact.displayName,
      phones: contact.phones.map((item)=>item.value).toSet(),
      emails:contact.emails.map((item)=>item.value).toSet(),
      id:contact.identifier,
      avatar:contact.avatar,
    );
    removeDuplicateNumbers(profile);
    return profile;
  }

  static Future<int> updateLiked(String contactId) async {
    _yettoswipelength--;
    _totalLikes++;
    return DatabaseHelper.updateContactState(contactId, ContactState.liked);
  }

  static Future<int> updateDisliked(String contactId) async {
    _yettoswipelength--;
    _totalDislikes++;
    return  DatabaseHelper.updateContactState(contactId, ContactState.disliked);
  }

  static Future<int> updateSuperliked(String contactId) async {
    _yettoswipelength--;
    _totalSuperLikes++;
    return  DatabaseHelper.updateContactState(contactId, ContactState.superliked);
  }

  static void removeDuplicateNumbers(Profile profile) {
    if(profile.phones!=null && profile.phones.length>0){
        Set<String> phones = Set();
        for(String phone in profile.phones){
          phone = removeSpaces(phone);
          if(phone.length>0)
            phones.add(phone);
        }
        profile.phones=phones;
    }

//    if(profile.emails!=null && profile.emails.length>0){
//      Set<String> emails = Set();
//      for(String email in profile.emails){
//        email = removeSpaces(email);
//        if(email.length>0)
//        emails.add(email);
//      }
//      profile.emails=emails;
//    }
  }

  static String removeSpaces(String text){
    String prefix="";
    if(text.startsWith("+")){
      text=text.substring(1);
      prefix="+";
    }

    return prefix+text.replaceAll(new RegExp("\\D"), "");
  }

  static void deleteAllData(){
    DatabaseHelper.deleteAll();

  }

}