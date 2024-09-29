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

  Player({required this.name, this.score = 0, this.diceValue = 1});
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<Player> players = [
    Player(name: 'Maryam'),
    Player(name: 'Fazeela'),
    Player(name: 'Ayesha'),
    Player(name: 'Shanza'),
  ];

  int round = 0;
  int maxRounds = 5;

  late AnimationController _controller;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _zoomAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  void rollDiceForPlayers() {
    setState(() {
      for (var player in players) {
        player.diceValue =
            Random().nextInt(6) + 1; // Each player gets a different dice value
        player.score +=
            player.diceValue; // Update score based on individual dice value
      }
      round++;
    });
  }

  Player? declareWinner() {
    return players.reduce((a, b) =>
        a.score > b.score ? a : b); // Declare player with highest score
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Player? winner = round >= maxRounds ? declareWinner() : null;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Image.asset('assets/images/background.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity),

          // Main Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Round: $round',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                SizedBox(height: 20),

                // Row for two upper dice images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('${players[0].name}',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                        Image.asset(
                            'assets/images/dice${players[0].diceValue}.png',
                            width: 100,
                            height: 100),
                        Text('Score: ${players[0].score}',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('${players[1].name}',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                        Image.asset(
                            'assets/images/dice${players[1].diceValue}.png',
                            width: 100,
                            height: 100),
                        Text('Score: ${players[1].score}',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Row for two lower dice images
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('${players[2].name}',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                        Image.asset(
                            'assets/images/dice${players[2].diceValue}.png',
                            width: 100,
                            height: 100),
                        Text('Score: ${players[2].score}',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('${players[3].name}',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                        Image.asset(
                            'assets/images/dice${players[3].diceValue}.png',
                            width: 100,
                            height: 100),
                        Text('Score: ${players[3].score}',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: round < maxRounds
                      ? rollDiceForPlayers
                      : () {
                          if (winner != null) {
                            _controller.forward(
                                from: 0.0); // Start the zoom-in animation
                            showDialog(
                              context: context,
                              builder: (context) {
                                return ScaleTransition(
                                  scale: _zoomAnimation,
                                  child: AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          20), // Rounded corners for the dialog
                                    ),
                                    backgroundColor: Colors.white.withOpacity(
                                        0.9), // Slight transparency for the pop-up
                                    title: Text(
                                      '🎉 Winner! 🎉',
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
                                          '${winner.name} is the winner with ${winner.score} points!',
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
                                                player.diceValue =
                                                    1; // Resetting dice value to 1
                                              }
                                            });
                                          },
                                          child: Text(
                                            'Play Again',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          }
                        },
                  child:
                      Text(round < maxRounds ? 'Roll Dice' : 'Declare Winner'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
