/// Extension adding an ability to get [MapChangeNotification]s from [Stream].
extension MapChangesExtension<K, T> on Stream<Map<K, T>> {
  /// Gets [MapChangeNotification]s from [Stream].
  Stream<List<MapChangeNotification<K, T>>> changes() {
    Map<K, T> last = {};

    return asyncExpand((e) async* {
      final List<MapChangeNotification<K, T>> changed = [];

      for (final MapEntry<K, T> entry in e.entries) {
        final T? item = last[entry.key];
        if (item == null) {
          changed.add(MapChangeNotification.added(entry.key, entry.value));
        } else {
          if (entry.value != item) {
            changed.add(
              MapChangeNotification.updated(
                entry.key,
                entry.key,
                entry.value,
              ),
            );
          }
        }
      }

      for (final MapEntry<K, T> entry in last.entries) {
        final T? item = e[entry.key];
        if (item == null) {
          changed.add(MapChangeNotification.removed(entry.key, entry.value));
        }
      }

      last = e;

      yield changed;
    });
  }
}

/// Change in an [Map].
class MapChangeNotification<K, V> {
  /// Returns notification with [op] operation.
  MapChangeNotification(this.key, this.oldKey, this.value, this.op);

  /// Returns notification with [OperationKind.added] operation.
  MapChangeNotification.added(this.key, this.value)
      : op = OperationKind.added,
        oldKey = null;

  /// Returns notification with [OperationKind.updated] operation.
  MapChangeNotification.updated(this.key, this.oldKey, this.value)
      : op = OperationKind.updated;

  /// Returns notification with [OperationKind.removed] operation.
  MapChangeNotification.removed(this.key, this.value)
      : op = OperationKind.removed,
        oldKey = null;

  /// Key of the changed element.
  final K? key;

  /// Previous key the changed element had.
  final K? oldKey;

  /// Value of the changed element.
  final V? value;

  /// Operation causing the [element] to change.
  final OperationKind op;
}

/// Possible operation kinds changing an iterable.
enum OperationKind { added, removed, updated }

/// Change in an [ObsList].
class ListChangeNotification<E> {
  /// Returns notification with [op] operation.
  ListChangeNotification(this.element, this.op, this.pos);

  /// Returns notification with [OperationKind.added] operation.
  ListChangeNotification.added(this.element, this.pos)
      : op = OperationKind.added;

  /// Returns notification with [OperationKind.updated] operation.
  ListChangeNotification.updated(this.element, this.pos)
      : op = OperationKind.updated;

  /// Returns notification with [OperationKind.removed] operation.
  ListChangeNotification.removed(this.element, this.pos)
      : op = OperationKind.removed;

  /// Element being changed.
  final E element;

  /// Operation causing the [element] to change.
  final OperationKind op;

  /// Position of the changed [element].
  final int pos;
}
