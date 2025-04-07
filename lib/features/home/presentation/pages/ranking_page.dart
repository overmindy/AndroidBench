import 'package:flutter/material.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '性能排行榜',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: ListView.builder(
                itemCount: 10, // 暂时使用固定数量
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text('手机型号 ${index + 1}'),
                    subtitle: Text('性能得分: ${(1000 - index * 50).toString()}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: 实现查看详细信息
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}