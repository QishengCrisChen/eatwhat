import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatelessWidget {
  final String restaurantName;
  final int priceLevel;
  final String speed;  // 添加速度参数

  const MapPage({
    super.key, 
    required this.restaurantName, 
    required this.priceLevel,
    required this.speed,  // 添加速度参数
  });

  Future<void> _openGoogleMaps() async {
    // 获取当前时间
    final now = TimeOfDay.now();
    final hour = now.hour;
    
    // 构建搜索关键词
    String timePrefix = '';
    if (hour < 11) {
      timePrefix = 'breakfast';
    } else if (hour < 15) {
      timePrefix = 'lunch';
    } else {
      timePrefix = 'dinner';
    }

    // 构建完整的搜索查询
    final String searchQuery = '$timePrefix $restaurantName restaurant ${speed.toLowerCase()} food';
    final String priceLevel = '\$' * this.priceLevel; // 价格等级
    
    final String query = Uri.encodeComponent('$searchQuery $priceLevel');
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw '无法打开地图链接';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    
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
                  restaurantName,
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
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                priceLevel,
                (index) => Text(
                  '\$',
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.orange.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              speed,
              style: TextStyle(
                fontSize: 36,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 50),
            Container(
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
                onPressed: _openGoogleMaps,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '在 Google Maps 中打开',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 