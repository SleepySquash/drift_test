import 'dart:async';

import 'package:drift_test/domain/repository/pagination.dart';
import 'package:drift_test/util/diff.dart';
import 'package:drift_test/util/obs/rx_list.dart';
import 'package:drift_test/util/obs/rx_sorted_map.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:log_me/log_me.dart';
import 'package:mutex/mutex.dart';

// Should:
// 1. Retrieve pages from `drift`.
// 2. Watch the changes of items (from `drift`).
// 3. Pages should be fetched by offset/limit.
class PaginatedImpl<K, T> extends Paginated<K, T> {
  PaginatedImpl({
    required this.provider,
    required this.compare, // TODO: Might add `default` compare.
    required this.onKey,
    this.perPage = 15,
  });

  @override
  final RxBool hasNext = RxBool(false);

  @override
  final RxBool hasPrevious = RxBool(false);

  final PageProvider<T> provider;

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

  final int Function(T a, T b) compare;
  final K Function(T) onKey;

  // Sort the list?
  // Keep the Map instead?
  @override
  late final RxSortedObsMap<K, T> items = RxSortedObsMap(compare);

  final int perPage;

  final Mutex _guard = Mutex();

  final List<StreamSubscription> _subscriptions = [];

  // T? _start;
  // T? _end;

  @override
  Future<void> dispose() async {
    await provider.dispose();

    for (var e in _subscriptions) {
      e.cancel();
    }
    _subscriptions.clear();
  }

  @override
  Future<void> around() async {
    final bool locked = _guard.isLocked;

    await _guard.protect(() async {
      if (locked) {
        return;
      }

      Log.debug('around()', '$runtimeType');

      final page = await provider.around(null, perPage);
      _subscribeTo(page);

      hasNext.value = false;
      hasPrevious.value = true;
    });
  }

  @override
  Future<void> next() async {
    if (items.isEmpty) {
      return await around();
    }

    final bool locked = _guard.isLocked;

    await _guard.protect(() async {
      if (locked) {
        return;
      }

      Log.debug('next()', '$runtimeType');

      final page = await provider.after(items.last, perPage);
      _subscribeTo(page);

      hasNext.value = page.length >= perPage;
    });
  }

  @override
  Future<void> previous() async {
    if (items.isEmpty) {
      return await around();
    }

    final bool locked = _guard.isLocked;

    await _guard.protect(() async {
      if (locked) {
        return;
      }

      Log.debug('previous()', '$runtimeType');

      final page = await provider.before(items.first, perPage);
      _subscribeTo(page);

      hasPrevious.value = page.length >= perPage;
    });
  }

  @override
  Future<void> clear() async {
    await _guard.protect(() async {
      Log.debug('clear()', '$runtimeType');

      items.clear();
    });
  }

  @override
  Future<void> put(List<T> items) async {
    await _guard.protect(() async {
      Log.debug('put($items)', '$runtimeType');

      bool put = false;

      for (var item in items) {
        if (this.items.isEmpty) {
          put = hasNext.isFalse && hasPrevious.isFalse;
        } else if (compare(item, this.items.last) == 1) {
          put = hasNext.isFalse;
        } else if (compare(item, this.items.first) == -1) {
          put = hasPrevious.isFalse;
        } else {
          put = true;
        }

        if (put) {
          this.items[onKey(item)] = item;
        }
      }
    });
  }

  @override
  Future<List<T>> remove(List<T> items) async {
    Log.debug('remove($items)', '$runtimeType');

    final List<T> removed = [];

    for (var e in items.toList()) {
      if (items.remove(e)) {
        removed.add(e);
      }
    }

    return removed;
  }

  void _subscribeTo(RxObsList<T> page) {
    for (var e in page) {
      items[onKey(e)] = e;
    }

    _subscriptions.add(
      page.changes.listen((e) {
        switch (e.op) {
          case OperationKind.added:
          case OperationKind.updated:
            items[onKey(e.element)] = e.element;
            break;

          case OperationKind.removed:
            items.remove(onKey(e.element));
            break;
        }
      }),
    );
  }
}

abstract class PageProvider<T> {
  Future<void> dispose();
  Future<RxObsList<T>> around(T? item, int count);
  Future<RxObsList<T>> after(T item, int count);
  Future<RxObsList<T>> before(T item, int count);
  Future<void> put(T item);
  Future<void> remove(T item);
  Future<void> clear();
}
