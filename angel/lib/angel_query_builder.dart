import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:json_god/json_god.dart' as god;
import 'package:query_builder/query_builder.dart';

// Extends a `query_builder` single query.
typedef SingleQuery<Map<String, dynamic>> SingleQueryCallback(
    SingleQuery<Map<String, dynamic>> query);

// Extends a `query_builder` repository query.
typedef RepositoryQuery<Map<String, dynamic>> QueryCallback(
    RepositoryQuery<Map<String, dynamic>> query);

class RepositoryService extends Service {
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

  final Repository<Map<String, dynamic>> repository;

  RepositoryService(this.repository,
      {this.allowRemoveAll: false,
      this.allowQuery: true,
      this.debug: false,
      this.listenForChanges: false})
      : super() {}

  RepositoryQuery<Map<String, dynamic>> buildQuery(
      RepositoryQuery<Map<String, dynamic>> initialQuery, Map params) {
    if (params != null)
      params['broadcast'] = params.containsKey('broadcast')
          ? params['broadcast']
          : (listenForChanges != true);

    var q = _getQueryInner(initialQuery, params);

    if (params?.containsKey('query_builder') == true &&
        params['query_builder'] is QueryCallback)
      q = params['query_builder'](q);

    return q ?? initialQuery;
  }

  SingleQuery<Map<String, dynamic>> buildSingleQuery(
      SingleQuery<Map<String, dynamic>> initialQuery, Map params) {
    if (params != null)
      params['broadcast'] = params.containsKey('broadcast')
          ? params['broadcast']
          : (listenForChanges != true);

    var q = _getSingleQueryInner(initialQuery, params);

    if (params?.containsKey('query_builder') == true &&
        params['query_builder'] is SingleQueryCallback)
      q = params['query_builder'](q);

    return q ?? initialQuery;
  }

  RepositoryQuery<Map<String, dynamic>> _getQueryInner(
      RepositoryQuery<Map<String, dynamic>> query, Map params) {
    if (params == null || !params.containsKey('query'))
      return null;
    else {
      if (params['query'] is RepositoryQuery<Map<String, dynamic>>)
        return params['query'];
      else if (params['query'] is QueryCallback)
        return params['query'](table);
      else if (params['query'] is! Map || allowQuery != true)
        return query;
      else {
        Map q = params['query'];
        return q.keys
            .map((k) => k.toString())
            .fold<RepositoryQuery<Map<String, dynamic>>>(query, (out, key) {
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

  SingleQuery<Map<String, dynamic>> _getSingleQueryInner(
      SingleQuery<Map<String, dynamic>> query, Map params) {
    if (params == null || !params.containsKey('query'))
      return null;
    else {
      if (params['query'] is RepositoryQuery<Map<String, dynamic>>)
        return params['query'];
      else if (params['query'] is QueryCallback)
        return params['query'](table);
      else if (params['query'] is! Map || allowQuery != true)
        return query;
      else if (params['query'] is Iterable) {
        var it = params['query'] as Iterable;
        return it
            .map<String>((i) => i.toString())
            .fold<SingleQuery<Map<String, dynamic>>>(
                query, (out, k) => out.value(k));
      } else
        return out;
    }
  }

  _serialize(data) {
    if (data is Map)
      return data;
    else if (data is Iterable)
      return data.map(_serialize).toList();
    else
      return god.serializeObject(data);
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
  Future<List<Map<String, dynamic>>> index([Map params]) {
    var query = buildQuery(repository.all(), params);
    return query.get().toList();
  }

  @override
  Future<Map<String, dynamic>> read(id, [Map params]) =>
      buildSingleQuery(repository.find(id?.toString()), params).get().then((i) {
        if (i == null)
          throw new AngelHttpException.notFound(
              message: 'No record found for ID $id');
        else
          return i;
      });

  @override
  Future<Map<String, dynamic>> create(data, [Map params]) async {
    var creation = await repository.insert(data);

    if (!creation.successful) {
      throw new AngelHttpException(new QueryBuilderException(creation.message),
          message: creation.message, errors: creation.errors);
    } else {
      return creation.insertedItems.first;
    }
  }

  @override
  Future<Map<String, dynamic>> modify(id, data, [Map params]) async {
    var d = _serialize(data);
    var update_ =
        await buildSingleQuery(repository.find(id?.toString()), params)
            .update(d);

    if (!update_.successful) {
      throw new AngelHttpException(new QueryBuilderException(update_.message),
          message: update_.message, errors: update_.errors);
    } else {
      return update_.updatedItems.first;
    }
  }

  @override
  Future<Map<String, dynamic>> update(id, data, [Map params]) =>
      modify(id, data, params);

  @override
  Future<Map<String, dynamic>> remove(id, [Map params]) async {
    if (id == null ||
        id == 'null' &&
            (allowRemoveAll == true ||
                params?.containsKey('provider') != true)) {
      var deletion = await buildQuery(repository.all(), params).delete();

      if (!deletion.successful) {
        throw new AngelHttpException(
            new QueryBuilderException(deletion.message),
            message: deletion.message,
            errors: deletion.errors);
      } else {
        return {
          'deleted_ids': deletion.deletedIds,
          'deleted_items': deletion.deletedItems,
          'number_deleted': deletion.numberDeleted
        };
      }
    } else {
      var deletion =
          await buildSingleQuery(repository.find(id), params).delete();

      if (!deletion.successful) {
        throw new AngelHttpException(
            new QueryBuilderException(deletion.message),
            message: deletion.message,
            errors: deletion.errors);
      } else
        return deletion.deletedItems.first;
    }
  }
}
