import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/bluetooth_service.dart';
import 'ui/dashboard.dart';

void main() async {
    WidgetFlutterBinding.ensureInitialized();
    await TrackingService.init();
    runApp(
        MultiProvider(
            providers:[
                ChangeNotifierProvider(create: (_) => BluetoothService()),
            ],
            child: PuddleEyesApp(),
        ),
    );
}

class PuddleEyesApp extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: "Puddle Eyes",
            theme: ThemeData(
                primarySwatch: Colors.green,
            ),
            home: DashboardScreen(),
        );
    }
}