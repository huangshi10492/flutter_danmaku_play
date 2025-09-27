import 'package:fldanplay/model/history.dart';
import 'package:fldanplay/model/storage.dart';
import 'package:hive_ce/hive.dart';
part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<Storage>(),
  AdapterSpec<History>(),
  AdapterSpec<StorageType>(),
  AdapterSpec<HistoriesType>(),
])
class HiveAdapters {}
