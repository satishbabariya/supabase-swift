//
//  PostgrestTypedTransformBuilder.swift
//
//
//  Created by Guilherme Souza on 21/06/24.
//

import Foundation

/*
  let countries = try await client.from(Country.self)
   .select(
     .name,
     .cities(.name)
   )
   .execute()

  let messages = try await client
   .from(Message.self)
   .select(
     .content,
     .from(.name),
     .to(.name)
   )
   .execute()

 struct Country {
  let name: String

  @Relationship
  let cities: [City]
 }

  struct PartialCountry {
   let name: String

   @Relationship
   let cities: [City]

   struct Columns {
     let name = ColumnDefinition("name")
     let countries = ColumnDefinition("cities")

     func countries(_ first: City.Columns, _ rest: City.Columns...) -> ColumnDefinition {
       ColumnDefinition("cities(\(([first] + rest).joined(separator: ","))")
     }
  }

  let cities = try await client
   .from(Country.self)
   .select()
   .eq(.countries(.name), "Estonia")
   .execute()
  */

public class PostgrestTypedTransformBuilder<Model: PostgrestModel, Response: Sendable>: PostgrestTypedBuilder<Model, Response>, @unchecked Sendable {
  public func select(
    _ first: KeyPath<Model.Metadata.Attributes, _AnyPropertyMetadata>,
    _ rest: KeyPath<Model.Metadata.Attributes, _AnyPropertyMetadata>...
  ) -> PostgrestTypedTransformBuilder<Model, [Model]> {
    select([first] + rest)
  }

  public func select(
    _ attributes: [KeyPath<Model.Metadata.Attributes, _AnyPropertyMetadata>]
  ) -> PostgrestTypedTransformBuilder<Model, [Model]> {
    let columns: String = if attributes.isEmpty {
      "*"
    } else {
      attributes.map { Model.Metadata.attributes[keyPath: $0].name }.joined(separator: ",")
    }

    return request.withValue {
      $0.query.appendOrUpdate(URLQueryItem(name: "select", value: columns))
      if $0.headers["prefer"] != nil {
        $0.headers["prefer", default: ""] += ","
      }

      $0.headers["prefer", default: ""] += "return=representation"

      return PostgrestTypedTransformBuilder<Model, [Model]>(configuration: configuration, request: $0)
    }
  }

  public func order(
    _ column: KeyPath<Model.Metadata.Attributes, _AnyPropertyMetadata>,
    ascending: Bool = true,
    nullsFirst: Bool = false,
    referencedTable: String? = nil
  ) -> PostgrestTypedTransformBuilder<Model, Response> {
    let columnName = Model.Metadata.attributes[keyPath: column].name

    request.withValue {
      let key = referencedTable.map { "\($0).order" } ?? "order"
      let existingOrderIndex = request.query.firstIndex { $0.name == key }
      let value =
        "\(columnName).\(ascending ? "asc" : "desc").\(nullsFirst ? "nullsfirst" : "nullslast")"

      if let existingOrderIndex,
         let currentValue = $0.query[existingOrderIndex].value
      {
        $0.query[existingOrderIndex] = URLQueryItem(
          name: key,
          value: "\(currentValue),\(value)"
        )
      } else {
        $0.query.append(URLQueryItem(name: key, value: value))
      }
    }

    return self
  }

  public func single() -> PostgrestTypedTransformBuilder<Model, Model> where Response == [Model] {
    request.withValue {
      $0.headers["Accept"] = "application/vnd.pgrst.object+json"
      return PostgrestTypedTransformBuilder<Model, Model>(configuration: configuration, request: $0)
    }
  }
}
