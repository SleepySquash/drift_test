import 'dart:async';

import 'package:drift_test/store/paginated.dart';
import 'package:drift_test/util/diff.dart';
import 'package:drift_test/util/obs/rx_list.dart';
import 'package:log_me/log_me.dart';

class DriftPageProvider<K, T> extends PageProvider<T> {
  DriftPageProvider({
    required this.onKey,
    required this.fetch,
    this.add,
    this.delete,
    this.reset,
  });

  final K Function(T) onKey;

  final Stream<List<MapChangeNotification<K, T>>> Function({
    T? before,
    T? after,
    required int count,
  }) fetch;

  final Future<void> Function(T item)? add;
  final Future<void> Function(T item)? delete;
  final Future<void> Function()? reset;

  final List<StreamSubscription> _subscriptions = [];

  @override
  Future<void> dispose() async {
    for (var e in _subscriptions) {
      e.cancel();
    }
    _subscriptions.clear();
  }

  @override
  Future<RxObsList<T>> around(T? item, int count) async {
    return await _page(count);
  }

  @override
  Future<RxObsList<T>> after(T item, int count) async {
    return await _page(count, after: item);
  }

  @override
  Future<RxObsList<T>> before(T item, int count) async {
    return await _page(count, before: item);
  }

  @override
  Future<void> put(T item) async {
    await add?.call(item);
  }

  @override
  Future<void> remove(T item) async {
    await delete?.call(item);
  }

  @override
  Future<void> clear() async {
    await reset?.call();
  }

  Future<RxObsList<T>> _page(int count, {T? after, T? before}) async {
    final Completer completer = Completer();
    final RxObsList<T> list = RxObsList();

    _subscriptions.add(fetch(
      count: count,
      after: after,
      before: before,
    ).listen((e) {
      Log.debug(
        '_page($count, after: $after, before: $before) fired: ${e.length}',
        '$runtimeType',
      );

      if (!completer.isCompleted) {
        completer.complete();
      }

      for (var o in e) {
        switch (o.op) {
          case OperationKind.added:
            list.add(o.value as T);
            break;

          case OperationKind.updated:
            final int i = list.indexWhere((m) => onKey(m) == o.key);
            if (i == -1) {
              list.add(o.value as T);
            } else {
              list[i] = o.value as T;
            }
            break;

          case OperationKind.removed:
            list.removeWhere((m) => onKey(m) == o.key);
            break;
        }
      }
    }));

    await completer.future;

    return list;
  }
}
