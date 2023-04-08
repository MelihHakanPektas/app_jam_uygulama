import 'package:app_jam_uygulama/providers/app_info_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommonAlertDialogs {
  static shareNewNote(BuildContext context) => showDialog(
      context: context,
      builder: (BuildContext context) {
        final titleController = TextEditingController();
        final subtitleController = TextEditingController();
        final formKey = GlobalKey<FormState>();
        return AlertDialog(
          title: const Text('Not Paylaş'),
          scrollable: true,
          content: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                  controller: titleController,
                  keyboardType: TextInputType.name,
                  maxLength: 50,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: 'Başlık',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Boş bırakılamaz';
                    }
                    if (value.length < 7) return 'Çok Kısa';
                  }),
              TextFormField(
                controller: subtitleController,
                maxLength: 5000,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Açıklama',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Boş bırakılamaz';
                  if (value.length < 50) return 'Çok Kısa';
                },
                maxLines: null,
              ),
              ElevatedButton(
                  onPressed: () {
                    CommonAlertDialogs.loadingScreen(context);
                    FirebaseFirestore.instance.collection('notes').doc().set({
                      'title': titleController.text,
                      'subtitle': subtitleController.text,
                      'uid': FirebaseAuth.instance.currentUser!.uid,
                      'name': context.read<AppInfoBloc>().state.userName,
                      'date': Timestamp.now()
                    }).then((value) => Navigator.of(context)
                      ..pop()
                      ..pop());
                  },
                  child: const Text('Paylaş'))
            ]),
          ),
        );
      });
  static loadingScreen(BuildContext context) => showDialog(
      context: context,
      builder: (BuildContext context) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    width: 50,
                    child: Image.asset('assets/images/oua_logo.png')),
                const SizedBox(
                  height: 16,
                ),
                const CircularProgressIndicator(),
              ],
            ),
          ));
  static newUser(BuildContext context) => showDialog(
      context: (context),
      builder: (BuildContext context) {
        final nameController = TextEditingController();
        final emailController = TextEditingController();
        final passwordController = TextEditingController();
        final confirmPasswordController = TextEditingController();
        return AlertDialog(
          title: const Text('Kayıt Ol'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // full name
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Ad Soyad',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 10),
              // email
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 10),
              // password
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Şifre',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 10),
              // confirm password
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  hintText: 'Şifre Onayla',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (passwordController.text ==
                      confirmPasswordController.text) {
                    try {
                      await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .set({'name': nameController.text}).then(
                              (value) => Navigator.pop(context));
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Şifre zayıf. Lütfen daha güçlü bir şifre seçin.'),
                          ),
                        );
                      } else if (e.code == 'email-already-in-use') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Bu email adresi ile daha önce kayıt olunmuş.'),
                          ),
                        );
                      }
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Şifreler uyuşmuyor.'),
                      ),
                    );
                  }
                },
                child: const Text('Kayıt Ol'),
              ),
            ],
          ),
        );
      });
  static forgotPassword(BuildContext context) => showDialog(
        context: context,
        builder: (BuildContext context) {
          final resetEmailController = TextEditingController();
          final formKey = GlobalKey<FormState>();
          return AlertDialog(
            title: const Text('Şifre Sıfırlama'),
            content: Form(
              key: formKey,
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bu alan boş bırakılamaz';
                  }
                  if (value == '') return null;
                  final bool emailValid = RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value);
                  if (!emailValid) {
                    return 'Geçersiz email adresi';
                  }
                  return null;
                },
                controller: resetEmailController,
                decoration:
                    const InputDecoration(hintText: 'Email adresinizi girin'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final isValid = formKey.currentState!.validate();
                  if (isValid) {
                    FirebaseAuth.instance
                        .sendPasswordResetEmail(
                            email: resetEmailController.text)
                        .then((value) {
                      // Show a success message to the user
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Password reset email sent')));
                    }).catchError((error) {
                      // Show an error message to the user
                      if (error.code == 'user-not-found') {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                'Email address not associated with an account')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Error resetting password: $error')));
                      }
                    }).then((value) => Navigator.pop(context));
                  }
                },
                child: const Text('Gönder'),
              ),
            ],
          );
        },
      );
}