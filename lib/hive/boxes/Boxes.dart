

import 'package:hive/hive.dart';
import 'package:vocab_keeper/hive/model/DiaryModel.dart';
import 'package:vocab_keeper/hive/model/VocabularyModel.dart';

class Boxes{
  static Box<VocabularyModel> getVocabs() => Hive.box<VocabularyModel>('vocabs');
  static Box<DiaryModel> getDiary() => Hive.box<DiaryModel>('diary');
}