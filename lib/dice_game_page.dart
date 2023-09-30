import 'dart:math';

import 'package:flutter/material.dart';

enum WinLoseStatus {
  directWin,
  directLose,
  targetWin,
  targetLose,
}

class DiceGamePage extends StatefulWidget {
  const DiceGamePage({super.key});

  @override
  State<DiceGamePage> createState() => _DiceGamePageState();
}

class _DiceGamePageState extends State<DiceGamePage> {
  final diceList = <String>[
    'images/one.png',
    'images/two.png',
    'images/three.png',
    'images/four.png',
    'images/five.png',
    'images/six.png',
  ];
  String status = '';
  int index1 = 0, index2 = 0, diceSum = 0, target = 0;

  //new variables start
  double balance = 100;
  final double minBalance = 10;
  final String currency = '\$';
  final double directWinFactor = 1.0;
  final double directLoseFactor = 0.8;
  final double targetWinFactor = 0.5;
  final double targetLoseFactor = 0.4;
  bool isRolling = false;

  bool get insufficientBalance => balance < minBalance;

  //new variables end
  bool isGameOver = false;
  bool isStart = true;
  final random = Random.secure();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Masters'),
      ),
      body: AnimatedCrossFade(
        duration: const Duration(milliseconds: 500),
        crossFadeState:
            isStart ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        firstChild: startBody(context),
        secondChild: insufficientBalance ? endBody(context) : gameBody(context),
      ),
    );
  }

  Widget startBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Dice Masters',
            style: const TextStyle(fontSize: 30),
          ),
          DiceButton(
            onPressed: _startTheGame,
            title: 'START',
          ),
          DiceButton(
            onPressed: _howToPlay,
            title: 'HOW TO PLAY',
          ),
        ],
      ),
    );
  }

  Widget gameBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        balanceSection(context),
        if (isRolling)
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 100,
            child: Text(
              'ROLLING',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        if (!isRolling) diceSection(context),
        if (target > 0)
          Text('Your target is $target',
              style: Theme.of(context).textTheme.titleLarge),
        if (target > 0)
          Text(
            'Keep rolling until you match your target point is\n$target',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        if (!isGameOver)
          DiceButton(
            onPressed: isRolling
                ? null
                : () {
                    setState(() {
                      isRolling = true;
                    });
                    Future.delayed(const Duration(seconds: 1), () {
                      setState(() {
                        isRolling = false;
                      });
                      _rollTheDice();
                    });
                  },
            title: 'Roll',
          ),
        if (isGameOver)
          DiceButton(
            onPressed: _reset,
            title: 'Reset',
          ),
        Text(
          status,
          style: Theme.of(context).textTheme.displayLarge,
        )
      ],
    );
  }

  Column diceSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              diceList[index1],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              width: 10,
            ),
            Image.asset(
              diceList[index2],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ],
        ),
        Text(
          'Dice Sum: $diceSum',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }

  Widget balanceSection(BuildContext context) {
    return Column(
      children: [
        Text(
          'Balance: $currency${balance.toStringAsFixed(1)}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          'Minimum Balance Required: $currency${minBalance.toStringAsFixed(1)}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget endBody(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'You Lost\n You have insufficient balance\n$currency${balance.toStringAsFixed(1)}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(
            height: 20,
          ),
          DiceButton(
            onPressed: () {
              _reset();
              setState(() {
                isStart = true;
                balance = 100;
              });
            },
            title: 'MAIN',
          )
        ],
      ),
    );
  }

  void _rollTheDice() {
    setState(() {
      index1 = random.nextInt(6);
      index2 = random.nextInt(6);
      diceSum = index1 + index2 + 2;
      if (target > 0) {
        if (diceSum == target) {
          status = 'Player Wins!';
          isGameOver = true;
          calculateBalance(WinLoseStatus.targetWin);
        } else if (diceSum == 7) {
          status = 'Player Lost!';
          isGameOver = true;
          calculateBalance(WinLoseStatus.targetLose);
        }
      } else {
        if (diceSum == 7 || diceSum == 11) {
          status = 'Player Wins!';
          isGameOver = true;
          calculateBalance(WinLoseStatus.directWin);
        } else if (diceSum == 2 || diceSum == 3 || diceSum == 12) {
          status = 'Player Lost!!!';
          isGameOver = true;
          calculateBalance(WinLoseStatus.directLose);
        } else {
          target = diceSum;
        }
      }
    });
  }

  calculateBalance(WinLoseStatus status) {
    setState(() {
      switch (status) {
        case WinLoseStatus.directWin:
          balance += balance * directWinFactor;
          break;
        case WinLoseStatus.directLose:
          balance -= balance * directLoseFactor;
          break;
        case WinLoseStatus.targetWin:
          balance += balance * targetWinFactor;
          break;
        case WinLoseStatus.targetLose:
          balance -= balance * targetLoseFactor;
          break;
        default:
          break;
      }
    });
  }

  void _reset() {
    setState(() {
      index1 = 0;
      index2 = 0;
      diceSum = 0;
      isGameOver = false;
      status = '';
      target = 0;
    });
  }

  void _startTheGame() {
    setState(() {
      isStart = false;
    });
  }

  void _howToPlay() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Game Rules'),
              content: Text(rules),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CLOSE'),
                )
              ],
            ));
  }
}

class DiceButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const DiceButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 65,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            backgroundColor: Colors.blueGrey.shade900,
            foregroundColor: Colors.white,
          ),
          onPressed: onPressed,
          child: Text(title),
        ),
      ),
    );
  }
}

const rules = '''
1. At the first roll, if the Dice Sum is 7 or 11, Player wins!
2. At the first roll, if the Dice Sum is 2, 3 or 12, Player lose
3. At the first roll, if the Dice Sum is 4, 5, 6, 8, 9 or 10, Dice Sum will be the target point
4. If the dice sum matches the target point, player wins
5. if the dice sum is 7 while chasing the target, player loses.''';
