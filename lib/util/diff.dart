/// Extension adding an ability to get [MapChangeNotification]s from [Stream].
extension MapChangesExtension<K, T> on Stream<Map<K, T>> {
  /// Gets [MapChangeNotification]s from [Stream].
  Stream<MapChangeNotification<K, T>> changes(dynamic Function(T) getId) {
    Map<K, T> last = {};

    return asyncExpand((e) async* {
      for (final MapEntry<K, T> entry in e.entries) {
        final T? item = last[entry.key];
        if (item == null) {
          yield MapChangeNotification.added(entry.key, entry.value);
        } else {
          if (entry.value != item) {
            yield MapChangeNotification.updated(
              entry.key,
              entry.key,
              entry.value,
            );
          }
        }
      }

      for (final MapEntry<K, T> entry in last.entries) {
        final T? item = e[entry.key];
        if (item == null) {
          yield MapChangeNotification.removed(entry.key, entry.value);
        }
      }

      last = e;
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
