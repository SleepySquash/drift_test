import 'package:get/get.dart';

import '/util/obs/rx_sorted_map.dart';

abstract class Paginated<K, T> {
  RxSortedObsMap<K, T> get items;

  RxBool get hasNext;
  RxBool get hasPrevious;

  Future<void> dispose();

  Future<void> around();
  Future<void> next();
  Future<void> previous();

  Future<void> clear();

  Future<void> put(List<T> items);
  Future<List<T>> remove(List<T> items);
}
