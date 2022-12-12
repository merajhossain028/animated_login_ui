import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  var animationLink = 'assets/login.riv';
  late SMITrigger failTrigger, succcessTrigger;
  late SMIBool isChecking, isHandsUp;
  late SMINumber lookNum;
  Artboard? artboard;
  late StateMachineController? stateMachineController;

  @override
  void initState() {
    super.initState();
    initArtBoard();
  }

  initArtBoard() {
    rootBundle.load(animationLink).then(
      (value) async {
        final file = RiveFile.import(value);
        final art = file.mainArtboard;
        art.addController(SimpleAnimation('idle'));
        stateMachineController =
            StateMachineController.fromArtboard(art, 'login');
        if (stateMachineController != null) {
          art.addController(stateMachineController!);

          for (var element in stateMachineController!.inputs) {
            if (element.name == 'isChecking') {
              isChecking = element as SMIBool;
            } else if (element.name == 'isHandsUp') {
              isHandsUp = element as SMIBool;
            } else if (element.name == 'trigSuccess') {
              succcessTrigger = element as SMITrigger;
            } else if (element.name == 'trigFail') {
              failTrigger = element as SMITrigger;
            } else if (element.name == 'numLook') {
              lookNum = element as SMINumber;
            }
          }
        }
        setState(() {
          artboard = art;
        });
      },
    );
  }

  chechking() {
    isChecking.change(false);
    isHandsUp.change(true);
    lookNum.change(0);
  }

  moveEyes(value) {
    lookNum.change(value.length.toDouble());
  }

  handsUp() {
    isHandsUp.change(false);
    isChecking.change(true);
  }

  login() {
    isHandsUp.change(false);
    isChecking.change(true);
    if (emailController.text == 'admin' && passwordController.text == 'admin') {
      succcessTrigger.fire();
    } else {
      failTrigger.fire();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (artboard != null)
                SizedBox(
                  width: 400,
                  height: 350,
                  child: Rive(
                    artboard: artboard!,
                    fit: BoxFit.contain,
                  ),
                ),
              Container(
                alignment: Alignment.center,
                width: 400,
                padding: const EdgeInsets.only(bottom: 15),
                margin: const EdgeInsets.only(bottom: 15 * 4),
                decoration: BoxDecoration(
                  color: const Color(0xffd6e2ea),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          const SizedBox(height: 15.2),
                          const SizedBox(height: 20),
                          SizedBox(
                            child: TextFormField(
                              onTap:chechking,
                              onChanged: (value) {
                                moveEyes(value);
                              },
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Email',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            child: TextFormField(
                              onTap: () {
                                handsUp();
                              },
                              controller: passwordController,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Password',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Remember me'),
                              Text('Forgot password?'),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              login();
                            },
                            child: const Text('Login'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
