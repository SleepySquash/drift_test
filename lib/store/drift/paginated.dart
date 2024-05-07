import 'package:drift_test/domain/repository/pagination.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

// Should:
// 1. Retrieve pages from `drift`.
// 2. Watch the changes of items (from `drift`).
// 3. Pages should be fetched by offset/limit.
class PaginatedImpl<T> extends Paginated<T> {
  PaginatedImpl({
    required this.fetch,
    required this.compare, // TODO: Might add `default` compare.
    this.perPage = 15,
  });

  // We need a way to retrieve `OFFSET` of `before`/`after` item.
  // Why? Because page providers may be really different. E.g. GraphQL provider
  // will use the cursors of [T] items to fetch before/after pages. And `drift`
  // provider should be able to do so by using LIMIT and OFFSET keywords of SQL.
  // => from the [T] item it should be able to get the required position and use
  // it to get N items before or after?
  //
  // `rowid` doesn't allow us to do so, as it must account the `ORDER BY`
  // statement.
  //
  // Perhaps we may create temporary table and COUNT the items until the ID?
  // Or query the whole SELECT at all?
  //
  // Hm. We can simply use `WHERE updated_at < ... LIMIT 15` and this does it?
  final Future<List<T>> Function({
    T? before,
    T? after,
    required int count,
  }) fetch;

  final int Function(T a, T b) compare;

  // Sort the list?
  // Keep the Map instead?
  @override
  final RxList<T> items = RxList();

  final int perPage;

  @override
  Future<void> around() async {
    items.addAll(await fetch(count: perPage));
  }

  @override
  Future<void> next() async {
    if (items.isEmpty) {
      return await around();
    }

    items.addAll(await fetch(count: perPage, after: items.last));
  }

  @override
  Future<void> previous() async {
    if (items.isEmpty) {
      return await around();
    }

    items.addAll(await fetch(count: perPage, before: items.first));
  }

  @override
  Future<void> put(List<T> items) async {
    for (var e in items.toList()) {
      final int i = this.items.indexWhere((m) => compare(e, m) == 0);
      if (i == -1) {
        items.add(e);
      } else {
        items[i] = e;
      }
    }
  }

  @override
  Future<List<T>> remove(List<T> items) async {
    final List<T> removed = [];

    for (var e in items.toList()) {
      if (items.remove(e)) {
        removed.add(e);
      }
    }

    return removed;
  }
}