import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinder/data/profiles.dart';
import 'package:contacts_service/contacts_service.dart';
import 'contactsdb.dart';
class ContactsUtil{
  static int totalContactsLength,yettoswipelength;





  static Future<List<Profile>> loadYetoSwipeContacts() async{
    int rowCount = await DatabaseHelper.queryRowCount();
    if(rowCount==0){
        await syncDBContacts();
    }
    List<Map<String,dynamic>> profiles=await DatabaseHelper.queryYetToSwiped();
    yettoswipelength=profiles.length;

    return shuffle(profiles.map((map)=>Profile().fromMap(map)).toList());

  }

  static int getTotalContactsLength(){
    return totalContactsLength;
  }

  static int getYetToSwipeLength(){
    return yettoswipelength;
  }

  static void updateTotalContactsLength(int length) async{
     totalContactsLength=length;
     final prefs = await SharedPreferences.getInstance();
     prefs.setInt("totalcontacts", totalContactsLength);
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
      DatabaseHelper.updateAllProfiles(profilesToInsert);
    if(profilesToDelete.length>0){
      DatabaseHelper.insertAllProfiles(profilesToInsert);
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
      phones: contact.phones.map((item)=>item.value).toList(),
      emails:contact.emails.map((item)=>item.value).toList(),
      id:contact.identifier,
      avatar:contact.avatar,
    );
    return profile;
  }

  static Future<int> updateLiked(String contactId) async {

    return DatabaseHelper.updateContactState(contactId, ContactState.liked);
  }

  static Future<int> updateDisliked(String contactId) async {

    return  DatabaseHelper.updateContactState(contactId, ContactState.disliked);
  }

  static Future<int> updateSuperliked(String contactId) async {

    return  DatabaseHelper.updateContactState(contactId, ContactState.superliked);
  }

}