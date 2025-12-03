import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:news_app_with_getx/controller/news_controller.dart';
import 'package:news_app_with_getx/screens/news_detail_screen.dart';
import 'package:news_app_with_getx/screens/news_search_screen.dart';

class NewsHomeScreen extends StatelessWidget {
  const NewsHomeScreen({super.key});

  Widget categoryButton(String label, String type) {
    final newsController = Get.find<NewsController>();

    return Obx(() => ElevatedButton( 
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: newsController.selectedCategory.value == type 
            ? Colors.orangeAccent 
            : Colors.grey, 
        textStyle: TextStyle(
          fontWeight: newsController.selectedCategory.value == type
              ? FontWeight.w800
              : FontWeight.w400,
        ),
        elevation: newsController.selectedCategory.value == type ? 0 : 3,
        side: newsController.selectedCategory.value == type 
            ? const BorderSide(color: Colors.orangeAccent, width: 2) 
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        newsController.changeCategory(type);
      },
      child: Text(label),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final newsController = Get.put(NewsController()); 

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
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
              Get.to(() => const NewsSearchScreen());
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  categoryButton('Semua', 'semua'),
                  const SizedBox(width: 10),
                  categoryButton('National', 'nasional'),
                  const SizedBox(width: 10),
                  categoryButton('International', 'internasional'),
                  const SizedBox(width: 10),
                  categoryButton('Ekonomi', 'ekonomi'),
                  const SizedBox(width: 10),
                  categoryButton('Olahraga', 'olahraga'),
                  const SizedBox(width: 10),
                  categoryButton('Teknologi', 'teknologi'),
                  const SizedBox(width: 10),
                  categoryButton('Hiburan', 'hiburan'),
                  const SizedBox(width: 10),
                  categoryButton('Gaya-hidup', 'gaya-hidup'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Obx(() {
              if (newsController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final listToDisplay = newsController.filteredNews;
              
              if (listToDisplay.isEmpty) {
                return const Center(child: Text('No news found'));
              }

              return ListView.separated(
                itemCount: listToDisplay.length,
                itemBuilder: (context, index) {
                  final item = listToDisplay[index];
                  final imageUrl = item['image']?['small'] ?? 'https://via.placeholder.com/150';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: InkWell(
                      onTap: () {
                        Get.to(() => NewsDetailScreen(newsDetail: item));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
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
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                  onError: (exception, stackTrace) {
                                    // Handle jika gambar error
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: SizedBox(
                                height: 120,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['title'] ?? 'No Title',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16, // Ukuran font disesuaikan agar muat
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          // Format tanggal sederhana atau default
                                          (item['isoDate'] as String?)?.substring(0, 10) ?? '',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Obx(() {
                                          final isBookMarked = newsController.isBookMark(item);
                                          return GestureDetector(
                                            onTap: () {
                                              if (isBookMarked) {
                                                newsController.removeBookMark(item);
                                              } else {
                                                newsController.addBookMark(item);
                                              }
                                            },
                                            child: Icon(
                                              isBookMarked
                                                  ? Icons.bookmark_rounded
                                                  : Icons.bookmark_border_rounded,
                                              color: isBookMarked ? Colors.orange : Colors.grey,
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 20);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}