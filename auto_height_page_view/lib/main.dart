import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
      ),
      home: const MyHomePage(title: 'Flutter Auto Height PageView Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// 当前滑动到的位置下标
  int currentPageIndex = 0;

  /// 横向列表卡片高度集合
  /// 卡片渲染完成时，记录当前卡片高度
  Map<int, double> cardHeightMap = {};

  List<int> listData = List.generate(10, (index) => Random().nextInt(4) + 1);

  PageController pageController = PageController(viewportFraction: 0.8);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        showToast("点击了背景页面");
      },
      child: Container(
        width: MediaQuery.of(ctx).size.width,
        height: double.infinity,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(height: 30),
            _buildPageView(),
            // TextButton(
            //   onPressed: () {},
            //   child: Text('data'),
            // ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageView() {
    double cardHeight = 200.0; // 默认卡片最大高度
    if (listData.length > currentPageIndex) {
      cardHeight = cardHeightMap[currentPageIndex] ?? 200;
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: cardHeight,
      color: Colors.transparent,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollEndNotification) {
            // 滚动停止时的操作
            onPageViewScrollEndListener();
          }
          return true; // 返回 true 表示事件已处理
        },
        child: PageView.builder(
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, index) {
            return _pageItemView(index);
          },
          itemCount: listData.length,
          controller: pageController,
        ),
      ),
    );
  }

  Widget _pageItemView(int index) {
    double width = MediaQuery.of(context).size.width - 100;
    Widget child = GestureDetector(
      onTap: () {
        showToast("点击了卡片");
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.circular(8.0),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            listData[index],
            (i) => SizedBox(
              width: double.infinity,
              height: 40,
            ),
          ),
        ),
      ),
    );
    child = CustomLayoutSizedBox(
      child: child,
      onPerformLayout: (height) {
        cardHeightMap[index] = height;
      },
    );
    double height = 0.1; // 设置一个默认最低高度
    if (listData.length > currentPageIndex) {
      height = cardHeightMap[currentPageIndex] ?? 0.1;
    }
    child = Container(
      alignment: Alignment.topLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: width,
            height: height,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: child,
          ),
        ],
      ),
    );

    return child;
  }

  // 列表滑动停止
  void onPageViewScrollEndListener() {
    currentPageIndex = pageController.page?.toInt() ?? 0;
    setState(() {});
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT, // 短时间显示
      gravity: ToastGravity.CENTER, // 吐司位置
      timeInSecForIosWeb: 1, // iOS 和 Web 上的显示时间
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}

class CustomLayoutSizedBox extends SingleChildRenderObjectWidget {
  const CustomLayoutSizedBox({
    super.key,
    super.child,
    required this.onPerformLayout,
  });

  final void Function(double height)? onPerformLayout;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return CustomRenderConstrainedBox(onPerformLayout: onPerformLayout);
  }
}

class CustomRenderConstrainedBox extends RenderProxyBox {
  CustomRenderConstrainedBox({required this.onPerformLayout});

  final void Function(double height)? onPerformLayout;

  @override
  void performLayout() {
    super.performLayout();
    onPerformLayout?.call(child?.size.height ?? 0);
  }
}
