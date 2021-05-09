import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  Categories({Key key, this.categoriesMap, this.theme}) : super(key: key);

  final Map<String, dynamic> categoriesMap;
  final ThemeData theme;

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<String> categoriesList = [];
  Map<String, dynamic> categoriesMap;
  ThemeData themeData;

  @override
  void initState() {
    super.initState();
    themeData = widget.theme;
    categoriesMap = widget.categoriesMap;
    if (categoriesList.isNotEmpty) {
      for (var i = 0; i < categoriesList.length; i++) {
        categoriesList.remove(0);
      }
    }

    for (var i = 0; i < categoriesMap.length; i++) {
      categoriesList.add(categoriesMap['$i']['title']);
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context);
    var fwidth = media.size.width;
    var fheight = media.size.height;

    return Container(
      width: fwidth - 20,
      height: fheight * 0.2,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categoriesList.length,
          itemBuilder: (context, index) =>
              buildCategory(index, fwidth, fheight)),
    );

    // return FutureBuilder(
    //   // future: body.getData(),
    //   builder: (context, snapshot) {
    //     return buildListTile(fheight, fwidth);
    //   },
    //   // future: ,
    // );
  }

  // ListTile buildListTile(double fheight, double fwidth) {
  //   return ListTile(
  //     title: Padding(
  //       padding: EdgeInsets.all(5),
  //       child: SizedBox(
  //         height: fheight * 0.2,
  //         child: ListView.builder(
  //             scrollDirection: Axis.horizontal,
  //             itemCount: categoriesList.length,
  //             itemBuilder: (context, index) =>
  //                 buildCategory(index, fwidth, fheight)),
  //       ),
  //     ),
  //     onTap: () {},
  //   );
  // }

  Widget buildCategory(int index, var width, var height) {
    return Container(
      width: width * 0.3,
      height: height * 0.15,
      child: TextButton(
        onPressed: () {},
        child: Column(
          children: [
            Image.network(
              'https://cdnimg.melon.co.kr/cm2/album/images/105/54/246/10554246_20210325161233_500.jpg?304eb9ed9c07a16ec6d6e000dc0e7d91/melon/resize/282/quality/80/optimize',
            ),
            Text(
              categoriesList[index],
              maxLines: 2,
              overflow: TextOverflow.fade,
              softWrap: true,
              textAlign: TextAlign.center,
              style: themeData.textTheme.bodyText2,
            ),
          ],
        ),
      ),
    );
  }
}
