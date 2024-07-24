//
//  PostgrestTypedFilterBuilder.swift
//
//
//  Created by Guilherme Souza on 21/06/24.
//

import Foundation

public class PostgrestTypedFilterBuilder<Model: PostgrestModel, Response: Sendable>: PostgrestTypedTransformBuilder<Model, Response>, @unchecked Sendable {
  public func eq<Value: URLQueryRepresentable & Sendable>(
    _ column: KeyPath<Model.Metadata.TypedAttributes, _PropertyMetadata<Model, Value>>,
    _ value: Value
  ) -> PostgrestTypedFilterBuilder<Model, Response> {
    filter(column, "eq", value)
  }

  public func neq<Value: URLQueryRepresentable & Sendable>(
    _ column: KeyPath<Model.Metadata.TypedAttributes, _PropertyMetadata<Model, Value>>,
    _ value: Value
  ) -> PostgrestTypedFilterBuilder<Model, Response> {
    not(column, "eq", value)
  }

  public func not<Value: URLQueryRepresentable & Sendable>(
    _ column: KeyPath<Model.Metadata.TypedAttributes, _PropertyMetadata<Model, Value>>,
    _ op: String,
    _ value: Value
  ) -> PostgrestTypedFilterBuilder<Model, Response> {
    filter(column, "not.\(op)", value)
  }

  public func likeAllOf(
    _ column: KeyPath<Model.Metadata.TypedAttributes, _PropertyMetadata<Model, String>>,
    _ values: [String]
  ) -> PostgrestTypedFilterBuilder<Model, Response> {
    filter(column, "like(all)", "{\(values.joined(separator: ","))}")
  }

  private func filter<Value: URLQueryRepresentable & Sendable>(
    _ column: KeyPath<Model.Metadata.TypedAttributes, _PropertyMetadata<Model, Value>>,
    _ op: String,
    _ value: Value
  ) -> PostgrestTypedFilterBuilder<Model, Response> {
    let name = Model.Metadata.typedAttributes[keyPath: column].name
    request.withValue {
      $0.query.append(
        URLQueryItem(
          name: name,
          value: "\(op).\(value.queryValue)"
        )
      )
    }

    return self
  }
}
