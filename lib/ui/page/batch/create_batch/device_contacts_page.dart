import 'dart:typed_data';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:flutter/material.dart';
import 'package:gyansagar_frontend/ui/widget/form/p_textfield.dart';
import 'package:gyansagar_frontend/ui/widget/p_button.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';

class AllContactsPage extends StatefulWidget {
  const AllContactsPage({
    super.key,
    required this.selectedFromDeviceContact,
  });

  final List<Contact> selectedFromDeviceContact;

  static MaterialPageRoute getRoute(List<Contact> selectedFromDeviceContact) {
    return MaterialPageRoute(
        builder: (_) => AllContactsPage(
            selectedFromDeviceContact: selectedFromDeviceContact));
  }

  @override
  _AllContactsPageState createState() => _AllContactsPageState();
}

class _AllContactsPageState extends State<AllContactsPage> {
  GetIt getIt = GetIt.instance;
  String searchTerm = '';

  late List<Contact> _contacts;
  final List<Contact> _selectedContacts = [];
  late List<Contact> selectedFromDeviceContact;
  final bool _isUploading = false;
  late TextEditingController search;

  @override
  void initState() {
    selectedFromDeviceContact = widget.selectedFromDeviceContact;
    search = TextEditingController();
    _refreshContacts(initial: true);
    super.initState();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: const Text(
          'Select Contacts',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () async {
              Navigator.pop(context, _selectedContacts);
            },
          )
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: _contacts.isNotEmpty
              ? Column(
            children: [
              PTextField(
                controller: search,
                type: FieldType.text,
                onChange: (val) {
                  searchTerm = val;
                  _refreshContacts();
                },
                label: "Search",
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: _contacts.length,
                itemBuilder: (BuildContext context, int index) {
                  final List<String> contactsList = [];

                  final Contact contact = _contacts.elementAt(index);
                  if (contact.phones.isNotEmpty) {
                    contact.phones
                        .map((i) => contactsList.add(i.number))
                        .toList();
                  } else {
                    contactsList.add('Null');
                  }

                  bool isSelected = _selectedContacts.any((model) =>
                  model.id == contact.id &&
                      model.phones.map((e) => e.number).join() ==
                          contact.phones.map((e) => e.number).join() &&
                      model.displayName == contact.displayName);

                  return Card(
                    child: InkWell(
                      child: Container(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : null,
                        child: ListTile(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedContacts.removeWhere((model) =>
                                model.id == contact.id);
                                print(
                                    "removed: list length ${_selectedContacts.length}");
                              } else {
                                _selectedContacts.add(contact);
                                print("added: list length ${_selectedContacts.length}");
                              }
                            });
                          },
                          leading: FutureBuilder<Uint8List?>(
                            future: FastContacts.getContactImage(contact.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done &&
                                  snapshot.hasData &&
                                  snapshot.data != null) {
                                return CircleAvatar(
                                  backgroundImage: MemoryImage(snapshot.data!),
                                );
                              } else {
                                return CircleAvatar(
                                  child: Text(contact.displayName.substring(0, 2).toUpperCase()),
                                );
                              }
                            },
                          ),
                          title: Text(
                            contact.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black),
                          ),
                          subtitle: Text(
                            contact.phones.isNotEmpty
                                ? contact.phones.first.number
                                : "N/A",
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          )
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Future<void> _refreshContacts({bool initial = false}) async {
    PermissionStatus permissionStatus = await getContactPermission();
    if (permissionStatus == PermissionStatus.granted) {
      final contacts = await FastContacts.getAllContacts();

      if (contacts.isNotEmpty) {
        /// Remove contacts having null contact or Display name
        contacts.removeWhere(
                (element) => element.phones.isEmpty || element.displayName == '');

        /// Apply search
        _contacts = searchTerm.isNotEmpty
            ? contacts.where((contact) {
          return (contact.displayName.toLowerCase().contains(searchTerm.toLowerCase())) ||
              contact.phones
                  .any((element) => element.number.contains(searchTerm));
        }).toList()
            : contacts;

        /// Mark preselected contacts
        if (initial && selectedFromDeviceContact.isNotEmpty) {
          _selectedContacts.clear();
          for (var contact in contacts) {
            for (var model in selectedFromDeviceContact) {
              var isAvailable = model.displayName.toLowerCase() ==
                  contact.displayName.toLowerCase() &&
                  model.phones.map((e) => e.number).join() ==
                      contact.phones.map((e) => e.number).join();
              if (isAvailable) {
                setState(() {
                  /// Check for duplicacy
                  if (!_selectedContacts.contains(contact)) {
                    _selectedContacts.add(contact);
                  }
                });
              }
            }
          }
        } else {
          print("Access");
        }

        setState(() {});
      }
    } else {
      handleInvalidPermissions(permissionStatus);
    }
  }
}

class _SearchDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 20,
          left: 100,
          right: 100,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 10.0),
            TextField(
              controller: _controller,
              maxLines: 1,
              keyboardType: TextInputType.emailAddress,
              autofocus: false,
              decoration: const InputDecoration(
                hintText: 'I\'M LOOKING FOR...',
              ),
            ),
            const SizedBox(height: 24.0),
            Align(
              alignment: Alignment.bottomRight,
              child: PFlatButton(
                onPressed: () {
                  Navigator.pop(context, _controller.text);
                },
                label: 'Search',
                isLoading: ValueNotifier(false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<PermissionStatus> getContactPermission() async {
  var permission = await Permission.contacts.status;
  if (permission != PermissionStatus.granted &&
      permission != PermissionStatus.restricted) {
    final permissionStatus = await Permission.contacts.request();
    return permissionStatus;
  } else {
    return permission;
  }
}

void handleInvalidPermissions(PermissionStatus permissionStatus) {
  if (permissionStatus == PermissionStatus.denied) {
    print("Access to location data denied");
  } else if (permissionStatus == PermissionStatus.permanentlyDenied) {
    print("Contact permission is permanentlyDenied");
  }
}