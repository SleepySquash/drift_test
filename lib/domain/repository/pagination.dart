import 'package:get/get.dart';

abstract class Paginated<T> {
  RxList<T> get items;

  Future<void> around();
  Future<void> next();
  Future<void> previous();

  Future<void> put(List<T> items);
  Future<List<T>> remove(List<T> items);
}
