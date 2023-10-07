import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Puzzle Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WordPuzzleGame(),
    );
  }
}

class WordPuzzleGame extends StatefulWidget {
  @override
  _WordPuzzleGameState createState() => _WordPuzzleGameState();
}

class _WordPuzzleGameState extends State<WordPuzzleGame> {
  List<String> words = ["MOOD", "FACEBOOK", "MOON", "TODAY"];
  int currentLevel = 0;
  int wordIndex = 0;
  String originalWord = "";
  List<String> shuffledLetters = [];
  List<String> userLetters = [];
  bool isChecking = false;
  int secondsLeft = 30;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _initializeWords();
    _startNewLevel();
  }

  Future<List<String>> _loadWords() async {
    String jsonString = await rootBundle.loadString('assets/words.json');
    List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<String>();
  }


  void _initializeWords() async {
    List<String> loadedWords = await _loadWords();
    setState(() {
      words = loadedWords;

    });
  }

  void _startNewLevel() {
    if (words.isNotEmpty /*&& currentLevel < words.length*/) {
      setState(() {
        print(wordIndex);
        originalWord = words[wordIndex];
        wordIndex++;
        shuffledLetters = _shuffleLetters(originalWord.split(''));
        userLetters = List.from(shuffledLetters);
        isChecking = false;
        secondsLeft = 30;
        _startTimer();
      });
    } else {
      // Handle the case when the words list is empty or currentLevel is out of bounds
    }
  }

  List<String> _shuffleLetters(List<String> letters) {
    var random = Random();
    for (int i = letters.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      var temp = letters[i];
      letters[i] = letters[j];
      letters[j] = temp;
    }
    return letters;
  }

  bool _isWordCorrect() {
    return userLetters.join('') == originalWord;
  }

  void _startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        secondsLeft--;
        if (secondsLeft == 0) {
          _showTimeUpDialog();
        }
      });
    });
  }

  void _stopTimer() {
    timer.cancel();
  }

  void _showTimeUpDialog() {
    _stopTimer();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Time Up!'),
          content: Text('You ran out of time. Try again!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _startNewLevel();
              },
              child: Text('Next Level'),
            ),
          ],
        );
      },
    );
  }

  void _showResultDialog(bool isCorrect) {
    _stopTimer();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isCorrect ? 'Correct!' : 'Incorrect'),
          content: isCorrect
              ? Text('You solved the puzzle!')
              : Text('The letters do not form the correct word.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (isCorrect) {
                  if (currentLevel < words.length - 1) {
                    _startNewLevel();
                  } else {
                    _showGameCompleteDialog();
                  }
                }
              },
              child: Text('Next Level'),
            ),
          ],
        );
      },
    );
  }

  void _showGameCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You completed all levels!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restartGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  void _restartGame() {
    setState(() {
      currentLevel = 0;
    });
    _startNewLevel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Word Puzzle Game'),
    ),
    body: Padding(        padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Level $currentLevel',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Time left: $secondsLeft seconds',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: userLetters.map((letter) {
              return Draggable(
                data: letter,
                feedback: Material(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      letter,
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
                child: DragTarget(
                  builder: (context, candidateData, rejectedData) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    );
                  },
                  onWillAccept: (data) {
                    return true;
                  },
                  onAccept: (data) {
                    setState(() {
                      userLetters.remove(data as String);
                      userLetters.add(data as String);
                    });
                  },
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isChecking
                ? null
                : () {
              setState(() {
                isChecking = true;
              });
              if (_isWordCorrect()) {
                _showResultDialog(true);
                currentLevel++;
              } else {
                _showResultDialog(false);
              }
            },
            child: Text('Check'),
          ),
        ],
      ),
    ),
    );
  }
}


