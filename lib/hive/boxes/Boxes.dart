

import 'package:hive/hive.dart';
import 'package:vocab_keeper/hive/model/VocabularyModel.dart';

class Boxes{
  static Box<VocabularyModel> getVocabs() => Hive.box<VocabularyModel>('vocabs');
}