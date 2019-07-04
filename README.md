# ARCHIVED
This project has been archived, in favor of the Angel ORM:
https://github.com/angel-dart/orm

# query_builder
[![version 0.0.1](https://img.shields.io/badge/pub-0.0.1-red.svg)](https://pub.dartlang.org/packages/query_builder)
[![build status](https://travis-ci.org/angel-dart/query_builder.svg)](https://travis-ci.org/angel-dart/query_builder)

Powerful, database-agnostic query builder for Dart applications.

`query_builder` is heavily inspired by 
[Eloquent](https://laravel.com/docs/5.0/eloquent),
and allows you to build fluent queries that run on virtually any database.

# Adapters
* `in_memory` - Good for development/testing purposes
* `mongo`
* `postgres`
* `rethink`

# Uses
`query_builder` can be used in any Dart application, whether client or server. Server-side users will
find it useful because they only need to learn one DSL for any database they use.

The [Angel](https://github.com/angel-dart/angel)
framework already provides
[*services*](https://github.com/angel-dart/angel/wiki/Service-Basics), a powerful abstraction over data stores that provides
CRUD functionality in addition to automatic REST API's, WebSockets and more. `query_builder`
can be easily used with Angel to provide services for data stores that do not have their own
built-in support, such as PostgreSQL or MySQL.
