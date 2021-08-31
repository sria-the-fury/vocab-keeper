import 'package:hive/hive.dart';


part 'VocabularyModel.g.dart';


@HiveType(typeId: 0)
class VocabularyModel extends HiveObject{

  @HiveField(0)
  late String word;

  @HiveField(1)
  late String englishMeaning;

  @HiveField(2)
  late String nativeMeaning;

  @HiveField(3)
  late String sentences;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late String id;

  @HiveField(6)
  late String dayMonthYear;

}