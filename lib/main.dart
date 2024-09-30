import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(LudoApp());
}

class LudoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ludo Game',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomeScreen(),
    );
  }
}

class Player {
  String name;
  int score;
  int diceValue;
  bool isTurn;

  Player({required this.name, this.score = 0, this.diceValue = 1, this.isTurn = false});
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final List<Player> players = [
    Player(name: 'Maryam', isTurn: true),
    Player(name: 'Fazeela'),
    Player(name: 'Ayesha'),
    Player(name: 'Shanza'),
  ];

  int round = 0;
  int currentPlayerIndex = 0; // Track which player's turn it is
  int maxRounds = 6;

  late AnimationController _controller;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _zoomAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  void rollDiceForPlayer(int index) {
    setState(() {
      // Only allow the current player to roll the dice
      if (players[index].isTurn) {
        players[index].diceValue = Random().nextInt(6) + 1;
        players[index].score += players[index].diceValue;
        round++;
        // Move turn to the next player
        players[index].isTurn = false;
        currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
        players[currentPlayerIndex].isTurn = true;
      }
    });
  }

  Player? declareWinner() {
    return players.reduce((a, b) => a.score > b.score ? a : b); // Declare player with the highest score
  }

  void showWinnerDialog(Player winner) {
    _controller.forward(from: 0.0); // Start the zoom-in animation
    showDialog(
      context: context,
      builder: (context) {
        return ScaleTransition(
          scale: _zoomAnimation,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded corners for the dialog
            ),
            backgroundColor: Colors.white.withOpacity(0.9), // Slight transparency for the pop-up
            title: Text(
              '🎉 Congratulations! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.purpleAccent,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.purple,
                    offset: Offset(5.0, 5.0),
                  ),
                ],
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${winner.name} is the champion with ${winner.score} points! 🎊',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Image.asset(
                  'assets/images/confetti.png', // Optional confetti image for celebration
                  width: 100,
                  height: 100,
                ),
              ],
            ),
            actions: [
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      round = 0;
                      for (var player in players) {
                        player.score = 0;
                        player.diceValue = 1; // Resetting dice value to 1
                        player.isTurn = player.name == 'Maryam'; // Reset turns to the first player
                      }
                      currentPlayerIndex = 0; // Reset current player index
                    });
                  },
                  child: Text(
                    'Play Again',
                    style: TextStyle(fontSize: 18, color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Player? winner = round >= maxRounds * players.length ? declareWinner() : null;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset('assets/images/background.png',
              fit: BoxFit.cover, width: double.infinity, height: double.infinity),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Round: ${round ~/ players.length}', // Divide round by players.length to show actual rounds
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                SizedBox(height: 20),

                // Row for two upper dice images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildPlayerColumn(0),
                    buildPlayerColumn(1),
                  ],
                ),
                SizedBox(height: 20),

                // Row for two lower dice images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    buildPlayerColumn(2),
                    buildPlayerColumn(3),
                  ],
                ),
                SizedBox(height: 20),
                if (winner != null)
                  ElevatedButton(
                    onPressed: () => showWinnerDialog(winner),
                    child: Text('Show Winner'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column buildPlayerColumn(int index) {
    return Column(
      children: [
        Text('${players[index].name}', style: TextStyle(fontSize: 18, color: Colors.white)),
        Image.asset('assets/images/dice${players[index].diceValue}.png', width: 100, height: 100),
        Text('Score: ${players[index].score}', style: TextStyle(fontSize: 18, color: Colors.white)),
        ElevatedButton(
          onPressed: players[index].isTurn && round < maxRounds * players.length
              ? () => rollDiceForPlayer(index)
              : null,
          child: Text('Roll Dice'),
        ),
      ],
    );
  }
}
