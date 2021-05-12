import 'package:agenda_de_contatos/widgets/update_contact_form.dart';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';

import '../models/contact.dart';

class SearchContactsForm extends StatefulWidget {
  final String username;

  SearchContactsForm({this.username});

  @override
  _SearchContactsFormState createState() => _SearchContactsFormState();
}

class _SearchContactsFormState extends State<SearchContactsForm> {
  final _formKey = GlobalKey<FormState>();
  final db = FirebaseDatabase.instance.reference().child("contacts");
  String selectedFilter = 'id';
  List<Contact> findedContacts = [];

  bool loading = false;

  /*String _validateUsername(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um nome de usuário para continuar';
    }

    return validationResult;
  }*/

  void showErrorMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  /*Future<List<Contact>> _getContacts() async {
    DataSnapshot data = await db.once();
    if (data.value == null) {
      return [];
    }
    Map<String, dynamic> dynamicMaps =
        new Map<String, dynamic>.from(data.value);
    List<dynamic> maps = new List<dynamic>.from(dynamicMaps.values);

    List<Contact> newContacts = List.generate(maps.length, (i) {
      return Contact(
          name: maps[i]['name'],
          email: maps[i]['email'],
          address: maps[i]['address'],
          phone: maps[i]['phone'],
          owner: maps[i]['owner']);
    });
    newContacts.sort((a, b) => a.name.compareTo(b.name));

    return newContacts;
  }*/

  @override
  Widget build(BuildContext context) {
    /*void _makeLogin() async {
      if (_formKey.currentState.validate()) {
        setState(() {
          this.loading = true;
        });

        List<User> users = await getUsers();

        bool userExists = false;

        for (var user in users) {
          if (this._controllerForUsername.text == user.username) {
            userExists = true;
            if (this._controllerForPassword.text == user.password) {
              List<Contact> oldContacts = await _getContacts();
              setState(() {
                this.loading = false;
              });
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddContactScreen(
                            oldContacts: oldContacts,
                            username: user,
                          )),
                  (route) => false);
            } else {
              showErrorMessage('A senha inserida está errada!', context);
            }
          }
        }

        if (!userExists) {
          showErrorMessage('O usuário inserido não existe!', context);
        }

        if (this.loading) {
          setState(() {
            this.loading = false;
          });
        }
      }
    }

    void _doSignup() async {
      setState(() {
        this.loading = true;
      });

      List<User> users = await getUsers();

      setState(() {
        this.loading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpScreen(
            users: users,
          ),
        ),
      );
    }*/

    void _handleSearch(String term) async {
      setState(() {
        this.loading = true;
      });
      DataSnapshot data;
      if (this.selectedFilter == 'id') {
        data = await db.orderByKey().equalTo(term).once();
      } else {
        data = await db.orderByChild("name").equalTo(term).once();
      }

      if (data.value == null) {
        setState(() {
          this.findedContacts = [];
          this.loading = false;
        });
      } else {
        Map<String, dynamic> dynamicMaps =
            new Map<String, dynamic>.from(data.value);
        dynamicMaps.removeWhere(
            (key, value) => value['owner'] != this.widget.username);
        List<dynamic> maps = new List<dynamic>.from(dynamicMaps.keys);

        List<Contact> newContacts = List.generate(maps.length, (i) {
          return Contact(
              key: maps[i],
              name: dynamicMaps[maps[i]]['name'],
              email: dynamicMaps[maps[i]]['email'],
              address: dynamicMaps[maps[i]]['address'],
              phone: dynamicMaps[maps[i]]['phone'],
              owner: dynamicMaps[maps[i]]['owner']);
        });
        newContacts.sort((a, b) => a.name.compareTo(b.name));
        setState(() {
          this.findedContacts = newContacts;
          this.loading = false;
        });
      }
    }

    void _handleUpdate(Contact contact) async {
      final result = await showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              children: [
                UpdateContactForm(
                  contact: contact,
                )
              ],
              title: Text('Editar contato'),
            );
          });
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
          ),
        );
      }
      setState(() {
        this.findedContacts = [];
      });
    }

    void _handleDelete(Contact contact) async {
      final result = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Deletar contato'),
              content: Text('Tem certeza que deseja deletar esse contato?',
                  textAlign: TextAlign.center),
              actions: [
                TextButton(
                  child: Text('Não'),
                  onPressed: () => Navigator.pop(context, false),
                ),
                TextButton(
                  child: Text('Sim'),
                  onPressed: () => Navigator.pop(context, true),
                )
              ],
            );
          });
      if (result) {
        db.child(contact.key).remove().then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contato deletado com sucesso!'),
            ),
          );
        }).catchError((onError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(onError),
            ),
          );
        });
        setState(() {
          this.findedContacts = [];
        });
      }
    }

    return Form(
      key: this._formKey,
      child: Column(
        children: [
          Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints contraints) {
                    return Container(
                      child: TextFormField(
                        decoration: InputDecoration(
                          errorMaxLines: 2,
                          suffixIcon: Icon(Icons.search),
                          hintText: 'Digite um ' + this.selectedFilter,
                        ),
                        textInputAction: TextInputAction.search,
                        onFieldSubmitted: _handleSearch,
                      ),
                      width: MediaQuery.of(context).size.width * 0.60,
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.10,
                          right: MediaQuery.of(context).size.width * 0.05,
                          top: 20,
                          bottom: 20),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints contraints) {
                    return Container(
                        child: DropdownButton(
                          icon: Icon(Icons.filter_list),
                          value: this.selectedFilter,
                          items: <DropdownMenuItem<String>>[
                            DropdownMenuItem(
                              child: Text('Id'),
                              value: 'id',
                            ),
                            DropdownMenuItem(
                              child: Text('Nome'),
                              value: 'nome',
                            )
                          ],
                          onChanged: (value) {
                            setState(() {
                              this.selectedFilter = value;
                            });
                          },
                        ),
                        width: MediaQuery.of(context).size.width * 0.20,
                        margin: EdgeInsets.only(top: 20, bottom: 20));
                  },
                ),
              ),
            ],
          ),
          this.loading
              ? Container(
                  child: CircularProgressIndicator(
                    value: null,
                  ),
                )
              : this.findedContacts.length == 0
                  ? Container(
                      child: Text(
                        'Nenhum contato foi encontrado com esse ' +
                            this.selectedFilter +
                            ', tente mudar o termo procurado!',
                        textAlign: TextAlign.center,
                      ),
                      margin:
                          EdgeInsets.symmetric(vertical: 100, horizontal: 50),
                    )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: this.findedContacts.length,
                          itemBuilder: (context, index) {
                            Contact contactItem = this.findedContacts[index];

                            return Container(
                              child: Card(
                                elevation: 5,
                                child: LayoutBuilder(
                                    builder: (context, constraints) {
                                  return ListTile(
                                    trailing: Container(
                                      child: Row(
                                        children: [
                                          IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () =>
                                                  _handleUpdate(contactItem)),
                                          IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () =>
                                                  _handleDelete(contactItem))
                                        ],
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                    ),
                                    title: Row(
                                      children: [
                                        Icon(Icons.person),
                                        Text(contactItem.name)
                                      ],
                                    ),
                                    isThreeLine: true,
                                    subtitle: Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.email),
                                              Text(
                                                contactItem.email,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.place),
                                              Text(
                                                contactItem.address,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.phone),
                                              Text(
                                                contactItem.phone.toString(),
                                              ),
                                            ],
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              margin: EdgeInsets.only(left: 20, right: 20),
                            );
                          }),
                    ),
        ],
      ),
    );
  }
}
