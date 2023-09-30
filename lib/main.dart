import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simple_dice_game/dice_game_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: GoogleFonts.exo2TextTheme()
      ),
      home: const DiceGamePage(),
    );
  }
}

///
/// 1. At the first roll, if the Dice Sum is 7 or 11, Player wins!
// 2. At the first roll, if the Dice Sum is 2, 3 or 12, Player lose
// 3. At the first roll, if the Dice Sum is 4, 5, 6, 8, 9 or 10, Dice Sum will be the target point
///4. If the dice sum matches the target point, player wins
///5. if the dice sum is 7 while chasing the target, player loses.