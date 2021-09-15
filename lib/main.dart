import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/ui/pages/admin/admin_dashboard.dart';
import 'package:flutter_ecommerce/blocs/authBloc/auth_bloc.dart';
import 'package:flutter_ecommerce/blocs/authBloc/auth_event.dart';
import 'package:flutter_ecommerce/blocs/authBloc/auth_state.dart';
import 'package:flutter_ecommerce/repositories/user_repository.dart';
import 'package:flutter_ecommerce/splash_page.dart';
import 'package:flutter_ecommerce/ui/pages/noRoles/register_role.dart';
import 'package:flutter_ecommerce/ui/pages/user/bottom_navigation_bar.dart';
import 'package:flutter_ecommerce/ui/pages/login_page.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final UserRepository userRepository = UserRepository();

  void setErrorBuilder() {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return Scaffold(
          body: Center(
              child: Text("Unexpected error. See console for details.")));
    };
  }

  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: android.smallIcon,
              ),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setErrorBuilder();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      routes: {
        '/app': (BuildContext context) => App(
              userRepository: userRepository,
            ),
      },
      builder: (BuildContext context, Widget widget) {
        setErrorBuilder();
        return widget;
      },
      home: BlocProvider(
        create: (context) =>
            AuthBloc(userRepository: userRepository)..add(StartApp()),
        child: App(
          userRepository: userRepository,
        ),
      ),
    );
  }
}

class App extends StatelessWidget {
  final UserRepository userRepository;

  App({
    @required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitialState) {
          return SplashPage();
        } else if (state is AuthenticatedState) {
          return CustomBottomNavigationBar(
            currentIndex: 0,
            user: state.user,
            userRepository: userRepository,
          );
        } else if (state is AuthenticatedAdminState) {
          return AdminDashboard(
              user: state.user, userRepository: userRepository);
        } else if (state is AuthenticatednoRoleState) {
          return RegisterRoles(
              user: state.user, userRepository: userRepository);
        } else if (state is UnauthenticatedState) {
          return LoginPageParent(userRepository: userRepository);
        } else {
          return Container();
        }
      },
    );
  }
}
