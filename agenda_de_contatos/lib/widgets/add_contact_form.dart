import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

import '../models/contact.dart';
import '../models/user.dart';

class AddContactForm extends StatefulWidget {
  final List<Contact> oldContacts;
  final User username;

  AddContactForm({this.oldContacts, this.username});

  @override
  _AddContactFormState createState() => _AddContactFormState();
}

class _AddContactFormState extends State<AddContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _controllerForName = TextEditingController();
  final _controllerForAddress = TextEditingController();
  final _controllerForPhone = TextEditingController();
  final _controllerForEmail = TextEditingController();
  final db = FirebaseDatabase.instance.reference().child("contacts");

  String _validateName(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um nome para continuar';
    }

    return validationResult;
  }

  String _validateAddress(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um endereço para continuar';
    }

    return validationResult;
  }

  String _validatePhone(value) {
    String validationResult;

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um telefone para continuar';
    }

    return validationResult;
  }

  String _validateEmail(value) {
    String validationResult;
    bool isValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);

    if (value == null || value.isEmpty) {
      validationResult = 'Digite um email para continuar';
    }

    if (!isValid) {
      validationResult = 'Insira um email válido. Exemplo: exemplo@teste.com';
    }

    return validationResult;
  }

  void clearFields() {
    this._controllerForName.clear();
    this._controllerForAddress.clear();
    this._controllerForPhone.clear();
    this._controllerForEmail.clear();
  }

  Future<void> insertContact(Contact contact, BuildContext context) async {
    this.db.push().set({
      "name": contact.name,
      "email": contact.email,
      "address": contact.address,
      "phone": contact.phone,
      "owner": contact.owner
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contato inserido com sucesso!'),
        ),
      );
      this.clearFields();
    }).catchError((onError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(onError),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    void _completeInsert() async {
      if (_formKey.currentState.validate()) {
        await insertContact(
            new Contact(
              name: this._controllerForName.text,
              email: this._controllerForEmail.text,
              address: this._controllerForAddress.text,
              phone: num.parse(this._controllerForPhone.text),
              owner: this.widget.username.username,
            ),
            context);
        this.clearFields();
      }
    }

    void _cancelInsert() {
      this.clearFields();
    }

    return Form(
      key: this._formKey,
      child: Column(
        children: [
          Container(
            child: TextFormField(
              controller: this._controllerForName,
              decoration: InputDecoration(
                labelText: 'Nome do contato',
                errorMaxLines: 2,
              ),
              validator: this._validateName,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForEmail,
              decoration: InputDecoration(
                labelText: 'Email',
                errorMaxLines: 2,
              ),
              validator: this._validateEmail,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForAddress,
              decoration: InputDecoration(
                labelText: 'Endereço',
                errorMaxLines: 2,
              ),
              validator: this._validateAddress,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Container(
            child: TextFormField(
              controller: this._controllerForPhone,
              decoration: InputDecoration(
                labelText: 'Telefone',
                errorMaxLines: 2,
              ),
              validator: this._validatePhone,
              keyboardType: TextInputType.phone,
            ),
            margin: EdgeInsets.only(top: 0, left: 100, right: 100, bottom: 20),
          ),
          Row(
            children: [
              Container(
                child: ElevatedButton(
                  onPressed: _completeInsert,
                  child: Text('Salvar contato'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                ),
                margin: EdgeInsets.only(right: 20),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: _cancelInsert,
                  child: Text('Cancelar'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                  ),
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
    );
  }
}
