import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp()); // MyApp で定義したアプリの実行をFlutterに指示
}

class MyApp extends StatelessWidget {
  // MyAppState クラスでアプリの状態を定義
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // どのウィジェットでも、そのウィジェットを常に最新にするために、周囲の状況が変化するたびに自動的に呼び出される build() メソッドを定義
    return ChangeNotifierProvider(
      // 状態を作成、アプリ全体に提供　これにより、アプリ内のどのウィジェットも状態を取得できるように
      create: (context) => MyAppState(),
      child: MaterialApp(
          title: 'Namer App',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: MyHomePage(),
          debugShowCheckedModeBanner: false),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // アプリの状態を定義　アプリが機能するために必要となるデータを定義
// ChangeNotifier を拡張　つまり、自身の変更に関する通知を行うことができるということ
  var current = WordPair.random();

  void getNext() {
    // currentに新しいランダムなWordPairを再代入
    current = WordPair.random();
    notifyListeners(); // 監視しているMyAppStateに通知するためにnotifyListeners()を呼び出す
  }

  var favorites =
      <WordPair>[]; // お気に入りの単語を格納するリスト ジェネリクス(<>)により、WordPairのみを格納できるようになる(WordPair以外にしようとすると実行拒否！！)

  void toggleFavorite() {
    // 気に入りのリストから現在の単語ペアを取り除くか（すでにそこにある場合）、追加する どっちも場合でもnotifyListeners()を呼び出す
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
              ],
              selectedIndex: 0,
              onDestinationSelected: (value) {
                print('selected: $value');
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: GeneratorPage(),
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // アプリの現在のテーマをリクエスト
    final style = theme.textTheme.displayMedium!.copyWith(
      // theme.textThemeでアプリのフォントテーマにアクセス　displayMediumは見出し書体　copywith()は定義した変更が反映された新しいテキストスタイルを返す
      // copyWithはテキスト スタイルの色以外にも多数のプロパティを変更できる！　cmd+shift+spaceでみれる
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      color: theme.colorScheme
          .primary, // カードの色をテーマのcolorSchemeプロパティと同じになるように定義　primaryはアプリの最も目立つ色
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          // スクリーンリーダーでも2つの単語を問題なく識別できるようにする
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
