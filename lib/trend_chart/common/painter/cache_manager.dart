import 'package:flutter/material.dart';

import '../range.dart';

class Cache {
  Range? xRange;
  Range? yRange;

  Cache({
    this.xRange,
    this.yRange,
  });
}

class _CacheManager {
  _CacheManager._();

  static final _internal = _CacheManager._();
  factory _CacheManager() => _internal;

  final List<Cache> _caches = [];

  Cache createCache() {
    final cache = Cache();
    _caches.add(cache);
    return cache;
  }

  Cache? get current {
    return _caches.isEmpty ? null : _caches.last;
  }

  Cache drop() {
    assert(_caches.isNotEmpty);
    final current = _caches.last;
    _caches.removeLast();
    return current;
  }

  void startTransaction() => createCache();

  void endTransaction() => drop();

  void transaction(VoidCallback? transaction) {
    startTransaction();
    transaction?.call();
    endTransaction();
  }
}

void write({
  Range? xRange,
  Range? yRange,
}) {
  _CacheManager().current?.xRange ??= xRange;
  _CacheManager().current?.yRange ??= yRange;
}
