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
          debugShowCheckedModeBanner: false), // debugの旗を消す
    );
  }
}

class MyAppState extends ChangeNotifier {
  // アプリの状態を定義　アプリが機能するために必要となるデータを定義
// ChangeNotifier を拡張　つまり、自身の変更に関する通知を行うことができるということ
  var current = WordPair.random();
  var history = <WordPair>[]; // WordPairの履歴を格納するリスト

  GlobalKey? historyListKey; // 履歴リストのキーを格納する変数
  // ?マークでnull許容型にしている
  // GlobalKeyは、任意の画面(ページ)やWidgetツリーの全く別の階層から特定のWidgetにアクセスするために利用

  void getNext() {
    // currentに新しいランダムなWordPairを再代入
    history.insert(0, current); // 履歴リストに現在の単語ペアを追加
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0); // 履歴リストの先頭にアニメーション付きで現在の単語ペアを追加
    current = WordPair.random();
    notifyListeners(); // 監視しているMyAppStateに通知するためにnotifyListeners()を呼び出す
  }

  var favorites =
      <WordPair>[]; // お気に入りの単語を格納するリスト ジェネリクス(<>)により、WordPairのみを格納できるようになる(WordPair以外にしようとすると実行拒否！！)

///////////////////////////よくわからない
  void toggleFavorite([WordPair? pair]) {
    // 気に入りのリストから現在の単語ペアを取り除くか（すでにそこにある場合）、追加する どっちも場合でもnotifyListeners()を呼び出す
    pair = pair ?? current; // pairがnullの場合、currentを代入
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

///////////////////////////よくわからない
  void removeFavorite(WordPair pair) {
    // お気に入りのリストから単語ペアを削除
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Stateクラスを継承しているため、自身の値を管理できる
// 銭湯が_なのでクラスが非公開になる

  var selectedIndex = 0; // 0に初期化
  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme;

    Widget page;
    switch (selectedIndex) {
      // selectedIndexの現在の値に基づいて、画面をpageに代入
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page =
            FavoritesPage(); // Placeholder()...配置した場所に従事が入った四角形を描画 その部分のUIが未完成なことを示す便利なウィジェット
        break;
      default:
        throw UnimplementedError(
            'no widget for $selectedIndex'); // ファイルファストの法則 selectedIndexが0でも1でもないとき、エラーをスロー
    }
/*
    var mainArea = ColoredBox(
      child: AnimatedSwitcher(
        // 画面の切り替え時にアニメーションを実行
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );
    */

    return LayoutBuilder(builder: (context, constraints) {
      // builderコールバックは、制約が変化するたびに呼び出される(アプリのウィンドウサイズを変更した、スマホの向きを変えた、MyHomePage横のウィジェットサイズが大きくなり、MyHomePageの制約が小さくなった)
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              // その子がハードウェアノッチやステータスバーで隠れないようにする(NavigationRailを包み、ナビゲーションボタンが隠されるのを防いでいる)
              child: NavigationRail(
                extended:
                    constraints.maxWidth >= 600, // 600以上の場合、ナビゲーションバーが拡張される
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
                selectedIndex:
                    selectedIndex, //　０が選択されると最初のデスティネーションが選択され、１が選択されると２番目のデスティネーションが選択される
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              // ある子は必要なだけのスペースをできる限り埋め、別のウィジェットは残りのスペースをできる限り埋める
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
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
                  appState.toggleFavorite(); // お気に入りの単語を切り替えるs
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

class FavoritesPage extends StatelessWidget {
  /*
  アプリの現在の状態を取得
  お気に入りのリストが空の場合は、中央寄せされた「No faviroites yet *.*」を表示
  そうでないばあいはリストを表示(スクロール可能)
  リストの最初には概要を表示(ex: You have 5 favorites*.*)
  すべてのお気に入りについて反復処理をお行い、それぞれにListTileを構築
  */
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // アプリの現在の状態を取得

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}
