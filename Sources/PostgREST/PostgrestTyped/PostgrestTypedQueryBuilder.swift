//
//  PostgrestTypedQueryBuilder.swift
//
//
//  Created by Guilherme Souza on 21/06/24.
//

import Foundation

public class PostgrestTypedQueryBuilder<Model: PostgrestModel>: PostgrestTypedBuilder<Model, Void>, @unchecked Sendable {
  public func select() -> PostgrestTypedFilterBuilder<Model, [Model]> {
    select([], as: Model.self)
  }

  public func select<Response>(
    _ first: KeyPath<Model.Metadata.Attributes, _AnyPropertyMetadata>,
    _ rest: KeyPath<Model.Metadata.Attributes, _AnyPropertyMetadata>...,
    as: Response.Type
  ) -> PostgrestTypedFilterBuilder<Model, [Response]> {
    select([first] + rest, as: Response.self)
  }

  public func select<Response>(
    _ attributes: [KeyPath<Model.Metadata.Attributes, _AnyPropertyMetadata>],
    as _: Response.Type
  ) -> PostgrestTypedFilterBuilder<Model, [Response]> {
    let columns: String = if attributes.isEmpty {
      "*"
    } else {
      attributes.map { Model.Metadata.attributes[keyPath: $0].name }.joined(separator: ",")
    }

    return request.withValue {
      $0.method = .get
      $0.query.appendOrUpdate(URLQueryItem(name: "select", value: columns))

      return PostgrestTypedFilterBuilder(configuration: configuration, request: $0)
    }
  }

  public func insert(
    _ value: Model.Insert
  ) throws -> PostgrestTypedFilterBuilder<Model, Void> {
    try request.withValue {
      $0.method = .post
      $0.body = try Model.Insert.encoder.encode(value)
      return PostgrestTypedFilterBuilder(configuration: configuration, request: $0)
    }
  }

  public func insert(
    _ values: [Model.Insert]
  ) throws -> PostgrestTypedFilterBuilder<Model, Void> {
    try request.withValue {
      $0.method = .post
      $0.body = try Model.Insert.encoder.encode(values)

      var allKeys: Set<String> = []
      for value in values {
        allKeys.formUnion(value._propertiesMetadata.map(\.name))
      }
      let allColumns = allKeys.sorted().joined(separator: ",")
      $0.query.appendOrUpdate(URLQueryItem(name: "columns", value: allColumns))

      return PostgrestTypedFilterBuilder(configuration: configuration, request: $0)
    }
  }
}
