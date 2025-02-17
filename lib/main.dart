import 'package:flutter/material.dart';
import 'dart:async';
import 'dinner_page.dart';
import 'map_page.dart';
import 'dart:math' as Math;
import 'package:just_audio/just_audio.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  bool showPage2 = false;
  bool isSpinning = false;
  int selectedPrice = 1;
  final List<String> items = ['Steak', 'sushi', 'Hotpot',  // 原数组
    'Pizza', 'Tacos', 'Pasta', 'Burger', 'Ramen',  // 更多食物
    'Paella', 'Pho', 'Tandoori Chicken', 'Feijoada', 'Moussaka',  // 不同国家的特色菜
    'Fine Dining', 'Street Food', 'Buffet', 'Farm-to-Table', 'Fusion Cuisine'];  // 饮食文化相关词汇];
  int currentIndex = 0;
  Timer? spinTimer;
  late AnimationController _bounceController;
  double _scrollOffset = 0.0;
  double dragDistance = 0.0;
  late AudioPlayer _coinPlayer;
  late AudioPlayer _slotPlayer;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // 初始化音频播放器
    _coinPlayer = AudioPlayer();
    _slotPlayer = AudioPlayer();
    
    // 初始化音频文件
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      await _coinPlayer.setAsset('assets/sounds/coin.wav');
      await _slotPlayer.setAsset('assets/sounds/slot.wav');
      print('Audio initialized successfully');  // 调试信息
    } catch (e) {
      print('Error initializing audio: $e');  // 错误信息
    }
  }

  void startSpinning() {
    setState(() {
      showPage2 = true;
      isSpinning = true;
      currentIndex = 0;
      dragDistance = 0;
    });

    // 播放老虎机滚动声音
    _slotPlayer.seek(Duration.zero).then((_) {
      _slotPlayer.play();
      print('Slot sound started');
    }).catchError((e) {
      print('Error playing slot sound: $e');
    });

    final random = Math.Random();
    final targetIndex = random.nextInt(items.length);

    double velocity = 0.5;
    const duration = Duration(milliseconds: 16);
    double position = 0;
    int elapsedTime = 0;
    final totalDuration = 3000;

    spinTimer?.cancel();
    spinTimer = Timer.periodic(duration, (timer) {
      elapsedTime += duration.inMilliseconds;
      
      setState(() {
        position += velocity;
        currentIndex = position.floor() % items.length;
      });

      // 计算减速
      double progress = elapsedTime / totalDuration;
      if (progress > 0.5) {
        velocity *= 0.97;
      }

      if (elapsedTime >= totalDuration) {
        timer.cancel();
        // 停止老虎机声音
        _slotPlayer.stop().then((_) {
          print('Slot sound stopped');
        }).catchError((e) {
          print('Error stopping slot sound: $e');
        });
        setState(() {
          isSpinning = false;
          currentIndex = targetIndex;
        });
        
        Future.delayed(const Duration(milliseconds: 500), () {
          final now = TimeOfDay.now();
          final isAfter3PM = now.hour >= 15;

          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => 
                isAfter3PM 
                  ? DinnerPage(
                      restaurantName: items[currentIndex],
                    )
                  : MapPage(
                      restaurantName: items[currentIndex],
                      priceLevel: selectedPrice,
                      speed: 'Fast',
                    ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        });
      }
    });
  }

  double calculateFontSize(String text, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double maxWidth = screenWidth * 0.8;
    const double characterWidth = 0.6;  // 估计每个字符的宽度比例
    double estimatedWidth = text.length * characterWidth * baseSize;
    
    if (estimatedWidth > maxWidth) {
      return (maxWidth / (text.length * characterWidth));
    }
    return baseSize;
  }

  Widget buildSpinningText() {
    int prevIndex = (currentIndex - 1 + items.length) % items.length;
    int nextIndex = (currentIndex + 1) % items.length;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth,
      height: screenHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.grey.shade100,
            Colors.white,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: screenWidth * 0.9,  // 增加到90%宽度
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 上一个项目
                  Container(
                    height: 80,  // 固定高度
                    child: FittedBox(  // 使用FittedBox自适应文字大小
                      fit: BoxFit.scaleDown,
                      child: Opacity(
                        opacity: 0.5,
                        child: Text(
                          items[prevIndex],
                          style: TextStyle(
                            fontSize: 72,
                            color: Colors.grey.shade500,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 当前项目
                  Container(
                    height: 160,  // 固定高度
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.orange.shade200, width: 1),
                        bottom: BorderSide(color: Colors.orange.shade200, width: 1),
                      ),
                    ),
                    child: FittedBox(  // 使用FittedBox自适应文字大小
                      fit: BoxFit.scaleDown,
                      child: Text(
                        items[currentIndex],
                        style: TextStyle(
                          fontSize: 144,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 下一个项目
                  Container(
                    height: 80,  // 固定高度
                    child: FittedBox(  // 使用FittedBox自适应文字大小
                      fit: BoxFit.scaleDown,
                      child: Opacity(
                        opacity: 0.5,
                        child: Text(
                          items[nextIndex],
                          style: TextStyle(
                            fontSize: 72,
                            color: Colors.grey.shade500,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (!showPage2) {  // 改回使用 showPage2 检查
            setState(() {
              dragDistance += details.delta.dy;
              dragDistance = dragDistance.clamp(0.0, 200.0);
            });
          }
        },
        onVerticalDragEnd: (details) {
          if (dragDistance > 50) {  // 移除 isSpinning 检查
            startSpinning();
          } else {
            setState(() {
              dragDistance = 0;
            });
          }
        },
        child: Center(
          child: !showPage2
              ? Container(
                  height: screenHeight,
                  child: Column(
                    children: [
                      // 顶部标题区域
                      SizedBox(height: screenHeight * 0.12), // 减小顶部留白
                      Container(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: const Text(
                          'WHAT TO EAT?',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      
                      // 价格选择区域
                      SizedBox(height: screenHeight * 0.06), // 减小间距
                      buildPriceButtons(),
                      
                      // 下拉按钮区域
                      SizedBox(height: screenHeight * 0.15),
                      Transform.translate(
                        offset: Offset(0, dragDistance),  // 使用 dragDistance 控制位移
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.1),
                            end: const Offset(0, 0.1),
                          ).animate(CurvedAnimation(
                            parent: _bounceController,
                            curve: Curves.easeInOut,
                          )),
                          child: Container(
                            margin: EdgeInsets.only(bottom: screenHeight * 0.05),
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 32,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.orange.shade300,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.restaurant_menu_rounded,
                                  color: Colors.orange.shade400,
                                  size: 28,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'DISCOVER',
                                  style: TextStyle(
                                    color: Colors.orange.shade700,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.orange.shade400,
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: showPage2 ? 1.0 : 0.0,
                  child: buildSpinningText(),
                ),
        ),
      ),
    );
  }

  Widget buildPriceButtons() {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          bool isSelected = index < selectedPrice;
          return GestureDetector(
            onTap: () {
              // 播放硬币声音
              _coinPlayer.seek(Duration.zero).then((_) {
                _coinPlayer.play();
                print('Coin sound played');
              }).catchError((e) {
                print('Error playing coin sound: $e');
              });
              setState(() {
                selectedPrice = index + 1;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 钱币外圈
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.amber : Colors.grey.shade200,
                      border: Border.all(
                        color: isSelected ? Colors.orange.shade800 : Colors.grey.shade400,
                        width: 2,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        )
                      ] : [],
                    ),
                  ),
                  // 钱币内部纹路
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.orange.shade800.withOpacity(0.5) : Colors.grey.shade400.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                  ),
                  // $ 符号
                  Text(
                    '\$',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.orange.shade900 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    spinTimer?.cancel();
    _coinPlayer.dispose();
    _slotPlayer.dispose();
    super.dispose();
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, size.height * 0.3)
      ..quadraticBezierTo(
        size.width / 2, 0,
        size.width, size.height * 0.3,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

