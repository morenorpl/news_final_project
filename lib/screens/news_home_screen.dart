import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:news_app_with_getx/controller/news_controller.dart';
import 'package:news_app_with_getx/screens/news_detail_screen.dart';
import 'package:news_app_with_getx/screens/news_search_screen.dart';

class NewsHomeScreen extends StatelessWidget {
  const NewsHomeScreen({super.key});

  Widget categoryButton(String label, String type) {
    final newsController = Get.find<NewsController>();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        // The foreground color also depends on the controller's state.
        foregroundColor: Colors.orangeAccent,
        textStyle: TextStyle(
          fontWeight: newsController.selectedCategory.value == type
              ? FontWeight.w800
              : FontWeight.w400,
        ),
        elevation: newsController.selectedCategory.value == type ? 0 : 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        newsController.changeCategory(type);
      },
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final newsController = Get.find<NewsController>();
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: 'Kabari',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(
                text: 'Feed',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        toolbarHeight: 100,
        actions: [
          IconButton(
            onPressed: () {
              Get.to(NewsSearchScreen());
            },
            icon: Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Obx(() {
                return Row(
                  spacing: 10,
                  children: [
                    categoryButton('Semua', 'semua'),
                    categoryButton('National', 'nasional'),
                    categoryButton('International', 'internasional'),
                    categoryButton('Ekonomi', 'ekonomi'),
                    categoryButton('Olahraga', 'olahraga'),
                    categoryButton('Teknologi', 'teknologi'),
                    categoryButton('Hiburan', 'hiburan'),
                    categoryButton('Gaya-hidup', 'gaya-hidup'),
                  ],
                );
              }),
            ),
          ),
          SizedBox(height: 20),

          Expanded(
            child: Obx(() {
              final listToDisplay = newsController.filteredNews;
              if (newsController.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (listToDisplay.isEmpty) {
                return Center(child: Text('no news found'));
              }

              return ListView.separated(
                itemCount: listToDisplay.length,
                itemBuilder: (context, index) {
                  final item = listToDisplay[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: InkWell(
                      onTap: () {
                        Get.to(NewsDetailScreen(newsDetail: item));
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x2020200D),
                              spreadRadius: 3,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 120,
                              width: 110,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(item['image']['small']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            SizedBox(
                              width: 220,
                              height: 120,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['title'],
                                      maxLines: 3,

                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item['isoDate'],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Obx(() {
                                final isBookMarked = newsController.isBookMark(
                                  item,
                                );
                                return IconButton(
                                  onPressed: () {
                                    if (isBookMarked) {
                                      newsController.removeBookMark(item);
                                    } else {
                                      newsController.addBookMark(item);
                                    }
                                  },
                                  icon: isBookMarked
                                      ? Icon(Icons.bookmark_rounded)
                                      : Icon(Icons.bookmark_border_rounded),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: 20);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
