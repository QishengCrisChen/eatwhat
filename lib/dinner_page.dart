import 'package:flutter/material.dart';
import 'map_page.dart';

class DinnerPage extends StatelessWidget {
  final String restaurantName;  // 添加餐厅名称参数

  const DinnerPage({
    super.key,
    required this.restaurantName,  // 添加构造函数参数
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    
    void navigateToMap(String speed) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => MapPage(
            restaurantName: restaurantName,  // 使用传入的餐厅名称
            priceLevel: speed == 'Fast' ? 2 : 4, // Fast 对应 2个$，Slow 对应 4个$
            speed: speed,  // 传递速度参数
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
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.9,  // 改为90%屏幕宽度
              height: 240,  // 添加固定高度
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.orange.shade200, width: 1),
                  bottom: BorderSide(color: Colors.orange.shade200, width: 1),
                ),
              ),
              child: FittedBox(  // 添加 FittedBox 自适应文字大小
                fit: BoxFit.scaleDown,
                child: Text(
                  restaurantName,  // 使用传入的餐厅名称
                  style: TextStyle(
                    fontSize: 144,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSpeedButton('Fast', () => navigateToMap('Fast')),
                _buildSpeedButton('Slow', () => navigateToMap('Slow')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.orange.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
} 