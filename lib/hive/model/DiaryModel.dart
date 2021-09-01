
import 'package:hive/hive.dart';

part 'DiaryModel.g.dart';

@HiveType(typeId: 1)
class DiaryModel extends HiveObject{

  @HiveField(0)
  late String id;

  @HiveField(1)
  late String diaryTextDelta;

  @HiveField(2)
  late String dayMonthYear;

  @HiveField(3)
  late DateTime createdAt;



}