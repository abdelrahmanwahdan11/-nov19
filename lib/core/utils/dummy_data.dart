import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

class CollectionModel {
  CollectionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    required this.location,
    required this.images,
    this.isFavourite = false,
    this.tasks = const [],
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime date;
  final String location;
  final List<String> images;
  final bool isFavourite;
  final List<TaskModel> tasks;

  CollectionModel copyWith({bool? isFavourite}) => CollectionModel(
        id: id,
        title: title,
        description: description,
        type: type,
        date: date,
        location: location,
        images: images,
        isFavourite: isFavourite ?? this.isFavourite,
        tasks: tasks,
      );
}

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.assignee,
    this.completed = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final String assignee;
  final bool completed;

  TaskModel copyWith({bool? completed}) => TaskModel(
        id: id,
        title: title,
        subtitle: subtitle,
        date: date,
        assignee: assignee,
        completed: completed ?? this.completed,
      );
}

class GalleryItem {
  const GalleryItem({
    required this.id,
    required this.image,
    required this.title,
    required this.description,
    required this.collectionId,
    this.isFavourite = false,
  });

  final String id;
  final String image;
  final String title;
  final String description;
  final String collectionId;
  final bool isFavourite;
}

class DummyData {
  static List<CollectionModel> collections = [
    CollectionModel(
      id: 'c1',
      title: 'Sunrise Desert Trip',
      description:
          'Watch the sunrise with friends and enjoy Bedouin breakfast with camel rides.',
      type: 'Trip',
      date: DateTime.now().add(const Duration(days: 6)),
      location: 'Dubai Desert',
      images: const [
        'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=400&q=80',
      ],
      isFavourite: true,
      tasks: const [
        TaskModel(
          id: 't1',
          title: 'Book Jeeps',
          subtitle: 'Call safari provider and confirm 10 seats',
          date: DateTime.now().add(Duration(days: 2)),
          assignee: 'Laila',
        ),
        TaskModel(
          id: 't2',
          title: 'Confirm breakfast menu',
          subtitle: 'Share vegan options with chef',
          date: DateTime.now().add(Duration(days: 3)),
          assignee: 'Omar',
        ),
      ],
    ),
    CollectionModel(
      id: 'c2',
      title: 'Nuviq Anniversary',
      description:
          'Elegant dinner with acoustic trio and projection mapping on walls.',
      type: 'Anniversary',
      date: DateTime.now().add(const Duration(days: 20)),
      location: 'Amman Downtown',
      images: const [
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=400&q=80',
      ],
    ),
    CollectionModel(
      id: 'c3',
      title: 'Secret Rooftop Party',
      description:
          'Neon vibes with immersive visuals, secret DJs, and AI photo booth.',
      type: 'Party',
      date: DateTime.now().add(const Duration(days: 2)),
      location: 'Riyadh',
      images: const [
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=600&q=80',
      ],
    ),
  ];

  static List<GalleryItem> gallery = [
    GalleryItem(
      id: 'g1',
      image: AppAssets.onboarding1,
      title: 'Sunrise dunes',
      description: 'Soft gradients of the golden desert morning.',
      collectionId: 'c1',
      isFavourite: true,
    ),
    GalleryItem(
      id: 'g2',
      image: AppAssets.onboarding2,
      title: 'Slow coffee',
      description: 'Manual brew workshop snapshot.',
      collectionId: 'c2',
    ),
    GalleryItem(
      id: 'g3',
      image: AppAssets.onboarding3,
      title: 'Dance floor',
      description: 'Holographic vibes for rooftop party.',
      collectionId: 'c3',
    ),
  ];

  static List<Map<String, String>> onboarding = [
    {
      'title': 'Collect dream events',
      'subtitle': 'Curate multi-day experiences with tactile planning tools.',
      'image': AppAssets.onboarding1,
    },
    {
      'title': 'Collaborate effortlessly',
      'subtitle': 'Assign tasks, comment, and monitor your team in one place.',
      'image': AppAssets.onboarding2,
    },
    {
      'title': 'Celebrate boldly',
      'subtitle': 'Design immersive parties using Nuviq inspired palettes.',
      'image': AppAssets.onboarding3,
    },
  ];

  static List<Color> primaryChoices = const [
    Color(0xFFB4DC3A),
    Color(0xFFFCB045),
    Color(0xFF56CFE1),
    Color(0xFFF15BB5),
    Color(0xFF6D67E4),
  ];
}
