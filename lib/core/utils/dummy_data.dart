import 'package:flutter/material.dart';

import '../constants/app_assets.dart';

class ItineraryTags {
  static const logistics = 'Logistics';
  static const experience = 'Experience';
  static const culinary = 'Culinary';
  static const wellness = 'Wellness';
  static const tech = 'Tech';
}

class ItinerarySlotModel {
  const ItinerarySlotModel({
    required this.id,
    required this.title,
    required this.note,
    required this.time,
    required this.tag,
  });

  final String id;
  final String title;
  final String note;
  final TimeOfDay time;
  final String tag;

  ItinerarySlotModel copyWith({
    String? title,
    String? note,
    TimeOfDay? time,
    String? tag,
  }) =>
      ItinerarySlotModel(
        id: id,
        title: title ?? this.title,
        note: note ?? this.note,
        time: time ?? this.time,
        tag: tag ?? this.tag,
      );
}

class ItineraryDayModel {
  const ItineraryDayModel({
    required this.id,
    required this.date,
    required this.focus,
    this.cover = '',
    this.slots = const [],
  });

  final String id;
  final DateTime date;
  final String focus;
  final String cover;
  final List<ItinerarySlotModel> slots;

  ItineraryDayModel copyWith({String? focus, List<ItinerarySlotModel>? slots}) =>
      ItineraryDayModel(
        id: id,
        date: date,
        focus: focus ?? this.focus,
        cover: cover,
        slots: slots ?? this.slots,
      );
}

class CollectionModel {
  CollectionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    required this.location,
    required this.images,
    required this.budgetPlanned,
    required this.budgetUsed,
    this.milestones = const [],
    this.isFavourite = false,
    this.tasks = const [],
    this.journalEntries = const [],
    this.itinerary = const [],
    this.guests = const [],
  });

  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime date;
  final String location;
  final List<String> images;
  final double budgetPlanned;
  final double budgetUsed;
  final List<MilestoneModel> milestones;
  final bool isFavourite;
  final List<TaskModel> tasks;
  final List<JournalEntryModel> journalEntries;
  final List<ItineraryDayModel> itinerary;
  final List<GuestModel> guests;

  CollectionModel copyWith({
    bool? isFavourite,
    List<TaskModel>? tasks,
    double? budgetPlanned,
    double? budgetUsed,
    List<MilestoneModel>? milestones,
    List<JournalEntryModel>? journalEntries,
    List<ItineraryDayModel>? itinerary,
    List<GuestModel>? guests,
  }) =>
      CollectionModel(
        id: id,
        title: title,
        description: description,
        type: type,
        date: date,
        location: location,
        images: images,
        budgetPlanned: budgetPlanned ?? this.budgetPlanned,
        budgetUsed: budgetUsed ?? this.budgetUsed,
        milestones: milestones ?? this.milestones,
        isFavourite: isFavourite ?? this.isFavourite,
        tasks: tasks ?? this.tasks,
        journalEntries: journalEntries ?? this.journalEntries,
        itinerary: itinerary ?? this.itinerary,
        guests: guests ?? this.guests,
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

  TaskModel copyWith({bool? completed, DateTime? date, String? title, String? subtitle, String? assignee}) =>
      TaskModel(
        id: id,
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        date: date ?? this.date,
        assignee: assignee ?? this.assignee,
        completed: completed ?? this.completed,
      );
}

enum MilestoneStatus { planned, progress, done }

class MilestoneModel {
  const MilestoneModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    this.status = MilestoneStatus.planned,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime date;
  final MilestoneStatus status;

  MilestoneModel copyWith({MilestoneStatus? status}) => MilestoneModel(
        id: id,
        title: title,
        subtitle: subtitle,
        date: date,
        status: status ?? this.status,
      );
}

enum JournalMood { excited, calm, focused }

class JournalEntryModel {
  const JournalEntryModel({
    required this.id,
    required this.title,
    required this.note,
    required this.date,
    required this.mood,
    required this.image,
  });

  final String id;
  final String title;
  final String note;
  final DateTime date;
  final JournalMood mood;
  final String image;
}

enum GuestStatus { invited, confirmed, tentative, declined }

class GuestModel {
  const GuestModel({
    required this.id,
    required this.name,
    required this.role,
    required this.contact,
    required this.avatar,
    this.status = GuestStatus.invited,
  });

