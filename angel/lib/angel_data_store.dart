import 'dart:async';
import 'dart:mirrors';
import 'package:angel_framework/angel_framework.dart';
import 'package:data_store/data_store.dart';

// Extends a `data_store` query.
typedef RepositoryQuery<T> QueryCallback<T>(RepositoryQuery<T> query);

class RepositoryService<T> extends Service {
  /// If set to `true`, clients can remove all items by passing a `null` `id` to `remove`.
  ///
  /// `false` by default.
  final bool allowRemoveAll;

  /// If set to `true`, parameters in `req.query` are applied to the database query.
  final bool allowQuery;

  final bool debug;

  /// If set to `true`, then a HookedService mounted over this instance
  /// will fire events when the underlying [repository] pushes changes.
  ///
  /// Good for scaling. ;)
  final bool listenForChanges;

  final Repository<T> repository;

  RepositoryService(this.repository,
      {this.allowRemoveAll: false,
      this.allowQuery: true,
      this.debug: false,
      this.listenForChanges: false})
      : super() {
    if (!reflectType(T).isAssignableTo(reflectType(Model)))
      throw new Exception(
          "If you specify a type for RepositoryService, it must extend Model.");
  }

  RepositoryQuery<T> buildQuery(RepositoryQuery<T> initialQuery, Map params) {
    if (params != null)
      params['broadcast'] = params.containsKey('broadcast')
          ? params['broadcast']
          : (listenForChanges != true);

    var q = _getQueryInner(initialQuery, params);

    if (params?.containsKey('data_store') == true &&
        params['data_store'] is QueryCallback<T>) q = params['data_store'](q);

    return q ?? initialQuery;
  }

  RepositoryQuery<T> _getQueryInner(RepositoryQuery<T> query, Map params) {
    if (params == null || !params.containsKey('query'))
      return null;
    else {
      if (params['query'] is RepositoryQuery<T>)
        return params['query'];
      else if (params['query'] is QueryCallback<T>)
        return params['query'](table);
      else if (params['query'] is! Map || allowQuery != true)
        return query;
      else {
        Map q = params['query'];
        return q.keys.map((k) => k.toString()).fold<RepositoryQuery<T>>(query,
            (out, key) {
          var val = q[key];

          if (val is RequestContext ||
              val is ResponseContext ||
              key == 'provider' ||
              val is Providers)
            return out;
          else {
            return out.where(k.toString(), val);
          }
        });
      }
    }
  }

  @override
  void onHooked(HookedService hookedService) {
    if (listenForChanges == true) {
      repository.all().changes().listen((e) {
        var oldVal = e.oldValue as Model, newVal = e.newValue as Model;

        if (e.type == ChangeEventType.CREATED) {
          // Create
          hookedService.fireEvent(
              hookedService.afterCreated,
              new HookedServiceEvent(
                  true, null, null, this, HookedServiceEvent.CREATED,
                  result: newVal));
        } else if (e.type == ChangeEventType.CREATED) {
          // Update
          hookedService.fireEvent(
              hookedService.afterCreated,
              new HookedServiceEvent(
                  true, null, null, this, HookedServiceEvent.UPDATED,
                  result: newVal, id: oldVal.id, data: newVal));
        } else if (e.type == ChangeEventType.REMOVED) {
          // Remove
          hookedService.fireEvent(
              hookedService.afterCreated,
              new HookedServiceEvent(
                  true, null, null, this, HookedServiceEventREMOVED,
                  result: oldVal, id: oldVal.id));
        }
      });
    }
  }

  @override
  Future<List<T>> index([Map params]) {
    var query = buildQuery(repository.all(), params);
    return query.get().toList();
  }

  @override
  Future<T> read(id, [Map params]) => repository.find(id?.toString()).get();
}
