import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trello_demo/ui/blocs/main_bloc.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text('Authorization'),
      ),
      body: BlocBuilder<MainBloc, MainBlocState>(
        builder: (context, state) {
          return Container(
              width: double.infinity,
              height: double.infinity,
              padding: EdgeInsets.all(28.0),
              color: Theme.of(context).backgroundColor,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 40,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              'Login',
                              style: TextStyle(fontSize: 18),
                            ),
                            color: state.page == Screen.auth
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).buttonColor,
                            onPressed: () {
                              BlocProvider.of<MainBloc>(context)
                                  .add(MainBlocEvents.login_tab_selected);
                            },
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          height: 40,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              'Register',
                              style: TextStyle(fontSize: 18),
                            ),
                            color: state.page == Screen.register
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).buttonColor,
                            onPressed: () {
                              BlocProvider.of<MainBloc>(context)
                                  .add(MainBlocEvents.register_tab_selected);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller:
                          BlocProvider.of<MainBloc>(context).usernameController,
                      validator:
                          BlocProvider.of<MainBloc>(context).validateUsername,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(),
                          hintText: "Username"),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    if (state.page == Screen.register)
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller:
                            BlocProvider.of<MainBloc>(context).emailController,
                        validator:
                            BlocProvider.of<MainBloc>(context).validateEmail,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(),
                            hintText: "Email"),
                      ),
                    if (state.page == Screen.register)
                      SizedBox(
                        height: 8,
                      ),
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller:
                          BlocProvider.of<MainBloc>(context).passwordController,
                      validator:
                          BlocProvider.of<MainBloc>(context).validatePassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      obscureText: true,
                      decoration: InputDecoration(
                          hintStyle: TextStyle(color: Colors.white54),
                          border: OutlineInputBorder(),
                          hintText: "Password"),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: 120,
                      height: 40,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          'Submit',
                          style: TextStyle(fontSize: 18),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          if (state.page == Screen.auth)
                            BlocProvider.of<MainBloc>(context)
                                .add(MainBlocEvents.login_pressed);
                          else if (state.page == Screen.register)
                            BlocProvider.of<MainBloc>(context)
                                .add(MainBlocEvents.register_pressed);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        state.error ?? '',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    )
                  ],
                ),
              ));
        },
      ),
    );
  }
}
