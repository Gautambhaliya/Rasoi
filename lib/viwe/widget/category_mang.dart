import 'package:flutter/material.dart';
// import 'package:recipe/viwe/widget/support_widget.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String imagePath;
  CategoryItem(this.title, this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 20.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              height: 68,
              width: 68,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 10),
          Text(title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))
        ],
      ),
    );
  }
}
