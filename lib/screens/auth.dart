//using this widget in auth.dart file
import 'dart:io';
import 'package:chat_app/Widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _firebase = FirebaseAuth.instance; //for sign up bish

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  File? _selectedImage;
  var _isAuthenticating = false; //for spinner
  var _enteredUsername = '';

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid || _selectedImage == null && !_isLogin) {
      return;
    }
    _formKey.currentState!.save();
    // print(_enteredEmail + _enteredPassword);
    try {
      setState(() {
        _isAuthenticating = true; //for spinner
      });
      if (_isLogin) {
        //logs users in
        final userCredentialsforLogging =
            await _firebase.signInWithEmailAndPassword(
                email: _enteredEmail, password: _enteredPassword);
      } else {
        //for sign up

        final usercredentialsforSigning =
            await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        //ye reference dega cloud storage ki, ek sath ni kr skte image ko store kyuki
        //firebase kmla support ni krta toh phele user bna ke fir add kr denge.
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${usercredentialsforSigning.user!.uid}.jpg');
        //child() will create new directory
        await storageRef.putFile(_selectedImage!); //ye store kr dega
        final imageURL = await storageRef.getDownloadURL();
        //yha se url le lenge uska baad mei use krne ke liye\

        //ye collections ke saath kaam krta hai.
        await FirebaseFirestore.instance
            .collection('users')
            .doc(usercredentialsforSigning.user!.uid)
            .set(
          {
            'username': _enteredUsername,
            'email': _enteredEmail,
            'password': _enteredPassword,
            'image_url': imageURL
          },
        );
      }
      // print(usercredentials);
    } on FirebaseAuthException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.code,
          ),
          backgroundColor: Theme.of(context).primaryColor,
          showCloseIcon: true,
          shape: Border.all(),
        ),
      );
      setState(
        () {
          _isAuthenticating = false;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                    top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            //the widget UserImagePicker
                            UserImagePicker(
                              onPickImage: (pickedImage) {
                                _selectedImage = pickedImage;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email Address'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid E-mail';
                              } else {
                                return null;
                              }
                              /*validator gives us the value and we return NULL if the value is valid else not.*/
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Username'),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter atleast 4 characters';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Password must be alteast 6 letters long';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              onPressed: _submit,
                              child: Text(
                                _isLogin ? 'Log in' : 'Sign Up',
                              ),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? 'Create an Account'
                                    : 'I already have an account',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
