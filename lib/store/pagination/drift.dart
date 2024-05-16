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
    required int limit,
    required int offset,
  }) fetch;

  final Future<void> Function(T item)? add;
  final Future<void> Function(T item)? delete;
  final Future<void> Function()? reset;

  int offset = 0;
  int limit = 0;

  final RxObsList<T> list = RxObsList();

  StreamSubscription? _subscription;

  @override
  Future<void> dispose() async {
    _subscription?.cancel();
  }

  @override
  Future<Page<T>> around(T? item, int count) async {
    offset = 0;
    limit = count;

    return Page(
      edges: await _page(),
      hasPrevious: true,
      hasNext: false,
    );
  }

  @override
  Future<Page<T>> after(T item, int count) async {
    limit += count * 2;
    offset += count; // ??

    final int edgesBefore = list.length;
    final RxObsList<T> edges = await _page();

    return Page(
      edges: edges,
      hasNext: edges.length - edgesBefore < count,
      hasPrevious: true,
    );
  }

  @override
  Future<Page<T>> before(T item, int count) async {
    limit += count;

    final int edgesBefore = list.length;
    final RxObsList<T> edges = await _page();

    return Page(
      edges: edges,
      hasNext: true,
      hasPrevious: edges.length - edgesBefore >= count,
    );
  }

  @override
  Future<void> put(T item) async {
    limit += 1;
    await add?.call(item);
  }

  @override
  Future<void> remove(T item) async {
    limit -= 1;
    await delete?.call(item);
  }

  @override
  Future<void> clear() async {
    await reset?.call();
  }

  Future<RxObsList<T>> _page() async {
    final Completer completer = Completer();

    _subscription?.cancel();
    _subscription = fetch(limit: limit, offset: offset).listen((e) {
      Log.debug(
        '_page(limit: $limit, offset: $offset) fired: ${e.length}',
        '$runtimeType',
      );

      if (!completer.isCompleted) {
        completer.complete();
      }

      for (var o in e) {
        switch (o.op) {
          case OperationKind.added:
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
    });

    await completer.future;

    return list;
  }
}
