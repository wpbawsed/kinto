import 'package:flutter/material.dart';

/// 搜尋頁（prd §F04 / §4.3）：SearchBar + 縣市快捷 + 結果清單。
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  static const _cities = ['台北市', '新北市', '桃園市', '台中市', '台南市', '高雄市'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('搜尋資源')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: SearchBar(hintText: '輸入地址或場所名稱'),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: _cities
                  .map((c) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ActionChip(label: Text(c), onPressed: () {}),
                      ))
                  .toList(),
            ),
          ),
          const Expanded(
            child: Center(child: Text('搜尋結果（待接 API）')),
          ),
        ],
      ),
    );
  }
}
