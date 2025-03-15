import 'package:fast_contacts/fast_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactService {
  static Future<List<Contact>> getContacts() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
      if (!status.isGranted) {
        // Handle the case where the user denied the permission
        return [];
      }
    }

    try {
      List<Contact> contacts = await FastContacts.getAllContacts();
      return contacts;
    } catch (e) {
      // Handle error
      print("Error fetching contacts: $e");
      return [];
    }
  }
}