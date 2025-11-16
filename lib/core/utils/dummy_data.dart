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

enum DocumentStatus { draft, review, approved }

class DocumentModel {
  const DocumentModel({
    required this.id,
    required this.title,
    required this.category,
    required this.owner,
    required this.updatedAt,
    required this.status,
    required this.preview,
    this.sizeMb = 0,
  });

  final String id;
  final String title;
  final String category;
  final String owner;
  final DateTime updatedAt;
  final DocumentStatus status;
  final String preview;
  final double sizeMb;

  DocumentModel copyWith({
    String? title,
    String? category,
    String? owner,
    DateTime? updatedAt,
    DocumentStatus? status,
    String? preview,
    double? sizeMb,
  }) =>
      DocumentModel(
        id: id,
        title: title ?? this.title,
        category: category ?? this.category,
        owner: owner ?? this.owner,
        updatedAt: updatedAt ?? this.updatedAt,
        status: status ?? this.status,
        preview: preview ?? this.preview,
        sizeMb: sizeMb ?? this.sizeMb,
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
    this.vendors = const [],
    this.logistics = const [],
    this.budgetLines = const [],
    this.documents = const [],
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
  final List<VendorModel> vendors;
  final List<LogisticItemModel> logistics;
  final List<BudgetLineModel> budgetLines;
  final List<DocumentModel> documents;

  CollectionModel copyWith({
    bool? isFavourite,
    List<TaskModel>? tasks,
    double? budgetPlanned,
    double? budgetUsed,
    List<MilestoneModel>? milestones,
    List<JournalEntryModel>? journalEntries,
    List<ItineraryDayModel>? itinerary,
    List<GuestModel>? guests,
    List<VendorModel>? vendors,
    List<LogisticItemModel>? logistics,
    List<BudgetLineModel>? budgetLines,
    List<DocumentModel>? documents,
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
        vendors: vendors ?? this.vendors,
        logistics: logistics ?? this.logistics,
        budgetLines: budgetLines ?? this.budgetLines,
        documents: documents ?? this.documents,
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

class BudgetLineModel {
  const BudgetLineModel({
    required this.id,
    required this.category,
    required this.planned,
    required this.spent,
    this.note = '',
  });

  final String id;
  final String category;
  final double planned;
  final double spent;
  final String note;

  BudgetLineModel copyWith({
    String? category,
    double? planned,
    double? spent,
    String? note,
  }) =>
      BudgetLineModel(
        id: id,
        category: category ?? this.category,
        planned: planned ?? this.planned,
        spent: spent ?? this.spent,
        note: note ?? this.note,
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

enum VendorStatus { scouting, negotiating, booked, paid }

class VendorModel {
  const VendorModel({
    required this.id,
    required this.name,
    required this.category,
    required this.contact,
    required this.avatar,
    required this.cost,
    required this.dueDate,
    this.status = VendorStatus.scouting,
  });

  final String id;
  final String name;
  final String category;
  final String contact;
  final String avatar;
  final double cost;
  final DateTime dueDate;
  final VendorStatus status;

  VendorModel copyWith({
    String? name,
    String? category,
    String? contact,
    String? avatar,
    double? cost,
    DateTime? dueDate,
    VendorStatus? status,
  }) =>
      VendorModel(
        id: id,
        name: name ?? this.name,
        category: category ?? this.category,
        contact: contact ?? this.contact,
        avatar: avatar ?? this.avatar,
        cost: cost ?? this.cost,
        dueDate: dueDate ?? this.dueDate,
        status: status ?? this.status,
      );
}

enum LogisticsType { transport, flight, stay, experience }

enum LogisticsStatus { pending, booked, enRoute, arrived }

class LogisticItemModel {
  const LogisticItemModel({
    required this.id,
    required this.title,
    required this.type,
    required this.provider,
    required this.location,
    required this.reference,
    required this.start,
    required this.end,
    this.status = LogisticsStatus.pending,
    this.note = '',
    this.cost = 0,
  });

  final String id;
  final String title;
  final LogisticsType type;
  final String provider;
  final String location;
  final String reference;
  final DateTime start;
  final DateTime end;
  final LogisticsStatus status;
  final String note;
  final double cost;

  LogisticItemModel copyWith({
    String? title,
    LogisticsType? type,
    String? provider,
    String? location,
    String? reference,
    DateTime? start,
    DateTime? end,
    LogisticsStatus? status,
    String? note,
    double? cost,
  }) =>
      LogisticItemModel(
        id: id,
        title: title ?? this.title,
        type: type ?? this.type,
        provider: provider ?? this.provider,
        location: location ?? this.location,
        reference: reference ?? this.reference,
        start: start ?? this.start,
        end: end ?? this.end,
        status: status ?? this.status,
        note: note ?? this.note,
        cost: cost ?? this.cost,
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
      budgetLines: const [
        BudgetLineModel(
          id: 'c1b1',
          category: 'Transport',
          planned: 4000,
          spent: 2800,
          note: 'Jeeps, drivers, and dune permits.',
        ),
        BudgetLineModel(
          id: 'c1b2',
          category: 'Food & Beverage',
          planned: 3200,
          spent: 2100,
          note: 'Sunrise breakfast menu and tea ritual.',
        ),
        BudgetLineModel(
          id: 'c1b3',
          category: 'Experiences',
          planned: 2800,
          spent: 1900,
          note: 'Camel rides, drone team, and music.',
        ),
        BudgetLineModel(
          id: 'c1b4',
          category: 'Safety & permits',
          planned: 2000,
          spent: 1400,
          note: 'Insurance and ranger standby.',
        ),
      ],
      documents: [
        DocumentModel(
          id: 'c1doc1',
          title: 'Dune permit pack',
          category: 'Permits',
          owner: 'Laila',
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          status: DocumentStatus.review,
          preview: AppAssets.docPlaceholder,
          sizeMb: 2.1,
        ),
        DocumentModel(
          id: 'c1doc2',
          title: 'Sunrise catering brief',
          category: 'Food & Beverage',
          owner: 'Omar',
          updatedAt: DateTime.now().subtract(const Duration(hours: 10)),
          status: DocumentStatus.draft,
          preview: AppAssets.docPlaceholder,
          sizeMb: 3.4,
        ),
        DocumentModel(
          id: 'c1doc3',
          title: 'Guest waiver template',
          category: 'Guests',
          owner: 'Sara',
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
          status: DocumentStatus.approved,
          preview: AppAssets.docPlaceholder,
          sizeMb: 0.9,
        ),
      ],
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
      logistics: [
        LogisticItemModel(
          id: 'c1log1',
          title: 'Convoy meetup',
          provider: 'Desert Wheels',
          type: LogisticsType.transport,
          location: 'Dubai → Al Marmoom',
          reference: 'DW-904',
          start: DateTime.now().add(const Duration(days: 5, hours: 2)),
          end: DateTime.now().add(const Duration(days: 5, hours: 4)),
          status: LogisticsStatus.booked,
          note: 'Gather jeeps, radios, and hydration packs.',
          cost: 1200,
        ),
        LogisticItemModel(
          id: 'c1log2',
          title: 'Camp setup',
          provider: 'Nomad Shelters',
          type: LogisticsType.stay,
          location: 'Al Marmoom oasis',
          reference: 'NS-220',
          start: DateTime.now().add(const Duration(days: 5, hours: 6)),
          end: DateTime.now().add(const Duration(days: 6, hours: 8)),
          status: LogisticsStatus.pending,
          note: 'Double-check cooling fans + lantern grid.',
          cost: 800,
        ),
        LogisticItemModel(
          id: 'c1log3',
          title: 'Sunrise drone shuttle',
          provider: 'Skyline Drones',
          type: LogisticsType.experience,
          location: 'Dune ridge launchpad',
          reference: 'SD-118',
          start: DateTime.now().add(const Duration(days: 6, hours: 5)),
          end: DateTime.now().add(const Duration(days: 6, hours: 7)),
          status: LogisticsStatus.enRoute,
          note: 'Pilot briefing before takeoff.',
          cost: 650,
        ),
      ],
      logistics: [
        LogisticItemModel(
          id: 'c2log1',
          title: 'Artist flight',
          provider: 'Royal Wings',
          type: LogisticsType.flight,
          location: 'Beirut → Amman',
          reference: 'RW-771',
          start: DateTime.now().add(const Duration(days: 17, hours: 8)),
          end: DateTime.now().add(const Duration(days: 17, hours: 11)),
          status: LogisticsStatus.booked,
          note: 'Add trio instruments as fragile luggage.',
          cost: 1450,
        ),
        LogisticItemModel(
          id: 'c2log2',
          title: 'Suite check-in',
          provider: 'Amman Loft Hotel',
          type: LogisticsType.stay,
          location: 'Amman Downtown',
          reference: 'ALH-33',
          start: DateTime.now().add(const Duration(days: 18, hours: 12)),
          end: DateTime.now().add(const Duration(days: 20)),
          status: LogisticsStatus.pending,
          note: 'Deliver welcome amenity with projection map.',
          cost: 2100,
        ),
        LogisticItemModel(
          id: 'c2log3',
          title: 'Guest shuttle',
          provider: 'Velvet Rides',
          type: LogisticsType.transport,
          location: 'Hotels → Venue',
          reference: 'VR-554',
          start: DateTime.now().add(const Duration(days: 19, hours: 16)),
          end: DateTime.now().add(const Duration(days: 19, hours: 18)),
          status: LogisticsStatus.booked,
          note: 'Hold signage with Nuviq gradients.',
          cost: 500,
        ),
      ],
      logistics: [
        LogisticItemModel(
          id: 'c3log1',
          title: 'Rooftop freight elevator',
          provider: 'SkyLift',
          type: LogisticsType.transport,
          location: 'Basement → Rooftop',
          reference: 'SL-221',
          start: DateTime.now().add(const Duration(days: 1, hours: 10)),
          end: DateTime.now().add(const Duration(days: 1, hours: 13)),
          status: LogisticsStatus.enRoute,
          note: 'Stage rig + LED columns batch 1.',
          cost: 600,
        ),
        LogisticItemModel(
          id: 'c3log2',
          title: 'Secret DJ arrival',
          provider: 'Midnight Jet',
          type: LogisticsType.flight,
          location: 'Dubai → Riyadh',
          reference: 'MJ-992',
          start: DateTime.now().add(const Duration(days: 1, hours: 14)),
          end: DateTime.now().add(const Duration(days: 1, hours: 16)),
          status: LogisticsStatus.booked,
          note: 'Need VIP escort at gate 3.',
          cost: 980,
        ),
        LogisticItemModel(
          id: 'c3log3',
          title: 'Afterparty suites',
          provider: 'Glow Hotel',
          type: LogisticsType.stay,
          location: 'Riyadh Center',
          reference: 'GH-55',
          start: DateTime.now().add(const Duration(days: 2)),
          end: DateTime.now().add(const Duration(days: 3)),
          status: LogisticsStatus.pending,
          note: 'Request neon welcome amenity.',
          cost: 1300,
        ),
      ],
      vendors: [
        VendorModel(
          id: 'v1',
          name: 'Desert Wheels',
          category: 'Transport',
          contact: '+971 55 880 2210',
          avatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80',
          cost: 2800,
          dueDate: DateTime.now().add(const Duration(days: 2)),
          status: VendorStatus.negotiating,
        ),
        VendorModel(
          id: 'v2',
          name: 'Bedouin Feast Co.',
          category: 'Catering',
          contact: '+971 55 612 7821',
          avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
          cost: 1900,
          dueDate: DateTime.now().add(const Duration(days: 4)),
          status: VendorStatus.booked,
        ),
        VendorModel(
          id: 'v3',
          name: 'Skyline Drones',
          category: 'Media',
          contact: '+971 50 300 1133',
          avatar: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=200&q=80',
          cost: 1500,
          dueDate: DateTime.now().add(const Duration(days: 8)),
          status: VendorStatus.scouting,
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
      budgetLines: const [
        BudgetLineModel(
          id: 'c2b1',
          category: 'Venue & decor',
          planned: 3200,
          spent: 3400,
          note: 'Projection mapping gear and rentals.',
        ),
        BudgetLineModel(
          id: 'c2b2',
          category: 'Catering',
          planned: 2800,
          spent: 2500,
          note: 'Seven-course tasting dinner.',
        ),
        BudgetLineModel(
          id: 'c2b3',
          category: 'Entertainment',
          planned: 1600,
          spent: 1400,
          note: 'Acoustic trio and audio tech.',
        ),
        BudgetLineModel(
          id: 'c2b4',
          category: 'Gifting',
          planned: 1400,
          spent: 500,
          note: 'Personalized keepsakes and packaging.',
        ),
      ],
      documents: [
        DocumentModel(
          id: 'c2doc1',
          title: 'Venue layout',
          category: 'Logistics',
          owner: 'Maya',
          updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
          status: DocumentStatus.review,
          preview: AppAssets.docPlaceholder,
          sizeMb: 4.2,
        ),
        DocumentModel(
          id: 'c2doc2',
          title: 'Entertainment rider',
          category: 'Vendors',
          owner: 'Rashed',
          updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
          status: DocumentStatus.draft,
          preview: AppAssets.docPlaceholder,
          sizeMb: 1.6,
        ),
      ],
      documents: [
        DocumentModel(
          id: 'c3doc1',
          title: 'Anniversary speech cues',
          category: 'Program',
          owner: 'Noura',
          updatedAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
          status: DocumentStatus.approved,
          preview: AppAssets.docPlaceholder,
          sizeMb: 0.8,
        ),
        DocumentModel(
          id: 'c3doc2',
          title: 'Photo booth checklist',
          category: 'Vendors',
          owner: 'Hamad',
          updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
          status: DocumentStatus.review,
          preview: AppAssets.docPlaceholder,
          sizeMb: 1.1,
        ),
      ],
      documents: [
        DocumentModel(
          id: 'c4doc1',
          title: 'Venue insurance letter',
          category: 'Permits',
          owner: 'Farah',
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
          status: DocumentStatus.review,
          preview: AppAssets.docPlaceholder,
          sizeMb: 2.7,
        ),
        DocumentModel(
          id: 'c4doc2',
          title: 'Menu tasting feedback',
          category: 'Food & Beverage',
          owner: 'Yousef',
          updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
          status: DocumentStatus.draft,
          preview: AppAssets.docPlaceholder,
          sizeMb: 1.5,
        ),
        DocumentModel(
          id: 'c4doc3',
          title: 'Decor inspiration deck',
          category: 'Design',
          owner: 'Mina',
          updatedAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
          status: DocumentStatus.approved,
          preview: AppAssets.docPlaceholder,
          sizeMb: 5.2,
        ),
      ],
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
      vendors: [
        VendorModel(
          id: 'v4',
          name: 'Maison Gather',
          category: 'Catering',
          contact: '+962 78 300 9988',
          avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
          cost: 3100,
          dueDate: DateTime.now().add(const Duration(days: 7)),
          status: VendorStatus.booked,
        ),
        VendorModel(
          id: 'v5',
          name: 'Lumen AV Lab',
          category: 'Lighting',
          contact: '+962 79 115 5522',
          avatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=60',
          cost: 2200,
          dueDate: DateTime.now().add(const Duration(days: 9)),
          status: VendorStatus.negotiating,
        ),
        VendorModel(
          id: 'v6',
          name: 'Trio Resonance',
          category: 'Entertainment',
          contact: '+962 77 700 4421',
          avatar: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=200&q=70',
          cost: 1450,
          dueDate: DateTime.now().add(const Duration(days: 12)),
          status: VendorStatus.booked,
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
      budgetLines: const [
        BudgetLineModel(
          id: 'c3b1',
          category: 'Production',
          planned: 6000,
          spent: 5200,
          note: 'LED walls, lasers, stage automation.',
        ),
        BudgetLineModel(
          id: 'c3b2',
          category: 'Talent',
          planned: 3000,
          spent: 2700,
          note: 'Secret DJs and VJ crew.',
        ),
        BudgetLineModel(
          id: 'c3b3',
          category: 'Hospitality',
          planned: 2800,
          spent: 1900,
          note: 'Premium bar program and bites.',
        ),
        BudgetLineModel(
          id: 'c3b4',
          category: 'Experience tech',
          planned: 2200,
          spent: 1200,
          note: 'AI photo booth + NFC invites.',
        ),
      ],
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
      vendors: [
        VendorModel(
          id: 'v7',
          name: 'Neon Hive Studios',
          category: 'Visuals',
          contact: '+966 58 100 1200',
          avatar: 'https://images.unsplash.com/photo-1521119989659-a83eee488004?auto=format&fit=crop&w=200&q=80',
          cost: 4200,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          status: VendorStatus.negotiating,
        ),
        VendorModel(
          id: 'v8',
          name: 'Haze District',
          category: 'Effects',
          contact: '+966 53 340 9822',
          avatar: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=200&q=80',
          cost: 900,
          dueDate: DateTime.now().add(const Duration(days: 3)),
          status: VendorStatus.booked,
        ),
        VendorModel(
          id: 'v9',
          name: 'Midnight Shawarma',
          category: 'Culinary',
          contact: '+966 50 990 8712',
          avatar: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=200&q=80',
          cost: 750,
          dueDate: DateTime.now().add(const Duration(days: 2)),
          status: VendorStatus.booked,
        ),
        VendorModel(
          id: 'v10',
          name: 'Soundwave Agency',
          category: 'Entertainment',
          contact: '+966 59 200 5501',
          avatar: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=200&q=80',
          cost: 2600,
          dueDate: DateTime.now().add(const Duration(days: 5)),
          status: VendorStatus.scouting,
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
