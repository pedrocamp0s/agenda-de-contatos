import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';

import '../models/contact.dart';

class UpdateContactForm extends StatefulWidget {
  final Contact contact;

  UpdateContactForm({this.contact});

  @override
  _UpdateContactFormState createState() => _UpdateContactFormState();
}

class _UpdateContactFormState extends State<UpdateContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _controllerForName = TextEditingController();
  final _controllerForAddress = TextEditingController();
  final _controllerForPhone = TextEditingController();
  final _controllerForEmail = TextEditingController();
  final db = FirebaseDatabase.instance.reference().child("contacts");

  @override
  void initState() {
    super.initState();
    this._controllerForName.text = this.widget.contact.name;
    this._controllerForEmail.text = this.widget.contact.email;
    this._controllerForAddress.text = this.widget.contact.address;
    this._controllerForPhone.text = this.widget.contact.phone.toString();
  }

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

  @override
  Widget build(BuildContext context) {
    void _completeEdit() async {
      if (_formKey.currentState.validate()) {
        db.child(this.widget.contact.key).set({
          "name": this._controllerForName.text,
          "email": this._controllerForEmail.text,
          "address": this._controllerForAddress.text,
          "phone": num.parse(this._controllerForPhone.text),
          "owner": this.widget.contact.owner
        }).then((_) {
          Navigator.pop(context, 'Contato atualizado com sucesso!');
        }).catchError((onError) {
          Navigator.pop(context, onError);
        });
      }
    }

    void _cancelEdit() {
      Navigator.pop(context);
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
            margin: EdgeInsets.only(top: 0, left: 50, right: 50, bottom: 20),
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
            margin: EdgeInsets.only(top: 0, left: 50, right: 50, bottom: 20),
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
            margin: EdgeInsets.only(top: 0, left: 50, right: 50, bottom: 20),
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
            margin: EdgeInsets.only(top: 0, left: 50, right: 50, bottom: 20),
          ),
          Row(
            children: [
              Container(
                child: ElevatedButton(
                  onPressed: _completeEdit,
                  child: Text('Editar contato'),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue),
                  ),
                ),
                margin: EdgeInsets.only(right: 20),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: _cancelEdit,
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