  final String id;
  final String name;
  final String role;
  final String contact;
  final String avatar;
  final GuestStatus status;

  GuestModel copyWith({
    String? name,
    String? role,
    String? contact,
    String? avatar,
    GuestStatus? status,
  }) =>
      GuestModel(
        id: id,
        name: name ?? this.name,
        role: role ?? this.role,
        contact: contact ?? this.contact,
        avatar: avatar ?? this.avatar,
        status: status ?? this.status,
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

  GalleryItem copyWith({bool? isFavourite}) => GalleryItem(
        id: id,
        image: image,
        title: title,
        description: description,
        collectionId: collectionId,
        isFavourite: isFavourite ?? this.isFavourite,
      );
}

class NuviqNotification {
  const NuviqNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime time;
  final bool read;

  NuviqNotification copyWith({bool? read}) => NuviqNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        time: time,
        read: read ?? this.read,
      );
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
      budgetPlanned: 12000,
      budgetUsed: 6200,
      isFavourite: true,
      tasks: [
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
      milestones: [
        MilestoneModel(
          id: 'm1',
          title: 'Route scouting',
          subtitle: 'Confirm dune entry checkpoints',
          date: DateTime.now().add(const Duration(days: 1)),
        ),
        MilestoneModel(
          id: 'm2',
          title: 'Logistics sync',
          subtitle: 'Share packing list with guests',
          date: DateTime.now().add(const Duration(days: 3)),
          status: MilestoneStatus.progress,
        ),
        MilestoneModel(
          id: 'm3',
          title: 'Sunrise drone test',
          subtitle: 'Dry-run filming with pilot',
          date: DateTime.now().add(const Duration(days: 5)),
        ),
      ],
      journalEntries: [
        JournalEntryModel(
          id: 'j1',
          title: 'Dawn scouting',
          note: 'Tested dune entry before sunrise and mapped camel break spots.',
          date: DateTime.now().subtract(const Duration(hours: 8)),
          mood: JournalMood.excited,
          image: AppAssets.onboarding1,
        ),
        JournalEntryModel(
          id: 'j2',
          title: 'Menu tasting',
          note: 'Chef nailed the saffron pancakes, only tweak is more cardamom.',
          date: DateTime.now().subtract(const Duration(days: 1)),
          mood: JournalMood.calm,
          image: 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?auto=format&fit=crop&w=900&q=80',
        ),
      ],
      guests: const [
        GuestModel(
          id: 'g1',
          name: 'Laila Hassan',
          role: 'Logistics lead',
          contact: '+971 55 200 1122',
          avatar: 'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?auto=format&fit=crop&w=200&q=80',
          status: GuestStatus.confirmed,
        ),
        GuestModel(
          id: 'g2',
          name: 'Omar Nasser',
          role: 'Drone pilot',
          contact: '+971 50 334 4422',
          avatar: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=200&q=80',
          status: GuestStatus.confirmed,
        ),
        GuestModel(
          id: 'g3',
          name: 'Sara Qamar',
          role: 'Experience guest',
          contact: 'sara@nuviq.app',
          avatar: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=200&q=80',
          status: GuestStatus.tentative,
        ),
        GuestModel(
          id: 'g4',
          name: 'Jad Farah',
          role: 'Chef liaison',
          contact: '+971 55 199 8733',
          avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=200&q=80',
          status: GuestStatus.invited,
        ),
      ],
      itinerary: [
        ItineraryDayModel(
          id: 'c1d1',
          date: DateTime.now().add(const Duration(days: 5)),
          focus: 'Convoy warm-up',
          cover:
              'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1000&q=80',
          slots: [
            ItinerarySlotModel(
              id: 'c1s1',
              time: const TimeOfDay(hour: 4, minute: 30),
              title: 'Convoy meetup',
              note: 'Load jeeps, hand radios, hydration check.',
              tag: ItineraryTags.logistics,
            ),
            ItinerarySlotModel(
              id: 'c1s2',
              time: const TimeOfDay(hour: 5, minute: 45),
              title: 'Dune ascent briefing',
              note: 'Pilot shares sunrise anchor points.',
              tag: ItineraryTags.tech,
            ),
            ItinerarySlotModel(
              id: 'c1s3',
              time: const TimeOfDay(hour: 7, minute: 0),
              title: 'Bedouin breakfast',
              note: 'Serve saffron pancakes + mint labneh.',
              tag: ItineraryTags.culinary,
            ),
          ],
        ),
        ItineraryDayModel(
          id: 'c1d2',
          date: DateTime.now().add(const Duration(days: 6)),
          focus: 'Desert wellness',
          cover:
              'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=900&q=60',
          slots: [
            ItinerarySlotModel(
              id: 'c1s4',
              time: const TimeOfDay(hour: 6, minute: 15),
              title: 'Sunrise yoga',
              note: 'Calm stretch with sand anchors.',
              tag: ItineraryTags.wellness,
            ),
            ItinerarySlotModel(
              id: 'c1s5',
              time: const TimeOfDay(hour: 8, minute: 30),
              title: 'Camel ride loop',
              note: 'Split guests in two groups.',
              tag: ItineraryTags.experience,
            ),
            ItinerarySlotModel(
              id: 'c1s6',
              time: const TimeOfDay(hour: 10, minute: 0),
              title: 'Drone photo drop',
              note: 'Capture hero shots + deliver via Airdrop booth.',
              tag: ItineraryTags.tech,
            ),
          ],
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
      budgetPlanned: 9000,
      budgetUsed: 7800,
      tasks: [
        TaskModel(
          id: 't3',
          title: 'Confirm band set list',
          subtitle: 'Share favourite songs with trio',
          date: DateTime.now().add(Duration(days: 10)),
          assignee: 'Maya',
        ),
        TaskModel(
          id: 't4',
          title: 'Finalize projection mapping',
          subtitle: 'Send updated storyboards',
          date: DateTime.now().add(Duration(days: 12)),
          assignee: 'Yousef',
        ),
      ],
      milestones: [
        MilestoneModel(
          id: 'm4',
          title: 'Guest list freeze',
          subtitle: 'Confirm RSVPs and allergies',
          date: DateTime.now().add(const Duration(days: 7)),
          status: MilestoneStatus.progress,
        ),
        MilestoneModel(
          id: 'm5',
          title: 'Venue lighting test',
          subtitle: 'Warm dim + projection alignment',
          date: DateTime.now().add(const Duration(days: 11)),
        ),
        MilestoneModel(
          id: 'm6',
          title: 'Chef tasting',
          subtitle: 'Approve tasting menu + plating',
          date: DateTime.now().add(const Duration(days: 14)),
        ),
      ],
      journalEntries: [
        JournalEntryModel(
          id: 'j3',
          title: 'Projection tests',
          note: 'Gradient loop looks soft on the brick wall after recalibrating brightness.',
          date: DateTime.now().subtract(const Duration(days: 2)),
          mood: JournalMood.focused,
          image: AppAssets.onboarding2,
        ),
        JournalEntryModel(
          id: 'j4',
          title: 'Acoustic trio jam',
          note: 'Band improvised an Arabic lo-fi bridge that fits the dinner reveal.',
          date: DateTime.now().subtract(const Duration(days: 4)),
          mood: JournalMood.calm,
          image: 'https://images.unsplash.com/photo-1440404653325-ab127d49abc1?auto=format&fit=crop&w=900&q=80',
        ),
      ],
      guests: const [
        GuestModel(
          id: 'g5',
          name: 'Maya Rahman',
          role: 'Host',
          contact: 'maya@nuviq.app',
          avatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80',
          status: GuestStatus.confirmed,
        ),
        GuestModel(
          id: 'g6',
          name: 'Yousef Ghannam',
          role: 'Projection artist',
          contact: '+962 79 444 2211',
          avatar: 'https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=200&q=80',
          status: GuestStatus.tentative,
        ),
        GuestModel(
          id: 'g7',
          name: 'Reem Awwad',
          role: 'VIP guest',
          contact: 'reem@nuviq.app',
          avatar: 'https://images.unsplash.com/photo-1544723795-432537f7794d?auto=format&fit=crop&w=200&q=80',
          status: GuestStatus.invited,
        ),
        GuestModel(
          id: 'g8',
          name: 'Tareq Halabi',
          role: 'Acoustic trio',
          contact: '+962 78 555 9011',
          avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
          status: GuestStatus.confirmed,
        ),
      ],
      itinerary: [
        ItineraryDayModel(
          id: 'c2d1',
          date: DateTime.now().add(const Duration(days: 18)),
          focus: 'Arrival ritual',
          cover:
              'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=1200&q=70',
          slots: [
            ItinerarySlotModel(
              id: 'c2s1',
              time: const TimeOfDay(hour: 17, minute: 0),
              title: 'Guest welcome',
              note: 'Acoustic foyer loop + scent diffusion.',
              tag: ItineraryTags.experience,
            ),
            ItinerarySlotModel(
              id: 'c2s2',
              time: const TimeOfDay(hour: 18, minute: 30),
              title: 'Projection reveal',
              note: 'Sync lighting cues with trio bridge.',
              tag: ItineraryTags.tech,
            ),
            ItinerarySlotModel(
              id: 'c2s3',
              time: const TimeOfDay(hour: 19, minute: 15),
              title: 'Chef parade',
              note: 'Slow walk plating to each table.',
              tag: ItineraryTags.culinary,
            ),
          ],
        ),
        ItineraryDayModel(
          id: 'c2d2',
          date: DateTime.now().add(const Duration(days: 19)),
          focus: 'Intimate finale',
          cover:
              'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=60',
          slots: [
            ItinerarySlotModel(
              id: 'c2s4',
              time: const TimeOfDay(hour: 16, minute: 45),
              title: 'Sound check',
              note: 'Balance trio with projection hum.',
              tag: ItineraryTags.tech,
            ),
            ItinerarySlotModel(
              id: 'c2s5',
              time: const TimeOfDay(hour: 20, minute: 0),
              title: 'Anniversary toast',
              note: 'Lighting drop + curated story slides.',
              tag: ItineraryTags.experience,
            ),
            ItinerarySlotModel(
              id: 'c2s6',
              time: const TimeOfDay(hour: 21, minute: 0),
              title: 'Dessert garden',
              note: 'Install edible flowers on mirrored trays.',
              tag: ItineraryTags.culinary,
            ),
          ],
        ),
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
      budgetPlanned: 15000,
      budgetUsed: 11000,
      tasks: [
        TaskModel(
          id: 't5',
          title: 'Secure rooftop permit',
          subtitle: 'Send documents to municipality',
          date: DateTime.now().add(Duration(days: 1)),
          assignee: 'Hani',
        ),
        TaskModel(
          id: 't6',
          title: 'Sync DJs playlist',
          subtitle: 'Finalize set order and visuals cues',
          date: DateTime.now().add(Duration(days: 2)),
          assignee: 'Layth',
        ),
      ],
      milestones: [
        MilestoneModel(
          id: 'm7',
          title: 'Permit approval',
          subtitle: 'City official walk-through',
          date: DateTime.now().add(const Duration(days: 1)),
          status: MilestoneStatus.done,
        ),
        MilestoneModel(
          id: 'm8',
          title: 'Stage rig build',
          subtitle: 'Finalize LED columns',
          date: DateTime.now().add(const Duration(days: 1)),
          status: MilestoneStatus.progress,
        ),
        MilestoneModel(
          id: 'm9',
          title: 'Secret invite drop',
          subtitle: 'Push AR invites to VIPs',
          date: DateTime.now().add(const Duration(days: 2)),
        ),
      ],
      journalEntries: [
        JournalEntryModel(
          id: 'j5',
          title: 'Permit win',
          note: 'City official loved the sustainability focus—approval signed instantly.',
          date: DateTime.now().subtract(const Duration(hours: 3)),
          mood: JournalMood.excited,
          image: AppAssets.onboarding3,
        ),
        JournalEntryModel(
          id: 'j6',
          title: 'Light rehearsal',
          note: 'Tested neon columns with haze—needs extra diffusion on camera angles.',
          date: DateTime.now().subtract(const Duration(days: 1)),
          mood: JournalMood.focused,
          image: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80',
        ),
      ],
      guests: const [
        GuestModel(
          id: 'g9',
          name: 'Hani Al Amer',
          role: 'Permit lead',
          contact: '+966 54 330 2111',
          avatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&q=80',
          status: GuestStatus.confirmed,
        ),
        GuestModel(
          id: 'g10',
          name: 'Layth Zidan',
          role: 'Music director',
          contact: '+966 59 811 9088',
          avatar: 'https://images.unsplash.com/photo-1544723795-432537f7794d?auto=format&fit=crop&w=200&q=80',
          status: GuestStatus.confirmed,
        ),
        GuestModel(
          id: 'g11',
          name: 'Noor Alia',
          role: 'Influencer guest',
          contact: 'noor@nuviq.app',
          avatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80',
          status: GuestStatus.tentative,
        ),
        GuestModel(
          id: 'g12',
          name: 'Rami Abdel',
          role: 'Production',
          contact: '+966 58 399 9980',
          avatar: 'https://images.unsplash.com/photo-1521119989659-a83eee488004?auto=format&fit=crop&w=200&q=80',
          status: GuestStatus.invited,
        ),
      ],
      itinerary: [
        ItineraryDayModel(
          id: 'c3d1',
          date: DateTime.now().add(const Duration(days: 1)),
          focus: 'Immersive prep',
          cover:
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1100&q=70',
          slots: [
            ItinerarySlotModel(
              id: 'c3s1',
              time: const TimeOfDay(hour: 14, minute: 0),
              title: 'Rig load-in',
              note: 'Haze calibration + LED focus.',
              tag: ItineraryTags.tech,
            ),
            ItinerarySlotModel(
              id: 'c3s2',
              time: const TimeOfDay(hour: 17, minute: 0),
              title: 'Secret DJ briefing',
              note: 'Hand signal cues with visual artist.',
              tag: ItineraryTags.logistics,
            ),
            ItinerarySlotModel(
              id: 'c3s3',
              time: const TimeOfDay(hour: 20, minute: 0),
              title: 'Soft opening',
              note: 'VIP sips + neon photo walk.',
              tag: ItineraryTags.experience,
            ),
          ],
        ),
        ItineraryDayModel(
          id: 'c3d2',
          date: DateTime.now().add(const Duration(days: 2)),
          focus: 'Party ignition',
          cover:
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=900&q=60',
          slots: [
            ItinerarySlotModel(
              id: 'c3s4',
              time: const TimeOfDay(hour: 19, minute: 30),
              title: 'Guest arrival drop',
              note: 'AR invite scan + elevator reveal.',
              tag: ItineraryTags.tech,
            ),
            ItinerarySlotModel(
              id: 'c3s5',
              time: const TimeOfDay(hour: 22, minute: 0),
              title: 'AI photo booth',
              note: 'Loop prompts + share to LED wall.',
              tag: ItineraryTags.experience,
            ),
            ItinerarySlotModel(
              id: 'c3s6',
              time: const TimeOfDay(hour: 23, minute: 15),
              title: 'Late-night shawarma bar',
              note: 'Charcoal cart + secret sauces.',
              tag: ItineraryTags.culinary,
            ),
          ],
        ),
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
    GalleryItem(
      id: 'g4',
      image: 'https://images.unsplash.com/photo-1470229538611-16ba8c7ffbd7?auto=format&fit=crop&w=900&q=80',
      title: 'Botanical dinner',
      description: 'Verdant setup for anniversary dinner.',
      collectionId: 'c2',
    ),
    GalleryItem(
      id: 'g5',
      image: 'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?auto=format&fit=crop&w=900&q=80',
      title: 'Secret map',
      description: 'Location scouting snapshot.',
      collectionId: 'c1',
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

  static List<NuviqNotification> notifications = [
    NuviqNotification(
      id: 'n1',
      title: 'Tasks synced',
      body: 'Laila confirmed jeep bookings for the desert trip.',
      type: 'Planning',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    NuviqNotification(
      id: 'n2',
      title: 'Moodboard update',
      body: 'New rooftop renders were added to Secret Rooftop Party.',
      type: 'Gallery',
      time: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NuviqNotification(
      id: 'n3',
      title: 'Task due soon',
      body: 'Projection mapping storyboard review tomorrow.',
      type: 'Tasks',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      read: true,
    ),
    NuviqNotification(
      id: 'n4',
      title: 'Anniversary insights',
      body: 'Your anniversary dinner has 80% tasks confirmed.',
      type: 'Planning',
      time: DateTime.now().subtract(const Duration(days: 1)),
      read: true,
    ),
  ];
}
