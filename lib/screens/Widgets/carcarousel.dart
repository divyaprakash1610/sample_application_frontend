import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarCarouselSheet extends StatefulWidget {
  const CarCarouselSheet({super.key});

  @override
  State<CarCarouselSheet> createState() => _CarCarouselSheetState();
}

class _CarCarouselSheetState extends State<CarCarouselSheet> {
  final Set<String> likedCars = {};

  final List<Map<String, Object>> carGroups = [
    {
      'title': 'Electric Cars',
      'cars': [
        {
          'name': 'Nissan Leaf',
          'image': 'assets/images/leaf.jpg',
          'specs': 'Electric · 226 mi range · 7.4s 0-60 mph',
          'desc': 'Affordable and reliable electric hatchback.'
        },
        {
          'name': 'BMW i4',
          'image': 'assets/images/bmwi4.jpg',
          'specs': 'Electric · 301 mi range · 4.0s 0-60 mph',
          'desc': 'Sleek German engineering with impressive speed.'
        },
        {
          'name': 'Audi e-Tron',
          'image': 'assets/images/etron.jpg',
          'specs': 'Electric · 222 mi range · AWD',
          'desc': 'Luxury meets electric innovation in this SUV.'
        },
        {
          'name': 'Hyundai Ioniq 5',
          'image': 'assets/images/ioniq5.jpg',
          'specs': 'Electric · 303 mi range · 5.2s 0-60 mph',
          'desc': 'Futuristic design with smart features and space.'
        },
      ],
    },
    {
      'title': 'Muscle Cars',
      'cars': [
        {
          'name': 'Chevrolet Corvette',
          'image': 'assets/images/corvette.jpg',
          'specs': 'V8 · 495 hp · 2.9s 0-60 mph',
          'desc': 'A modern American icon with mid-engine thrills.'
        },
        {
          'name': 'Lamborghini Huracán',
          'image': 'assets/images/huracan.jpg',
          'specs': 'V10 · 602 hp · 2.5s 0-60 mph',
          'desc': 'Exotic performance with sharp Italian styling.'
        },
        {
          'name': 'Ford Mustang',
          'image': 'assets/images/mustang.jpg',
          'specs': 'V8 · 480 hp · 4.2s 0-60 mph',
          'desc': 'Legendary pony car with attitude and muscle.'
        },
        {
          'name': 'Chevy Camaro',
          'image': 'assets/images/camaro.jpg',
          'specs': 'V8 · 455 hp · 4.0s 0-60 mph',
          'desc': 'Aggressive looks backed by raw power.'
        },
        {
          'name': 'Dodge Challenger',
          'image': 'assets/images/challenger.jpg',
          'specs': 'V8 · 717 hp · 3.5s 0-60 mph',
          'desc': 'Bold retro styling with supercharged fury.'
        },
        {
          'name': 'Dodge Charger',
          'image': 'assets/images/charger.jpg',
          'specs': 'V8 · 707 hp · 3.6s 0-60 mph',
          'desc': 'Powerful sedan blending muscle and comfort.'
        },
      ],
    },
    {
      'title': 'Luxury Classics',
      'cars': [
        {
          'name': 'BMW M4',
          'image': 'assets/images/bmw.jpg',
          'specs': 'Twin-turbo I6 · 473 hp · 3.8s 0-60 mph',
          'desc': 'Precision driving with German craftsmanship.'
        },
        {
          'name': 'Audi A6',
          'image': 'assets/images/audi.jpg',
          'specs': 'Turbo V6 · AWD · 335 hp',
          'desc': 'Elegant, tech-filled executive sedan.'
        },
        {
          'name': 'Porsche 911',
          'image': 'assets/images/porsche911.jpg',
          'specs': 'Flat-6 · 443 hp · 3.5s 0-60 mph',
          'desc': 'Timeless sports car with unmatched balance.'
        },
        {
          'name': 'Pontiac GTO',
          'image': 'assets/images/gto.jpg',
          'specs': 'V8 · 400 hp · Muscle legend',
          'desc': 'Classic American muscle from the 60s.'
        },
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    return Container(
      height: screenHeight * 0.97,
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: carGroups.length,
        itemBuilder: (context, groupIndex) {
          final group = carGroups[groupIndex];
          final title = group['title'] as String;
          final cars = group['cars'] as List<Map<String, String>>;

          return Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.025),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.015),
                CarouselSlider.builder(
                  options: CarouselOptions(
                    height: screenHeight * 0.47,
                    enlargeCenterPage: true,
                    enlargeStrategy: CenterPageEnlargeStrategy.height,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    viewportFraction: 0.85,
                  ),
                  itemCount: cars.length,
                  itemBuilder: (context, index, _) {
                    final car = cars[index];
                    final carName = car['name']!;
                    final isLiked = likedCars.contains(carName);

                    return Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[900],
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.asset(
                              car['image']!,
                              height: screenHeight * 0.3,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          carName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (isLiked) {
                                              likedCars.remove(carName);
                                            } else {
                                              likedCars.add(carName);
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  Flexible(
                                    child: Text(
                                      car['specs']!,
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: screenWidth * 0.035,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  Flexible(
                                    child: Text(
                                      car['desc']!,
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: screenWidth * 0.032,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
